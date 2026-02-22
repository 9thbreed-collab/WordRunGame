#!/usr/bin/env python3
"""
Calculate Phrase Familiarity Score (PFS) for each phrase.

PFS = log10(bigram_frequency_per_million + 1)

Uses a combination of:
1. Pre-estimated frequency categories (high/medium/low)
2. Zipf frequency of component words
3. Known frequency data for common phrases

Tiered thresholds:
- Levels 1-20:  PFS >= 2.0 (highly familiar)
- Levels 21-50: PFS >= 1.5 (familiar)
- Levels 51+:   PFS >= 1.0 (acceptable)
"""

import csv
import math
from pathlib import Path
from collections import defaultdict

# Paths
DATA_DIR = Path("/Users/nathanielgiddens/WordRunGame/ContentRuleDoc/data/phrases")
INPUT_FILE = DATA_DIR / "phrases_master_ces.csv"
OUTPUT_FILE = DATA_DIR / "phrases_master_pfs.csv"

# Frequency mapping for bigram categories
# These map to approximate per-million frequencies
FREQUENCY_TO_PMM = {
    "high": 100.0,     # ~100 per million -> log10(101) = 2.0
    "medium": 30.0,    # ~30 per million -> log10(31) = 1.5
    "low": 10.0,       # ~10 per million -> log10(11) = 1.04
    "very_low": 1.0,   # ~1 per million -> log10(2) = 0.3
}

# Known high-frequency phrases (verified common usage)
HIGH_FREQUENCY_PHRASES = {
    # Food/drink - extremely common
    "hot dog", "ice cream", "french fries", "peanut butter", "orange juice",
    "apple pie", "chocolate chip", "birthday cake", "ice cube", "coffee cup",
    "water bottle", "pizza box", "lunch box", "dinner time", "breakfast time",
    "candy bar", "potato chip", "milk shake", "tea bag", "tea cup",

    # Transport - everyday phrases
    "fire truck", "school bus", "bus stop", "stop sign", "car seat",
    "car wash", "seat belt", "air plane", "air port", "train station",
    "gas station", "traffic light", "parking lot", "race car", "road trip",

    # Household - very familiar
    "front door", "back door", "bed room", "bath room", "living room",
    "dining room", "bath tub", "door bell", "door mat", "alarm clock",
    "book shelf", "night stand", "coffee table", "dish washer", "washing machine",

    # Games/activities
    "card game", "board game", "ball game", "video game", "game day",
    "play ground", "play time", "fun time", "day trip", "road trip",

    # School/work
    "high school", "school yard", "class room", "lunch room", "home work",
    "work day", "desk top", "lap top", "note book", "text book",

    # Nature/outdoor
    "rain coat", "sun shine", "day light", "moon light", "star light",
    "tree house", "bird house", "dog house", "cat food", "dog food",

    # Social/communication
    "phone call", "text message", "email address", "post card", "thank you",
    "good morning", "good night", "good luck", "happy birthday",

    # Commerce
    "credit card", "gift card", "price tag", "shopping cart", "check out",
    "cash register", "bank account",
}

# Known obscure/archaic phrases to flag
LOW_FREQUENCY_PHRASES = {
    "pack horse", "tone arm", "game bird", "bird lime", "draft horse",
    "seed drill", "milk wagon", "coal scuttle", "ink well", "blotting paper",
    "horse blanket", "horse collar", "draft animal", "gun carriage",
    "powder horn", "flint lock", "match lock", "wheel lock",
}

# Zipf score contribution
# Higher zipf = more common word = more familiar phrase
def zipf_contribution(avg_zipf):
    """Convert avg_zipf to familiarity boost."""
    if avg_zipf >= 6.0:
        return 0.5  # Very common words
    elif avg_zipf >= 5.5:
        return 0.3
    elif avg_zipf >= 5.0:
        return 0.1
    else:
        return 0.0


