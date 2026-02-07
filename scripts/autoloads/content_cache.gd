## ContentCache -- Manages loading and caching level content from JSON.
## Loads from baseline bundled content or user cache (for future cloud updates).
extends Node

const BASELINE_DIR = "res://data/baseline/"
const CACHE_DIR = "user://content_cache/"

var _land_cache: Dictionary = {}  # land_id -> parsed JSON data


func _ready() -> void:
	_ensure_cache_dir()


func _ensure_cache_dir() -> void:
	if not DirAccess.dir_exists_absolute(CACHE_DIR):
		DirAccess.make_dir_recursive_absolute(CACHE_DIR)


## Load a land's content. Checks user cache first, falls back to baseline.
func load_land(land_id: String) -> Dictionary:
	if _land_cache.has(land_id):
		return _land_cache[land_id]

	var data := _try_load_json(CACHE_DIR + land_id + ".json")
	if data.is_empty():
		data = _try_load_json(BASELINE_DIR + land_id + ".json")

	if not data.is_empty():
		_land_cache[land_id] = data
	return data


## Build a LevelData resource from JSON level entry
func build_level_data(level_json: Dictionary) -> LevelData:
	var level := LevelData.new()
	level.level_name = level_json.get("level_name", "")
	level.time_limit_seconds = level_json.get("time_limit_seconds", 180)
	level.base_word_count = level_json.get("base_word_count", 12)
	level.bonus_word_count = level_json.get("bonus_word_count", 3)

	# Build word pairs
	var pairs_json: Array = level_json.get("word_pairs", [])
	for pair_data in pairs_json:
		var wp := WordPair.new()
		wp.word_a = pair_data.get("word_a", "")
		wp.word_b = pair_data.get("word_b", "")
		level.word_pairs.append(wp)

	# Build surge config
	var surge_json: Dictionary = level_json.get("surge_config", {})
	if not surge_json.is_empty():
		var sc := SurgeConfig.new()
		sc.max_value = surge_json.get("max_value", 100.0)
		sc.fill_per_word = surge_json.get("fill_per_word", 15.0)
		sc.thresholds = Array(surge_json.get("thresholds", [30.0, 60.0, 80.0]), TYPE_FLOAT, "", null)
		sc.section_drain_times = Array(surge_json.get("section_drain_times", [15.3, 9.35, 5.95, 4.25]), TYPE_FLOAT, "", null)
		sc.bust_drain_rate = surge_json.get("bust_drain_rate", 25.0)
		sc.multipliers = Array(surge_json.get("multipliers", [1.0, 1.5, 2.0, 3.0]), TYPE_FLOAT, "", null)
		level.surge_config = sc

	# Build obstacle configs
	var obstacles_json: Array = level_json.get("obstacle_configs", [])
	for obs_data in obstacles_json:
		var oc := ObstacleConfig.new()
		oc.obstacle_type = obs_data.get("obstacle_type", "")
		oc.display_name = obs_data.get("display_name", oc.obstacle_type)
		oc.word_index = obs_data.get("word_index", 0)
		oc.trigger_type = obs_data.get("trigger_type", "word_start")
		oc.delay_seconds = obs_data.get("delay_seconds", 0.0)
		oc.effect_data = obs_data.get("effect_data", {})
		level.obstacle_configs.append(oc)

	return level


## Get level count for a land
func get_level_count(land_id: String) -> int:
	var data := load_land(land_id)
	return data.get("levels", []).size()


## Get specific level JSON from a land
func get_level_json(land_id: String, level_index: int) -> Dictionary:
	var data := load_land(land_id)
	var levels: Array = data.get("levels", [])
	if level_index < levels.size():
		return levels[level_index]
	return {}


## Clear the cache for a specific land (used when cloud update arrives)
func invalidate_land(land_id: String) -> void:
	_land_cache.erase(land_id)


## Clear entire cache
func clear_cache() -> void:
	_land_cache.clear()


func _try_load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_warning("ContentCache: Failed to parse JSON at " + path)
		return {}
	if json.data is Dictionary:
		return json.data
	return {}
