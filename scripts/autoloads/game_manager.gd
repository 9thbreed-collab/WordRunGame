## GameManager -- App state machine with enum-based transitions.
## Tracks the current application state and emits transitions via EventBus.
extends Node

enum AppState {
	LOADING,
	AUTH,
	MENU,
	PLAYING,
	PAUSED,
	RESULTS,
	STORE,
}

var current_state: AppState = AppState.LOADING
var last_score: int = 0
var last_time_elapsed: int = 0


func _ready() -> void:
	EventBus.level_completed.connect(_on_level_completed)
	EventBus.level_failed.connect(_on_level_failed)


## Transitions to a new app state. Emits EventBus.app_state_changed with
## string representations of the old and new states, then runs entry logic.
func transition_to(new_state: AppState) -> void:
	var old_state := current_state
	current_state = new_state
	var old_name: String = AppState.keys()[old_state]
	var new_name: String = AppState.keys()[new_state]
	EventBus.app_state_changed.emit(old_name, new_name)
	print("GameManager: %s -> %s" % [old_name, new_name])
	_handle_state_entry(new_state)


## Per-state entry logic. Each case is a stub for future implementation.
func _handle_state_entry(state: AppState) -> void:
	match state:
		AppState.LOADING:
			pass
		AppState.AUTH:
			pass
		AppState.MENU:
			pass
		AppState.PLAYING:
			pass
		AppState.PAUSED:
			pass
		AppState.RESULTS:
			pass
		AppState.STORE:
			pass


## Changes the active scene and emits EventBus.screen_changed.
func change_screen(scene_path: String) -> void:
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("GameManager: Failed to change scene to '%s'. Error: %d" % [scene_path, err])
		return
	var screen_name := scene_path.get_file().get_basename()
	EventBus.screen_changed.emit(screen_name)


## Handles level completion by transitioning to results screen.
func _on_level_completed() -> void:
	transition_to(AppState.RESULTS)
	change_screen("res://scenes/screens/results_screen.tscn")


## Handles level failure by transitioning to results screen.
func _on_level_failed() -> void:
	transition_to(AppState.RESULTS)
	change_screen("res://scenes/screens/results_screen.tscn")
