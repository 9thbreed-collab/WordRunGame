## RandomBlocksObstacle -- Virus that spawns blocks one at a time.
## Blocks break when player types correct letters.
## Spreads to next word if blocks exceed 50% of slots.
class_name RandomBlocksObstacle
extends ObstacleBase

signal block_spawned_on_active_slot(word_index: int, slot_index: int)
signal virus_spreading(from_word: int, to_word: int)
signal word_fully_blocked(word_index: int)

const BLOCK_INTERVAL: float = 10.0  # Seconds between block spawns
const SPREAD_FIRST_BLOCK_DELAY: float = 5.0  # Delay for first block on spread word
const MAX_SPREAD_WORDS: int = 4     # Maximum words virus can spread to

var _all_word_rows: Array = []
var _infected_words: Dictionary = {}  ## word_index -> Array[int] of blocked slot indices
var _active: bool = false
var _block_timer: Timer = null
var _current_target_word: int = -1
var _spread_count: int = 0  # How many words virus has spread to


func setup(obstacle_config: ObstacleConfig, word_row) -> void:
	config = obstacle_config
	_all_word_rows = []  # Will be set by setup_with_rows


func setup_with_rows(obstacle_config: ObstacleConfig, word_rows: Array, start_word: int) -> void:
	config = obstacle_config
	_all_word_rows = word_rows
	_current_target_word = start_word
	_infected_words = {}
	_spread_count = 0


func activate() -> void:
	if _all_word_rows.is_empty():
		obstacle_activated.emit()
		return

	_active = true
	_infected_words[_current_target_word] = []

	# Connect to letter input to break blocks on correct letters
	EventBus.letter_input.connect(_on_letter_input)
	EventBus.word_completed.connect(_on_word_completed)

	# Start block spawn timer
	_block_timer = Timer.new()
	_block_timer.wait_time = BLOCK_INTERVAL
	_block_timer.timeout.connect(_spawn_next_block)
	add_child(_block_timer)

	# Spawn first block immediately
	_spawn_next_block()

	_block_timer.start()

	EventBus.obstacle_triggered.emit(config.word_index, "random_blocks")
	obstacle_activated.emit()


func _spawn_next_block() -> void:
	if not _active:
		return

	# Find an empty slot on current target word
	if _current_target_word >= _all_word_rows.size():
		_stop_virus()
		return

	var word_row = _all_word_rows[_current_target_word]

	# Skip completed or sand-blocked words
	if word_row.is_completed() or word_row.is_sand_blocked():
		_try_spread_to_next_word()
		return

	# Find available slots (not first letter, empty, not already blocked)
	var available_slots: Array[int] = []
	var blocked_slots: Array = _infected_words.get(_current_target_word, [])

	for i in range(1, word_row._letter_slots.size()):  # Skip first letter
		var slot: LetterSlot = word_row._letter_slots[i]
		if not slot.is_protected() and slot.get_letter() == "" and not slot._is_blocked and not i in blocked_slots:
			available_slots.append(i)

	if available_slots.is_empty():
		# No more slots to block on this word
		if _all_slots_blocked(_current_target_word):
			word_fully_blocked.emit(_current_target_word)
		return

	# Pick random slot and block it
	available_slots.shuffle()
	var slot_idx: int = available_slots[0]

	# Check if this is the active input slot
	var is_active_slot: bool = _is_active_input_slot(_current_target_word, slot_idx)

	# Block the slot
	if not _infected_words.has(_current_target_word):
		_infected_words[_current_target_word] = []
	_infected_words[_current_target_word].append(slot_idx)
	word_row._letter_slots[slot_idx].set_blocked(true)

	# Signal if this was the active slot (game should pause and blink)
	if is_active_slot:
		block_spawned_on_active_slot.emit(_current_target_word, slot_idx)

	# Reset timer to normal interval if it was set to spread delay
	if _block_timer and _block_timer.wait_time != BLOCK_INTERVAL:
		_block_timer.wait_time = BLOCK_INTERVAL

	# Check for virus spread (>50% blocked)
	_check_virus_spread()


func _is_active_input_slot(word_idx: int, slot_idx: int) -> bool:
	if word_idx >= _all_word_rows.size():
		return false
	var word_row = _all_word_rows[word_idx]
	# Check if this word is active and slot_idx is the current input position
	if word_row._is_active:
		var current_input_idx: int = word_row._current_index
		return slot_idx == current_input_idx
	return false


func _check_virus_spread() -> void:
	if not _active:
		return

	var word_row = _all_word_rows[_current_target_word]
	var total_slots: int = word_row._letter_slots.size() - 1  # Exclude first letter
	var blocked_count: int = _infected_words.get(_current_target_word, []).size()

	# Check if >50% blocked
	var threshold: float = total_slots * 0.5
	if blocked_count > threshold:
		_try_spread_to_next_word()


