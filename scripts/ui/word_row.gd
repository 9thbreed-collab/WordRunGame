## WordRow -- Single word puzzle row with clue label and dynamic letter slots.
## Handles letter input, completion detection, and shake feedback.
extends HBoxContainer

signal word_completed

const LetterSlotScene = preload("res://scenes/ui/letter_slot.tscn")

@onready var _clue_label: Label = $ClueLabel

var _solution_word: String = ""
var _current_index: int = 0
var _letter_slots: Array[LetterSlot] = []
var _is_active: bool = false
var _original_position_x: float = 0.0


func _ready() -> void:
	_original_position_x = position.x


func set_word_pair(pair: WordPair) -> void:
	# Set clue text
	_clue_label.text = pair.word_a.to_upper()

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


func handle_input(letter: String) -> bool:
	if not _is_active or _current_index >= _solution_word.length():
		return false

	var input_upper: String = letter.to_upper()
	var expected_letter: String = _solution_word[_current_index]

	if input_upper == expected_letter:
		# Correct letter
		var slot: LetterSlot = _letter_slots[_current_index]
		slot.set_letter(input_upper)
		slot.set_state(LetterSlot.State.FILLED)
		_current_index += 1

		# Check if word is complete
		if _current_index == _solution_word.length():
			_mark_all_correct()
			word_completed.emit()

		return true
	else:
		# Incorrect letter
		var slot: LetterSlot = _letter_slots[_current_index]

		# Flash incorrect state
		slot.set_letter(input_upper)
		slot.set_state(LetterSlot.State.INCORRECT)

		# Reset after brief delay
		await get_tree().create_timer(0.2).timeout
		slot.clear()

		# Trigger shake
		shake()

		return false


func delete_letter() -> void:
	if _current_index > 0:
		_current_index -= 1
		_letter_slots[_current_index].clear()


func activate() -> void:
	_is_active = true
	# Add subtle visual highlight
	modulate = Color(1.0, 1.0, 1.0, 1.0)


func deactivate() -> void:
	_is_active = false
	# Dim slightly when inactive
	modulate = Color(0.7, 0.7, 0.7, 1.0)


func shake() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)

	# Oscillate position.x +-15px
	tween.tween_property(self, "position:x", _original_position_x + 15, 0.05)
	tween.tween_property(self, "position:x", _original_position_x - 15, 0.05)
	tween.tween_property(self, "position:x", _original_position_x + 10, 0.05)
	tween.tween_property(self, "position:x", _original_position_x - 5, 0.05)
	tween.tween_property(self, "position:x", _original_position_x, 0.05)


func _mark_all_correct() -> void:
	for slot in _letter_slots:
		slot.set_state(LetterSlot.State.CORRECT)
