## WordRow -- Single word puzzle row with clue label and dynamic letter slots.
## Handles letter input, word-level auto-submit on last slot, and shake feedback.
extends HBoxContainer

signal word_completed
signal zero_point_completed
signal word_unsolvable

const LetterSlotScene = preload("res://scenes/ui/letter_slot.tscn")

var _solution_word: String = ""
var _current_index: int = 0
var _revealed_count: int = 0
var _letter_slots: Array[LetterSlot] = []
var _is_active: bool = false
var _is_locked: bool = false
var _is_sand_blocked: bool = false
var _original_position_x: float = 0.0


func _ready() -> void:
	_original_position_x = position.x


func set_word_pair(pair: WordPair) -> void:
	# Store solution
	_solution_word = pair.word_b.to_upper()

	# Clear existing slots
	for slot in _letter_slots:
		slot.queue_free()
	_letter_slots.clear()

	# Create new slots for solution
	for i in range(_solution_word.length()):
		var slot: LetterSlot = LetterSlotScene.instantiate()
		add_child(slot)
		_letter_slots.append(slot)

	# Reset state
	_current_index = 0
	_revealed_count = 0


## Reveal all letters (used for the starter word -- non-interactive reference).
func reveal_all() -> void:
	for i in range(_solution_word.length()):
		_letter_slots[i].set_letter(_solution_word[i], false)
		_letter_slots[i].set_state(LetterSlot.State.FILLED)
	_revealed_count = _solution_word.length()
	_current_index = _solution_word.length()
	# Starter word stays fully visible (not dimmed)
	modulate = Color(1.0, 1.0, 1.0, 1.0)


## Reveal the first letter (used for playable words).
func reveal_first_letter() -> void:
	if _solution_word.length() > 0:
		_letter_slots[0].set_letter(_solution_word[0], false)
		_letter_slots[0].set_state(LetterSlot.State.FILLED)
		_letter_slots[0].set_protected(true)  # Protect from sand
		_revealed_count = 1
		_current_index = 1


## Accept a letter into the next available slot. Returns true if accepted.
## Auto-submits when the last slot is filled.
func handle_input(letter: String) -> bool:
	if not _is_active or _is_locked:
		return false

	var input_upper: String = letter.to_upper()

	# First blank position: if user re-types the revealed letter, always flash
	# and ignore. Word lists should avoid double-opening-letter words.
	if _current_index == _revealed_count and _revealed_count > 0:
		var revealed_letter: String = _solution_word[_revealed_count - 1]
		if input_upper == revealed_letter:
			_letter_slots[_revealed_count - 1].flash_white()
			return false

	# Find next available slot (skip fully sanded slots)
	var target_index: int = _find_next_available_slot(_current_index)
	if target_index == -1:
		# No available slots - check if word is unsolvable
		if is_unsolvable():
			word_unsolvable.emit()
		return false

	var slot: LetterSlot = _letter_slots[target_index]

	# If current slot is fully sanded, flash it and move to available slot
	if target_index != _current_index:
		_letter_slots[_current_index].flash_white()
		_current_index = target_index

	slot.set_letter(input_upper)
	slot.set_state(LetterSlot.State.FILLED)
	_current_index = target_index + 1

	# Find next available slot for cursor position
	var next_available: int = _find_next_available_slot(_current_index)
	if next_available != -1:
		_current_index = next_available

	# Check if all fillable slots are filled (for auto-submit)
	if _are_all_slots_filled():
		_auto_submit()

	return true


## Find left-most available slot starting from given index. Returns -1 if none.
func _find_next_available_slot(from_index: int) -> int:
	for i in range(from_index, _solution_word.length()):
		if _letter_slots[i].can_accept_input() and _letter_slots[i].get_letter() == "":
			return i
	return -1


## Find left-most available slot in the entire word. Returns -1 if none.
func find_leftmost_available_slot() -> int:
	return _find_next_available_slot(_revealed_count)


## Check if all non-protected slots are either filled with letters or fully sanded
func _are_all_slots_filled() -> bool:
	for i in range(_revealed_count, _solution_word.length()):
		var slot: LetterSlot = _letter_slots[i]
		if slot.get_letter() == "" and not slot.is_fully_sanded():
			return false
	return true


