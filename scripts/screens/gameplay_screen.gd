## GameplayScreen -- Main puzzle loop orchestration.
## Loads level data, creates word rows, routes keyboard input, manages timer,
## handles auto-scroll on word completion, and signals level completion/failure.
extends Control

const WordRowScene = preload("res://scenes/ui/word_row.tscn")

enum InputMethod { QWERTY, RADIAL }

@onready var _timer_label: Label = %TimerLabel
@onready var _word_count_label: Label = %WordCountLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _multiplier_label: Label = %MultiplierLabel
@onready var _word_rows_container: VBoxContainer = %WordRows
@onready var _keyboard: VBoxContainer = %Keyboard
@onready var _game_timer: Timer = %GameTimer
@onready var _word_display: ScrollContainer = %WordDisplay
@onready var _surge_system: Node = %SurgeSystem
@onready var _surge_bar: Control = %SurgeBar
@onready var _star_bar: Control = %StarBar
@onready var _bust_flash: ColorRect = %BustFlash
@onready var _obstacle_manager: Node = %ObstacleManager
@onready var _boost_manager: Node = %BoostManager
@onready var _boost_panel: HBoxContainer = %BoostPanel

var _level_data: LevelData
var _word_rows: Array = []
var _current_word_index: int = 0
var _words_completed: int = 0
var _time_elapsed: int = 0
var _is_level_active: bool = false
var _score: int = 0
var _current_multiplier: float = 1.0
var _input_method: InputMethod = InputMethod.QWERTY
var _skipped_padlock_word: int = -1  # Track the word we skipped due to padlock

const BASE_SCORE: int = 100


func _ready() -> void:
	# Load test level
	_level_data = load("res://data/levels/test_level_01.tres")

	# Setup timer
	_game_timer.wait_time = 1.0
	_game_timer.timeout.connect(_on_timer_tick)

	# Connect on-screen keyboard
	_keyboard.key_pressed.connect(_on_key_pressed)

	# Connect surge signals
	EventBus.surge_threshold_crossed.connect(_on_surge_threshold_crossed)
	EventBus.surge_bust.connect(_on_surge_bust)

	# Initialize surge system
	_surge_system.start(_level_data.surge_config)
	_surge_bar.setup(_level_data.surge_config)

	# Build word rows
	_build_word_rows()

	# Load obstacle configs for this level
	_obstacle_manager.load_level_obstacles(_level_data, _word_rows)

	# Setup boosts (hardcoded loadout for testing -- Phase 5 adds inventory/loadout screen)
	var test_loadout: Array[String] = ["lock_key", "block_breaker", "bucket_of_water"]
	_boost_manager.setup(_obstacle_manager, test_loadout)
	_boost_panel.setup(test_loadout)
	_boost_panel.boost_pressed.connect(_on_boost_pressed)

	# Reveal starter word (index 0) -- fully visible reference
	_word_rows[0].reveal_all()

	# Reveal first letter of all playable words
	for i in range(1, _word_rows.size()):
		_word_rows[i].reveal_first_letter()

	# Initialize timer (counts up)
	_time_elapsed = 0
	_update_timer_display()

	# Initialize score display
	_score = 0
	_update_score_display()
	_update_multiplier_display()

	# Start on word 1 (first playable word after starter)
	_current_word_index = 1
	_word_rows[1].activate()
	_update_word_count()

	# Start game
	_is_level_active = true
	_game_timer.start()
	_star_bar.start_timer()

	# Setup input method
	_apply_input_method()

	# Transition to PLAYING state
	GameManager.transition_to(GameManager.AppState.PLAYING)


func _build_word_rows() -> void:
	for i in range(_level_data.word_pairs.size()):
		var word_pair: WordPair = _level_data.word_pairs[i]
		var word_row = WordRowScene.instantiate()

		# Add to tree first so @onready vars resolve
		_word_rows_container.add_child(word_row)

		# Now set up the row
		word_row.set_word_pair(word_pair)
		word_row.word_completed.connect(_on_word_completed.bind(i))
		word_row.zero_point_completed.connect(_on_word_zero_point_completed.bind(i))
		_word_rows.append(word_row)

		# Deactivate all rows (will activate word 1 in _ready)
		word_row.deactivate()


