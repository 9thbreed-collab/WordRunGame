## SurgeSystem -- Manages surge momentum mechanics (fill, drain, thresholds, bust).
## Node child of GameplayScreen. Tracks surge value, state transitions, and multiplier levels.
extends Node

enum State {
	IDLE,       ## Normal drain state before any activity
	FILLING,    ## Actively filling from word completions
	IMMINENT,   ## Past final threshold, faster drain, one mistake = bust
	BUSTED      ## Surge busted, draining to zero, no longer active
}

var _surge_value: float = 0.0
var _config: SurgeConfig
var _state: State = State.IDLE
var _current_multiplier: float = 1.0
var _was_imminent: bool = false  ## Tracks if we entered imminent zone


func start(config: SurgeConfig) -> void:
	_config = config
	_surge_value = 0.0
	_state = State.IDLE
	_current_multiplier = 1.0
	_was_imminent = false
	_emit_surge_changed()


func fill() -> void:
	if _state == State.BUSTED:
		return  ## No fills after bust

	_surge_value = min(_surge_value + _config.fill_per_word, _config.max_value)
	_state = State.FILLING
	_check_thresholds()
	_emit_surge_changed()


func _process(delta: float) -> void:
	if _config == null:
		return

	# Drain logic based on state
	match _state:
		State.BUSTED:
			# Tween drain to zero (handled by bust logic, no active drain here)
			pass
		State.IMMINENT:
			_surge_value = max(0.0, _surge_value - _config.imminent_drain_rate * delta)
			_check_bust()
		State.IDLE, State.FILLING:
			_surge_value = max(0.0, _surge_value - _config.idle_drain_rate * delta)
			# Check if we dropped below thresholds
			_check_thresholds()

	_emit_surge_changed()


func _check_thresholds() -> void:
	var previous_multiplier: float = _current_multiplier
	_current_multiplier = get_multiplier()

	# Check if we entered imminent zone (past final threshold)
	if _config.thresholds.size() > 0:
		var final_threshold: float = _config.thresholds[-1]
		if _surge_value >= final_threshold:
			if _state != State.IMMINENT:
				_state = State.IMMINENT
				_was_imminent = true

	# Emit signal if multiplier changed
	if _current_multiplier != previous_multiplier:
		EventBus.surge_threshold_crossed.emit(_current_multiplier)


func _check_bust() -> void:
	# Bust condition: was in imminent zone and dropped below final threshold
	if _was_imminent and _config.thresholds.size() > 0:
		var final_threshold: float = _config.thresholds[-1]
		if _surge_value < final_threshold:
			_trigger_bust()


func _trigger_bust() -> void:
	_state = State.BUSTED
	EventBus.surge_bust.emit()

	# Tween drain to zero
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "_surge_value", 0.0, 0.8)


func get_multiplier() -> float:
	# Determine current multiplier based on surge value and thresholds
	if _config.thresholds.size() == 0:
		return _config.multipliers[0] if _config.multipliers.size() > 0 else 1.0

	# Find which threshold bracket we're in
	var bracket_index: int = 0
	for i in range(_config.thresholds.size()):
		if _surge_value >= _config.thresholds[i]:
			bracket_index = i + 1
		else:
			break

	# Return corresponding multiplier
	if bracket_index < _config.multipliers.size():
		return _config.multipliers[bracket_index]
	else:
		return _config.multipliers[-1] if _config.multipliers.size() > 0 else 1.0


func _emit_surge_changed() -> void:
	EventBus.surge_changed.emit(_surge_value, _config.max_value)
