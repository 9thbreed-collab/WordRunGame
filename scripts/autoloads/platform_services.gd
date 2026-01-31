## PlatformServices -- Abstraction layer for all monetization plugins.
## Game code never calls plugin methods directly; every ad and IAP operation
## goes through this stable internal API, making plugin swaps zero-cost.
extends Node

# --- Internal state ---
var _admob_initialized := false
var _iap_initialized := false
var _interstitial_loaded := false
var _rewarded_loaded := false
var _banner_loaded := false

# --- Plugin references ---
## Reference to the Admob node in the scene tree (set during _init_ads).
var _admob_node: Node = null
## Reference to the GodotIapWrapper node (set during _init_iap).
var _iap_node: Node = null


func _ready() -> void:
	# Defer initialization so the scene tree is fully built before we look
	# for plugin nodes.
	call_deferred("_deferred_init")


func _deferred_init() -> void:
	_init_ads()
	_init_iap()


# ---------------------------------------------------------------------------
# Feature capability checks
# ---------------------------------------------------------------------------

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


# ---------------------------------------------------------------------------
# Ads interface
# ---------------------------------------------------------------------------

func show_interstitial() -> void:
	if not has_interstitial_ads():
		return
	if _admob_node == null:
		push_warning("PlatformServices: AdMob node not available -- cannot show interstitial")
		return
	if not _interstitial_loaded:
		push_warning("PlatformServices: interstitial not loaded yet")
		return
	_admob_node.show_interstitial_ad()


func show_rewarded() -> void:
	if not has_rewarded_ads():
		return
	if _admob_node == null:
		push_warning("PlatformServices: AdMob node not available -- cannot show rewarded")
		return
	if not _rewarded_loaded:
		push_warning("PlatformServices: rewarded ad not loaded yet")
		return
	_admob_node.show_rewarded_ad()


func show_banner() -> void:
	if not has_banner_ads():
		return
	# Emit the region signal BEFORE the plugin call so UI region appears
	# immediately (Decision 01-02-D1).
	EventBus.banner_region_show.emit()
	if _admob_node == null:
		push_warning("PlatformServices: AdMob node not available -- banner stub only")
		return
	if _banner_loaded:
		_admob_node.show_banner_ad()
	else:
		# Load a banner; once it loads it will be shown automatically via the
		# banner_ad_loaded callback.
		_admob_node.load_banner_ad()


func hide_banner() -> void:
	# Always emit hide signal regardless of plugin/flag state (Decision 01-02-D2).
	EventBus.banner_region_hide.emit()
	if _admob_node != null and _banner_loaded:
		_admob_node.hide_banner_ad()


# ---------------------------------------------------------------------------
# IAP interface
# ---------------------------------------------------------------------------

func purchase(product_id: String) -> void:
	if not has_iap():
		EventBus.iap_purchase_failed.emit(product_id, "IAP not available")
		return
	if _iap_node == null:
		EventBus.iap_purchase_failed.emit(product_id, "IAP plugin not loaded")
		return
	# Build a purchase request using the GodotIapWrapper typed API.
	# The plugin's request_purchase() expects a Types.RequestPurchaseProps object,
	# but since we are behind an abstraction, we use the raw dictionary method for
	# maximum compatibility and simplicity.
	var platform := OS.get_name()
	var request := {}
	if platform == "Android":
		request = {
			"type": "in-app",
			"requestPurchase": {
				"google": {
					"skus": [product_id],
				}
			}
		}
	elif platform == "iOS":
		request = {
			"type": "in-app",
			"requestPurchase": {
				"apple": {
					"sku": product_id,
				}
			}
		}
	else:
		# Desktop / editor -- emit failure so callers get a response.
		EventBus.iap_purchase_failed.emit(product_id, "IAP not supported on %s" % platform)
		return

	var result = _iap_node._request_purchase_raw(request)
	if result.get("success", false):
		EventBus.iap_purchase_completed.emit(product_id)
	else:
		EventBus.iap_purchase_failed.emit(product_id, result.get("error", "Unknown error"))


func restore_purchases() -> void:
	if not has_iap():
		return
	if _iap_node == null:
		push_warning("PlatformServices: IAP plugin not loaded -- cannot restore")
		return
	_iap_node.restore_purchases()
	EventBus.iap_restore_completed.emit()


# ---------------------------------------------------------------------------
# AdMob initialization
# ---------------------------------------------------------------------------

func _init_ads() -> void:
	# The AdMob plugin registers its class_name "Admob" via the EditorPlugin.
	# At runtime on a device the native singleton "AdmobPlugin" must exist.
	# On desktop (editor) the singleton is absent -- we gracefully degrade.
	_admob_node = _find_admob_node()
	if _admob_node == null:
		push_warning("PlatformServices: AdMob node not found in scene tree -- ads disabled (desktop/editor mode)")
		return

	# Connect lifecycle signals from the Admob node to our internal handlers,
	# which in turn emit the appropriate EventBus signals.
	_admob_node.initialization_completed.connect(_on_admob_initialized)
	_admob_node.banner_ad_loaded.connect(_on_banner_ad_loaded)
	_admob_node.banner_ad_failed_to_load.connect(_on_banner_ad_failed_to_load)
	_admob_node.interstitial_ad_loaded.connect(_on_interstitial_ad_loaded)
	_admob_node.interstitial_ad_failed_to_load.connect(_on_interstitial_ad_failed_to_load)
	_admob_node.interstitial_ad_dismissed_full_screen_content.connect(_on_interstitial_ad_closed)
	_admob_node.rewarded_ad_loaded.connect(_on_rewarded_ad_loaded)
	_admob_node.rewarded_ad_failed_to_load.connect(_on_rewarded_ad_failed_to_load)
	_admob_node.rewarded_ad_dismissed_full_screen_content.connect(_on_rewarded_ad_closed)
	_admob_node.rewarded_ad_user_earned_reward.connect(_on_rewarded_ad_earned)

	# Kick off initialization.  The Admob node handles connecting to the
	# native AdmobPlugin singleton internally in its own _ready().  We just
	# need to call initialize().
	_admob_node.initialize()


