#!/usr/bin/env python3
"""
Spoken Corpus Phrase Frequency Score (PFS) Generator

Per Stabilization Directive: Phrase Frequency Correction (Spoken Corpus)

Uses Google Ngrams (filtered for recent decades) as primary accessible source
for bigram frequency data in American English.

PFS Normalization:
- Top 10%    → PFS = 5
- 70–90%    → PFS = 4
- 40–70%    → PFS = 3
- 20–40%    → PFS = 2
- Below 20% → PFS = 1

Tier Enforcement:
- Tier 1 → require PFS >= 4
- Tier 2 → require PFS >= 3
- Tier 3+ → no PFS restriction
"""

import csv
import json
import re
import time
import urllib.request
import urllib.parse
from pathlib import Path
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple
import statistics

# Paths
DATA_DIR = Path("/Users/nathanielgiddens/WordRunGame/ContentRuleDoc/data")
PHRASES_DIR = DATA_DIR / "phrases"
INPUT_FILE = PHRASES_DIR / "phrases_master_pfs.csv"
OUTPUT_FILE = PHRASES_DIR / "phrases_spoken_pfs.csv"
CACHE_FILE = PHRASES_DIR / "ngram_cache.json"
AUDIT_FILE = DATA_DIR / "tier1_frequency_audit.md"


@dataclass
class PhraseFrequency:
    """Frequency data for a phrase."""
    phrase: str
    word1: str
    word2: str
    spoken_count: int  # Raw frequency count
    percentile: float  # Percentile rank (0-100)
    pfs: int          # Normalized PFS (1-5)
    source: str       # Data source used


def query_google_ngrams(phrase: str, start_year: int = 2000, end_year: int = 2019) -> Optional[int]:
    """
    Query Google Ngrams for bigram frequency.

    Uses curl to bypass SSL issues, then parses JSON response.
    Returns average frequency count across the year range.
    """
    import subprocess

    # Clean phrase for query
    clean_phrase = phrase.lower().strip()

    # Build URL
    base_url = "https://books.google.com/ngrams/json"
    params = {
        "content": clean_phrase,
        "year_start": start_year,
        "year_end": end_year,
        "corpus": "en-US-2019",  # American English
        "smoothing": 0,
    }
    url = f"{base_url}?{urllib.parse.urlencode(params)}"

    try:
        # Use curl with insecure flag to bypass SSL issues
        result = subprocess.run(
            ["curl", "-s", "-k", url],
            capture_output=True,
            text=True,
            timeout=15
        )

        if result.returncode != 0:
            return None

        data = json.loads(result.stdout)

        if data and len(data) > 0 and "timeseries" in data[0]:
            # Get average frequency (these are normalized values, not raw counts)
            timeseries = data[0]["timeseries"]
            if timeseries:
                # Google returns frequency as fraction of total words
                # Multiply by approximate corpus size to get pseudo-count
                avg_freq = statistics.mean(timeseries)
                # Corpus is ~500 billion words; scale to reasonable count
                pseudo_count = int(avg_freq * 1_000_000_000)
                return pseudo_count
        return 0
    except Exception as e:
        print(f"  Error querying '{phrase}': {e}")
        return None


def load_cache() -> Dict[str, int]:
    """Load cached frequency data."""
    if CACHE_FILE.exists():
        with open(CACHE_FILE, "r") as f:
            return json.load(f)
    return {}


def save_cache(cache: Dict[str, int]):
    """Save frequency cache."""
    with open(CACHE_FILE, "w") as f:
        json.dump(cache, f, indent=2)


def calculate_percentile(value: int, all_values: List[int]) -> float:
    """Calculate percentile rank of a value within a distribution."""
    if not all_values:
        return 50.0
    sorted_values = sorted(all_values)
    rank = sum(1 for v in sorted_values if v < value)
    return (rank / len(sorted_values)) * 100


def percentile_to_pfs(percentile: float) -> int:
    """
    Convert percentile to PFS score.

    Per Stabilization Directive:
    - Top 10%    → PFS = 5
    - 70–90%    → PFS = 4
    - 40–70%    → PFS = 3
    - 20–40%    → PFS = 2
    - Below 20% → PFS = 1
    """
    if percentile >= 90:
        return 5
    elif percentile >= 70:
        return 4
    elif percentile >= 40:
        return 3
    elif percentile >= 20:
        return 2
    else:
        return 1


def load_phrases() -> List[dict]:
    """Load all phrases from master CSV."""
    phrases = []
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            phrases.append(row)
    return phrases


def get_tier1_phrases(phrases: List[dict]) -> List[dict]:
    """Filter to Tier 1 phrases only."""
    tier1 = []
    for p in phrases:
        level_tier = p.get("level_tier", "").lower()
        if "early" in level_tier or "1-20" in level_tier:
            tier1.append(p)
    return tier1


def query_frequencies_batch(phrases: List[dict], cache: Dict[str, int], limit: int = None) -> Dict[str, int]:
    """
    Query frequencies for a batch of phrases.

    Uses cache to avoid redundant queries.
    """
    frequencies = {}
    queries_made = 0

    phrase_list = phrases[:limit] if limit else phrases

    for i, p in enumerate(phrase_list):
        phrase = p["phrase"].lower().strip()

        if phrase in cache:
            frequencies[phrase] = cache[phrase]
            continue

        print(f"  [{i+1}/{len(phrase_list)}] Querying: {phrase}")

        freq = query_google_ngrams(phrase)
        if freq is not None:
            frequencies[phrase] = freq
            cache[phrase] = freq
        else:
            # Mark as queried but failed
            frequencies[phrase] = 0
            cache[phrase] = 0

        queries_made += 1

        # Rate limiting
        if queries_made % 10 == 0:
            save_cache(cache)
            time.sleep(1)  # Be respectful to the API

    return frequencies


