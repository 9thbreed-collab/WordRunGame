#!/usr/bin/env python3
"""
Early-Game Filter for WordRun! phrases.

STABILIZED VERSION - Per Phrase Frequency Correction Directive

Enforces ONLY documented constraints:
- PHRASE FREQUENCY SCORE (PFS) from spoken American English corpus
- Entropy <= entropy_cap
- Category whitelist for Tier 1-2
- Blocklist/Allowlist checks
- Phrase reuse rules

PFS DEFINITION (per Stabilization Directive):
- PFS = normalized percentile rank of bigram frequency from spoken corpora
- Sources: COCA Spoken, SUBTLEX-US, Google Ngrams (fallback)

REMOVED (drift from spec):
- avg_zipf word-level heuristics
- concreteness_score (not documented)
- abstraction_level (not documented)
"""

import csv
import json
from pathlib import Path
from dataclasses import dataclass
from typing import Optional, Callable, Set, Dict

# Paths
DATA_DIR = Path("/Users/nathanielgiddens/WordRunGame/ContentRuleDoc/data/phrases")
INPUT_FILE = DATA_DIR / "phrases_master_pfs.csv"
SPOKEN_PFS_FILE = DATA_DIR / "spoken_pfs_manual.json"

# Load spoken PFS data
_SPOKEN_PFS_CACHE: Dict[str, int] = {}

def _load_spoken_pfs() -> Dict[str, int]:
    """Load spoken PFS data from JSON file."""
    global _SPOKEN_PFS_CACHE
    if not _SPOKEN_PFS_CACHE and SPOKEN_PFS_FILE.exists():
        with open(SPOKEN_PFS_FILE, "r") as f:
            _SPOKEN_PFS_CACHE = json.load(f)
    return _SPOKEN_PFS_CACHE

# =============================================================================
# BLOCKLIST - Explicit phrases that should NEVER appear in early game
# =============================================================================
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

# =============================================================================
# ALLOWLIST - Verified familiar phrases for early game (fast-pass)
# =============================================================================
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

# =============================================================================
# CATEGORY WHITELIST - Allowed categories for Tier 1-2 (Phase 2)
# =============================================================================
TIER_1_2_ALLOWED_CATEGORIES = {
    "household",
    "object_neutral",
    "food",
    "animal",
    "nature",
    "clothing",
    "transport",
    "agriculture",
    "craft",
    # Also allow these concrete object categories
    "object",
    "drink",
}

# =============================================================================
# ARCHAIC WORD DETECTION
# =============================================================================
SUSPICIOUS_WORD1 = {
    "pack", "tone", "game", "draft", "gun", "wheel",
    "mill", "forge", "kiln", "anvil", "loom",
    "plow", "plough", "harness", "yoke", "cart",
    "barrel", "cask", "keg", "vat", "trough",
}

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


def get_spoken_pfs(phrase: str) -> int:
    """
    Get PHRASE FREQUENCY SCORE from spoken American English corpus.

    Per Stabilization Directive:
    - PFS = normalized percentile rank of bigram frequency
    - Sources: COCA Spoken, SUBTLEX-US, Google Ngrams

    | Percentile | PFS |
    |------------|-----|
    | Top 10%    | 5   |
    | 70-90%     | 4   |
    | 40-70%     | 3   |
    | 20-40%     | 2   |
    | Below 20%  | 1   |

    Returns:
        PFS score (1-5), or 0 if not in corpus
    """
    pfs_data = _load_spoken_pfs()
    phrase_key = phrase.lower().strip()
    return pfs_data.get(phrase_key, 0)


def compute_familiarity_score(avg_zipf: float) -> int:
    """
    DEPRECATED: Use get_spoken_pfs() instead.

    This function is kept for backwards compatibility but should not be used.
    Per Stabilization Directive, familiarity is now based on spoken corpus PFS,
    not word-level Zipf heuristics.
    """
    if avg_zipf >= 6.0:
        return 5
    elif avg_zipf >= 5.5:
        return 4
    elif avg_zipf >= 5.0:
        return 3
    elif avg_zipf >= 4.5:
        return 2
    else:
        return 1


