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
@onready var _hint_button: Control = %HintButton

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
var _in_bonus_mode: bool = false
var _bonus_words_revealed: int = 0  # How many bonus words have been shown
var _bonus_words_completed: int = 0  # How many bonus words have been solved
var _bonus_scroll_tween: Tween = null  # Track bonus scroll to prevent stacking

const BASE_SCORE: int = 100


func _ready() -> void:
	# Load level from ContentCache (JSON), fallback to .tres for testing
	var land_id: String = GameManager.selected_land
	var level_idx: int = GameManager.selected_level
	var level_json := ContentCache.get_level_json(land_id, level_idx)
	if not level_json.is_empty():
		_level_data = ContentCache.build_level_data(level_json)
		print("Loaded: %s level %d" % [land_id, level_idx + 1])
	else:
		_level_data = load("res://data/levels/test_level_01.tres")
		print("Fallback: test_level_01.tres")

	# Setup timer
	_game_timer.wait_time = 1.0
	_game_timer.timeout.connect(_on_timer_tick)

	# Connect on-screen keyboard
	_keyboard.key_pressed.connect(_on_key_pressed)

	# Connect surge signals
	EventBus.surge_threshold_crossed.connect(_on_surge_threshold_crossed)
	EventBus.surge_bust.connect(_on_surge_bust)

	# Connect obstacle signals for scroll handling
	EventBus.obstacle_triggered.connect(_on_obstacle_triggered)

	# Connect sand fill complete signal
	EventBus.slot_fully_sanded.connect(_on_slot_fully_sanded)

	# Connect bonus mode signal
	EventBus.bonus_mode_ended.connect(_on_bonus_mode_ended)

	# Initialize surge system
	_surge_system.start(_level_data.surge_config)
	_surge_bar.setup(_level_data.surge_config)

	# Build word rows
	_build_word_rows()

	# Load obstacle configs for this level
	_obstacle_manager.load_level_obstacles(_level_data, _word_rows)

	# Connect to random blocks signals after obstacles are loaded
	_connect_block_signals()

	# Setup boosts (hardcoded loadout for testing -- Phase 5 adds inventory/loadout screen)
	var test_loadout: Array[String] = ["lock_key", "block_breaker", "bucket_of_water"]
	_boost_manager.setup(_obstacle_manager, test_loadout)
	_boost_panel.setup(test_loadout)
	_boost_panel.boost_pressed.connect(_on_boost_pressed)

	# Connect hint button
	_hint_button.hint_requested.connect(_on_hint_requested)

	# Reveal starter word (index 0) -- fully visible reference
	_word_rows[0].reveal_all()

	# Reveal first letter of base words only (bonus words hidden until earned)
	# Base words are indices 1 through base_word_count (inclusive)
	var first_bonus_index: int = _level_data.base_word_count + 1  # +1 for starter word
	for i in range(1, _word_rows.size()):
		if i < first_bonus_index:
			_word_rows[i].reveal_first_letter()
		else:
			# Bonus words: hide initially
			_word_rows[i].visible = false

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
		word_row.word_unsolvable.connect(_on_word_unsolvable.bind(i))
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
	# Handle bonus words separately
	if _in_bonus_mode:
		_on_bonus_word_completed()
		return

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

	# Check if this is the last base word before bonus words
	if word_index == _level_data.base_word_count:
		_check_bonus_gate()
		return

	# If we just completed a word after a padlocked word, unlock and backtrack
	if _skipped_padlock_word != -1 and word_index == _skipped_padlock_word + 1:
		_obstacle_manager.clear_obstacle(_skipped_padlock_word)
		var backtrack_word: int = _skipped_padlock_word
		_skipped_padlock_word = -1
		_word_rows[_current_word_index].deactivate()
		_current_word_index = backtrack_word
		_word_rows[backtrack_word].activate()
		_scroll_to_word(backtrack_word)
		return

	# If we just completed the padlocked word itself (after being unlocked), clear the flag
	if _skipped_padlock_word == word_index:
		_skipped_padlock_word = -1

	# Find next available word (skip completed and sand-blocked)
	var next_idx := word_index + 1
	while next_idx < _word_rows.size():
		var row = _word_rows[next_idx]
		if not row.is_completed() and not row.is_sand_blocked():
			break
		next_idx += 1

	if next_idx < _word_rows.size():
		_advance_to_next_word(next_idx)
	else:
		_level_complete()


