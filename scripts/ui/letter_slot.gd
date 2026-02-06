## LetterSlot -- Single letter display slot with 4 visual states (EMPTY, FILLED, CORRECT, INCORRECT).
## Used by WordRow to build the answer field.
class_name LetterSlot
extends PanelContainer

enum State { EMPTY, FILLED, CORRECT, INCORRECT, LOCKED, BLOCKED, SANDED }

@onready var _label: Label = $Label

var _current_state: State = State.EMPTY
var _style_empty: StyleBoxFlat
var _style_filled: StyleBoxFlat
var _style_correct: StyleBoxFlat
var _style_incorrect: StyleBoxFlat
var _style_locked: StyleBoxFlat
var _style_blocked: StyleBoxFlat
var _style_sanded: StyleBoxFlat

var _is_locked: bool = false
var _is_blocked: bool = false
var _is_sanded: bool = false
var _sand_fill_progress: float = 0.0  # 0.0 to 1.0
var _sand_fill_tween: Tween = null
var _is_protected: bool = false  # First letter protection


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

	# LOCKED: dark gray background
	_style_locked = StyleBoxFlat.new()
	_style_locked.bg_color = Color(0.3, 0.3, 0.3, 1)
	_style_locked.border_color = Color(0.5, 0.5, 0.5, 1)
	_style_locked.border_width_left = 2
	_style_locked.border_width_right = 2
	_style_locked.border_width_top = 2
	_style_locked.border_width_bottom = 2
	_style_locked.corner_radius_top_left = 4
	_style_locked.corner_radius_top_right = 4
	_style_locked.corner_radius_bottom_left = 4
	_style_locked.corner_radius_bottom_right = 4

	# BLOCKED: brown wood-grain placeholder
	_style_blocked = StyleBoxFlat.new()
	_style_blocked.bg_color = Color(0.55, 0.35, 0.15, 1)
	_style_blocked.border_color = Color(0.4, 0.25, 0.1, 1)
	_style_blocked.border_width_left = 2
	_style_blocked.border_width_right = 2
	_style_blocked.border_width_top = 2
	_style_blocked.border_width_bottom = 2
	_style_blocked.corner_radius_top_left = 4
	_style_blocked.corner_radius_top_right = 4
	_style_blocked.corner_radius_bottom_left = 4
	_style_blocked.corner_radius_bottom_right = 4

	# SANDED: sandy fill
	_style_sanded = StyleBoxFlat.new()
	_style_sanded.bg_color = Color(0.85, 0.75, 0.55, 0.8)
	_style_sanded.border_color = Color(0.7, 0.6, 0.4, 1)
	_style_sanded.border_width_left = 2
	_style_sanded.border_width_right = 2
	_style_sanded.border_width_top = 2
	_style_sanded.border_width_bottom = 2
	_style_sanded.corner_radius_top_left = 4
	_style_sanded.corner_radius_top_right = 4
	_style_sanded.corner_radius_bottom_left = 4
	_style_sanded.corner_radius_bottom_right = 4


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
		State.LOCKED:
			add_theme_stylebox_override("panel", _style_locked)
			_label.modulate = Color(0.5, 0.5, 0.5, 0.6)  # Dim text
		State.BLOCKED:
			add_theme_stylebox_override("panel", _style_blocked)
			_label.modulate = Color(0.9, 0.8, 0.6, 1)  # Wood text
		State.SANDED:
			add_theme_stylebox_override("panel", _style_sanded)
			_label.modulate = Color(0.6, 0.5, 0.3, 0.8)  # Sandy text


func set_letter(character: String, animate: bool = true) -> void:
	_label.text = character.to_upper()
	if animate:
		_pop_in()


func get_letter() -> String:
	return _label.text


func clear() -> void:
	_label.text = ""
	set_state(State.EMPTY)


## Snappy scale pop-in when a letter is typed.
func _pop_in() -> void:
	pivot_offset = custom_minimum_size / 2.0
	scale = Vector2.ZERO
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)


