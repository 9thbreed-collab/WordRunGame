#!/usr/bin/env python3
"""
Backtracking DFS Pathfinder for WordRun! level generation.

Builds a directed graph from phrase bank where:
- Nodes are words
- Edges are phrases (word1 -> word2)

Finds paths of specified length maximizing:
- Sum of PFS * familiarity_weight
- Minimizing reuse penalty

Features:
- Backtracking when stuck
- Node reuse with penalty (soft constraint)
- Comprehensive logging
- Objective function optimization
"""

import csv
import json
import random
from pathlib import Path
from collections import defaultdict
from dataclasses import dataclass, field
from typing import List, Dict, Set, Optional, Tuple
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Paths
DATA_DIR = Path("/Users/nathanielgiddens/WordRunGame/ContentRuleDoc/data/phrases")
INPUT_FILE = DATA_DIR / "phrases_master_pfs.csv"


@dataclass
class Phrase:
    """Represents a phrase with all its attributes."""
    phrase: str
    word1: str
    word2: str
    pfs: float
    ces: int
    concreteness: float
    abstraction_level: str
    tone_tag: str
    category_tag: str
    level_tier: str

    def __hash__(self):
        return hash(self.phrase)

    def __eq__(self, other):
        return self.phrase == other.phrase


@dataclass
class PathfinderStats:
    """Statistics for pathfinding operation."""
    total_branches_explored: int = 0
    backtracks: int = 0
    dead_ends: int = 0
    paths_found: int = 0
    unique_nodes_available: int = 0
    max_depth_reached: int = 0
    reuses: int = 0


@dataclass
class PathResult:
    """Result of a path search."""
    path: List[Phrase]
    score: float
    stats: PathfinderStats
    dead_end_words: List[str] = field(default_factory=list)


class PhraseGraph:
    """Directed graph of phrases for pathfinding."""

    def __init__(self):
        self.phrases: Dict[str, Phrase] = {}  # phrase -> Phrase
        self.edges: Dict[str, List[Phrase]] = defaultdict(list)  # word -> [phrases starting with word]
        self.reverse_edges: Dict[str, List[Phrase]] = defaultdict(list)  # word -> [phrases ending with word]

    def add_phrase(self, phrase: Phrase):
        """Add a phrase to the graph."""
        self.phrases[phrase.phrase] = phrase
        self.edges[phrase.word1.lower()].append(phrase)
        self.reverse_edges[phrase.word2.lower()].append(phrase)

    def get_outgoing(self, word: str) -> List[Phrase]:
        """Get all phrases that start with word (can continue from word)."""
        return self.edges.get(word.lower(), [])

    def get_incoming(self, word: str) -> List[Phrase]:
        """Get all phrases that end with word."""
        return self.reverse_edges.get(word.lower(), [])

    def get_unique_words(self) -> Set[str]:
        """Get all unique words in the graph."""
        words = set()
        for phrase in self.phrases.values():
            words.add(phrase.word1.lower())
            words.add(phrase.word2.lower())
        return words