func _advance_to_next_word(next_index: int) -> void:
	# Deactivate current word
	_word_rows[_current_word_index].deactivate()

	# Skip sand-blocked words
	while next_index < _word_rows.size() and _word_rows[next_index].is_sand_blocked():
		next_index += 1

	if next_index >= _word_rows.size():
		_level_complete()
		return

	# Check if next word has a padlock - if so, spawn it and skip to the word after
	# Check both active obstacles AND configured obstacles (padlock triggers on word_start,
	# so it may not be active yet when we're deciding to skip)
	if _obstacle_manager.has_obstacle_type(next_index, "padlock") or \
	   _obstacle_manager.has_configured_obstacle(next_index, "padlock", "word_start"):
		# Spawn the padlock so it shows as locked and can respond to Key boost
		_obstacle_manager.check_trigger(next_index, "word_start")
		_skipped_padlock_word = next_index
		# Move to the next word after the padlock (only skip ONE word)
		var skip_target: int = next_index + 1
		# Skip any sand-blocked words after padlock too
		while skip_target < _word_rows.size() and _word_rows[skip_target].is_sand_blocked():
			skip_target += 1
		if skip_target >= _word_rows.size():
			_level_complete()
			return
		next_index = skip_target

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


func _scroll_to_bonus_word(_word_index: int) -> void:
	# Bonus words are hidden initially and just became visible
	# Wait for ScrollContainer to update its scrollbar range after VBoxContainer resizes
	# This takes 2 frames: Frame 1 = VBoxContainer resizes, Frame 2 = ScrollContainer updates
	var v_scroll_bar: ScrollBar = _word_display.get_v_scroll_bar()
	await v_scroll_bar.changed
	_do_bonus_scroll()


func _do_bonus_scroll() -> void:
	# Kill any in-progress bonus scroll to prevent animation stacking
	if _bonus_scroll_tween and _bonus_scroll_tween.is_running():
		_bonus_scroll_tween.kill()

	# Scroll down one row to reveal the newly populated bonus word
	var row_step := 84  # 80px row + 4px VBoxContainer separation
	var current_scroll: int = _word_display.scroll_vertical
	var target_scroll: int = current_scroll + row_step
	var max_scroll: int = _word_display.get_v_scroll_bar().max_value

	# Debug output
	print("BONUS SCROLL: current=%d, target=%d, max=%d" % [current_scroll, target_scroll, max_scroll])

	_bonus_scroll_tween = create_tween()
	_bonus_scroll_tween.set_trans(Tween.TRANS_CUBIC)
	_bonus_scroll_tween.set_ease(Tween.EASE_OUT)
	_bonus_scroll_tween.tween_property(_word_display, "scroll_vertical", target_scroll, 0.5)


func _check_bonus_gate() -> void:
	# Check if surge is above 60% (second threshold)
	if not _surge_system.is_above_bonus_threshold():
		# Not enough surge - level complete without bonus words
		_level_complete()
		return

	# Qualified for bonus mode!
	_enter_bonus_mode()


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
	GameManager.last_words_solved = _words_completed
	GameManager.last_total_words = _level_data.base_word_count  # Base words only
	EventBus.level_completed.emit()


