## SurgeSystem -- Manages surge momentum with per-section drain, partial bust, and multipliers.
## Drain rate is constant within each threshold section. Dropping below T3 after
## reaching it triggers a bust drain to below T1, then normal play resumes.
extends Node

var _surge_value: float = 0.0
var _config: SurgeConfig
var _current_multiplier: float = 1.0
var _was_above_t3: bool = false
var _bust_active: bool = false


func start(config: SurgeConfig) -> void:
	_config = config
	_surge_value = 0.0
	_current_multiplier = 1.0
	_was_above_t3 = false
	_bust_active = false
	_emit_surge_changed()


func fill() -> void:
	if _bust_active:
		return
	_surge_value = min(_surge_value + _config.fill_per_word, _config.max_value)
	_check_thresholds()
	_emit_surge_changed()


func _process(delta: float) -> void:
	if _config == null:
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
