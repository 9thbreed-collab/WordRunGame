## LetterSlot -- Single letter display slot with 4 visual states (EMPTY, FILLED, CORRECT, INCORRECT).
## Used by WordRow to build the answer field.
class_name LetterSlot
extends PanelContainer

enum State { EMPTY, FILLED, CORRECT, INCORRECT }

@onready var _label: Label = $Label

var _current_state: State = State.EMPTY
var _style_empty: StyleBoxFlat
var _style_filled: StyleBoxFlat
var _style_correct: StyleBoxFlat
var _style_incorrect: StyleBoxFlat


func _ready() -> void:
	_create_styles()
	set_state(State.EMPTY)


func _create_styles() -> void:
	# EMPTY: light gray border, transparent fill
	_style_empty = StyleBoxFlat.new()
	_style_empty.bg_color = Color(0, 0, 0, 0)  # Transparent
	_style_empty.border_color = Color(0.8, 0.8, 0.8, 1)  # #CCCCCC
	_style_empty.border_width_left = 2
	_style_empty.border_width_right = 2
	_style_empty.border_width_top = 2
	_style_empty.border_width_bottom = 2
	_style_empty.corner_radius_top_left = 4
	_style_empty.corner_radius_top_right = 4
	_style_empty.corner_radius_bottom_left = 4
	_style_empty.corner_radius_bottom_right = 4

	# FILLED: white background, dark border
	_style_filled = StyleBoxFlat.new()
	_style_filled.bg_color = Color(1, 1, 1, 1)  # White
	_style_filled.border_color = Color(0.2, 0.2, 0.2, 1)  # Dark gray
	_style_filled.border_width_left = 2
	_style_filled.border_width_right = 2
	_style_filled.border_width_top = 2
	_style_filled.border_width_bottom = 2
	_style_filled.corner_radius_top_left = 4
	_style_filled.corner_radius_top_right = 4
	_style_filled.corner_radius_bottom_left = 4
	_style_filled.corner_radius_bottom_right = 4

	# CORRECT: green background
	_style_correct = StyleBoxFlat.new()
	_style_correct.bg_color = Color(0.298, 0.686, 0.314, 1)  # #4CAF50
	_style_correct.border_color = Color(0.2, 0.5, 0.2, 1)  # Darker green
	_style_correct.border_width_left = 2
	_style_correct.border_width_right = 2
	_style_correct.border_width_top = 2
	_style_correct.border_width_bottom = 2
	_style_correct.corner_radius_top_left = 4
	_style_correct.corner_radius_top_right = 4
	_style_correct.corner_radius_bottom_left = 4
	_style_correct.corner_radius_bottom_right = 4

	# INCORRECT: red background
	_style_incorrect = StyleBoxFlat.new()
	_style_incorrect.bg_color = Color(0.957, 0.263, 0.212, 1)  # #F44336
	_style_incorrect.border_color = Color(0.7, 0.1, 0.1, 1)  # Darker red
	_style_incorrect.border_width_left = 2
	_style_incorrect.border_width_right = 2
	_style_incorrect.border_width_top = 2
	_style_incorrect.border_width_bottom = 2
	_style_incorrect.corner_radius_top_left = 4
	_style_incorrect.corner_radius_top_right = 4
	_style_incorrect.corner_radius_bottom_left = 4
	_style_incorrect.corner_radius_bottom_right = 4


func set_state(new_state: State) -> void:
	_current_state = new_state
	match new_state:
		State.EMPTY:
			add_theme_stylebox_override("panel", _style_empty)
			_label.modulate = Color(0.6, 0.6, 0.6, 1)  # Dim text for empty
		State.FILLED:
			add_theme_stylebox_override("panel", _style_filled)
			_label.modulate = Color(0, 0, 0, 1)  # Black text
		State.CORRECT:
			add_theme_stylebox_override("panel", _style_correct)
			_label.modulate = Color(1, 1, 1, 1)  # White text
		State.INCORRECT:
			add_theme_stylebox_override("panel", _style_incorrect)
			_label.modulate = Color(1, 1, 1, 1)  # White text


func set_letter(character: String) -> void:
	_label.text = character.to_upper()


func get_letter() -> String:
	return _label.text


func clear() -> void:
	_label.text = ""
	set_state(State.EMPTY)
