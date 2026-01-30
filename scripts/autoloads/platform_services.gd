## PlatformServices -- Abstraction layer for all monetization plugins.
## Game code never calls plugin methods directly; every ad and IAP operation
## goes through this stable internal API, making plugin swaps zero-cost.
extends Node

# --- Internal state ---
var _admob_initialized := false
var _iap_initialized := false


func _ready() -> void:
	_init_ads()
	_init_iap()


# --- Feature capability checks ---

func has_ads() -> bool:
	return FeatureFlags.get_flag("ads_enabled") and _admob_initialized


func has_iap() -> bool:
	return FeatureFlags.get_flag("iap_enabled") and _iap_initialized


func has_banner_ads() -> bool:
	return has_ads() and FeatureFlags.get_flag("banner_ads_enabled")


func has_interstitial_ads() -> bool:
	return has_ads() and FeatureFlags.get_flag("interstitial_ads_enabled")


func has_rewarded_ads() -> bool:
	return has_ads() and FeatureFlags.get_flag("rewarded_ads_enabled")


# --- Ads interface ---

func show_interstitial() -> void:
	if not has_interstitial_ads():
		return
	push_warning("PlatformServices: show_interstitial() stub -- no plugin wired yet")


func show_rewarded() -> void:
	if not has_rewarded_ads():
		return
	push_warning("PlatformServices: show_rewarded() stub -- no plugin wired yet")


func show_banner() -> void:
	if not has_banner_ads():
		return
	EventBus.banner_region_show.emit()
	push_warning("PlatformServices: show_banner() stub -- no plugin wired yet")


func hide_banner() -> void:
	EventBus.banner_region_hide.emit()


# --- IAP interface ---

func purchase(product_id: String) -> void:
	if not has_iap():
		EventBus.iap_purchase_failed.emit(product_id, "IAP not available")
		return
	push_warning("PlatformServices: purchase() stub -- no plugin wired yet")


func restore_purchases() -> void:
	if not has_iap():
		return
	push_warning("PlatformServices: restore_purchases() stub -- no plugin wired yet")


# --- Initialization stubs ---

func _init_ads() -> void:
	push_warning("PlatformServices: _init_ads() stub -- no AdMob plugin installed yet")


func _init_iap() -> void:
	push_warning("PlatformServices: _init_iap() stub -- no IAP plugin installed yet")
