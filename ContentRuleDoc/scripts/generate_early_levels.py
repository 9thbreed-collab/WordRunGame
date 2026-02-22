#!/usr/bin/env python3
"""
Generate Early-Game Levels for WordRun!

PIPELINE v2.1 - Strict Tier Filtering

Flow:
1. Create tier_filtered_phrases BEFORE building adjacency graph
2. Build graph ONLY from tier_filtered_phrases
3. Abort generation if graph is insufficient
4. Run strict validation before writing JSON
5. Refuse to commit on validation failure
"""

import csv
import json
import sys
from pathlib import Path
from datetime import datetime
from collections import defaultdict
from dataclasses import dataclass
from typing import List, Dict, Set, Optional, Tuple

# Add scripts directory to path
sys.path.insert(0, str(Path(__file__).parent))

from pathfinder import Pathfinder, PhraseGraph, load_phrases, Phrase
from early_filter import early_game_filter, create_filter_function, PhraseReuseTracker, get_spoken_pfs

# Paths
DATA_DIR = Path("/Users/nathanielgiddens/WordRunGame/ContentRuleDoc/data")
PHRASES_DIR = DATA_DIR / "phrases"
LEVELS_DIR = DATA_DIR / "levels"
INPUT_FILE = PHRASES_DIR / "phrases_master_pfs.csv"
OUTPUT_FILE = LEVELS_DIR / "early_game_test.json"
REPORT_FILE = DATA_DIR / "validation_report.md"

# Minimum graph requirements
MIN_PHRASES_FOR_GENERATION = 50
MIN_UNIQUE_WORDS = 30
MIN_AVG_CONNECTIVITY = 1.5


@dataclass
class ValidationResult:
    """Result of level validation."""
    passed: bool
    errors: List[str]
    warnings: List[str]


@dataclass
class GraphStats:
    """Statistics about the filtered graph."""
    total_phrases: int
    unique_words: int
    avg_out_degree: float
    max_out_degree: int
    isolated_words: int
    strongly_connected: bool


# =============================================================================
# STEP 1: TIER FILTERING (Before Graph Construction)
# =============================================================================

