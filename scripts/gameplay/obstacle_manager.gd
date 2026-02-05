## ObstacleManager -- Spawns, tracks, and clears obstacles during gameplay.
## Sits in GameplayScreen and manages obstacle lifecycle.
class_name ObstacleManager
extends Node

var _active_obstacles: Dictionary = {}  ## word_index -> ObstacleBase
var _level_obstacles: Array[ObstacleConfig] = []
var _word_rows: Array = []


func load_level_obstacles(level_data: LevelData, word_rows: Array) -> void:
	_word_rows = word_rows
	_level_obstacles = []
	for oc in level_data.obstacle_configs:
		_level_obstacles.append(oc)

	# Activate any "level_start" obstacles immediately
	for oc in _level_obstacles:
		if oc.trigger_type == "level_start":
			_spawn_obstacle(oc)


## Called when a word becomes active. Checks if any obstacles should trigger.
func check_trigger(word_index: int, trigger_type: String) -> void:
	for oc in _level_obstacles:
		if oc.word_index == word_index and oc.trigger_type == trigger_type:
			if not _active_obstacles.has(word_index):
				_spawn_obstacle(oc)


func _spawn_obstacle(oc: ObstacleConfig) -> void:
	var obstacle := _create_obstacle(oc)
	if obstacle == null:
		return

	var word_row = _get_word_row(oc.word_index)
	if word_row == null:
		obstacle.queue_free()
		return

	if oc.obstacle_type == "sand":
		obstacle.setup_multi(oc, _word_rows)
	else:
		obstacle.setup(oc, word_row)
	_active_obstacles[oc.word_index] = obstacle
	add_child(obstacle)

	if oc.delay_seconds > 0.0:
		await get_tree().create_timer(oc.delay_seconds).timeout

	obstacle.activate()


func _create_obstacle(oc: ObstacleConfig) -> ObstacleBase:
	match oc.obstacle_type:
		"padlock":
			return PadlockObstacle.new()
		"random_blocks":
			return RandomBlocksObstacle.new()
		"sand":
			return SandObstacle.new()
		_:
			push_warning("ObstacleManager: Unknown obstacle type: " + oc.obstacle_type)
			return null


func _get_word_row(word_index: int):
	if word_index >= 0 and word_index < _word_rows.size():
		return _word_rows[word_index]
	return null


## Clear the obstacle at a given word index.
func clear_obstacle(word_index: int, _boost_type: String = "") -> void:
	if _active_obstacles.has(word_index):
		var obstacle: ObstacleBase = _active_obstacles[word_index]
		obstacle.clear()
		obstacle.queue_free()
		_active_obstacles.erase(word_index)


## Check if a word has any active obstacle.
func has_obstacle(word_index: int) -> bool:
	return _active_obstacles.has(word_index)


## Check if a word has an obstacle of a specific type.
func has_obstacle_type(word_index: int, obstacle_type: String) -> bool:
	if _active_obstacles.has(word_index):
		var obstacle: ObstacleBase = _active_obstacles[word_index]
		return obstacle.config.obstacle_type == obstacle_type
	return false


## Get the active obstacle at a word index (or null).
func get_obstacle(word_index: int) -> ObstacleBase:
	return _active_obstacles.get(word_index, null)


## Find word index of any active padlock obstacle. Returns -1 if none found.
func find_padlock_word() -> int:
	for word_index in _active_obstacles:
		var obstacle: ObstacleBase = _active_obstacles[word_index]
		if obstacle.config.obstacle_type == "padlock":
			return word_index
	return -1


## Check if any sand obstacle is currently active
func has_active_sand() -> bool:
	for word_index in _active_obstacles:
		var obstacle: ObstacleBase = _active_obstacles[word_index]
		if obstacle.config.obstacle_type == "sand":
			var sand_obs: SandObstacle = obstacle as SandObstacle
			if sand_obs and sand_obs.is_active():
				return true
	return false


## Get all sanded slots within the next N words from current position
func get_sanded_slots_in_range(from_word: int, range_count: int) -> Array:
	var result: Array = []  # Array of {word_idx, slot_idx}
	for word_index in _active_obstacles:
		var obstacle: ObstacleBase = _active_obstacles[word_index]
		if obstacle.config.obstacle_type == "sand":
			var sand_obs: SandObstacle = obstacle as SandObstacle
			if sand_obs:
				var sanded_slots: Dictionary = sand_obs.get_sanded_slots()
				for word_idx in sanded_slots:
					if word_idx >= from_word and word_idx < from_word + range_count:
						result.append({"word_idx": word_idx, "slot_idx": sanded_slots[word_idx], "obstacle": sand_obs})
	return result


## Clear specific sanded slots
func clear_sanded_slots(slots_to_clear: Array) -> void:
	for slot_info in slots_to_clear:
		var sand_obs: SandObstacle = slot_info.obstacle
		sand_obs.clear_slot(slot_info.word_idx, slot_info.slot_idx)


## Clear sand using the water boost - clears up to 3 from active + pending. Returns {cleared, total}.
func clear_sand_with_boost() -> Dictionary:
	for word_index in _active_obstacles:
		var obstacle: ObstacleBase = _active_obstacles[word_index]
		if obstacle.config.obstacle_type == "sand":
			var sand_obs: SandObstacle = obstacle as SandObstacle
			if sand_obs and sand_obs.is_active():
				return sand_obs.clear_with_count()
	return {"cleared": 0, "total": 0}
