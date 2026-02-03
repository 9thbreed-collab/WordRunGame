## SandObstacle -- Slowly fills slots with sand over time across multiple words.
## Cleared by Bucket of Water boost (up to 3 words).
class_name SandObstacle
extends ObstacleBase

var _sanded_slots: Dictionary = {}  ## word_index -> Array[int] of slot indices
var _target_word_rows: Array = []
var _trickle_timer: Timer
var _trickle_interval: float = 3.0


## Sand targets multiple words, so uses a special setup.
func setup_multi(obstacle_config: ObstacleConfig, word_rows: Array) -> void:
	config = obstacle_config
	_target_word_rows = word_rows
	_trickle_interval = config.effect_data.get("trickle_interval", 3.0)


func activate() -> void:
	var word_count: int = config.effect_data.get("word_count", randi_range(1, 3))
	var word_indices: Array = config.effect_data.get("word_indices", [])

	if word_indices.is_empty():
		var available: Array[int] = []
		for i in range(_target_word_rows.size()):
			available.append(i)
		available.shuffle()
		for i in range(mini(word_count, available.size())):
			word_indices.append(available[i])

	for idx in word_indices:
		_sanded_slots[idx] = []

	_trickle_timer = Timer.new()
	_trickle_timer.wait_time = _trickle_interval
	_trickle_timer.timeout.connect(_on_trickle)
	add_child(_trickle_timer)
	_trickle_timer.start()

	EventBus.obstacle_triggered.emit(config.word_index, "sand")
	obstacle_activated.emit()


func _on_trickle() -> void:
	if _sanded_slots.is_empty():
		_trickle_timer.stop()
		return

	var word_indices = _sanded_slots.keys()
	word_indices.shuffle()
	var target_idx: int = word_indices[0]

	if target_idx >= _target_word_rows.size():
		return

	var word_row = _target_word_rows[target_idx]
	var available: Array[int] = []
	for i in range(word_row._letter_slots.size()):
		if not _sanded_slots[target_idx].has(i) and word_row._letter_slots[i].can_accept_input():
			available.append(i)

	if available.size() > 0:
		available.shuffle()
		var slot_idx: int = available[0]
		_sanded_slots[target_idx].append(slot_idx)
		word_row._letter_slots[slot_idx].set_sanded(true)


func clear() -> void:
	var cleared: int = 0
	var keys_to_erase: Array = []
	for word_idx in _sanded_slots.keys():
		if cleared >= 3:
			break
		if word_idx < _target_word_rows.size():
			var word_row = _target_word_rows[word_idx]
			for slot_idx in _sanded_slots[word_idx]:
				if slot_idx < word_row._letter_slots.size():
					word_row._letter_slots[slot_idx].set_sanded(false)
		keys_to_erase.append(word_idx)
		cleared += 1
	for key in keys_to_erase:
		_sanded_slots.erase(key)
	if _sanded_slots.is_empty() and _trickle_timer:
		_trickle_timer.stop()
	EventBus.obstacle_cleared.emit(config.word_index, "sand")
	obstacle_cleared.emit()
