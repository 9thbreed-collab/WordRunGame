## GameplayScreen -- Main puzzle loop orchestration.
## Loads level data, creates word rows, routes keyboard input, manages timer,
## handles auto-scroll on word completion, and signals level completion/failure.
extends Control

const WordRowScene = preload("res://scenes/ui/word_row.tscn")

@onready var _timer_label: Label = %TimerLabel
@onready var _word_count_label: Label = %WordCountLabel
@onready var _word_rows_container: VBoxContainer = %WordRows
@onready var _keyboard: VBoxContainer = %Keyboard
@onready var _game_timer: Timer = %GameTimer
@onready var _word_display: ScrollContainer = %WordDisplay

var _level_data: LevelData
var _word_rows: Array = []
var _current_word_index: int = 0
var _time_remaining: int = 0
var _is_level_active: bool = false


func _ready() -> void:
	# Load test level
	_level_data = load("res://data/levels/test_level_01.tres")

	# Setup timer
	_game_timer.wait_time = 1.0
	_game_timer.timeout.connect(_on_timer_tick)

	# Connect keyboard
	_keyboard.key_pressed.connect(_on_key_pressed)

	# Build word rows
	_build_word_rows()

	# Initialize timer
	_time_remaining = _level_data.time_limit_seconds
	_update_timer_display()
	_update_word_count()

	# Activate first word and start game
	_word_rows[0].activate()
	_is_level_active = true
	_game_timer.start()

	# Transition to PLAYING state
	GameManager.transition_to(GameManager.AppState.PLAYING)


func _build_word_rows() -> void:
	for i in range(_level_data.word_pairs.size()):
		var word_pair: WordPair = _level_data.word_pairs[i]
		var word_row = WordRowScene.instantiate()

		# Set up the row
		word_row.set_word_pair(word_pair)
		word_row.word_completed.connect(_on_word_completed.bind(i))

		# Add to container and track
		_word_rows_container.add_child(word_row)
		_word_rows.append(word_row)

		# Deactivate all except first (will activate first in _ready)
		if i > 0:
			word_row.deactivate()


func _on_key_pressed(key: String) -> void:
	if not _is_level_active:
		return

	if key == "DEL":
		_word_rows[_current_word_index].delete_letter()
	else:
		var correct: bool = _word_rows[_current_word_index].handle_input(key)
		EventBus.letter_input.emit(key, correct)


func _on_word_completed(word_index: int) -> void:
	EventBus.word_completed.emit(word_index)
	_update_word_count()

	# Check if this was the last word
	if word_index == _level_data.word_pairs.size() - 1:
		_level_complete()
	# Check if this is word 11 (last base word before bonus words at indices 12-14)
	elif word_index == 11:
		_check_bonus_gate()
	else:
		_advance_to_next_word(word_index + 1)


func _advance_to_next_word(next_index: int) -> void:
	# Deactivate current word
	_word_rows[_current_word_index].deactivate()

	# Update index
	_current_word_index = next_index

	# Activate next word
	_word_rows[_current_word_index].activate()

	# Tween scroll to next word
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_word_display, "scroll_vertical", int(_word_rows[next_index].position.y), 0.4)


func _check_bonus_gate() -> void:
	# STUB: Phase 3 will check surge momentum here
	# For now, always allow bonus words
	_advance_to_next_word(12)


func _on_timer_tick() -> void:
	_time_remaining -= 1
	_update_timer_display()

	if _time_remaining <= 0:
		_level_failed()


func _update_timer_display() -> void:
	var minutes: int = _time_remaining / 60
	var seconds: int = _time_remaining % 60
	_timer_label.text = "%02d:%02d" % [minutes, seconds]


func _update_word_count() -> void:
	_word_count_label.text = "%d/%d" % [_current_word_index + 1, _level_data.word_pairs.size()]


func _level_complete() -> void:
	_is_level_active = false
	_game_timer.stop()
	EventBus.level_completed.emit()


func _level_failed() -> void:
	_is_level_active = false
	_game_timer.stop()
	EventBus.level_failed.emit()
