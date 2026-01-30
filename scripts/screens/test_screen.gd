## TestScreen -- Architecture validation screen.
## Displays autoload status, banner toggle buttons, and state machine demo.
extends VBoxContainer

@onready var eventbus_label: Label = %EventBusStatus
@onready var savedata_label: Label = %SaveDataStatus
@onready var gamemanager_label: Label = %GameManagerStatus
@onready var platformservices_label: Label = %PlatformServicesStatus
@onready var state_label: Label = %StateLabel

@onready var show_banner_btn: Button = %ShowBannerBtn
@onready var hide_banner_btn: Button = %HideBannerBtn
@onready var test_interstitial_btn: Button = %TestInterstitialBtn
@onready var test_iap_btn: Button = %TestIAPBtn


func _ready() -> void:
	_update_autoload_status()
	_connect_buttons()
	EventBus.app_state_changed.connect(_on_app_state_changed)
	# Demonstrate the state machine by transitioning to MENU
	GameManager.transition_to(GameManager.AppState.MENU)


func _update_autoload_status() -> void:
	eventbus_label.text = "EventBus: %s" % ("loaded" if Engine.has_singleton("EventBus") or get_node_or_null("/root/EventBus") != null else "missing")
	savedata_label.text = "SaveData: %s" % ("loaded" if get_node_or_null("/root/SaveData") != null else "missing")
	gamemanager_label.text = "GameManager: %s" % ("loaded" if get_node_or_null("/root/GameManager") != null else "missing")
	platformservices_label.text = "PlatformServices: %s" % ("loaded" if get_node_or_null("/root/PlatformServices") != null else "missing")


func _connect_buttons() -> void:
	show_banner_btn.pressed.connect(_on_show_banner)
	hide_banner_btn.pressed.connect(_on_hide_banner)
	test_interstitial_btn.pressed.connect(_on_test_interstitial)
	test_iap_btn.pressed.connect(_on_test_iap)


func _on_show_banner() -> void:
	PlatformServices.show_banner()


func _on_hide_banner() -> void:
	PlatformServices.hide_banner()


func _on_test_interstitial() -> void:
	PlatformServices.show_interstitial()


func _on_test_iap() -> void:
	PlatformServices.purchase("test_product")


func _on_app_state_changed(old_state: String, new_state: String) -> void:
	state_label.text = "State: %s -> %s" % [old_state, new_state]
