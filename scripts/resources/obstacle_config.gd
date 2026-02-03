## ObstacleConfig -- Data definition for a single obstacle instance in a level.
## Each obstacle targets a specific word index and activates based on trigger conditions.
class_name ObstacleConfig
extends Resource

## Obstacle type identifier: "padlock", "random_blocks", "sand"
@export var obstacle_type: String = ""

## Human-readable name for UI display
@export var display_name: String = ""

## Which word index this obstacle targets (0-based)
@export var word_index: int = 0

## When the obstacle activates: "word_start" or "level_start"
@export var trigger_type: String = "word_start"

## Optional delay after trigger before obstacle activates
@export var delay_seconds: float = 0.0

## Type-specific parameters (e.g., block_count for random_blocks)
@export var effect_data: Dictionary = {}
