## PadlockObstacle -- Locks a word until the previous word is solved or Lock Key boost used.
class_name PadlockObstacle
extends ObstacleBase


func activate() -> void:
	_target_word_row.set_locked(true)
	EventBus.obstacle_triggered.emit(config.word_index, "padlock")
	obstacle_activated.emit()


func clear() -> void:
	_target_word_row.set_locked(false)
	EventBus.obstacle_cleared.emit(config.word_index, "padlock")
	obstacle_cleared.emit()


func blocks_input() -> bool:
	return true
