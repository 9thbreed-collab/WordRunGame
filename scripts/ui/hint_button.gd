## HintButton -- Lightbulb hint button with remaining hints badge.
class_name HintButton
extends Control

signal hint_requested

const MAX_HINTS: int = 3

@onready var _button: Button = $Button
@onready var _badge: Label = $Badge

var _hints_remaining: int = MAX_HINTS


func _ready() -> void:
	_button.pressed.connect(_on_button_pressed)
	_update_badge()


func reset() -> void:
	_hints_remaining = MAX_HINTS
	_button.disabled = false
	_update_badge()


func use_hint() -> bool:
	if _hints_remaining <= 0:
		return false
	_hints_remaining -= 1
	_update_badge()
	if _hints_remaining <= 0:
		_button.disabled = true
	return true


func get_hints_remaining() -> int:
	return _hints_remaining


func _update_badge() -> void:
	_badge.text = str(_hints_remaining)
	if _hints_remaining <= 0:
		_badge.modulate = Color(0.5, 0.5, 0.5, 0.8)
	else:
		_badge.modulate = Color(1, 1, 1, 1)


func _on_button_pressed() -> void:
	if _hints_remaining > 0:
		hint_requested.emit()


func flash_empty() -> void:
	var original_color: Color = _button.modulate
	var tween := create_tween()
	tween.tween_property(_button, "modulate", Color(1, 0.3, 0.3, 1), 0.1)
	tween.tween_property(_button, "modulate", original_color, 0.1)
	tween.tween_property(_button, "modulate", Color(1, 0.3, 0.3, 1), 0.1)
	tween.tween_property(_button, "modulate", original_color, 0.1)
