## AudioManager -- Global audio control with SFX pool and BGM crossfade.
## Plays sound effects via pooled AudioStreamPlayers, handles background music,
## and fires haptic feedback alongside audio cues.
extends Node

const SFX_POOL_SIZE: int = 10

var _sfx_pool: Array[AudioStreamPlayer] = []
var _bgm_a: AudioStreamPlayer
var _bgm_b: AudioStreamPlayer
var _current_bgm: AudioStreamPlayer

# Preloaded SFX streams (null if asset not yet created)
var _sfx_letter_tap: AudioStream
var _sfx_word_correct: AudioStream
var _sfx_word_incorrect: AudioStream
var _sfx_surge_threshold: AudioStream
var _sfx_surge_bust: AudioStream
var _sfx_level_complete: AudioStream


func _ready() -> void:
	# Build SFX player pool
	for i in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_pool.append(player)

	# Build BGM players
	_bgm_a = AudioStreamPlayer.new()
	_bgm_a.bus = "BGM"
	add_child(_bgm_a)

	_bgm_b = AudioStreamPlayer.new()
	_bgm_b.bus = "BGM"
	add_child(_bgm_b)

	_current_bgm = _bgm_a

	# Load SFX streams (gracefully handles missing files)
	_sfx_letter_tap = _try_load("res://assets/audio/sfx/letter_tap.wav")
	_sfx_word_correct = _try_load("res://assets/audio/sfx/word_correct.wav")
	_sfx_word_incorrect = _try_load("res://assets/audio/sfx/word_incorrect.wav")
	_sfx_surge_threshold = _try_load("res://assets/audio/sfx/surge_threshold.wav")
	_sfx_surge_bust = _try_load("res://assets/audio/sfx/surge_bust.wav")
	_sfx_level_complete = _try_load("res://assets/audio/sfx/level_complete.wav")

	# Wire EventBus signals
	EventBus.letter_input.connect(_on_letter_input)
	EventBus.word_completed.connect(_on_word_completed)
	EventBus.word_incorrect.connect(_on_word_incorrect)
	EventBus.surge_threshold_crossed.connect(_on_surge_threshold)
	EventBus.surge_bust.connect(_on_surge_bust)
	EventBus.level_completed.connect(_on_level_completed)


func _try_load(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path)
	return null


func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	for player in _sfx_pool:
		if not player.playing:
			player.stream = stream
			player.play()
			return


func play_bgm(stream: AudioStream) -> void:
	if stream == null:
		return
	var next: AudioStreamPlayer = _bgm_b if _current_bgm == _bgm_a else _bgm_a
	next.stream = stream
	next.volume_db = -40.0
	next.play()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_current_bgm, "volume_db", -40.0, 1.0)
	tween.tween_property(next, "volume_db", 0.0, 1.0)
	tween.chain().tween_callback(func():
		_current_bgm.stop()
		_current_bgm = next
	)


func stop_bgm() -> void:
	var tween := create_tween()
	tween.tween_property(_current_bgm, "volume_db", -40.0, 0.5)
	tween.tween_callback(func(): _current_bgm.stop())


# --- Signal handlers ---

func _on_letter_input(_letter: String, _correct: bool) -> void:
	play_sfx(_sfx_letter_tap)
	Input.vibrate_handheld(30)


func _on_word_completed(_word_index: int) -> void:
	play_sfx(_sfx_word_correct)
	Input.vibrate_handheld(100)


func _on_word_incorrect() -> void:
	play_sfx(_sfx_word_incorrect)
	Input.vibrate_handheld(200)


func _on_surge_threshold(_new_multiplier: float) -> void:
	play_sfx(_sfx_surge_threshold)
	Input.vibrate_handheld(150)


func _on_surge_bust() -> void:
	play_sfx(_sfx_surge_bust)
	Input.vibrate_handheld(400)


func _on_level_completed() -> void:
	play_sfx(_sfx_level_complete)
	Input.vibrate_handheld(200)
