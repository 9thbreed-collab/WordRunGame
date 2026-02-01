## SurgeConfig -- Configuration resource for surge momentum mechanics.
## Defines surge bar parameters, thresholds, and multipliers.
class_name SurgeConfig
extends Resource

## Maximum surge value (full bar)
@export var max_value: float = 100.0

## Surge points added per completed word
@export var fill_per_word: float = 15.0

## Drain rate in points/second when state is IDLE or FILLING
@export var idle_drain_rate: float = 2.0

## Drain rate in points/second when state is IMMINENT (past final threshold)
@export var imminent_drain_rate: float = 8.0

## Surge value thresholds that trigger multiplier increases (ascending order)
@export var thresholds: Array[float] = [30.0, 60.0, 90.0]

## Score multipliers at each level.
## Index 0 = below first threshold
## Index 1 = above thresholds[0], below thresholds[1]
## Index 2 = above thresholds[1], below thresholds[2]
## Index 3 = above thresholds[2] (imminent zone)
@export var multipliers: Array[float] = [1.0, 1.5, 2.0, 3.0]
