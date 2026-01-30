## BannerAdRegion -- Collapsible bottom banner ad region with safe-area awareness.
## Listens to EventBus.banner_region_show/hide to toggle visibility.
## When hidden, sets custom_minimum_size.y to 0 so VBoxContainer reflows.
extends MarginContainer

@export var default_height: int = 80
@export var show_artwork_fallback: bool = true

var _is_collapsed: bool = false


func _ready() -> void:
	_apply_safe_area_bottom()
	EventBus.banner_region_show.connect(_on_show)
	EventBus.banner_region_hide.connect(_on_hide)
	# Start visible with artwork placeholder
	if show_artwork_fallback:
		_show_artwork()
	custom_minimum_size.y = default_height


func _apply_safe_area_bottom() -> void:
	var screen_size := DisplayServer.screen_get_size()
	var safe_area := DisplayServer.get_display_safe_area()
	var bottom_inset: int = screen_size.y - (safe_area.position.y + safe_area.size.y)
	if bottom_inset > 0:
		add_theme_constant_override("margin_bottom", bottom_inset)


func _on_show() -> void:
	_is_collapsed = false
	visible = true
	custom_minimum_size.y = default_height


func _on_hide() -> void:
	_is_collapsed = true
	visible = false
	custom_minimum_size.y = 0


func _show_artwork() -> void:
	# Placeholder -- real game artwork with idle animation added in later phases
	pass
