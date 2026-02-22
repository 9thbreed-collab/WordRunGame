#!/usr/bin/env python3
"""
Merge and deduplicate all phrase CSV files into a unified master file.
"""

import csv
import os
from pathlib import Path
from collections import defaultdict

# Paths
DATA_DIR = Path("/Users/nathanielgiddens/WordRunGame/ContentRuleDoc/data/phrases")
OUTPUT_FILE = DATA_DIR / "phrases_master.csv"

# Unified schema for output
UNIFIED_SCHEMA = [
    "phrase", "word1", "word2", "bigram_frequency", "avg_zipf", "PFS",
    "CES_estimate", "concreteness_score", "abstraction_level", "tone_tag",
    "category_tag", "difficulty_score", "entropy", "familiarity"
]

def normalize_bigram_frequency(value):
    """Convert various frequency formats to standardized values."""
    if isinstance(value, str):
        value = value.lower().strip()
        if value in ["high", "h"]:
            return "high"
        elif value in ["medium", "med", "m"]:
            return "medium"
        elif value in ["low", "l"]:
            return "low"
    return "medium"  # default

def normalize_abstraction_level(value):
    """Normalize abstraction level values."""
    if isinstance(value, str):
        value = value.lower().strip()
        if value in ["concrete", "c"]:
            return "concrete"
        elif value in ["abstract", "a"]:
            return "abstract"
        elif value in ["semi-abstract", "semi"]:
            return "semi-abstract"
    return "concrete"  # default

def convert_pfs_from_frequency(freq):
    """Convert bigram_frequency to numeric PFS estimate."""
    freq_map = {"high": 2.5, "medium": 2.0, "low": 1.5}
    return freq_map.get(freq, 2.0)

def convert_concreteness(value, abstraction_level):
    """Convert concreteness score, using abstraction level as fallback."""
    if value and value not in ["", "None", "null"]:
        try:
            return float(value)
        except (ValueError, TypeError):
            pass
    # Infer from abstraction level
    if abstraction_level == "concrete":
        return 1.0
    elif abstraction_level == "abstract":
        return 0.5
    return 0.7  # default for semi-abstract