def generate_audit_table(
    phrases: List[dict],
    frequencies: Dict[str, int],
    output_path: Path
):
    """Generate markdown audit table for Tier 1 phrases."""

    # Calculate all percentiles
    all_counts = [frequencies.get(p["phrase"].lower(), 0) for p in phrases]

    # Build results
    results = []
    for p in phrases:
        phrase = p["phrase"].lower()
        count = frequencies.get(phrase, 0)
        percentile = calculate_percentile(count, all_counts)
        pfs = percentile_to_pfs(percentile)

        results.append({
            "phrase": p["phrase"],
            "spoken_corpus_count": count,
            "percentile": round(percentile, 1),
            "pfs": pfs,
            "tier": "1" if pfs >= 4 else "FAIL",
            "category": p.get("category_tag", ""),
        })

    # Sort by PFS descending, then by count
    results.sort(key=lambda x: (-x["pfs"], -x["spoken_corpus_count"]))

    # Generate markdown
    lines = [
        "# Tier 1 Phrase Frequency Audit",
        "",
        "**Source**: Google Ngrams (American English, 2000-2019)",
        "",
        "## PFS Distribution",
        "",
        f"- **Total Phrases**: {len(results)}",
        f"- **PFS >= 4 (PASS)**: {sum(1 for r in results if r['pfs'] >= 4)}",
        f"- **PFS < 4 (FAIL)**: {sum(1 for r in results if r['pfs'] < 4)}",
        "",
        "## Normalization Table Applied",
        "",
        "| Percentile | PFS |",
        "|------------|-----|",
        "| Top 10% (90-100) | 5 |",
        "| 70-90% | 4 |",
        "| 40-70% | 3 |",
        "| 20-40% | 2 |",
        "| Below 20% | 1 |",
        "",
        "## Frequency Audit Table",
        "",
        "| phrase | spoken_corpus_count | percentile | PFS | tier |",
        "|--------|---------------------|------------|-----|------|",
    ]

    for r in results:
        tier_display = r["tier"] if r["tier"] == "1" else f"**{r['tier']}**"
        lines.append(
            f"| {r['phrase']} | {r['spoken_corpus_count']:,} | {r['percentile']}% | {r['pfs']} | {tier_display} |"
        )

    lines.extend([
        "",
        "---",
        "",
        "**Legend**:",
        "- Tier 1 requires PFS >= 4",
        "- Phrases marked **FAIL** do not meet Tier 1 threshold",
    ])

    with open(output_path, "w") as f:
        f.write("\n".join(lines))

    print(f"\nAudit table saved to: {output_path}")
    return results


def update_phrases_csv(phrases: List[dict], frequencies: Dict[str, int]):
    """Update phrases CSV with new spoken PFS values."""

    all_counts = [frequencies.get(p["phrase"].lower(), 0) for p in phrases]

    # Add new columns
    updated_rows = []
    for p in phrases:
        phrase = p["phrase"].lower()
        count = frequencies.get(phrase, 0)
        percentile = calculate_percentile(count, all_counts)
        pfs = percentile_to_pfs(percentile)

        row = dict(p)
        row["spoken_count"] = count
        row["spoken_percentile"] = round(percentile, 1)
        row["spoken_pfs"] = pfs
        updated_rows.append(row)

    # Write output
    if updated_rows:
        fieldnames = list(updated_rows[0].keys())
        with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(updated_rows)

        print(f"Updated phrases saved to: {OUTPUT_FILE}")


def main():
    """Main entry point."""
    print("=" * 60)
    print("SPOKEN CORPUS PFS GENERATOR")
    print("=" * 60)

    # Load phrases
    print("\nLoading phrases...")
    all_phrases = load_phrases()
    print(f"Total phrases: {len(all_phrases)}")

    # Get Tier 1 candidates
    tier1_phrases = get_tier1_phrases(all_phrases)
    print(f"Tier 1 candidates: {len(tier1_phrases)}")

    # If no explicit tier marking, use familiarity/entropy as proxy
    if len(tier1_phrases) < 50:
        print("Few explicit Tier 1 phrases found. Using filter criteria...")
        tier1_phrases = [
            p for p in all_phrases
            if float(p.get("avg_zipf", 0)) >= 5.5
            and int(float(p.get("CES_estimate", p.get("entropy", 99)))) <= 2
        ]
        print(f"Filtered Tier 1 candidates: {len(tier1_phrases)}")

    # Load cache
    cache = load_cache()
    print(f"Cached frequencies: {len(cache)}")

    # Query frequencies (limit for initial run)
    print("\nQuerying Google Ngrams...")
    frequencies = query_frequencies_batch(tier1_phrases, cache, limit=100)

    # Save cache
    save_cache(cache)

    # Generate audit table
    print("\nGenerating audit table...")
    results = generate_audit_table(tier1_phrases[:100], frequencies, AUDIT_FILE)

    # Summary
    passing = sum(1 for r in results if r["pfs"] >= 4)
    print(f"\n{'=' * 60}")
    print(f"SUMMARY: {passing}/{len(results)} phrases pass Tier 1 (PFS >= 4)")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
