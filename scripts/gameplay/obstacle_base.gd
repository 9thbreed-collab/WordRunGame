## ObstacleBase -- Abstract base class for all obstacle types.
## Subclasses override activate(), clear(), and blocks_input().
class_name ObstacleBase
extends Node

signal obstacle_activated
signal obstacle_cleared

var config: ObstacleConfig
var _target_word_row  ## WordRow reference (untyped to avoid circular dep)


func setup(obstacle_config: ObstacleConfig, word_row) -> void:
	config = obstacle_config
	_target_word_row = word_row


## Override in subclasses to apply the obstacle effect.
func activate() -> void:
	obstacle_activated.emit()


## Override in subclasses to remove the obstacle effect.
func clear() -> void:
	obstacle_cleared.emit()


## Override if obstacle prevents player input on the target word.
func blocks_input() -> bool:
	return false
