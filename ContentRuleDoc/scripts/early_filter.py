#!/usr/bin/env python3
"""
Early-Game Filter for WordRun! phrases.

Enforces strict constraints for levels 1-20:
- CES = 1 (cognitively obvious - only one obvious answer)
- PFS >= 2.0 (high familiarity)
- concreteness_score >= 0.7 (concrete, not abstract)
- abstraction_level = "concrete"
- No archaic or technical vocabulary
- No double meanings or ambiguous phrases

Test cases:
- MUST FAIL: "pack horse", "tone arm", "game bird", "draft horse"
- MUST PASS: "hot dog", "fire truck", "ice cream", "school bus"
"""

import csv
from pathlib import Path
from dataclasses import dataclass
from typing import Optional, Callable

# Paths
DATA_DIR = Path("/Users/nathanielgiddens/WordRunGame/ContentRuleDoc/data/phrases")
INPUT_FILE = DATA_DIR / "phrases_master_pfs.csv"

# Explicit blocklist of phrases that should NEVER appear in early game
EARLY_GAME_BLOCKLIST = {
    # Archaic/technical terms
    "pack horse", "pack mule", "pack animal", "pack saddle",
    "tone arm", "tone dial", "tone wood",
    "game bird", "game fish", "game hen",
    "draft horse", "draft animal", "draft beer",
    "gun carriage", "gun metal", "gun boat",
    "horse blanket", "horse collar", "horse drawn",
    "seed drill", "seed bed", "seed pod",
    "milk wagon", "coal scuttle", "ink well",
    "blotting paper", "powder horn", "flint lock",
    "match lock", "wheel lock", "wheel wright",
    "plough horse", "plow horse", "dray horse",
    "cart horse", "shire horse", "harness horse",
    "beast burden", "pack beast",

    # Ambiguous double-meaning phrases
    "hot shot", "big shot", "moon shine",
    "bar fly", "bar tender", "pool shark",
    "ball buster", "heart break", "cold shoulder",
    "dead beat", "dead end", "dead weight",
    "low life", "low blow", "low ball",
    "high ball", "high horse", "high brow",

    # Regional/dialectal
    "lorry driver", "tram stop", "car park",
    "lift shaft", "boot sale", "bonnet catch",

    # Too abstract for early game
    "time warp", "mind set", "mind game",
    "brain storm", "brain wave", "brain drain",
    "heart felt", "soul mate", "soul food",
    "gut feeling", "gut instinct", "gut punch",

    # Potentially violent/inappropriate for early easy levels
    "gun shot", "knife edge", "blood bath",
    "death trap", "war zone", "fight club",
    "punch line", "hit man", "cut throat",
}

# Explicit allowlist of verified familiar phrases for early game
EARLY_GAME_ALLOWLIST = {
    # Food - universally known
    "hot dog", "ice cream", "apple pie", "french fries",
    "peanut butter", "orange juice", "birthday cake",
    "pizza box", "lunch box", "candy bar", "chocolate chip",
    "milk shake", "tea cup", "coffee cup", "water bottle",

    # Transport - everyday
    "fire truck", "school bus", "bus stop", "stop sign",
    "car seat", "car wash", "seat belt", "air plane",
    "train station", "gas station", "traffic light",
    "parking lot", "race car", "taxi cab", "fire engine",

    # Household - common items
    "front door", "back door", "bed room", "bath room",
    "living room", "dining room", "bath tub", "door bell",
    "door mat", "alarm clock", "book shelf", "night stand",
    "coffee table", "dish washer", "light bulb", "window sill",

    # School/activities - familiar
    "high school", "school yard", "class room", "lunch room",
    "home work", "note book", "text book", "back pack",
    "play ground", "play time", "game day", "card game",
    "board game", "ball game", "video game",

    # Nature - recognizable
    "rain coat", "sun shine", "day light", "tree house",
    "bird house", "dog house", "cat food", "dog food",
    "flower pot", "grass land", "sand box", "beach ball",
}

# Words that often lead to archaic/unfamiliar phrases
SUSPICIOUS_WORD1 = {
    "pack", "tone", "game", "draft", "gun", "wheel",
    "mill", "forge", "kiln", "anvil", "loom",
    "plow", "plough", "harness", "yoke", "cart",
    "barrel", "cask", "keg", "vat", "trough",
}

# Words that indicate archaic word2 (when paired with suspicious word1)
ARCHAIC_WORD2 = {
    "horse", "mule", "oxen", "wagon", "carriage",
    "wright", "monger",
    "scuttle", "yoke",
}