func _level_failed() -> void:
	_is_level_active = false
	_game_timer.stop()
	_star_bar.stop_timer()
	GameManager.last_score = _score
	GameManager.last_time_elapsed = _time_elapsed
	GameManager.last_words_solved = _words_completed
	GameManager.last_total_words = _level_data.base_word_count
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
	elif word_index == _level_data.base_word_count:
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

	# Special handling for Water boost
	if boost_id == "bucket_of_water":
		_handle_water_boost(index)
		return

	# Special handling for Breaker boost
	if boost_id == "block_breaker":
		_handle_breaker_boost(index)
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
		var backtrack_word: int = _skipped_padlock_word
		_skipped_padlock_word = -1
		_word_rows[_current_word_index].deactivate()
		_current_word_index = backtrack_word
		_word_rows[backtrack_word].activate()
		_scroll_to_word(backtrack_word)
	# Otherwise padlock was ahead of caret - just cleared, no backtrack needed


func _handle_water_boost(index: int) -> void:
	# Check if any sand is active
	if not _obstacle_manager.has_active_sand():
		_boost_panel.flash_boost(index)
		return

	# Mark boost as used
	var result: Dictionary = _boost_manager.use_boost(index, _current_word_index)
	if not result.used:
		return

	_boost_panel.disable_boost(index)

	# Clear sand (up to 3 from active + pending)
	var clear_result: Dictionary = _obstacle_manager.clear_sand_with_boost()

	# Show "X/Y cleared" text next to active word
	_show_sand_clear_text(clear_result.cleared, clear_result.total)


func _on_word_unsolvable(word_index: int) -> void:
	# Grey out the unsolvable word
	_word_rows[word_index].deactivate()
	_word_rows[word_index].modulate = Color(0.4, 0.4, 0.4, 0.6)

	# Check if this is a base word - if so, it's a loss
	if word_index <= _level_data.base_word_count:
		_level_failed_no_moves()
		return

	# Bonus word - just move to next word
	var next_idx: int = word_index + 1
	if next_idx < _word_rows.size():
		_advance_to_next_word(next_idx)
	else:
		# No more words - level complete (bonus words don't count against)
		_level_complete()


func _on_slot_fully_sanded(slot: Node) -> void:
	# Find which word contains this slot
	var word_index: int = -1
	for i in range(_word_rows.size()):
		var word_row = _word_rows[i]
		if slot in word_row._letter_slots:
			word_index = i
			break

	if word_index == -1:
		return

	# Grey out the word (sand block remains visible)
	_word_rows[word_index].set_sand_blocked(true)

	# If this is the current word, advance to next
	if word_index == _current_word_index:
		# Check if this is a base word - if so, it's a loss
		if word_index <= _level_data.base_word_count:
			_level_failed_no_moves()
			return

		# Bonus word - move to next word
		var next_idx: int = _find_next_available_word(word_index + 1)
		if next_idx != -1:
			_advance_to_next_word(next_idx)
		else:
			# No more words - level complete (bonus words don't count against)
			_level_complete()


func _find_next_available_word(from_index: int) -> int:
	# Find next word that isn't greyed out / sand blocked
	for i in range(from_index, _word_rows.size()):
		if not _word_rows[i].is_sand_blocked() and not _word_rows[i].is_completed():
			return i
	return -1


func _level_failed_no_moves() -> void:
	_is_level_active = false
	_game_timer.stop()
	_star_bar.stop_timer()
	GameManager.last_score = _score
	GameManager.last_time_elapsed = _time_elapsed
	GameManager.last_words_solved = _words_completed
	GameManager.last_total_words = _level_data.base_word_count
	# TODO: Show "No Available Moves" message
	EventBus.level_failed.emit()


func _on_obstacle_triggered(word_index: int, obstacle_type: String) -> void:
	if obstacle_type == "sand":
		# Get the sand obstacle's affected words and scroll to show them all
		_scroll_to_show_sand_words(word_index)
	elif obstacle_type == "random_blocks":
		# Connect to block signals
		_connect_block_signals()


func _handle_breaker_boost(index: int) -> void:
	# Check if any blocks are active
	if not _obstacle_manager.has_active_blocks():
		_boost_panel.flash_boost(index)
		return

	# Mark boost as used
	var result: Dictionary = _boost_manager.use_boost(index, _current_word_index)
	if not result.used:
		return

	_boost_panel.disable_boost(index)

	# Clear all blocks
	_obstacle_manager.clear_blocks_with_boost()


