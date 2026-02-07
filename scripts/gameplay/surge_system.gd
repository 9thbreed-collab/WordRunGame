## SurgeSystem -- Manages surge momentum with per-section drain, partial bust, and multipliers.
## Drain rate is constant within each threshold section. Dropping below T3 after
## reaching it triggers a bust drain to below T1, then normal play resumes.
## In bonus mode, bar turns purple and drains over 50 seconds total.
extends Node

const BONUS_MODE_TOTAL_TIME: float = 50.0

var _surge_value: float = 0.0
var _config: SurgeConfig
var _current_multiplier: float = 1.0
var _was_above_t3: bool = false
var _bust_active: bool = false
var _bonus_mode: bool = false
var _bonus_start_value: float = 0.0  # Surge value when bonus mode started


func start(config: SurgeConfig) -> void:
	_config = config
	_surge_value = 0.0
	_current_multiplier = 1.0
	_was_above_t3 = false
	_bust_active = false
	_bonus_mode = false
	_bonus_start_value = 0.0
	_emit_surge_changed()


func fill() -> void:
	if _bust_active:
		return
	if _bonus_mode:
		# In bonus mode, don't fill - just blink
		EventBus.bonus_mode_blink.emit()
		return
	_surge_value = min(_surge_value + _config.fill_per_word, _config.max_value)
	_check_thresholds()
	_emit_surge_changed()


## Check if surge is above the bonus threshold (60% / second threshold)
func is_above_bonus_threshold() -> bool:
	if _config == null or _config.thresholds.size() < 2:
		return false
	return _surge_value >= _config.thresholds[1]  # Second threshold (60%)


## Enter bonus mode - purple bar, drain-only, 50 second total time
func enter_bonus_mode() -> void:
	_bonus_mode = true
	_bonus_start_value = _surge_value
	_bust_active = false  # Disable bust in bonus mode
	EventBus.bonus_mode_entered.emit()


## Check if currently in bonus mode
func is_bonus_mode() -> bool:
	return _bonus_mode


## Get current surge value (for external checks)
func get_surge_value() -> float:
	return _surge_value


func _process(delta: float) -> void:
	if _config == null:
		return

	# Bonus mode: linear drain over 50 seconds total
	if _bonus_mode:
		# Drain rate = starting value / 50 seconds
		var drain_rate: float = _bonus_start_value / BONUS_MODE_TOTAL_TIME
		_surge_value = max(0.0, _surge_value - drain_rate * delta)
		_check_thresholds()  # Multiplier still applies
		_emit_surge_changed()
		if _surge_value <= 0.0:
			EventBus.bonus_mode_ended.emit()
		return

	if _bust_active:
		_surge_value = max(0.0, _surge_value - _config.bust_drain_rate * delta)
		if _surge_value <= _config.thresholds[0]:
			_bust_active = false
			_was_above_t3 = false
			_surge_value = max(0.0, _config.thresholds[0] - 0.1)
		_check_thresholds()
		_emit_surge_changed()
		return

	# Normal section-based drain
	var section := _get_section()
	var drain_rate := _get_drain_rate(section)
	_surge_value = max(0.0, _surge_value - drain_rate * delta)

	# Check bust: was above T3 and dropped below it
	if _was_above_t3 and _surge_value < _get_t3():
		_trigger_bust()
		_emit_surge_changed()
		return

	_check_thresholds()
	_emit_surge_changed()


func _get_section() -> int:
	for i in range(_config.thresholds.size() - 1, -1, -1):
		if _surge_value >= _config.thresholds[i]:
			return i + 1
	return 0


func _get_drain_rate(section: int) -> float:
	var idx: int = min(section, _config.section_drain_times.size() - 1)
	var drain_time: float = _config.section_drain_times[idx]
	if drain_time <= 0.0:
		return 0.0
	return _get_section_width(idx) / drain_time


func _get_section_width(section: int) -> float:
	var bottom: float = 0.0 if section == 0 else _config.thresholds[section - 1]
	var top: float
	if section >= _config.thresholds.size():
		top = _config.max_value
	else:
		top = _config.thresholds[section]
	return top - bottom


func _get_t3() -> float:
	return _config.thresholds[-1] if _config.thresholds.size() > 0 else _config.max_value


func _check_thresholds() -> void:
	var previous_multiplier := _current_multiplier
	_current_multiplier = _get_multiplier()

	if _surge_value >= _get_t3():
		_was_above_t3 = true

	if _current_multiplier != previous_multiplier:
		EventBus.surge_threshold_crossed.emit(_current_multiplier)


func _get_multiplier() -> float:
	if _config.multipliers.size() == 0:
		return 1.0
	var bracket: int = 0
	for i in range(_config.thresholds.size()):
		if _surge_value >= _config.thresholds[i]:
			bracket = i + 1
		else:
			break
	return _config.multipliers[min(bracket, _config.multipliers.size() - 1)]


func _trigger_bust() -> void:
	_bust_active = true
	EventBus.surge_bust.emit()


func _emit_surge_changed() -> void:
	EventBus.surge_changed.emit(_surge_value, _config.max_value)
