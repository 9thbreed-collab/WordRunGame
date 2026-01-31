## MenuScreen -- Main menu entry point.
## Displays the game title and Play button to launch gameplay.
extends Control

@onready var _play_button: Button = %PlayButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	GameManager.transition_to(GameManager.AppState.MENU)


func _on_play_pressed() -> void:
	GameManager.change_screen("res://scenes/screens/gameplay_screen.tscn")