## Check if word is unsolvable (all slots are blocked or filled, can't complete correctly)
func is_unsolvable() -> bool:
	# Word is unsolvable if no empty slots that can accept input
	for i in range(_revealed_count, _solution_word.length()):
		var slot: LetterSlot = _letter_slots[i]
		if slot.can_accept_input() and slot.get_letter() == "":
			return false
	# All slots are either filled or fully sanded - check if we can submit
	if _are_all_slots_filled():
		# Check if current letters match solution
		for i in range(_solution_word.length()):
			if _letter_slots[i].get_letter() != _solution_word[i]:
				# Wrong answer and can't retry - unsolvable
				return true
	return false


## Check the full word against the solution.
func _auto_submit() -> void:
	var all_correct := true
	for i in range(_solution_word.length()):
		if _letter_slots[i].get_letter() != _solution_word[i]:
			all_correct = false
			break

	if all_correct:
		_mark_all_correct()
		word_completed.emit()
	else:
		_flash_incorrect()


## Flash wrong answer feedback, then clear user-typed letters for retry.
func _flash_incorrect() -> void:
	_is_active = false  # Prevent input during animation
	EventBus.word_incorrect.emit()
	for i in range(_revealed_count, _solution_word.length()):
		var slot: LetterSlot = _letter_slots[i]
		if not slot.is_fully_sanded():
			slot.set_state(LetterSlot.State.INCORRECT)
	shake()
	await get_tree().create_timer(0.3).timeout
	for i in range(_revealed_count, _solution_word.length()):
		var slot: LetterSlot = _letter_slots[i]
		if not slot.is_fully_sanded():
			slot.clear()
	# Reset cursor to first available slot
	var first_available: int = _find_next_available_slot(_revealed_count)
	_current_index = first_available if first_available != -1 else _revealed_count
	_is_active = true  # Re-enable input for retry

	# Check if word became unsolvable after clearing
	if is_unsolvable():
		word_unsolvable.emit()


func delete_letter() -> void:
	# Only delete user-typed letters, never revealed ones
	if _current_index > _revealed_count:
		_current_index -= 1
		_letter_slots[_current_index].clear()


func activate() -> void:
	_is_active = true
	if not _is_locked:
		modulate = Color(1.0, 1.0, 1.0, 1.0)


func deactivate() -> void:
	_is_active = false
	modulate = Color(0.7, 0.7, 0.7, 1.0)


func set_locked(locked: bool) -> void:
	_is_locked = locked
	for slot in _letter_slots:
		slot.set_locked(locked)
	if locked:
		modulate = Color(0.5, 0.5, 0.5, 0.7)
	elif _is_active:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		# Unlocked but not active: use inactive modulate (future word state)
		modulate = Color(0.7, 0.7, 0.7, 1.0)


func is_locked() -> bool:
	return _is_locked


func set_sand_blocked(blocked: bool) -> void:
	_is_sand_blocked = blocked
	if blocked:
		_is_active = false
		modulate = Color(0.4, 0.4, 0.4, 0.6)


func is_sand_blocked() -> bool:
	return _is_sand_blocked


func is_completed() -> bool:
	# Check if all slots are in CORRECT state
	for slot in _letter_slots:
		if slot._current_state != LetterSlot.State.CORRECT:
			return false
	return _letter_slots.size() > 0


func shake() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:x", _original_position_x + 15, 0.05)
	tween.tween_property(self, "position:x", _original_position_x - 15, 0.05)
	tween.tween_property(self, "position:x", _original_position_x + 10, 0.05)
	tween.tween_property(self, "position:x", _original_position_x - 5, 0.05)
	tween.tween_property(self, "position:x", _original_position_x, 0.05)


func _mark_all_correct() -> void:
	for slot in _letter_slots:
		slot.set_state(LetterSlot.State.CORRECT)
	_celebrate()


## Auto-solve the word for 0 points (all slots blocked scenario).
func auto_solve_zero_points() -> void:
	for i in range(_solution_word.length()):
		_letter_slots[i].set_letter(_solution_word[i], false)
		_letter_slots[i].set_state(LetterSlot.State.FILLED)
	_current_index = _solution_word.length()
	zero_point_completed.emit()


## Staggered slot pop + row pulse on word completion.
func _celebrate() -> void:
	# Staggered scale pop on each slot
	for i in range(_letter_slots.size()):
		var slot: LetterSlot = _letter_slots[i]
		slot.pivot_offset = slot.custom_minimum_size / 2.0
		var t := create_tween()
		t.tween_interval(i * 0.04)
		t.tween_property(slot, "scale", Vector2(1.15, 1.15), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		t.tween_property(slot, "scale", Vector2.ONE, 0.12).set_ease(Tween.EASE_OUT)
