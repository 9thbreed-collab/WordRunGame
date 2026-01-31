## ResultsScreen -- Post-level results display.
## Shows win/lose state, stats, and navigation options to replay or return to menu.
extends Control

@onready var _result_label: Label = %ResultLabel
@onready var _words_solved_label: Label = %WordsSolvedLabel
@onready var _time_taken_label: Label = %TimeTakenLabel
@onready var _play_again_button: Button = %PlayAgainButton
@onready var _main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	_play_again_button.pressed.connect(_on_play_again_pressed)
	_main_menu_button.pressed.connect(_on_main_menu_pressed)
	GameManager.transition_to(GameManager.AppState.RESULTS)


func _on_play_again_pressed() -> void:
	GameManager.change_screen("res://scenes/screens/gameplay_screen.tscn")


func _on_main_menu_pressed() -> void:
	GameManager.change_screen("res://scenes/screens/menu_screen.tscn")
