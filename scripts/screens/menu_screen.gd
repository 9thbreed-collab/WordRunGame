## MenuScreen -- Main menu entry point.
## Displays the game title and Play button to launch gameplay.
extends Control

@onready var _play_button: Button = %PlayButton
@onready var _level_selector: OptionButton = %LevelSelector


func _ready() -> void:
	_play_button.pressed.connect(_on_play_pressed)
	GameManager.transition_to(GameManager.AppState.MENU)
	_populate_level_selector()


func _populate_level_selector() -> void:
	_level_selector.clear()
	var level_count: int = ContentCache.get_level_count("corinthia")
	for i in range(level_count):
		_level_selector.add_item("Level %d" % (i + 1), i)
	_level_selector.selected = 0


func _on_play_pressed() -> void:
	GameManager.selected_land = "corinthia"
	GameManager.selected_level = _level_selector.selected
	GameManager.change_screen("res://scenes/screens/gameplay_screen.tscn")