class Pathfinder:
    """Backtracking DFS pathfinder for level generation."""

    def __init__(
        self,
        graph: PhraseGraph,
        filter_func=None,
        reuse_penalty: float = 0.5,
        max_reuse: int = 2
    ):
        self.graph = graph
        self.filter_func = filter_func  # Optional filter for valid phrases
        self.reuse_penalty = reuse_penalty
        self.max_reuse = max_reuse

    def calculate_score(
        self,
        path: List[Phrase],
        used_words: Dict[str, int],
        familiarity_weight: float = 1.0
    ) -> float:
        """
        Calculate path score.

        Score = Sum(PFS * familiarity_weight) - Sum(reuse_penalty for each reuse)
        """
        if not path:
            return 0.0

        pfs_sum = sum(p.pfs for p in path) * familiarity_weight

        # Calculate reuse penalty
        total_reuses = sum(max(0, count - 1) for count in used_words.values())
        penalty = total_reuses * self.reuse_penalty

        return pfs_sum - penalty

    def find_path(
        self,
        start_word: str,
        target_length: int,
        max_depth: int = 50,
        used_phrases: Set[str] = None,
        seed: int = None
    ) -> PathResult:
        """
        Find a path of target_length phrases using backtracking DFS.

        Args:
            start_word: Word to start the path from
            target_length: Number of phrases to find
            max_depth: Maximum search depth before abandoning
            used_phrases: Set of phrases already used (from previous levels)
            seed: Random seed for reproducibility

        Returns:
            PathResult with path, score, and statistics
        """
        if seed is not None:
            random.seed(seed)

        if used_phrases is None:
            used_phrases = set()

        stats = PathfinderStats()
        stats.unique_nodes_available = len(self.graph.get_unique_words())

        # Track word usage in current path
        used_words: Dict[str, int] = defaultdict(int)
        used_words[start_word.lower()] = 1

        # Current path
        path: List[Phrase] = []
        dead_ends: List[str] = []

        # DFS with backtracking
        current_word = start_word.lower()
        choice_stack: List[List[Phrase]] = []  # Stack of remaining choices at each level

        while len(path) < target_length:
            stats.total_branches_explored += 1
            stats.max_depth_reached = max(stats.max_depth_reached, len(path))

            # Get valid continuations
            candidates = self.graph.get_outgoing(current_word)

            # Filter candidates
            valid_candidates = []
            for c in candidates:
                # Skip already used in this path (unless allowing reuse)
                if c.phrase in used_phrases:
                    continue

                # Check reuse limit
                w1_usage = used_words.get(c.word1.lower(), 0)
                w2_usage = used_words.get(c.word2.lower(), 0)
                if w1_usage >= self.max_reuse or w2_usage >= self.max_reuse:
                    continue

                # Apply filter function if provided
                if self.filter_func and not self.filter_func(c):
                    continue

                valid_candidates.append(c)

            # Sort by score (prefer higher PFS, lower CES)
            valid_candidates.sort(
                key=lambda p: (p.pfs - p.ces * 0.1),
                reverse=True
            )

            if not valid_candidates:
                # Dead end - need to backtrack
                dead_ends.append(current_word)
                stats.dead_ends += 1

                if not path:
                    # Completely stuck at start
                    logger.warning(f"No valid path from '{start_word}'")
                    break

                # Backtrack
                stats.backtracks += 1

                # Try next choice at previous level
                while choice_stack and not choice_stack[-1]:
                    # Pop exhausted level
                    choice_stack.pop()
                    if path:
                        removed = path.pop()
                        used_phrases.discard(removed.phrase)
                        used_words[removed.word1.lower()] -= 1
                        used_words[removed.word2.lower()] -= 1

                if not choice_stack:
                    # Exhausted all options
                    logger.warning(f"Exhausted all options, path length: {len(path)}")
                    break

                # Try next choice
                next_phrase = choice_stack[-1].pop(0)
                path.append(next_phrase)
                used_phrases.add(next_phrase.phrase)
                used_words[next_phrase.word1.lower()] += 1
                used_words[next_phrase.word2.lower()] += 1
                current_word = next_phrase.word2.lower()

            else:
                # Choose best candidate, save alternatives for backtracking
                chosen = valid_candidates[0]
                alternatives = valid_candidates[1:]

                choice_stack.append(alternatives)
                path.append(chosen)
                used_phrases.add(chosen.phrase)
                used_words[chosen.word1.lower()] += 1
                used_words[chosen.word2.lower()] += 1
                stats.reuses += max(0, used_words[chosen.word2.lower()] - 1)

                current_word = chosen.word2.lower()

            # Safety check
            if stats.total_branches_explored > max_depth * target_length * 10:
                logger.warning(f"Hit exploration limit, path length: {len(path)}")
                break

        if len(path) >= target_length:
            stats.paths_found = 1

        score = self.calculate_score(path, used_words)

        return PathResult(
            path=path[:target_length] if len(path) >= target_length else path,
            score=score,
            stats=stats,
            dead_end_words=list(set(dead_ends))
        )

    def find_multiple_paths(
        self,
        num_paths: int,
        phrases_per_path: int,
        filter_func=None,
        seed: int = None
    ) -> List[PathResult]:
        """
        Find multiple non-overlapping paths.

        Args:
            num_paths: Number of paths to generate
            phrases_per_path: Phrases per path
            filter_func: Optional filter for valid phrases
            seed: Random seed

        Returns:
            List of PathResults
        """
        if seed is not None:
            random.seed(seed)

        if filter_func:
            self.filter_func = filter_func

        results: List[PathResult] = []
        all_used_phrases: Set[str] = set()

        # Find good starting words (words with many outgoing edges)
        start_candidates = []
        for word in self.graph.get_unique_words():
            outgoing = self.graph.get_outgoing(word)
            if filter_func:
                outgoing = [p for p in outgoing if filter_func(p)]
            if len(outgoing) >= 3:  # Need at least 3 options
                start_candidates.append((word, len(outgoing)))

        start_candidates.sort(key=lambda x: x[1], reverse=True)

        if not start_candidates:
            logger.error("No valid starting words found!")
            return results

        start_idx = 0
        attempts = 0
        max_attempts = num_paths * 5

        while len(results) < num_paths and attempts < max_attempts:
            attempts += 1

            # Pick starting word (rotate through candidates)
            start_word = start_candidates[start_idx % len(start_candidates)][0]
            start_idx += 1

            # Find path
            result = self.find_path(
                start_word=start_word,
                target_length=phrases_per_path,
                used_phrases=all_used_phrases.copy(),
                seed=seed + attempts if seed else None
            )

            if len(result.path) >= phrases_per_path:
                results.append(result)
                # Add used phrases to global set
                for p in result.path:
                    all_used_phrases.add(p.phrase)
                logger.info(
                    f"Path {len(results)}: {phrases_per_path} phrases, "
                    f"score={result.score:.2f}, "
                    f"backtracks={result.stats.backtracks}"
                )
            else:
                logger.debug(
                    f"Partial path from '{start_word}': {len(result.path)} phrases, "
                    f"dead ends: {result.dead_end_words[:3]}"
                )

        return results


