## WordRow -- Single word puzzle row with clue label and dynamic letter slots.
## Handles letter input, word-level auto-submit on last slot, and shake feedback.
extends HBoxContainer

signal word_completed

const LetterSlotScene = preload("res://scenes/ui/letter_slot.tscn")

var _solution_word: String = ""
var _current_index: int = 0
var _revealed_count: int = 0
var _letter_slots: Array[LetterSlot] = []
var _is_active: bool = false
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
		_revealed_count = 1
		_current_index = 1


## Accept a letter into the next available slot. Returns true if accepted.
## Auto-submits when the last slot is filled.
func handle_input(letter: String) -> bool:
	if not _is_active or _current_index >= _solution_word.length():
		return false

	var input_upper: String = letter.to_upper()

	# First blank position: if user re-types the revealed letter, always flash
	# and ignore. Word lists should avoid double-opening-letter words.
	if _current_index == _revealed_count and _revealed_count > 0:
		var revealed_letter: String = _solution_word[_revealed_count - 1]
		if input_upper == revealed_letter:
			_letter_slots[_revealed_count - 1].flash_white()
			return false

	var slot: LetterSlot = _letter_slots[_current_index]
	slot.set_letter(input_upper)
	slot.set_state(LetterSlot.State.FILLED)
	_current_index += 1

	# Auto-submit when last slot is filled
	if _current_index == _solution_word.length():
		_auto_submit()

	return true


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
		_letter_slots[i].set_state(LetterSlot.State.INCORRECT)
	shake()
	await get_tree().create_timer(0.3).timeout
	for i in range(_revealed_count, _solution_word.length()):
		_letter_slots[i].clear()
	_current_index = _revealed_count
	_is_active = true  # Re-enable input for retry


func delete_letter() -> void:
	# Only delete user-typed letters, never revealed ones
	if _current_index > _revealed_count:
		_current_index -= 1
		_letter_slots[_current_index].clear()


func activate() -> void:
	_is_active = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)


func deactivate() -> void:
	_is_active = false
	modulate = Color(0.7, 0.7, 0.7, 1.0)


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