func _try_spread_to_next_word() -> void:
	if _spread_count >= MAX_SPREAD_WORDS:
		return

	# Find next unsolved word
	var next_word: int = _current_target_word + 1
	while next_word < _all_word_rows.size():
		var row = _all_word_rows[next_word]
		if not row.is_completed() and not row.is_sand_blocked():
			break
		next_word += 1

	if next_word >= _all_word_rows.size():
		# No more words to spread to
		return

	_spread_count += 1
	var old_word: int = _current_target_word
	_current_target_word = next_word
	_infected_words[next_word] = []

	virus_spreading.emit(old_word, next_word)

	# Reset timer for spread: first block after 5 seconds, then back to 10
	if _block_timer:
		_block_timer.stop()
		_block_timer.wait_time = SPREAD_FIRST_BLOCK_DELAY
		_block_timer.start()


func _all_slots_blocked(word_idx: int) -> bool:
	if word_idx >= _all_word_rows.size():
		return false
	var word_row = _all_word_rows[word_idx]
	for i in range(1, word_row._letter_slots.size()):
		var slot: LetterSlot = word_row._letter_slots[i]
		if slot.can_accept_input() and slot.get_letter() == "":
			return false
	return true


func _on_letter_input(letter: String, correct: bool) -> void:
	if not _active or not correct:
		return

	# Only break a block if the letter typed is correct for that slot position
	for word_idx in _infected_words.keys():
		if word_idx >= _all_word_rows.size():
			continue
		var word_row = _all_word_rows[word_idx]
		if not word_row._is_active:
			continue

		# Get the slot that was just filled
		var slot_idx: int = word_row.get_last_typed_slot_index()
		if slot_idx < 0 or slot_idx >= word_row._solution_word.length():
			break

		# Check if the typed letter matches the solution at this position
		if letter.to_upper() == word_row._solution_word[slot_idx]:
			_break_random_block(word_idx)
		break


func _break_random_block(word_idx: int) -> void:
	if not _infected_words.has(word_idx):
		return

	var blocked_slots: Array = _infected_words[word_idx]
	if blocked_slots.is_empty():
		return

	# Pick random block to break
	var random_idx: int = randi() % blocked_slots.size()
	var slot_idx: int = blocked_slots[random_idx]

	# Unblock the slot
	var word_row = _all_word_rows[word_idx]
	if slot_idx < word_row._letter_slots.size():
		word_row._letter_slots[slot_idx].set_blocked(false)

	blocked_slots.remove_at(random_idx)

	# Backtrack caret to leftmost available slot if this is the active word
	if word_row._is_active:
		var leftmost: int = word_row.find_leftmost_available_slot()
		if leftmost != -1:
			word_row._current_index = leftmost
			word_row._update_caret_glow()

	# Don't erase word from infected_words - allows regeneration
	# The virus can re-block empty slots on its next spawn cycle


func _on_word_completed(word_index: int) -> void:
	# Clear blocks on completed word
	if _infected_words.has(word_index):
		var word_row = _all_word_rows[word_index]
		for slot_idx in _infected_words[word_index]:
			if slot_idx < word_row._letter_slots.size():
				word_row._letter_slots[slot_idx].set_blocked(false)
		_infected_words.erase(word_index)

	# If this was the current target word, check if virus should stop
	if word_index == _current_target_word:
		# Player solved word before 50% spread - virus stops!
		var blocked_count: int = 0  # Already cleared above
		var total_slots: int = _all_word_rows[word_index]._letter_slots.size() - 1
		var threshold: float = total_slots * 0.5

		if blocked_count <= threshold:
			# Virus stopped
			_stop_virus()


func _stop_virus() -> void:
	_active = false
	if _block_timer:
		_block_timer.stop()

	if EventBus.letter_input.is_connected(_on_letter_input):
		EventBus.letter_input.disconnect(_on_letter_input)
	if EventBus.word_completed.is_connected(_on_word_completed):
		EventBus.word_completed.disconnect(_on_word_completed)


func clear() -> void:
	# Clear all blocks on all infected words
	for word_idx in _infected_words.keys():
		if word_idx < _all_word_rows.size():
			var word_row = _all_word_rows[word_idx]
			for slot_idx in _infected_words[word_idx]:
				if slot_idx < word_row._letter_slots.size():
					word_row._letter_slots[slot_idx].set_blocked(false)
			# Update caret position on active word after clearing
			if word_row._is_active:
				var leftmost: int = word_row.find_leftmost_available_slot()
				if leftmost != -1:
					word_row._current_index = leftmost
					word_row._update_caret_glow()

	_infected_words.clear()
	_stop_virus()

	EventBus.obstacle_cleared.emit(config.word_index, "random_blocks")
	obstacle_cleared.emit()


func is_active() -> bool:
	return _active


func get_infected_words() -> Array:
	return _infected_words.keys()


func has_blocks_on_word(word_idx: int) -> bool:
	return _infected_words.has(word_idx) and _infected_words[word_idx].size() > 0