func _on_key_pressed(key: String) -> void:
	if not _is_level_active:
		return

	if key == "DEL":
		_word_rows[_current_word_index].delete_letter()
	else:
		var accepted: bool = _word_rows[_current_word_index].handle_input(key)
		if accepted:
			EventBus.letter_input.emit(key, true)


## Handle native/physical keyboard input.
func _unhandled_input(event: InputEvent) -> void:
	if not _is_level_active:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_BACKSPACE:
			_on_key_pressed("DEL")
			get_viewport().set_input_as_handled()
		elif event.unicode > 0:
			var character: String = String.chr(event.unicode).to_upper()
			if character >= "A" and character <= "Z":
				_on_key_pressed(character)
				get_viewport().set_input_as_handled()


func _on_word_completed(word_index: int) -> void:
	_words_completed += 1
	_score += int(BASE_SCORE * _current_multiplier)
	_update_score_display()
	EventBus.word_completed.emit(word_index)
	EventBus.score_updated.emit(_score)
	_surge_system.fill()
	_update_word_count()

	# Check if this was the last word
	if word_index == _level_data.word_pairs.size() - 1:
		_level_complete()
		return

	# Check if this is the last base word before bonus words (index 12 = 12th base)
	if word_index == 12:
		_check_bonus_gate()
		return

	# If we just completed a word after a padlocked word, unlock and backtrack
	if _skipped_padlock_word != -1 and word_index == _skipped_padlock_word + 1:
		_obstacle_manager.clear_obstacle(_skipped_padlock_word)
		var backtrack_word := _skipped_padlock_word
		_skipped_padlock_word = -1
		_word_rows[_current_word_index].deactivate()
		_current_word_index = backtrack_word
		_word_rows[backtrack_word].activate()
		_scroll_to_word(backtrack_word)
		return

	# If we just completed a backtracked word, continue from word+2
	var next_idx := word_index + 1
	if next_idx < _word_rows.size() and _word_rows[next_idx].is_completed():
		next_idx += 1

	if next_idx < _word_rows.size():
		_advance_to_next_word(next_idx)


func _advance_to_next_word(next_index: int) -> void:
	# Deactivate current word
	_word_rows[_current_word_index].deactivate()

	# Check if next word has a padlock - if so, skip it
	if _obstacle_manager.has_obstacle_type(next_index, "padlock"):
		_skipped_padlock_word = next_index
		next_index += 1
		if next_index >= _word_rows.size():
			_level_complete()
			return

	# Update index
	_current_word_index = next_index

	# Trigger any obstacles for the new active word
	_obstacle_manager.check_trigger(next_index, "word_start")

	# Activate next word
	_word_rows[_current_word_index].activate()

	# Scroll to keep active word visible
	_scroll_to_word(next_index)


func _scroll_to_word(word_index: int) -> void:
	# Scroll only when the word would land at the 5th visible slot
	# or beyond (position index 4+). Scroll exactly one row so it sits at slot 4.
	var row_step := 84  # 80px row + 4px VBoxContainer separation
	var word_y: int = int(_word_rows[word_index].position.y)
	var visible_pos: int = word_y - _word_display.scroll_vertical
	if visible_pos >= 4 * row_step:
		var target_scroll: int = word_y - (3 * row_step)  # Position word at slot 3 (4th from top)
		target_scroll = max(0, target_scroll)
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(_word_display, "scroll_vertical", target_scroll, 0.4)


func _check_bonus_gate() -> void:
	# STUB: Phase 3 will check surge momentum here
	# For now, always allow bonus words
	_advance_to_next_word(13)


func _on_timer_tick() -> void:
	_time_elapsed += 1
	_update_timer_display()


