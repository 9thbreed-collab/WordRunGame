## SurgeBar -- Visual surge momentum bar with threshold markers and dynamic color.
## Fill color transitions through green → yellow → orange → red per section.
extends Control

@onready var _progress_bar: ProgressBar = %ProgressBar

var _config: SurgeConfig
var _threshold_markers: Array[ColorRect] = []
var _imminent_tween: Tween

const SECTION_COLORS: Array[Color] = [
	Color(0.298, 0.686, 0.314),  # Green  (section 0)
	Color(0.95, 0.85, 0.2),     # Yellow (section 1)
	Color(0.95, 0.55, 0.15),    # Orange (section 2)
	Color(0.9, 0.2, 0.2),       # Red    (section 3)
]

var _current_section: int = -1
var _fill_style: StyleBoxFlat


func _ready() -> void:
	EventBus.surge_changed.connect(_on_surge_changed)
	EventBus.surge_threshold_crossed.connect(_on_threshold_crossed)
	EventBus.surge_bust.connect(_on_bust)

	# Create mutable fill style
	_fill_style = StyleBoxFlat.new()
	_fill_style.bg_color = SECTION_COLORS[0]
	_fill_style.corner_radius_top_left = 4
	_fill_style.corner_radius_top_right = 4
	_fill_style.corner_radius_bottom_left = 4
	_fill_style.corner_radius_bottom_right = 4
	_progress_bar.add_theme_stylebox_override("fill", _fill_style)


func setup(config: SurgeConfig) -> void:
	_config = config
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = config.max_value
	_progress_bar.value = 0.0
	_current_section = 0
	_update_fill_color(0)

	_clear_markers()
	for threshold in config.thresholds:
		var marker := ColorRect.new()
		marker.color = Color(1.0, 1.0, 1.0, 0.6)
		marker.custom_minimum_size = Vector2(2, 0)
		marker.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_progress_bar.add_child(marker)
		_threshold_markers.append(marker)

	# Position markers after layout settles
	_progress_bar.sort_children.connect(_position_markers)


func _position_markers() -> void:
	if _config == null:
		return
	for i in range(_threshold_markers.size()):
		var pct: float = _config.thresholds[i] / _config.max_value
		var marker: ColorRect = _threshold_markers[i]
		marker.position.x = pct * _progress_bar.size.x
		marker.size = Vector2(2, _progress_bar.size.y)


func _on_surge_changed(current_value: float, max_value: float) -> void:
	_progress_bar.value = current_value

	# Determine section and update color
	var section := _calc_section(current_value)
	if section != _current_section:
		_current_section = section
		_update_fill_color(section)

		# Start/stop imminent pulse at top section
		if _config and section >= _config.thresholds.size():
			_start_imminent_pulse()
		else:
			_stop_imminent_pulse()


func _calc_section(value: float) -> int:
	if _config == null:
		return 0
	for i in range(_config.thresholds.size() - 1, -1, -1):
		if value >= _config.thresholds[i]:
			return i + 1
	return 0


func _update_fill_color(section: int) -> void:
	var idx: int = min(section, SECTION_COLORS.size() - 1)
	var target_color: Color = SECTION_COLORS[idx]
	var tween := create_tween()
	tween.tween_property(_fill_style, "bg_color", target_color, 0.3)


func _on_threshold_crossed(_new_multiplier: float) -> void:
	pivot_offset = size / 2.0
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.08, 1.08), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT)


func _on_bust() -> void:
	# Red flash on the bar (value drain handled by SurgeSystem)
	var t := create_tween()
	t.tween_property(_progress_bar, "modulate", Color(1.0, 0.3, 0.3, 1.0), 0.15)
	t.tween_property(_progress_bar, "modulate", Color.WHITE, 0.3)
	_stop_imminent_pulse()


func _start_imminent_pulse() -> void:
	_stop_imminent_pulse()
	pivot_offset = size / 2.0
	_imminent_tween = create_tween()
	_imminent_tween.set_loops()
	_imminent_tween.tween_property(self, "scale", Vector2(1.03, 1.03), 0.3).set_trans(Tween.TRANS_SINE)
	_imminent_tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SINE)


func _stop_imminent_pulse() -> void:
	if _imminent_tween and _imminent_tween.is_running():
		_imminent_tween.kill()
		_imminent_tween = null
		scale = Vector2.ONE


func _clear_markers() -> void:
	for marker in _threshold_markers:
		marker.queue_free()
	_threshold_markers.clear()