def load_phrases(filepath: Path) -> PhraseGraph:
    """Load phrases from CSV and build graph."""
    graph = PhraseGraph()

    with open(filepath, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                phrase = Phrase(
                    phrase=row["phrase"],
                    word1=row["word1"],
                    word2=row["word2"],
                    pfs=float(row.get("PFS", 1.5)),
                    ces=int(float(row.get("CES_estimate", 1))),
                    concreteness=float(row.get("concreteness_score", 0.7)),
                    abstraction_level=row.get("abstraction_level", "concrete"),
                    tone_tag=row.get("tone_tag", "neutral"),
                    category_tag=row.get("category_tag", "general"),
                    level_tier=row.get("level_tier", "mid (21-50)")
                )
                graph.add_phrase(phrase)
            except (ValueError, KeyError) as e:
                logger.warning(f"Skipping invalid row: {row.get('phrase', 'unknown')} - {e}")

    return graph


def demo():
    """Demo the pathfinder."""
    logger.info("Loading phrase graph...")
    graph = load_phrases(INPUT_FILE)
    logger.info(f"Loaded {len(graph.phrases)} phrases")
    logger.info(f"Unique words: {len(graph.get_unique_words())}")

    # Create pathfinder
    pathfinder = Pathfinder(graph, reuse_penalty=0.5, max_reuse=2)

    # Find a single path
    logger.info("\nFinding a 16-phrase path from 'ice'...")
    result = pathfinder.find_path("ice", target_length=16, seed=42)

    print(f"\nPath found: {len(result.path)} phrases, score={result.score:.2f}")
    print(f"Stats: {result.stats}")
    print("\nPath:")
    for i, p in enumerate(result.path, 1):
        print(f"  {i:2d}. {p.phrase} (PFS={p.pfs:.2f}, CES={p.ces})")

    if result.dead_end_words:
        print(f"\nDead ends encountered: {result.dead_end_words[:10]}")


if __name__ == "__main__":
    demo()