def read_batch_file(filepath):
    """Read a batch CSV file and normalize to unified schema."""
    phrases = []
    with open(filepath, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            phrase = row.get("phrase", "").strip()
            if not phrase:
                continue

            # Handle different column name variations
            word1 = row.get("word1", phrase.split()[0] if " " in phrase else "")
            word2 = row.get("word2", phrase.split()[1] if " " in phrase and len(phrase.split()) > 1 else "")

            bigram_freq = normalize_bigram_frequency(row.get("bigram_frequency", "medium"))
            abstraction = normalize_abstraction_level(row.get("abstraction_level", "concrete"))

            # Extract or compute scores
            pfs = row.get("PFS", "")
            if not pfs or pfs in ["", "None"]:
                pfs = convert_pfs_from_frequency(bigram_freq)
            else:
                try:
                    pfs = float(pfs)
                except ValueError:
                    pfs = convert_pfs_from_frequency(bigram_freq)

            ces = row.get("CES_estimate", "1")
            try:
                ces = int(float(ces)) if ces else 1
            except ValueError:
                ces = 1

            concreteness = convert_concreteness(
                row.get("concreteness_score", ""),
                abstraction
            )

            normalized = {
                "phrase": phrase,
                "word1": word1.strip(),
                "word2": word2.strip(),
                "bigram_frequency": bigram_freq,
                "avg_zipf": float(row.get("avg_zipf", 5.5)),
                "PFS": pfs,
                "CES_estimate": ces,
                "concreteness_score": concreteness,
                "abstraction_level": abstraction,
                "tone_tag": row.get("tone_tag", row.get("tone_score", "neutral")),
                "category_tag": row.get("category_tag", row.get("categories", "general")),
                "difficulty_score": float(row.get("difficulty_score", 20.0)),
                "entropy": int(float(row.get("entropy", 1))),
                "familiarity": int(float(row.get("familiarity", 4)))
            }
            phrases.append(normalized)
    return phrases

def read_scored_file(filepath):
    """Read the original phrases_scored.csv with its different schema."""
    phrases = []
    with open(filepath, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            phrase = row.get("phrase", "").strip()
            if not phrase:
                continue

            # Map tone_score to frequency estimate
            tone_score = int(row.get("tone_score", 5))
            if tone_score >= 20:
                bigram_freq = "medium"
            elif tone_score >= 10:
                bigram_freq = "medium"
            else:
                bigram_freq = "high"

            # Map categories to tone_tag
            categories = row.get("categories", "")
            if "food" in categories.lower():
                tone_tag = "neutral"
            elif "transport" in categories.lower():
                tone_tag = "neutral"
            else:
                tone_tag = "neutral"

            entropy = int(float(row.get("entropy", 1)))
            familiarity = int(float(row.get("familiarity", 4)))

            # Compute PFS from familiarity and zipf
            avg_zipf = float(row.get("avg_zipf", 5.5))
            pfs = avg_zipf + (familiarity - 3) * 0.2  # Simple formula

            normalized = {
                "phrase": phrase,
                "word1": row.get("word1", "").strip(),
                "word2": row.get("word2", "").strip(),
                "bigram_frequency": bigram_freq,
                "avg_zipf": avg_zipf,
                "PFS": pfs,
                "CES_estimate": entropy,  # Use entropy as CES proxy
                "concreteness_score": 1.0 if entropy == 1 else 0.7,
                "abstraction_level": "concrete",
                "tone_tag": tone_tag,
                "category_tag": categories,
                "difficulty_score": float(row.get("difficulty_score", 20.0)),
                "entropy": entropy,
                "familiarity": familiarity
            }
            phrases.append(normalized)
    return phrases

def merge_and_deduplicate():
    """Main function to merge all files and remove duplicates."""
    all_phrases = []
    file_counts = {}

    # Read batch files (batch1-6)
    batch_files = [
        "batch1_household_everyday.csv",
        "batch2_food_drink.csv",
        "batch3_transport_outdoor.csv",
        "batch4_school_social.csv",
        "batch5_commerce_work.csv",
        "batch6_abstraction.csv"
    ]

    for batch_file in batch_files:
        filepath = DATA_DIR / batch_file
        if filepath.exists():
            phrases = read_batch_file(filepath)
            file_counts[batch_file] = len(phrases)
            all_phrases.extend(phrases)
            print(f"Read {len(phrases)} phrases from {batch_file}")

    # Read original scored file
    scored_file = DATA_DIR / "phrases_scored.csv"
    if scored_file.exists():
        phrases = read_scored_file(scored_file)
        file_counts["phrases_scored.csv"] = len(phrases)
        all_phrases.extend(phrases)
        print(f"Read {len(phrases)} phrases from phrases_scored.csv")

    # Deduplicate by phrase (keep first occurrence, which has better data)
    seen = set()
    unique_phrases = []
    duplicates = []

    for p in all_phrases:
        phrase_key = p["phrase"].lower().strip()
        if phrase_key not in seen:
            seen.add(phrase_key)
            unique_phrases.append(p)
        else:
            duplicates.append(p["phrase"])

    # Sort by phrase for consistency
    unique_phrases.sort(key=lambda x: x["phrase"].lower())

    # Write output
    with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=UNIFIED_SCHEMA)
        writer.writeheader()
        for p in unique_phrases:
            writer.writerow(p)

    # Print summary
    print("\n" + "="*60)
    print("MERGE SUMMARY")
    print("="*60)
    print(f"Total phrases read: {len(all_phrases)}")
    print(f"Unique phrases: {len(unique_phrases)}")
    print(f"Duplicates removed: {len(duplicates)}")
    print(f"\nFile breakdown:")
    for fname, count in file_counts.items():
        print(f"  {fname}: {count}")
    print(f"\nOutput written to: {OUTPUT_FILE}")

    if duplicates:
        print(f"\nFirst 20 duplicates removed:")
        for d in duplicates[:20]:
            print(f"  - {d}")

    return unique_phrases, duplicates

if __name__ == "__main__":
    merge_and_deduplicate()