func _connect_block_signals() -> void:
	var blocks_obs: RandomBlocksObstacle = _obstacle_manager.get_active_blocks_obstacle()
	if blocks_obs:
		blocks_obs.block_spawned_on_active_slot.connect(_on_block_spawned_on_active_slot)
		blocks_obs.virus_spreading.connect(_on_virus_spreading)
		blocks_obs.word_fully_blocked.connect(_on_word_fully_blocked)


func _on_block_spawned_on_active_slot(word_index: int, slot_index: int) -> void:
	# Pause the game
	_is_level_active = false
	_game_timer.stop()

	# Blink the slot red
	var word_row = _word_rows[word_index]
	var slot: LetterSlot = word_row._letter_slots[slot_index]
	_blink_slot_red(slot)

	# After blink, resume and jump caret
	await get_tree().create_timer(1.5).timeout

	# Jump caret to left-most available slot
	var new_idx: int = word_row.find_leftmost_available_slot()
	if new_idx != -1:
		word_row._current_index = new_idx
		word_row._update_caret_glow()

	# Resume game
	_is_level_active = true
	_game_timer.start()


func _blink_slot_red(slot: LetterSlot) -> void:
	var blink_count: int = 3
	for i in range(blink_count):
		slot.modulate = Color(1, 0.3, 0.3, 1)  # Red tint
		await get_tree().create_timer(0.25).timeout
		slot.modulate = Color.WHITE  # Reset to white, not original (which may have caret glow)
		await get_tree().create_timer(0.25).timeout
	# Restore proper blocked visual after blink
	slot.set_state(slot._current_state)


func _on_virus_spreading(from_word: int, to_word: int) -> void:
	# Scroll to show all infected words
	_scroll_to_show_virus_words(to_word)


func _scroll_to_show_virus_words(last_infected_word: int) -> void:
	if last_infected_word >= _word_rows.size():
		return

	# Calculate scroll to show infected words + 0.2 of next word
	var row_step := 84
	var last_word_y: int = int(_word_rows[last_infected_word].position.y)
	var container_height: int = int(_word_display.size.y)

	var target_bottom_offset: int = int(row_step * 1.2)
	var target_scroll: int = last_word_y - container_height + target_bottom_offset
	target_scroll = max(0, target_scroll)

	var current_bottom: int = _word_display.scroll_vertical + container_height
	if last_word_y + row_step <= current_bottom:
		return

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_word_display, "scroll_vertical", target_scroll, 0.5)


func _on_word_fully_blocked(word_index: int) -> void:
	# Grey out the word
	_word_rows[word_index].set_sand_blocked(true)  # Reuse sand_blocked visual

	# If this is the current word, move to next
	if word_index == _current_word_index:
		if word_index <= _level_data.base_word_count:
			_level_failed_no_moves()
			return

		var next_idx: int = _find_next_available_word(word_index + 1)
		if next_idx != -1:
			_advance_to_next_word(next_idx)
		else:
			_level_complete()


func _show_sand_clear_text(cleared: int, total: int) -> void:
	# Create temporary label to show "X/Y cleared"
	var label := Label.new()
	label.text = "%d/%d cleared" % [cleared, total]
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0))  # Light blue
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 2)

	# Add to the main control (self) so it's not clipped by scroll container
	add_child(label)

	# Position near the center-right of the word display area
	var display_rect: Rect2 = _word_display.get_global_rect()
	label.global_position = Vector2(
		display_rect.position.x + display_rect.size.x - 100,
		display_rect.position.y + display_rect.size.y / 2
	)

	# Animate: pop in, hold, fade out
	label.scale = Vector2.ZERO
	label.pivot_offset = label.size / 2
	var tween := create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2.ONE, 0.1)
	tween.tween_interval(1.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)