func _update_timer_display() -> void:
	var minutes: int = _time_elapsed / 60
	var seconds: int = _time_elapsed % 60
	_timer_label.text = "%02d:%02d" % [minutes, seconds]


func _update_word_count() -> void:
	var total_playable: int = _level_data.word_pairs.size() - 1
	_word_count_label.text = "%d/%d" % [_words_completed, total_playable]


func _level_complete() -> void:
	_is_level_active = false
	_game_timer.stop()
	_star_bar.stop_timer()
	GameManager.last_score = _score
	GameManager.last_time_elapsed = _time_elapsed
	EventBus.level_completed.emit()


func _level_failed() -> void:
	_is_level_active = false
	_game_timer.stop()
	_star_bar.stop_timer()
	EventBus.level_failed.emit()


func _update_score_display() -> void:
	_score_label.text = "Score: %d" % _score


func _update_multiplier_display() -> void:
	_multiplier_label.text = "x%.1f" % _current_multiplier


func _on_surge_threshold_crossed(new_multiplier: float) -> void:
	_current_multiplier = new_multiplier
	_update_multiplier_display()


func _on_surge_bust() -> void:
	_current_multiplier = 1.0
	_update_multiplier_display()
	# Screen flash
	var t := create_tween()
	t.tween_property(_bust_flash, "color:a", 0.3, 0.15)
	t.tween_property(_bust_flash, "color:a", 0.0, 0.25)


func _on_word_zero_point_completed(word_index: int) -> void:
	_words_completed += 1
	_update_word_count()
	EventBus.word_completed.emit(word_index)
	if word_index == _level_data.word_pairs.size() - 1:
		_level_complete()
	elif word_index == 12:
		_check_bonus_gate()
	else:
		var next_idx := word_index + 1
		if next_idx < _word_rows.size() and _obstacle_manager.has_obstacle_type(next_idx, "padlock"):
			_obstacle_manager.clear_obstacle(next_idx)
		_advance_to_next_word(next_idx)


func _on_boost_pressed(index: int) -> void:
	if not _is_level_active:
		return

	var loadout: Array[String] = _boost_manager.get_loadout()
	if index >= loadout.size():
		return
	var boost_id: String = loadout[index]

	# Special handling for Key boost
	if boost_id == "lock_key":
		_handle_key_boost(index)
		return

	# Default handling for other boosts
	var result: Dictionary = _boost_manager.use_boost(index, _current_word_index)
	if result.used:
		_boost_panel.disable_boost(index)
		if result.bonus:
			_score += 500
			_update_score_display()
			EventBus.score_updated.emit(_score)


func _handle_key_boost(index: int) -> void:
	# Find any active padlock
	var padlock_word: int = _obstacle_manager.find_padlock_word()

	# No padlock exists - flash and don't consume
	if padlock_word == -1:
		_boost_panel.flash_boost(index)
		return

	# Padlock exists - use boost to clear it
	var result: Dictionary = _boost_manager.use_boost(index, padlock_word)
	if not result.used:
		return

	_boost_panel.disable_boost(index)

	# If this was the skipped word, trigger backtrack
	if _skipped_padlock_word != -1 and padlock_word == _skipped_padlock_word:
		var backtrack_word := _skipped_padlock_word
		_skipped_padlock_word = -1
		_word_rows[_current_word_index].deactivate()
		_current_word_index = backtrack_word
		_word_rows[backtrack_word].activate()
		_scroll_to_word(backtrack_word)
	# Otherwise padlock was ahead of caret - just cleared, no backtrack needed


## --- Input Method Toggle ---

func set_input_method(method: InputMethod) -> void:
	_input_method = method
	if is_inside_tree():
		_apply_input_method()


func _apply_input_method() -> void:
	match _input_method:
		InputMethod.QWERTY:
			_keyboard.visible = true
			# Radial wheel hidden when implemented
		InputMethod.RADIAL:
			_keyboard.visible = false
			# Radial wheel shown when implemented
