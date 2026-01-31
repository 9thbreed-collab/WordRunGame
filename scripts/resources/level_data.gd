## LevelData -- Complete configuration for one puzzle level.
## Holds all word pairs, time limit, and metadata for a single level.
## First 12 word_pairs = base words, last 3 (indices 12-14) = bonus words.
class_name LevelData
extends Resource

## Human-readable level name (e.g., "Level 1", "Test Level 1")
@export var level_name: String = ""

## Time limit for this level in seconds (default: 180 = 3 minutes)
@export var time_limit_seconds: int = 180

## Array of word pairs for this level. First 12 = base, last 3 = bonus.
@export var word_pairs: Array[WordPair] = []
