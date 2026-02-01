## SurgeBar -- Visual surge momentum bar with threshold markers.
## Updates smoothly via tweens when surge value changes.
extends Control

@onready var _progress_bar: ProgressBar = %ProgressBar

var _config: SurgeConfig
var _threshold_markers: Array[ColorRect] = []


func _ready() -> void:
	EventBus.surge_changed.connect(_on_surge_changed)


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


func _clear_markers() -> void:
	for marker in _threshold_markers:
		marker.queue_free()
	_threshold_markers.clear()