## Walk the current main scene looking for a child of type Admob.
func _find_admob_node() -> Node:
	var root := get_tree().current_scene
	if root == null:
		return null
	return _find_child_of_class(root, "Admob")


func _find_child_of_class(node: Node, class_name_str: String) -> Node:
	if node.get_class() == class_name_str or node.is_class(class_name_str):
		return node
	# Also check script class_name for GDScript-defined classes.
	var script = node.get_script()
	if script and script is GDScript:
		# The Admob class sets class_name Admob -- check the global name.
		if node is Admob:
			return node
	for child in node.get_children():
		var found := _find_child_of_class(child, class_name_str)
		if found:
			return found
	return null


# --- AdMob signal handlers ------------------------------------------------

func _on_admob_initialized(_status) -> void:
	_admob_initialized = true
	print("PlatformServices: AdMob initialized successfully")
	# Pre-load an interstitial and rewarded ad so they are ready when needed.
	_load_interstitial()
	_load_rewarded()


func _load_interstitial() -> void:
	if _admob_node and _admob_initialized:
		_admob_node.load_interstitial_ad()


func _load_rewarded() -> void:
	if _admob_node and _admob_initialized:
		_admob_node.load_rewarded_ad()


func _on_banner_ad_loaded(_ad_info, _response_info) -> void:
	_banner_loaded = true
	EventBus.ad_banner_loaded.emit()
	# Automatically show the banner if one was requested.
	if has_banner_ads():
		_admob_node.show_banner_ad()


func _on_banner_ad_failed_to_load(_ad_info, _error_data) -> void:
	_banner_loaded = false
	EventBus.ad_banner_failed.emit(0)
	push_warning("PlatformServices: banner ad failed to load")


func _on_interstitial_ad_loaded(_ad_info, _response_info) -> void:
	_interstitial_loaded = true
	EventBus.ad_interstitial_loaded.emit()


func _on_interstitial_ad_failed_to_load(_ad_info, _error_data) -> void:
	_interstitial_loaded = false
	push_warning("PlatformServices: interstitial ad failed to load")


func _on_interstitial_ad_closed(_ad_info) -> void:
	_interstitial_loaded = false
	EventBus.ad_interstitial_closed.emit()
	# Pre-load the next interstitial.
	_load_interstitial()


func _on_rewarded_ad_loaded(_ad_info, _response_info) -> void:
	_rewarded_loaded = true


func _on_rewarded_ad_failed_to_load(_ad_info, _error_data) -> void:
	_rewarded_loaded = false
	push_warning("PlatformServices: rewarded ad failed to load")


func _on_rewarded_ad_closed(_ad_info) -> void:
	_rewarded_loaded = false
	# Pre-load the next rewarded ad.
	_load_rewarded()


func _on_rewarded_ad_earned(_ad_info, reward_data) -> void:
	# reward_data is a RewardItem with get_type() and get_amount().
	var reward_type := "coins"
	var reward_amount := 1
	if reward_data and reward_data.has_method("get_type"):
		reward_type = reward_data.get_type()
	if reward_data and reward_data.has_method("get_amount"):
		reward_amount = reward_data.get_amount()
	EventBus.ad_rewarded_earned.emit(reward_type, reward_amount)


# ---------------------------------------------------------------------------
# IAP initialization
# ---------------------------------------------------------------------------

func _init_iap() -> void:
	# The godot-iap plugin registers an autoload named "GodotIapPlugin" when
	# enabled in the editor.  At runtime we look for it in the autoload path.
	_iap_node = get_node_or_null("/root/GodotIapPlugin")
	if _iap_node == null:
		# Also try finding it as a child of the current scene (in case someone
		# added it manually instead of via the plugin autoload).
		var root := get_tree().current_scene
		if root:
			for child in root.get_children():
				if child.get_class() == "GodotIapWrapper" or (child.get_script() and child is GodotIapWrapper):
					_iap_node = child
					break

	if _iap_node == null:
		push_warning("PlatformServices: IAP plugin not found -- IAP disabled (desktop/editor mode)")
		return

	# Connect IAP signals to our handlers -> EventBus.
	if _iap_node.has_signal("purchase_updated"):
		_iap_node.purchase_updated.connect(_on_iap_purchase_updated)
	if _iap_node.has_signal("purchase_error"):
		_iap_node.purchase_error.connect(_on_iap_purchase_error)
	if _iap_node.has_signal("connected"):
		_iap_node.connected.connect(_on_iap_connected)

	# Initialize the store connection.
	var connected := _iap_node.init_connection()
	if connected:
		_iap_initialized = true
		print("PlatformServices: IAP initialized successfully")
	else:
		push_warning("PlatformServices: IAP init_connection() returned false")


# --- IAP signal handlers --------------------------------------------------

func _on_iap_connected() -> void:
	_iap_initialized = true
	print("PlatformServices: IAP store connected")


func _on_iap_purchase_updated(purchase: Dictionary) -> void:
	var product_id: String = purchase.get("productId", "unknown")
	EventBus.iap_purchase_completed.emit(product_id)


func _on_iap_purchase_error(error: Dictionary) -> void:
	var product_id: String = error.get("productId", "unknown")
	var message: String = error.get("message", "Unknown error")
	EventBus.iap_purchase_failed.emit(product_id, message)
