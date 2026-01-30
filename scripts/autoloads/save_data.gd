## SaveData -- Local persistence stub and FeatureFlags loader.
## Loads or creates the FeatureFlags resource on startup.
## save_game / load_game are stubs for future implementation.
extends Node

const SAVE_PATH := "user://save_data.tres"
const FLAGS_PATH := "user://feature_flags.tres"


func _ready() -> void:
	_load_feature_flags()


## Loads feature flags from disk, or creates a new default resource if
## none exists. Assigns the loaded resource to FeatureFlags.instance.
func _load_feature_flags() -> void:
	if ResourceLoader.exists(FLAGS_PATH):
		var flags: FeatureFlags = ResourceLoader.load(FLAGS_PATH) as FeatureFlags
		if flags:
			FeatureFlags.instance = flags
			print("SaveData: Loaded feature flags from %s" % FLAGS_PATH)
			return

	# No saved flags found -- create defaults and save.
	var flags := FeatureFlags.new()
	FeatureFlags.instance = flags
	_save_feature_flags()
	print("SaveData: Created default feature flags at %s" % FLAGS_PATH)


## Persists the current FeatureFlags resource to disk.
func _save_feature_flags() -> void:
	if FeatureFlags.instance == null:
		push_warning("SaveData: No FeatureFlags instance to save.")
		return
	var err := ResourceSaver.save(FeatureFlags.instance, FLAGS_PATH)
	if err != OK:
		push_error("SaveData: Failed to save feature flags. Error code: %d" % err)


## Stub -- will persist full game data in a future plan.
func save_game() -> void:
	pass


## Stub -- will load full game data in a future plan.
func load_game() -> void:
	pass