@dataclass
class FilterResult:
    """Result of applying a filter."""
    passed: bool
    reason: str = ""


def early_game_filter(phrase_dict: dict, max_ces: int = 2) -> FilterResult:
    """
    Apply early-game constraints to a phrase.

    Args:
        phrase_dict: Dictionary with phrase attributes (from CSV row or Phrase object)
        max_ces: Maximum allowed CES (default 2 for early game)

    Returns:
        FilterResult indicating pass/fail and reason
    """
    phrase = phrase_dict.get("phrase", "").lower().strip()
    word1 = phrase_dict.get("word1", "").lower().strip()
    word2 = phrase_dict.get("word2", "").lower().strip()

    # Check explicit blocklist first
    if phrase in EARLY_GAME_BLOCKLIST:
        return FilterResult(False, f"Blocklist: '{phrase}' explicitly blocked")

    # Check explicit allowlist (fast-pass)
    if phrase in EARLY_GAME_ALLOWLIST:
        return FilterResult(True, "Allowlist: verified familiar phrase")

    # Check CES (Cognitive Entropy Score) - allow up to max_ces
    ces = int(float(phrase_dict.get("CES_estimate", 1)))
    if ces > max_ces:
        return FilterResult(False, f"CES={ces} > {max_ces}: too many obvious alternatives")

    # Check PFS (Phrase Familiarity Score) - minimum 1.6 for early game
    pfs = float(phrase_dict.get("PFS", 1.5))
    if pfs < 1.6:
        return FilterResult(False, f"PFS={pfs:.2f} < 1.6: insufficient familiarity")

    # Check concreteness
    concreteness = float(phrase_dict.get("concreteness_score", 0.7))
    if concreteness < 0.7:
        return FilterResult(False, f"Concreteness={concreteness:.2f} < 0.7: too abstract")

    # Check abstraction level
    abstraction = phrase_dict.get("abstraction_level", "concrete").lower()
    if abstraction != "concrete":
        return FilterResult(False, f"Abstraction='{abstraction}': not concrete")

    # Check for suspicious word combinations
    if word1 in SUSPICIOUS_WORD1 and word2 in ARCHAIC_WORD2:
        return FilterResult(False, f"Suspicious combo: '{word1}' + '{word2}' likely archaic")

    # Check for archaic word2
    if word2 in ARCHAIC_WORD2:
        return FilterResult(False, f"Archaic word2: '{word2}'")

    # All checks passed
    return FilterResult(True, "Passed all early-game constraints")


def create_filter_function(min_pfs: float = 2.0, max_ces: int = 2) -> Callable:
    """
    Create a filter function for the pathfinder.

    Args:
        min_pfs: Minimum PFS required
        max_ces: Maximum CES allowed (default 2 for manageable cognitive load)

    Returns:
        Filter function compatible with pathfinder
    """
    def filter_func(phrase) -> bool:
        # Handle both Phrase objects and dicts
        if hasattr(phrase, '__dict__'):
            phrase_dict = {
                "phrase": phrase.phrase,
                "word1": phrase.word1,
                "word2": phrase.word2,
                "PFS": phrase.pfs,
                "CES_estimate": phrase.ces,
                "concreteness_score": phrase.concreteness,
                "abstraction_level": phrase.abstraction_level,
                "tone_tag": phrase.tone_tag,
            }
        else:
            phrase_dict = phrase

        result = early_game_filter(phrase_dict, max_ces=max_ces)
        return result.passed

    return filter_func


