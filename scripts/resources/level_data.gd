## LevelData -- Complete configuration for one puzzle level.
## Holds all word pairs, time limit, and metadata for a single level.
## First N word_pairs = base words (required), remaining = bonus words.
class_name LevelData
extends Resource

## Human-readable level name (e.g., "Level 1", "Test Level 1")
@export var level_name: String = ""

## Time limit for this level in seconds (default: 180 = 3 minutes)
@export var time_limit_seconds: int = 180

## Number of base words (excluding starter). Bonus words come after.
@export var base_word_count: int = 12

## Number of bonus words after base words.
@export var bonus_word_count: int = 3

## Array of word pairs for this level. First base_word_count = base, then bonus_word_count = bonus.
@export var word_pairs: Array[WordPair] = []

## Surge momentum configuration for this level
@export var surge_config: SurgeConfig

## Obstacle configurations for this level
@export var obstacle_configs: Array[ObstacleConfig] = []