func set_locked(locked: bool) -> void:
	_is_locked = locked
	if locked:
		set_state(State.LOCKED)
	else:
		# Preserve FILLED state for slots that have content (e.g., revealed first letter)
		if _label.text != "":
			set_state(State.FILLED)
		else:
			set_state(State.EMPTY)


func set_blocked(blocked: bool) -> void:
	_is_blocked = blocked
	if blocked:
		set_state(State.BLOCKED)
	else:
		set_state(State.EMPTY)


func set_sanded(sanded: bool) -> void:
	_is_sanded = sanded
	if sanded:
		set_state(State.SANDED)
	else:
		_sand_fill_progress = 0.0
		if _sand_fill_tween:
			_sand_fill_tween.kill()
			_sand_fill_tween = null
		# Restore appropriate state - preserve CORRECT if word was solved
		if _current_state == State.CORRECT:
			# Keep CORRECT state, just update internal flag
			pass
		elif _label.text != "":
			set_state(State.FILLED)
		else:
			set_state(State.EMPTY)


func set_protected(protected: bool) -> void:
	_is_protected = protected


func is_protected() -> bool:
	return _is_protected


## Start gradual sand fill over duration seconds
func start_sand_fill(duration: float) -> void:
	if _is_protected:
		return
	_sand_fill_progress = 0.0
	_is_sanded = true
	_update_sand_visual()

	if _sand_fill_tween:
		_sand_fill_tween.kill()
	_sand_fill_tween = create_tween()
	_sand_fill_tween.tween_method(_set_sand_progress, 0.0, 1.0, duration)
	_sand_fill_tween.finished.connect(_on_sand_fill_complete)


func _set_sand_progress(progress: float) -> void:
	_sand_fill_progress = progress
	_update_sand_visual()


func _update_sand_visual() -> void:
	# Interpolate sand color based on fill progress
	var base_color := Color(0.85, 0.75, 0.55, 0.3)  # Light sand, low alpha
	var full_color := Color(0.85, 0.75, 0.55, 1.0)  # Full sand
	var current_color := base_color.lerp(full_color, _sand_fill_progress)

	_style_sanded.bg_color = current_color
	add_theme_stylebox_override("panel", _style_sanded)

	# Text gets more obscured as sand fills
	var text_alpha := 1.0 - (_sand_fill_progress * 0.7)
	_label.modulate = Color(0.6, 0.5, 0.3, text_alpha)


func _on_sand_fill_complete() -> void:
	_sand_fill_progress = 1.0
	# Erase any letter when fully sanded
	_label.text = ""
	_update_sand_visual()
	EventBus.slot_fully_sanded.emit(self)


func is_fully_sanded() -> bool:
	return _is_sanded and _sand_fill_progress >= 1.0


func get_sand_progress() -> float:
	return _sand_fill_progress


func can_accept_input() -> bool:
	# Can input if not locked/blocked, and either not sanded or sand not complete
	if _is_locked or _is_blocked:
		return false
	if _is_sanded and _sand_fill_progress >= 1.0:
		return false
	return true


## Flash the entire slot bright white then restore. Visible against the dark panel.
func flash_white() -> void:
	var flash_style := StyleBoxFlat.new()
	flash_style.bg_color = Color(1, 1, 1, 1)
	flash_style.border_color = Color(1, 1, 1, 1)
	flash_style.border_width_left = 2
	flash_style.border_width_right = 2
	flash_style.border_width_top = 2
	flash_style.border_width_bottom = 2
	flash_style.corner_radius_top_left = 4
	flash_style.corner_radius_top_right = 4
	flash_style.corner_radius_bottom_left = 4
	flash_style.corner_radius_bottom_right = 4
	add_theme_stylebox_override("panel", flash_style)
	_label.modulate = Color(1, 1, 1, 1)  # White text on white = letter vanishes
	await get_tree().create_timer(0.12).timeout
	set_state(_current_state)  # Snap back to previous visual
