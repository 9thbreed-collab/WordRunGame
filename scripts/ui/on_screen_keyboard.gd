## OnScreenKeyboard -- QWERTY layout keyboard with DEL key.
## Emits key_pressed signal when any key is tapped.
extends VBoxContainer

signal key_pressed(key: String)


func _ready() -> void:
	_connect_all_buttons()


func _connect_all_buttons() -> void:
	# Iterate through all HBoxContainer rows
	for row in get_children():
		if row is HBoxContainer:
			# Iterate through all Button children in this row
			for button in row.get_children():
				if button is Button:
					button.pressed.connect(_on_button_pressed.bind(button.text))


func _on_button_pressed(key: String) -> void:
	key_pressed.emit(key)
