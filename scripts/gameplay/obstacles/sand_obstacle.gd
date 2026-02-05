## SandObstacle -- Gradually fills 1 slot per word across up to 5 words.
## Each slot takes 30 seconds to fill, with 10-second staggered starts.
## All targets are predetermined at trigger time.
## Cleared by Bucket of Water boost (up to 3 slots).
class_name SandObstacle
extends ObstacleBase

const FILL_DURATION: float = 30.0   # Seconds to fully fill a slot
const STAGGER_DELAY: float = 10.0   # Seconds between starting each word's sand

var _all_word_rows: Array = []
var _predetermined_targets: Array = []  ## Array of {word_idx, slot_idx} - set at trigger time
var _active_fills: Dictionary = {}  ## word_idx -> slot_idx (currently filling)
var _pending_targets: Array = []  ## Targets not yet started filling
var _active: bool = false
var _stagger_timer: Timer = null


## Sand targets multiple words, so uses a special setup.
func setup_multi(obstacle_config: ObstacleConfig, word_rows: Array) -> void:
	config = obstacle_config
	_all_word_rows = word_rows
	_predetermined_targets = []
	_active_fills = {}
	_pending_targets = []


func activate() -> void:
	var word_count: int = config.effect_data.get("word_count", 3)
	var word_indices: Array = config.effect_data.get("word_indices", [])
	var start_index: int = config.word_index

	# If no specific indices provided, select sequential words from start_index
	if word_indices.is_empty():
		for i in range(word_count):
			var idx: int = start_index + i
			if idx < _all_word_rows.size():
				word_indices.append(idx)

	# PREDETERMINE all targets now (at trigger time)
	_predetermined_targets = []
	for word_idx in word_indices:
		if word_idx >= _all_word_rows.size():
			continue

		var word_row = _all_word_rows[word_idx]

		# Skip already completed words
		if word_row.is_completed():
			continue

		# Find available slots (not first letter, empty)
		var available_slots: Array[int] = []
		for i in range(1, word_row._letter_slots.size()):
			var slot: LetterSlot = word_row._letter_slots[i]
			if not slot.is_protected() and slot.get_letter() == "":
				available_slots.append(i)

		if available_slots.is_empty():
			continue

		# Pick random slot NOW (predetermined)
		available_slots.shuffle()
		var slot_idx: int = available_slots[0]

		_predetermined_targets.append({"word_idx": word_idx, "slot_idx": slot_idx})

	if _predetermined_targets.is_empty():
		obstacle_activated.emit()
		return

	_active = true
	_pending_targets = _predetermined_targets.duplicate()

	# Connect to word completion signals to clear sand when word is solved
	EventBus.word_completed.connect(_on_word_completed)

	# Start the first target immediately
	_start_next_sand()

	# Setup stagger timer for remaining targets
	if _pending_targets.size() > 0:
		_stagger_timer = Timer.new()
		_stagger_timer.wait_time = STAGGER_DELAY
		_stagger_timer.timeout.connect(_start_next_sand)
		add_child(_stagger_timer)
		_stagger_timer.start()

	EventBus.obstacle_triggered.emit(config.word_index, "sand")
	obstacle_activated.emit()


func _start_next_sand() -> void:
	if _pending_targets.is_empty():
		if _stagger_timer:
			_stagger_timer.stop()
		return

	var target: Dictionary = _pending_targets.pop_front()
	var word_idx: int = target.word_idx
	var slot_idx: int = target.slot_idx

	# Check if word was solved before this sand started
	if word_idx < _all_word_rows.size():
		var word_row = _all_word_rows[word_idx]
		if word_row.is_completed():
			# Word already solved, skip this target
			if _pending_targets.size() > 0:
				return  # Timer will fire again for next one
			elif _stagger_timer:
				_stagger_timer.stop()
			return

		var slot: LetterSlot = word_row._letter_slots[slot_idx]

		# Start the fill
		_active_fills[word_idx] = slot_idx
		slot.start_sand_fill(FILL_DURATION)

	# Stop timer if no more pending
	if _pending_targets.is_empty() and _stagger_timer:
		_stagger_timer.stop()


func _on_word_completed(word_index: int) -> void:
	# If this word has active sand, clear it and flash
	if _active_fills.has(word_index):
		var slot_idx: int = _active_fills[word_index]
		if word_index < _all_word_rows.size():
			var word_row = _all_word_rows[word_index]
			if slot_idx < word_row._letter_slots.size():
				var slot: LetterSlot = word_row._letter_slots[slot_idx]
				slot.set_sanded(false)
				slot.flash_white()
		_active_fills.erase(word_index)

	# Remove from pending if not yet started
	for i in range(_pending_targets.size() - 1, -1, -1):
		if _pending_targets[i].word_idx == word_index:
			_pending_targets.remove_at(i)

	_update_active_state()


func _update_active_state() -> void:
	_active = _active_fills.size() > 0 or _pending_targets.size() > 0
	if not _active:
		if _stagger_timer:
			_stagger_timer.stop()
		if EventBus.word_completed.is_connected(_on_word_completed):
			EventBus.word_completed.disconnect(_on_word_completed)


## Get total sand traps (active + pending)
func get_total_sand_count() -> int:
	return _active_fills.size() + _pending_targets.size()


## Clear up to 3 sand traps (active first, then pending). Returns {cleared, total}.
func clear_with_count() -> Dictionary:
	var total: int = get_total_sand_count()
	var cleared: int = 0
	var max_clear: int = 3

	# First, clear active fills
	var active_keys: Array = _active_fills.keys().duplicate()
	active_keys.shuffle()

	for word_idx in active_keys:
		if cleared >= max_clear:
			break
		var slot_idx: int = _active_fills[word_idx]
		if word_idx < _all_word_rows.size():
			var word_row = _all_word_rows[word_idx]
			if slot_idx < word_row._letter_slots.size():
				word_row._letter_slots[slot_idx].set_sanded(false)
		_active_fills.erase(word_idx)
		cleared += 1

	# Then, clear pending (cancel them before they start)
	while cleared < max_clear and _pending_targets.size() > 0:
		_pending_targets.pop_front()
		cleared += 1

	_update_active_state()

	EventBus.obstacle_cleared.emit(config.word_index, "sand")
	obstacle_cleared.emit()

	return {"cleared": cleared, "total": total}


## Legacy clear method
func clear() -> void:
	clear_with_count()


## Check if any sand is currently active
func is_active() -> bool:
	return _active


## Get all currently filling slots for boost targeting
func get_sanded_slots() -> Dictionary:
	return _active_fills.duplicate()


## Clear a specific slot (used by boost manager)
func clear_slot(word_idx: int, slot_idx: int) -> void:
	if _active_fills.has(word_idx) and _active_fills[word_idx] == slot_idx:
		if word_idx < _all_word_rows.size():
			var word_row = _all_word_rows[word_idx]
			if slot_idx < word_row._letter_slots.size():
				word_row._letter_slots[slot_idx].set_sanded(false)
		_active_fills.erase(word_idx)

	_update_active_state()
