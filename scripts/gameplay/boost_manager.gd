## BoostManager -- Handles boost activation and obstacle counter logic.
class_name BoostManager
extends Node

var _obstacle_manager: Node
var _loadout: Array[String] = []
var _used: Array[bool] = []


func setup(obstacle_manager: Node, loadout: Array[String]) -> void:
	_obstacle_manager = obstacle_manager
	_loadout = loadout
	_used.resize(loadout.size())
	_used.fill(false)


## Use a boost. Returns Dictionary with "used" bool and "bonus" bool.
func use_boost(index: int, current_word_index: int) -> Dictionary:
	var result := {"used": false, "bonus": false}
	if index >= _loadout.size() or _used[index]:
		return result

	var boost_id: String = _loadout[index]
	_used[index] = true
	result.used = true

	var counters := _get_counter_type(boost_id)

	if counters == "sand":
		# Sand clears globally, not per-word
		var sand_obstacles := _get_sand_obstacles()
		if sand_obstacles.size() > 0:
			for obs in sand_obstacles:
				obs.clear()
		else:
			result.bonus = true
	elif counters != "" and _obstacle_manager.has_obstacle_type(current_word_index, counters):
		_obstacle_manager.clear_obstacle(current_word_index, boost_id)
	else:
		result.bonus = true

	EventBus.boost_used.emit(boost_id, current_word_index)
	return result


func _get_counter_type(boost_id: String) -> String:
	match boost_id:
		"lock_key": return "padlock"
		"block_breaker": return "random_blocks"
		"bucket_of_water": return "sand"
	return ""


func _get_sand_obstacles() -> Array:
	var result: Array = []
	for key in _obstacle_manager._active_obstacles:
		var obs = _obstacle_manager._active_obstacles[key]
		if obs.config.obstacle_type == "sand":
			result.append(obs)
	return result


func is_boost_used(index: int) -> bool:
	return index < _used.size() and _used[index]


func get_loadout() -> Array[String]:
	return _loadout
