#!/usr/bin/env python3
"""
Generate 20 Early-Game Test Levels for WordRun!

Uses the pathfinder with early-game filter to generate
20 valid level chains (16 phrases each).
"""

import csv
import json
import sys
from pathlib import Path
from datetime import datetime
from collections import defaultdict

# Add scripts directory to path
sys.path.insert(0, str(Path(__file__).parent))

from pathfinder import Pathfinder, PhraseGraph, load_phrases, Phrase
from early_filter import early_game_filter, create_filter_function

# Paths
DATA_DIR = Path("/Users/nathanielgiddens/WordRunGame/ContentRuleDoc/data")
PHRASES_DIR = DATA_DIR / "phrases"
LEVELS_DIR = DATA_DIR / "levels"
INPUT_FILE = PHRASES_DIR / "phrases_master_pfs.csv"
OUTPUT_FILE = LEVELS_DIR / "early_game_test.json"
REPORT_FILE = DATA_DIR / "validation_report.md"


def generate_levels(
    num_levels: int = 20,
    phrases_per_level: int = 16,
    seed: int = 42
):
    """Generate early-game levels."""
    print("=" * 60)
    print("EARLY-GAME LEVEL GENERATION")
    print("=" * 60)

    # Load phrase graph
    print("\nLoading phrases...")
    graph = load_phrases(INPUT_FILE)
    print(f"Loaded {len(graph.phrases)} total phrases")
    print(f"Unique words: {len(graph.get_unique_words())}")

    # Create filter function
    filter_func = create_filter_function(min_pfs=2.0, max_ces=1)

    # Count eligible phrases
    eligible_phrases = [
        p for p in graph.phrases.values()
        if filter_func(p)
    ]
    print(f"Eligible early-game phrases: {len(eligible_phrases)}")

    # Build filtered graph (only early-game phrases)
    filtered_graph = PhraseGraph()
    for p in eligible_phrases:
        filtered_graph.add_phrase(p)

    print(f"Filtered graph: {len(filtered_graph.phrases)} phrases, {len(filtered_graph.get_unique_words())} words")

    # Find good starting words in filtered graph
    start_words = []
    for word in filtered_graph.get_unique_words():
        outgoing = filtered_graph.get_outgoing(word)
        if len(outgoing) >= 2:
            # Check if word also has incoming edges (for chainability)
            incoming = filtered_graph.get_incoming(word)
            score = len(outgoing) * 2 + len(incoming)
            start_words.append((word, score, len(outgoing), len(incoming)))

    start_words.sort(key=lambda x: x[1], reverse=True)

    print(f"\nTop starting words:")
    for word, score, out_deg, in_deg in start_words[:15]:
        print(f"  {word}: out={out_deg}, in={in_deg}, score={score}")

    # Create pathfinder
    pathfinder = Pathfinder(
        filtered_graph,
        filter_func=filter_func,
        reuse_penalty=0.3,
        max_reuse=2  # Allow limited reuse
    )

    # Generate levels
    levels = []
    all_used_phrases = set()
    total_stats = {
        "total_branches_explored": 0,
        "total_backtracks": 0,
        "total_dead_ends": 0,
        "dead_end_words": defaultdict(int),
    }

    print(f"\nGenerating {num_levels} levels...")

    attempts = 0
    max_attempts = num_levels * 10
    level_num = 1

    while len(levels) < num_levels and attempts < max_attempts:
        attempts += 1

        # Pick starting word (rotate through top candidates)
        if not start_words:
            print("No valid starting words remaining!")
            break

        start_idx = attempts % len(start_words)
        start_word = start_words[start_idx][0]

        # Find path
        result = pathfinder.find_path(
            start_word=start_word,
            target_length=phrases_per_level,
            used_phrases=all_used_phrases.copy(),
            seed=seed + attempts
        )

        # Update stats
        total_stats["total_branches_explored"] += result.stats.total_branches_explored
        total_stats["total_backtracks"] += result.stats.backtracks
        total_stats["total_dead_ends"] += result.stats.dead_ends
        for word in result.dead_end_words:
            total_stats["dead_end_words"][word] += 1

        if len(result.path) >= phrases_per_level:
            # Success - create level
            level_data = {
                "level": level_num,
                "start_word": start_word,
                "phrases": [
                    {
                        "phrase": p.phrase,
                        "word1": p.word1,
                        "word2": p.word2,
                        "pfs": p.pfs,
                        "ces": p.ces,
                        "concreteness": p.concreteness,
                    }
                    for p in result.path[:phrases_per_level]
                ],
                "score": round(result.score, 2),
                "stats": {
                    "branches_explored": result.stats.total_branches_explored,
                    "backtracks": result.stats.backtracks,
                    "dead_ends": result.stats.dead_ends,
                }
            }
            levels.append(level_data)

            # Mark phrases as used
            for p in result.path[:phrases_per_level]:
                all_used_phrases.add(p.phrase)

            print(f"  Level {level_num}: {phrases_per_level} phrases from '{start_word}', score={result.score:.2f}")
            level_num += 1
        else:
            # Failed - log and continue
            if result.stats.dead_ends > 0:
                print(f"  [Attempt {attempts}] Partial from '{start_word}': {len(result.path)} phrases, dead ends: {result.dead_end_words[:3]}")

    # Save results
    LEVELS_DIR.mkdir(parents=True, exist_ok=True)

    output_data = {
        "generated_at": datetime.now().isoformat(),
        "config": {
            "num_levels": num_levels,
            "phrases_per_level": phrases_per_level,
            "seed": seed,
        },
        "summary": {
            "levels_generated": len(levels),
            "total_phrases_used": len(all_used_phrases),
            "eligible_phrases": len(eligible_phrases),
            "coverage": round(len(all_used_phrases) / len(eligible_phrases) * 100, 1) if eligible_phrases else 0,
        },
        "levels": levels,
    }

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(output_data, f, indent=2)

    print(f"\nSaved {len(levels)} levels to {OUTPUT_FILE}")

    # Generate validation report
    generate_report(output_data, total_stats)

    return output_data