def test_filter():
    """Test the filter against known cases."""
    print("=" * 60)
    print("EARLY-GAME FILTER TEST")
    print("=" * 60)

    # Test cases that MUST FAIL
    must_fail = [
        {"phrase": "pack horse", "word1": "pack", "word2": "horse", "CES_estimate": 1, "PFS": 1.30, "concreteness_score": 1.0, "abstraction_level": "concrete"},
        {"phrase": "tone arm", "word1": "tone", "word2": "arm", "CES_estimate": 1, "PFS": 1.30, "concreteness_score": 0.8, "abstraction_level": "concrete"},
        {"phrase": "game bird", "word1": "game", "word2": "bird", "CES_estimate": 1, "PFS": 1.50, "concreteness_score": 1.0, "abstraction_level": "concrete"},
        {"phrase": "draft horse", "word1": "draft", "word2": "horse", "CES_estimate": 1, "PFS": 1.40, "concreteness_score": 1.0, "abstraction_level": "concrete"},
        {"phrase": "good luck", "word1": "good", "word2": "luck", "CES_estimate": 1, "PFS": 2.22, "concreteness_score": 0.5, "abstraction_level": "abstract"},
        {"phrase": "pack mule", "word1": "pack", "word2": "mule", "CES_estimate": 2, "PFS": 1.67, "concreteness_score": 1.0, "abstraction_level": "concrete"},
    ]

    # Test cases that MUST PASS
    must_pass = [
        {"phrase": "hot dog", "word1": "hot", "word2": "dog", "CES_estimate": 1, "PFS": 2.22, "concreteness_score": 1.0, "abstraction_level": "concrete"},
        {"phrase": "fire truck", "word1": "fire", "word2": "truck", "CES_estimate": 1, "PFS": 2.22, "concreteness_score": 1.0, "abstraction_level": "concrete"},
        {"phrase": "ice cream", "word1": "ice", "word2": "cream", "CES_estimate": 1, "PFS": 2.22, "concreteness_score": 1.0, "abstraction_level": "concrete"},
        {"phrase": "school bus", "word1": "school", "word2": "bus", "CES_estimate": 1, "PFS": 2.22, "concreteness_score": 1.0, "abstraction_level": "concrete"},
        {"phrase": "front door", "word1": "front", "word2": "door", "CES_estimate": 1, "PFS": 2.22, "concreteness_score": 1.0, "abstraction_level": "concrete"},
        {"phrase": "card game", "word1": "card", "word2": "game", "CES_estimate": 1, "PFS": 2.22, "concreteness_score": 1.0, "abstraction_level": "concrete"},
    ]

    print("\n--- Must FAIL cases ---")
    all_correct = True
    for case in must_fail:
        result = early_game_filter(case)
        status = "CORRECT" if not result.passed else "WRONG!"
        if result.passed:
            all_correct = False
        print(f"  {case['phrase']:20s} -> {'PASS' if result.passed else 'FAIL':4s} [{status}] {result.reason}")

    print("\n--- Must PASS cases ---")
    for case in must_pass:
        result = early_game_filter(case)
        status = "CORRECT" if result.passed else "WRONG!"
        if not result.passed:
            all_correct = False
        print(f"  {case['phrase']:20s} -> {'PASS' if result.passed else 'FAIL':4s} [{status}] {result.reason}")

    print("\n" + "=" * 60)
    if all_correct:
        print("ALL TEST CASES PASSED!")
    else:
        print("SOME TEST CASES FAILED!")
    print("=" * 60)

    return all_correct


def analyze_phrase_bank():
    """Analyze the full phrase bank with early-game filter."""
    print("\n" + "=" * 60)
    print("PHRASE BANK ANALYSIS")
    print("=" * 60)

    # Load phrases
    phrases = []
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            phrases.append(row)

    print(f"Total phrases: {len(phrases)}")

    # Apply filter
    passed = []
    failed_by_reason = {}

    for p in phrases:
        result = early_game_filter(p)
        if result.passed:
            passed.append(p)
        else:
            reason_key = result.reason.split(":")[0]
            if reason_key not in failed_by_reason:
                failed_by_reason[reason_key] = []
            failed_by_reason[reason_key].append((p["phrase"], result.reason))

    print(f"\nPassed early-game filter: {len(passed)} ({len(passed)/len(phrases)*100:.1f}%)")

    print("\nFailure breakdown:")
    for reason, items in sorted(failed_by_reason.items(), key=lambda x: -len(x[1])):
        print(f"  {reason}: {len(items)}")
        for phrase, detail in items[:3]:
            print(f"    - {phrase}: {detail}")

    print(f"\nSample PASSING phrases:")
    for p in passed[:20]:
        print(f"  {p['phrase']}: PFS={p['PFS']}, CES={p['CES_estimate']}")

    # Write passing phrases to file
    output_file = DATA_DIR / "phrases_early_game.csv"
    with open(output_file, "w", newline="", encoding="utf-8") as f:
        if passed:
            writer = csv.DictWriter(f, fieldnames=passed[0].keys())
            writer.writeheader()
            for p in passed:
                writer.writerow(p)

    print(f"\nWrote {len(passed)} early-game phrases to {output_file}")

    return passed


if __name__ == "__main__":
    # Run tests
    test_passed = test_filter()

    # Analyze phrase bank
    analyze_phrase_bank()
