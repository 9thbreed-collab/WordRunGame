## BoostPanel -- In-game boost buttons. Emits boost_pressed(index) on tap.
extends HBoxContainer

signal boost_pressed(index: int)

var _buttons: Array[Button] = []


func setup(loadout: Array[String]) -> void:
	for child in get_children():
		child.queue_free()
	_buttons.clear()

	for i in range(loadout.size()):
		var btn := Button.new()
		btn.text = _get_display_name(loadout[i])
		btn.custom_minimum_size = Vector2(100, 40)
		btn.pressed.connect(_on_button_pressed.bind(i))
		add_child(btn)
		_buttons.append(btn)


func disable_boost(index: int) -> void:
	if index < _buttons.size():
		_buttons[index].disabled = true
		_buttons[index].modulate = Color(0.5, 0.5, 0.5, 0.6)


func flash_boost(index: int) -> void:
	if index >= _buttons.size():
		return
	var btn := _buttons[index]
	var original_modulate := btn.modulate
	btn.modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.12).timeout
	btn.modulate = original_modulate


func _on_button_pressed(index: int) -> void:
	boost_pressed.emit(index)


func _get_display_name(boost_id: String) -> String:
	match boost_id:
		"lock_key": return "Key"
		"block_breaker": return "Breaker"
		"bucket_of_water": return "Water"
	return boost_id