func _scroll_to_show_sand_words(start_word_index: int) -> void:
	# Find all words that will be affected by sand (from level data)
	var sand_config: ObstacleConfig = null
	for oc in _level_data.obstacle_configs:
		if oc.obstacle_type == "sand" and oc.word_index == start_word_index:
			sand_config = oc
			break

	if sand_config == null:
		return

	var word_indices: Array = sand_config.effect_data.get("word_indices", [])
	if word_indices.is_empty():
		var word_count: int = sand_config.effect_data.get("word_count", 3)
		for i in range(word_count):
			word_indices.append(start_word_index + i)

	if word_indices.is_empty():
		return

	# Find the last affected word
	var last_word_idx: int = word_indices.max()
	if last_word_idx >= _word_rows.size():
		last_word_idx = _word_rows.size() - 1

	# Calculate scroll to show all affected words + 0.2 of next word
	var row_step := 84  # 80px row + 4px VBoxContainer separation
	var last_word_y: int = int(_word_rows[last_word_idx].position.y)
	var container_height: int = int(_word_display.size.y)

	# Target: last affected word should be near bottom with 0.2 of next word showing
	# This means last word at position (container_height - row_step - 0.2*row_step)
	var target_bottom_offset: int = int(row_step * 1.2)  # Full row + 0.2
	var target_scroll: int = last_word_y - container_height + target_bottom_offset

	# Don't scroll past the beginning
	target_scroll = max(0, target_scroll)

	# Don't scroll if we're already showing everything needed
	var current_bottom: int = _word_display.scroll_vertical + container_height
	if last_word_y + row_step <= current_bottom:
		return

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_word_display, "scroll_vertical", target_scroll, 0.5)


## --- Bonus Mode ---

func _enter_bonus_mode() -> void:
	_in_bonus_mode = true
	_bonus_words_revealed = 0
	_bonus_words_completed = 0

	# Tell surge system to enter bonus mode
	_surge_system.enter_bonus_mode()

	# Reveal the first bonus word
	_reveal_next_bonus_word()


func _reveal_next_bonus_word() -> void:
	var first_bonus_index: int = _level_data.base_word_count + 1  # +1 for starter
	var next_bonus_index: int = first_bonus_index + _bonus_words_revealed

	if next_bonus_index >= _word_rows.size():
		# No more bonus words
		_level_complete()
		return

	var word_row = _word_rows[next_bonus_index]
	word_row.visible = true
	word_row.set_bonus_word(true)
	word_row.reveal_first_letter()
	word_row.activate()

	_bonus_words_revealed += 1
	_current_word_index = next_bonus_index

	# Scroll container to show the new bonus word
	_scroll_to_bonus_word(next_bonus_index)


func _on_bonus_word_completed() -> void:
	_bonus_words_completed += 1
	_words_completed += 1
	_score += int(BASE_SCORE * _current_multiplier)
	_update_score_display()
	_update_word_count()
	EventBus.word_completed.emit(_current_word_index)
	EventBus.score_updated.emit(_score)
	_surge_system.fill()  # Will trigger blink in bonus mode (no actual fill)

	# Check if all bonus words completed
	if _bonus_words_completed >= _level_data.bonus_word_count:
		_level_complete()
		return

	# Check if surge is still active
	if _surge_system.get_surge_value() <= 0:
		_level_complete()
		return

	# Reveal next bonus word
	_word_rows[_current_word_index].deactivate()
	_reveal_next_bonus_word()


func _on_bonus_mode_ended() -> void:
	# Surge ran out during bonus mode
	if _in_bonus_mode:
		_level_complete()


## --- Hint System ---

func _on_hint_requested() -> void:
	if not _is_level_active:
		return

	# Try to reveal a random letter in the active word
	var revealed: bool = _word_rows[_current_word_index].reveal_random_letter()
	if revealed:
		_hint_button.use_hint()
	else:
		# No letters to reveal - flash the button
		_hint_button.flash_empty()


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