def create_tier_filtered_phrases(
    input_file: Path,
    tier: int = 1,
    entropy_cap: int = 2,
    min_pfs: int = 4,
    enforce_categories: bool = True
) -> Tuple[List[Phrase], Dict]:
    """
    STEP 1: Filter phrases by tier constraints BEFORE graph construction.

    Returns:
        Tuple of (filtered_phrases, filter_stats)
    """
    print("=" * 60)
    print(f"STEP 1: TIER {tier} PHRASE FILTERING")
    print("=" * 60)

    # Load all phrases
    all_phrases = []
    with open(input_file, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                phrase = Phrase(
                    phrase=row["phrase"],
                    word1=row["word1"],
                    word2=row["word2"],
                    pfs=float(row.get("PFS", 1.5)),
                    ces=int(float(row.get("CES_estimate", 1))),
                    avg_zipf=float(row.get("avg_zipf", 5.0)),
                    tone_tag=row.get("tone_tag", "neutral"),
                    category_tag=row.get("category_tag", "general"),
                    level_tier=row.get("level_tier", "mid (21-50)")
                )
                all_phrases.append(phrase)
            except (ValueError, KeyError) as e:
                pass  # Skip invalid rows

    print(f"Loaded {len(all_phrases)} total phrases from CSV")

    # Create filter function
    filter_func = create_filter_function(
        entropy_cap=entropy_cap,
        min_pfs=min_pfs,
        enforce_categories=enforce_categories
    )

    # Apply tier filter
    filtered_phrases = []
    rejection_reasons = defaultdict(int)

    for p in all_phrases:
        result = early_game_filter(
            {
                "phrase": p.phrase,
                "word1": p.word1,
                "word2": p.word2,
                "CES_estimate": p.ces,
                "category_tag": p.category_tag,
            },
            entropy_cap=entropy_cap,
            min_pfs=min_pfs,
            enforce_categories=enforce_categories
        )

        if result.passed:
            filtered_phrases.append(p)
        else:
            reason_key = result.reason.split(":")[0]
            rejection_reasons[reason_key] += 1

    # Compile stats
    filter_stats = {
        "total_input": len(all_phrases),
        "total_passed": len(filtered_phrases),
        "pass_rate": round(len(filtered_phrases) / len(all_phrases) * 100, 1) if all_phrases else 0,
        "rejection_breakdown": dict(rejection_reasons),
        "tier": tier,
        "entropy_cap": entropy_cap,
        "min_pfs": min_pfs,
    }

    print(f"\nFilter Results:")
    print(f"  Passed: {filter_stats['total_passed']} / {filter_stats['total_input']} ({filter_stats['pass_rate']}%)")
    print(f"\nRejection Breakdown:")
    for reason, count in sorted(rejection_reasons.items(), key=lambda x: -x[1]):
        print(f"  {reason}: {count}")

    return filtered_phrases, filter_stats


# =============================================================================
# STEP 2: BUILD GRAPH (Only from Filtered Phrases)
# =============================================================================

def build_filtered_graph(filtered_phrases: List[Phrase]) -> Tuple[PhraseGraph, GraphStats]:
    """
    STEP 2: Build adjacency graph ONLY from tier-filtered phrases.

    Returns:
        Tuple of (graph, graph_stats)
    """
    print("\n" + "=" * 60)
    print("STEP 2: BUILD FILTERED GRAPH")
    print("=" * 60)

    graph = PhraseGraph()
    for p in filtered_phrases:
        graph.add_phrase(p)

    # Calculate graph statistics
    unique_words = graph.get_unique_words()
    out_degrees = []
    isolated = 0

    for word in unique_words:
        out_deg = len(graph.get_outgoing(word))
        out_degrees.append(out_deg)
        if out_deg == 0 and len(graph.get_incoming(word)) == 0:
            isolated += 1

    avg_out = sum(out_degrees) / len(out_degrees) if out_degrees else 0
    max_out = max(out_degrees) if out_degrees else 0

    stats = GraphStats(
        total_phrases=len(filtered_phrases),
        unique_words=len(unique_words),
        avg_out_degree=round(avg_out, 2),
        max_out_degree=max_out,
        isolated_words=isolated,
        strongly_connected=(avg_out >= MIN_AVG_CONNECTIVITY)
    )

    print(f"\nGraph Statistics:")
    print(f"  Total phrases: {stats.total_phrases}")
    print(f"  Unique words: {stats.unique_words}")
    print(f"  Avg out-degree: {stats.avg_out_degree}")
    print(f"  Max out-degree: {stats.max_out_degree}")
    print(f"  Isolated words: {stats.isolated_words}")
    print(f"  Strongly connected: {stats.strongly_connected}")

    return graph, stats


# =============================================================================
# STEP 3: ABORT CHECK (Graph Sufficiency)
# =============================================================================

def check_graph_sufficiency(stats: GraphStats, num_levels: int, phrases_per_level: int) -> Tuple[bool, List[str]]:
    """
    STEP 3: Check if graph is sufficient for generation.

    Returns:
        Tuple of (is_sufficient, error_messages)
    """
    print("\n" + "=" * 60)
    print("STEP 3: GRAPH SUFFICIENCY CHECK")
    print("=" * 60)

    errors = []
    required_phrases = num_levels * phrases_per_level

    # Check minimum phrases
    if stats.total_phrases < MIN_PHRASES_FOR_GENERATION:
        errors.append(f"ABORT: Only {stats.total_phrases} phrases available (minimum: {MIN_PHRASES_FOR_GENERATION})")

    # Check minimum unique words
    if stats.unique_words < MIN_UNIQUE_WORDS:
        errors.append(f"ABORT: Only {stats.unique_words} unique words (minimum: {MIN_UNIQUE_WORDS})")

    # Check connectivity
    if stats.avg_out_degree < MIN_AVG_CONNECTIVITY:
        errors.append(f"ABORT: Avg connectivity {stats.avg_out_degree} too low (minimum: {MIN_AVG_CONNECTIVITY})")

    # Check if enough phrases for requested levels
    if stats.total_phrases < required_phrases * 0.5:
        errors.append(f"ABORT: {stats.total_phrases} phrases insufficient for {num_levels} levels of {phrases_per_level} phrases")

    is_sufficient = len(errors) == 0

    if is_sufficient:
        print("  [PASS] Graph is sufficient for generation")
    else:
        print("  [FAIL] Graph is INSUFFICIENT:")
        for err in errors:
            print(f"    - {err}")

    return is_sufficient, errors


# =============================================================================
# STEP 4: STRICT VALIDATION (Before Writing JSON)
# =============================================================================

def validate_level(level_data: dict, all_phrases_in_levels: Set[str]) -> ValidationResult:
    """
    Validate a single level before output.
    """
    errors = []
    warnings = []

    phrases = level_data.get("phrases", [])

    # Check phrase count
    if len(phrases) < 15:
        errors.append(f"Level {level_data['level']}: Only {len(phrases)} phrases (need 15)")

    # Check chain connectivity
    for i in range(len(phrases) - 1):
        word2 = phrases[i]["word2"].lower()
        word1_next = phrases[i + 1]["word1"].lower()
        if word2 != word1_next:
            errors.append(f"Level {level_data['level']}: Chain break at position {i+1}: '{word2}' != '{word1_next}'")

    # Check for duplicate phrases within level
    level_phrases = [p["phrase"].lower() for p in phrases]
    duplicates = [p for p in level_phrases if level_phrases.count(p) > 1]
    if duplicates:
        errors.append(f"Level {level_data['level']}: Duplicate phrases: {set(duplicates)}")

    # Check for reused phrases across levels
    for p in phrases:
        phrase_key = p["phrase"].lower()
        if phrase_key in all_phrases_in_levels:
            errors.append(f"Level {level_data['level']}: Phrase '{p['phrase']}' already used in another level")

    # Check PFS values
    for p in phrases:
        pfs = get_spoken_pfs(p["phrase"])
        if pfs < 4:
            warnings.append(f"Level {level_data['level']}: '{p['phrase']}' has PFS {pfs} < 4")

    return ValidationResult(
        passed=len(errors) == 0,
        errors=errors,
        warnings=warnings
    )


def validate_all_levels(levels: List[dict]) -> Tuple[bool, List[str], List[str]]:
    """
    STEP 4: Validate all levels before writing JSON.

    Returns:
        Tuple of (all_passed, all_errors, all_warnings)
    """
    print("\n" + "=" * 60)
    print("STEP 4: STRICT VALIDATION")
    print("=" * 60)

    all_errors = []
    all_warnings = []
    all_phrases_used = set()

    for level in levels:
        result = validate_level(level, all_phrases_used)
        all_errors.extend(result.errors)
        all_warnings.extend(result.warnings)

        # Track used phrases
        for p in level.get("phrases", []):
            all_phrases_used.add(p["phrase"].lower())

    all_passed = len(all_errors) == 0

    if all_passed:
        print(f"  [PASS] All {len(levels)} levels passed validation")
    else:
        print(f"  [FAIL] Validation failed with {len(all_errors)} errors:")
        for err in all_errors[:10]:
            print(f"    - {err}")
        if len(all_errors) > 10:
            print(f"    ... and {len(all_errors) - 10} more errors")

    if all_warnings:
        print(f"\n  [WARN] {len(all_warnings)} warnings:")
        for warn in all_warnings[:5]:
            print(f"    - {warn}")

    return all_passed, all_errors, all_warnings


# =============================================================================
# STEP 5: OUTPUT (Only on Validation Success)
# =============================================================================

def write_output(output_data: dict, output_file: Path) -> bool:
    """
    STEP 5: Write JSON output ONLY if validation passed.
    """
    print("\n" + "=" * 60)
    print("STEP 5: OUTPUT")
    print("=" * 60)

    if not output_data.get("validation_passed", False):
        print("  [REFUSE] Validation failed - NOT writing output file")
        print("  [REFUSE] NOT committing changes")
        return False

    output_file.parent.mkdir(parents=True, exist_ok=True)

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(output_data, f, indent=2)

    print(f"  [SUCCESS] Wrote {len(output_data['levels'])} levels to {output_file}")
    return True


# =============================================================================
# MAIN GENERATION PIPELINE
# =============================================================================

def generate_levels(
    num_levels: int = 20,
    phrases_per_level: int = 16,
    tier: int = 1,
    seed: int = 42
) -> Optional[dict]:
    """
    Main generation pipeline with strict tier filtering.
    """
    print("\n" + "=" * 60)
    print("WORDRUN LEVEL GENERATION PIPELINE v2.1")
    print("=" * 60)
    print(f"\nConfig: {num_levels} levels, {phrases_per_level} phrases/level, Tier {tier}")

    # STEP 1: Filter phrases by tier
    tier_config = {
        1: {"entropy_cap": 2, "min_pfs": 4},
        2: {"entropy_cap": 3, "min_pfs": 3},
        3: {"entropy_cap": 4, "min_pfs": 0},
    }
    config = tier_config.get(tier, tier_config[1])

    filtered_phrases, filter_stats = create_tier_filtered_phrases(
        INPUT_FILE,
        tier=tier,
        entropy_cap=config["entropy_cap"],
        min_pfs=config["min_pfs"],
        enforce_categories=(tier <= 2)
    )

    # STEP 2: Build graph from filtered phrases only
    graph, graph_stats = build_filtered_graph(filtered_phrases)

    # STEP 3: Check graph sufficiency - ABORT if insufficient
    is_sufficient, abort_errors = check_graph_sufficiency(graph_stats, num_levels, phrases_per_level)

    if not is_sufficient:
        print("\n" + "=" * 60)
        print("GENERATION ABORTED - INSUFFICIENT GRAPH")
        print("=" * 60)
        return None

    # Generate levels using pathfinder
    print("\n" + "=" * 60)
    print("PATHFINDING")
    print("=" * 60)

    pathfinder = Pathfinder(graph, reuse_penalty=0.3, max_reuse=1)

    levels = []
    all_used_phrases = set()
    reuse_tracker = PhraseReuseTracker()

    # Find starting words
    start_words = []
    for word in graph.get_unique_words():
        outgoing = graph.get_outgoing(word)
        if len(outgoing) >= 2:
            incoming = graph.get_incoming(word)
            score = len(outgoing) * 2 + len(incoming)
            start_words.append((word, score))
    start_words.sort(key=lambda x: -x[1])

    attempts = 0
    max_attempts = num_levels * 10
    level_num = 1

    while len(levels) < num_levels and attempts < max_attempts:
        attempts += 1
        start_word = start_words[attempts % len(start_words)][0]

        result = pathfinder.find_path(
            start_word=start_word,
            target_length=phrases_per_level - 1,  # 15 phrases = 16 words
            used_phrases=all_used_phrases.copy(),
            seed=seed + attempts
        )

        if len(result.path) >= phrases_per_level - 1:
            level_data = {
                "level": level_num,
                "start_word": start_word,
                "phrases": [
                    {
                        "phrase": p.phrase,
                        "word1": p.word1,
                        "word2": p.word2,
                        "pfs": get_spoken_pfs(p.phrase),
                        "entropy": p.ces,
                        "category": p.category_tag,
                    }
                    for p in result.path[:phrases_per_level - 1]
                ],
            }
            levels.append(level_data)

            for p in result.path[:phrases_per_level - 1]:
                all_used_phrases.add(p.phrase)
                reuse_tracker.mark_used(p.phrase, level_num)

            print(f"  Level {level_num}: {len(result.path)} phrases from '{start_word}'")
            level_num += 1

    # STEP 4: Strict validation
    validation_passed, errors, warnings = validate_all_levels(levels)

    # Compile output
    output_data = {
        "generated_at": datetime.now().isoformat(),
        "pipeline_version": "2.1",
        "config": {
            "num_levels": num_levels,
            "phrases_per_level": phrases_per_level,
            "tier": tier,
            "seed": seed,
        },
        "filter_stats": filter_stats,
        "graph_stats": {
            "total_phrases": graph_stats.total_phrases,
            "unique_words": graph_stats.unique_words,
            "avg_out_degree": graph_stats.avg_out_degree,
        },
        "validation_passed": validation_passed,
        "validation_errors": errors,
        "validation_warnings": warnings,
        "levels": levels,
    }

    # STEP 5: Write output only if validation passed
    success = write_output(output_data, OUTPUT_FILE)

    if not success:
        return None

    return output_data


if __name__ == "__main__":
    result = generate_levels(num_levels=10, phrases_per_level=16, tier=1, seed=42)

    if result is None:
        print("\n[PIPELINE FAILED]")
        sys.exit(1)
    else:
        print("\n[PIPELINE SUCCESS]")
        sys.exit(0)