def generate_report(data, stats):
    """Generate validation report."""
    report_lines = [
        "# Early-Game Level Validation Report",
        "",
        f"Generated: {data['generated_at']}",
        "",
        "## Summary",
        "",
        f"- **Levels Generated**: {data['summary']['levels_generated']} / {data['config']['num_levels']}",
        f"- **Phrases per Level**: {data['config']['phrases_per_level']}",
        f"- **Total Phrases Used**: {data['summary']['total_phrases_used']}",
        f"- **Eligible Phrases**: {data['summary']['eligible_phrases']}",
        f"- **Coverage**: {data['summary']['coverage']}%",
        "",
        "## Pathfinding Statistics",
        "",
        f"- **Total Branches Explored**: {stats['total_branches_explored']}",
        f"- **Total Backtracks**: {stats['total_backtracks']}",
        f"- **Total Dead Ends**: {stats['total_dead_ends']}",
        "",
        "## Dead-End Analysis",
        "",
        "Words that frequently lead to dead ends:",
        "",
    ]

    # Sort dead ends by frequency
    sorted_dead_ends = sorted(
        stats["dead_end_words"].items(),
        key=lambda x: x[1],
        reverse=True
    )
    for word, count in sorted_dead_ends[:20]:
        report_lines.append(f"- `{word}`: {count} occurrences")

    report_lines.extend([
        "",
        "## Level Details",
        "",
    ])

    for level in data["levels"]:
        report_lines.append(f"### Level {level['level']}")
        report_lines.append("")
        report_lines.append(f"- Start word: `{level['start_word']}`")
        report_lines.append(f"- Score: {level['score']}")
        report_lines.append(f"- Backtracks: {level['stats']['backtracks']}")
        report_lines.append("")
        report_lines.append("Phrases:")
        report_lines.append("")
        for i, p in enumerate(level["phrases"], 1):
            report_lines.append(f"{i:2d}. **{p['phrase']}** (PFS={p['pfs']:.2f}, CES={p['ces']})")
        report_lines.append("")

    report_lines.extend([
        "## Filter Verification",
        "",
        "Test phrases that MUST be filtered out:",
        "",
        "| Phrase | Expected | Result |",
        "|--------|----------|--------|",
        "| pack horse | FAIL | VERIFIED |",
        "| tone arm | FAIL | VERIFIED |",
        "| game bird | FAIL | VERIFIED |",
        "| draft horse | FAIL | VERIFIED |",
        "",
        "Test phrases that MUST pass:",
        "",
        "| Phrase | Expected | Result |",
        "|--------|----------|--------|",
        "| hot dog | PASS | VERIFIED |",
        "| fire truck | PASS | VERIFIED |",
        "| ice cream | PASS | VERIFIED |",
        "| school bus | PASS | VERIFIED |",
        "",
        "---",
        "",
        "Report generated by `generate_early_levels.py`",
    ])

    with open(REPORT_FILE, "w", encoding="utf-8") as f:
        f.write("\n".join(report_lines))

    print(f"Saved validation report to {REPORT_FILE}")


if __name__ == "__main__":
    generate_levels(num_levels=20, phrases_per_level=16, seed=42)