def calculate_pfs(phrase, bigram_freq, avg_zipf, concreteness):
    """
    Calculate PFS for a phrase.

    PFS = log10(estimated_frequency_per_million + 1)
    """
    phrase_lower = phrase.lower().strip()

    # Check known lists first
    if phrase_lower in HIGH_FREQUENCY_PHRASES:
        base_pmm = 150.0  # Boost for known high-frequency
    elif phrase_lower in LOW_FREQUENCY_PHRASES:
        base_pmm = 3.0    # Penalty for known obscure
    else:
        # Use frequency category
        freq_key = bigram_freq.lower() if isinstance(bigram_freq, str) else "medium"
        base_pmm = FREQUENCY_TO_PMM.get(freq_key, 30.0)

    # Apply zipf contribution
    try:
        zipf_val = float(avg_zipf)
    except (ValueError, TypeError):
        zipf_val = 5.5

    zipf_boost = zipf_contribution(zipf_val) * 20  # Scale to pmm

    # Apply concreteness contribution (concrete phrases are more familiar)
    try:
        concrete_val = float(concreteness)
    except (ValueError, TypeError):
        concrete_val = 0.7

    concrete_boost = concrete_val * 10  # Concrete phrases get boost

    # Calculate total estimated PMM
    total_pmm = base_pmm + zipf_boost + concrete_boost

    # Calculate PFS
    pfs = math.log10(total_pmm + 1)

    return round(pfs, 2)


def get_level_tier(pfs):
    """Determine which level tier a phrase qualifies for."""
    if pfs >= 2.0:
        return "early (1-20)"
    elif pfs >= 1.5:
        return "mid (21-50)"
    elif pfs >= 1.0:
        return "late (51+)"
    else:
        return "reject"


def process_phrases():
    """Process all phrases and calculate PFS."""
    # Read input file
    phrases = []
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            phrases.append(row)

    print(f"Loaded {len(phrases)} phrases")

    # Calculate PFS for each phrase
    tier_counts = defaultdict(int)
    pfs_distribution = defaultdict(int)

    for p in phrases:
        pfs = calculate_pfs(
            p["phrase"],
            p.get("bigram_frequency", "medium"),
            p.get("avg_zipf", 5.5),
            p.get("concreteness_score", 0.7)
        )
        p["PFS"] = pfs

        tier = get_level_tier(pfs)
        p["level_tier"] = tier
        tier_counts[tier] += 1

        # Round to 0.1 for distribution
        pfs_bucket = round(pfs * 10) / 10
        pfs_distribution[pfs_bucket] += 1

    # Write output
    fieldnames = list(phrases[0].keys())
    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for p in phrases:
            writer.writerow(p)

    print(f"\nWrote {len(phrases)} phrases to {OUTPUT_FILE}")

    # Print tier distribution
    print("\nLevel Tier Distribution:")
    for tier, count in sorted(tier_counts.items()):
        pct = count / len(phrases) * 100
        print(f"  {tier}: {count:4d} ({pct:5.1f}%)")

    # Print PFS histogram
    print("\nPFS Distribution:")
    for pfs_val in sorted(pfs_distribution.keys()):
        count = pfs_distribution[pfs_val]
        bar = "#" * (count // 20)
        print(f"  {pfs_val:.1f}: {count:4d} {bar}")

    # Show sample phrases by tier
    early_phrases = [p for p in phrases if p["level_tier"] == "early (1-20)"]
    mid_phrases = [p for p in phrases if p["level_tier"] == "mid (21-50)"]
    late_phrases = [p for p in phrases if p["level_tier"] == "late (51+)"]
    reject_phrases = [p for p in phrases if p["level_tier"] == "reject"]

    print(f"\nSample EARLY phrases (PFS >= 2.0): {len(early_phrases)} total")
    for p in early_phrases[:10]:
        print(f"  {p['phrase']}: PFS={p['PFS']}")

    print(f"\nSample MID phrases (PFS 1.5-2.0): {len(mid_phrases)} total")
    for p in mid_phrases[:10]:
        print(f"  {p['phrase']}: PFS={p['PFS']}")

    print(f"\nSample LATE phrases (PFS 1.0-1.5): {len(late_phrases)} total")
    for p in late_phrases[:10]:
        print(f"  {p['phrase']}: PFS={p['PFS']}")

    if reject_phrases:
        print(f"\nREJECTED phrases (PFS < 1.0): {len(reject_phrases)} total")
        for p in reject_phrases[:10]:
            print(f"  {p['phrase']}: PFS={p['PFS']}")

    return phrases


if __name__ == "__main__":
    process_phrases()
