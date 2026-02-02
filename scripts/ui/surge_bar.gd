## SurgeBar -- Visual surge momentum bar with threshold markers.
## Updates smoothly via tweens when surge value changes.
extends Control

@onready var _progress_bar: ProgressBar = %ProgressBar

var _config: SurgeConfig
var _threshold_markers: Array[ColorRect] = []


var _imminent_tween: Tween


func _ready() -> void:
	EventBus.surge_changed.connect(_on_surge_changed)
	EventBus.surge_threshold_crossed.connect(_on_threshold_crossed)
	EventBus.surge_bust.connect(_on_bust)


func setup(config: SurgeConfig) -> void:
	_config = config
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = config.max_value
	_progress_bar.value = 0.0

	# Create threshold markers
	_clear_markers()
	for threshold in config.thresholds:
		var marker: ColorRect = ColorRect.new()
		marker.color = Color(1.0, 1.0, 1.0, 0.6)  # Semi-transparent white
		marker.size = Vector2(2, _progress_bar.size.y)

		# Position marker at threshold percentage
		var percentage: float = threshold / config.max_value
		marker.position.x = percentage * _progress_bar.size.x

		_progress_bar.add_child(marker)
		_threshold_markers.append(marker)


func update_value(current: float, max_val: float) -> void:
	# Smooth tween to new value
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_progress_bar, "value", current, 0.2)


func _on_surge_changed(current_value: float, max_value: float) -> void:
	update_value(current_value, max_value)


func _on_threshold_crossed(_new_multiplier: float) -> void:
	pivot_offset = size / 2.0
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.08, 1.08), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT)
	# Brief brightness flash
	var c := create_tween()
	c.tween_property(_progress_bar, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.1)
	c.tween_property(_progress_bar, "modulate", Color.WHITE, 0.2)


func _on_bust() -> void:
	# Flash red then drain
	var t := create_tween()
	t.tween_property(_progress_bar, "modulate", Color(1.0, 0.3, 0.3, 1.0), 0.15)
	t.tween_property(_progress_bar, "value", 0.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	t.tween_property(_progress_bar, "modulate", Color.WHITE, 0.2)
	_stop_imminent_pulse()


func start_imminent_pulse() -> void:
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
