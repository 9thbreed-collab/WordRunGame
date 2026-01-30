## FeatureFlags -- Boolean feature flag system with static access.
## Allows toggling features (ads, IAP, individual ad types) at runtime
## without code changes. Persisted as a Resource file.
class_name FeatureFlags
extends Resource

# --- Singleton instance (set by SaveData on startup) ---
static var instance: FeatureFlags

# --- Exported flag properties ---
@export var ads_enabled: bool = true
@export var iap_enabled: bool = true
@export var banner_ads_enabled: bool = true
@export var interstitial_ads_enabled: bool = true
@export var rewarded_ads_enabled: bool = true


## Returns the value of a named flag. Falls back to false if the flag
## name does not match a known property or if no instance is loaded.
static func get_flag(flag_name: String) -> bool:
	if instance == null:
		push_warning("FeatureFlags: No instance loaded. Returning false for '%s'." % flag_name)
		return false
	if not flag_name in ["ads_enabled", "iap_enabled", "banner_ads_enabled",
			"interstitial_ads_enabled", "rewarded_ads_enabled"]:
		push_warning("FeatureFlags: Unknown flag '%s'. Returning false." % flag_name)
		return false
	return instance.get(flag_name)


## Sets the value of a named flag and emits EventBus.feature_flag_changed.
## Does nothing if the flag name is unknown or no instance is loaded.
static func set_flag(flag_name: String, value: bool) -> void:
	if instance == null:
		push_warning("FeatureFlags: No instance loaded. Cannot set '%s'." % flag_name)
		return
	if not flag_name in ["ads_enabled", "iap_enabled", "banner_ads_enabled",
			"interstitial_ads_enabled", "rewarded_ads_enabled"]:
		push_warning("FeatureFlags: Unknown flag '%s'. Cannot set." % flag_name)
		return
	instance.set(flag_name, value)
	EventBus.feature_flag_changed.emit(flag_name, value)
