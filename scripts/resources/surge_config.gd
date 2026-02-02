## SurgeConfig -- Configuration resource for surge momentum mechanics.
## Defines surge bar parameters, thresholds, drain times, and multipliers.
class_name SurgeConfig
extends Resource

## Maximum surge value (full bar)
@export var max_value: float = 100.0

## Surge points added per completed word
@export var fill_per_word: float = 15.0

## Surge value thresholds that trigger multiplier changes (ascending order)
@export var thresholds: Array[float] = [30.0, 60.0, 80.0]

## Time in seconds to drain each section's width.
## Index 0 = section below thresholds[0]
## Index 1 = section between thresholds[0] and thresholds[1]
## etc.
## Must have thresholds.size() + 1 entries.
@export var section_drain_times: Array[float] = [9.0, 5.5, 3.5, 2.5]

## Drain rate during bust (units/second). Bust drains from T3 to below T1.
@export var bust_drain_rate: float = 25.0

## Score multipliers per section (same indexing as section_drain_times).
@export var multipliers: Array[float] = [1.0, 1.5, 2.0, 3.0]