def early_game_filter(
    phrase_dict: dict,
    entropy_cap: int = 2,
    min_pfs: int = 4,
    enforce_categories: bool = True
) -> FilterResult:
    """
    Apply early-game constraints per Stabilization Directive.

    Args:
        phrase_dict: Dictionary with phrase attributes
        entropy_cap: Maximum entropy allowed (default 2 for Tier 1)
        min_pfs: Minimum PHRASE FREQUENCY SCORE (default 4 for Tier 1)
        enforce_categories: Whether to enforce category whitelist

    PFS Tier Enforcement:
        Tier 1 → require PFS >= 4
        Tier 2 → require PFS >= 3
        Tier 3+ → no PFS restriction

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

    # Check entropy (CES_estimate in CSV = entropy per ContentRuleDoc)
    entropy = int(float(phrase_dict.get("CES_estimate", phrase_dict.get("entropy", 1))))
    if entropy > entropy_cap:
        return FilterResult(False, f"Entropy={entropy} > {entropy_cap}: exceeds cap")

    # Check PHRASE FREQUENCY SCORE from spoken corpus (per Stabilization Directive)
    pfs = get_spoken_pfs(phrase)
    if pfs == 0:
        # Phrase not in spoken corpus - fall back to allowlist check
        # If not in allowlist, it fails
        return FilterResult(False, f"PFS=0: '{phrase}' not in spoken corpus")
    if pfs < min_pfs:
        return FilterResult(False, f"PFS={pfs} < {min_pfs}: insufficient spoken frequency")

    # Check category whitelist (Phase 2)
    if enforce_categories:
        category = phrase_dict.get("category_tag", "").lower().strip()
        if category and category not in TIER_1_2_ALLOWED_CATEGORIES:
            return FilterResult(False, f"Category '{category}' not in Tier 1-2 whitelist")

    # Check for suspicious word combinations (archaic detection)
    if word1 in SUSPICIOUS_WORD1 and word2 in ARCHAIC_WORD2:
        return FilterResult(False, f"Archaic combo: '{word1}' + '{word2}'")

    # Check for archaic word2
    if word2 in ARCHAIC_WORD2:
        return FilterResult(False, f"Archaic word2: '{word2}'")

    # All checks passed
    return FilterResult(True, f"Passed all constraints (PFS={pfs})")


def create_filter_function(
    entropy_cap: int = 2,
    min_pfs: int = 4,
    enforce_categories: bool = True
) -> Callable:
    """
    Create a filter function for the pathfinder.

    Args:
        entropy_cap: Maximum entropy allowed (default 2 for Tier 1)
        min_pfs: Minimum PHRASE FREQUENCY SCORE (default 4 for Tier 1, 3 for Tier 2)
        enforce_categories: Whether to enforce category whitelist

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
                "CES_estimate": getattr(phrase, 'ces', 1),
                "category_tag": getattr(phrase, 'category_tag', ''),
            }
        else:
            phrase_dict = phrase

        result = early_game_filter(
            phrase_dict,
            entropy_cap=entropy_cap,
            min_pfs=min_pfs,
            enforce_categories=enforce_categories
        )
        return result.passed

    return filter_func


# =============================================================================
# PHRASE REUSE RULES (Phase 3)
# =============================================================================

class PhraseReuseTracker:
    """
    Track phrase usage to enforce reuse rules.

    Rules:
    - No phrase may repeat within the first 20 levels.
    - After that, minimum reuse gap = 10 levels.
    """

    def __init__(self):
        self.phrase_last_used: dict[str, int] = {}  # phrase -> level number

    def can_use_phrase(self, phrase: str, current_level: int) -> bool:
        """Check if a phrase can be used at the current level."""
        phrase = phrase.lower().strip()

        if phrase not in self.phrase_last_used:
            return True

        last_used_level = self.phrase_last_used[phrase]

        # Rule: No phrase may repeat within the first 20 levels
        if current_level <= 20:
            return False  # Already used, and we're in first 20 levels

        # Rule: After level 20, minimum reuse gap = 10 levels
        gap = current_level - last_used_level
        return gap >= 10

    def mark_used(self, phrase: str, level: int):
        """Mark a phrase as used at a specific level."""
        phrase = phrase.lower().strip()
        self.phrase_last_used[phrase] = level

    def get_blocked_phrases(self, current_level: int) -> Set[str]:
        """Get set of phrases that cannot be used at current level."""
        blocked = set()
        for phrase, last_used in self.phrase_last_used.items():
            if not self.can_use_phrase(phrase, current_level):
                blocked.add(phrase)
        return blocked


# =============================================================================
# TEST FUNCTIONS
# =============================================================================

def test_filter():
    """Test the filter against known cases."""
    print("=" * 60)
    print("EARLY-GAME FILTER TEST (STABILIZED)")
    print("=" * 60)

    # Test cases that MUST FAIL
    must_fail = [
        {"phrase": "pack horse", "word1": "pack", "word2": "horse", "CES_estimate": 1, "avg_zipf": 5.5, "category_tag": "animal"},
        {"phrase": "tone arm", "word1": "tone", "word2": "arm", "CES_estimate": 1, "avg_zipf": 5.5, "category_tag": "object"},
        {"phrase": "game bird", "word1": "game", "word2": "bird", "CES_estimate": 1, "avg_zipf": 5.5, "category_tag": "animal"},
        {"phrase": "soup kitchen", "word1": "soup", "word2": "kitchen", "CES_estimate": 1, "avg_zipf": 5.2, "category_tag": "social"},  # Wrong category
        {"phrase": "bench press", "word1": "bench", "word2": "press", "CES_estimate": 1, "avg_zipf": 5.5, "category_tag": "sports"},  # Wrong category
    ]

    # Test cases that MUST PASS
    must_pass = [
        {"phrase": "hot dog", "word1": "hot", "word2": "dog", "CES_estimate": 1, "avg_zipf": 6.0, "category_tag": "food"},
        {"phrase": "fire truck", "word1": "fire", "word2": "truck", "CES_estimate": 1, "avg_zipf": 6.0, "category_tag": "transport"},
        {"phrase": "ice cream", "word1": "ice", "word2": "cream", "CES_estimate": 1, "avg_zipf": 6.0, "category_tag": "food"},
        {"phrase": "front door", "word1": "front", "word2": "door", "CES_estimate": 1, "avg_zipf": 6.0, "category_tag": "household"},
        {"phrase": "card game", "word1": "card", "word2": "game", "CES_estimate": 1, "avg_zipf": 5.8, "category_tag": "object"},
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
    """Analyze the full phrase bank with stabilized filter."""
    print("\n" + "=" * 60)
    print("PHRASE BANK ANALYSIS (STABILIZED)")
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
        avg_zipf = float(p.get('avg_zipf', 5.0))
        fam = compute_familiarity_score(avg_zipf)
        print(f"  {p['phrase']}: entropy={p.get('CES_estimate', p.get('entropy', '?'))}, familiarity={fam}, category={p.get('category_tag', '?')}")

    return passed


if __name__ == "__main__":
    # Run tests
    test_passed = test_filter()

    # Analyze phrase bank
    analyze_phrase_bank()
