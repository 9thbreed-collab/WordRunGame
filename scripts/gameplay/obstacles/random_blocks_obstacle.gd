## RandomBlocksObstacle -- Fills random letter slots with blocks.
## If all slots are blocked, word auto-solves for 0 points.
class_name RandomBlocksObstacle
extends ObstacleBase

var _blocked_slot_indices: Array[int] = []


func activate() -> void:
	var block_count: int = config.effect_data.get("block_count", randi_range(1, 3))
	_place_blocks(block_count)
	EventBus.obstacle_triggered.emit(config.word_index, "random_blocks")
	obstacle_activated.emit()


func _place_blocks(count: int) -> void:
	var available: Array[int] = []
	for i in range(_target_word_row._letter_slots.size()):
		var slot = _target_word_row._letter_slots[i]
		if slot.get_letter() == "" and slot.can_accept_input():
			available.append(i)
	available.shuffle()
	var to_block: int = mini(count, available.size())
	for i in range(to_block):
		var idx: int = available[i]
		_blocked_slot_indices.append(idx)
		_target_word_row._letter_slots[idx].set_blocked(true)
	if _all_slots_unusable():
		_auto_solve_zero.call_deferred()


func _all_slots_unusable() -> bool:
	for slot in _target_word_row._letter_slots:
		if slot.can_accept_input() and slot.get_letter() == "":
			return false
	return true


func _auto_solve_zero() -> void:
	_target_word_row.auto_solve_zero_points()


func clear() -> void:
	for idx in _blocked_slot_indices:
		if idx < _target_word_row._letter_slots.size():
			_target_word_row._letter_slots[idx].set_blocked(false)
	_blocked_slot_indices.clear()
	EventBus.obstacle_cleared.emit(config.word_index, "random_blocks")
	obstacle_cleared.emit()


func blocks_input() -> bool:
	return false  # Blocks individual slots, not the whole word
