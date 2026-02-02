## StarBar -- Time-based star rating bar that drains over the level duration.
## 3 stars at configurable positions go from solid to outline as the fill recedes.
extends Control

@onready var _progress_bar: ProgressBar = %StarProgress
@onready var _star_1: Label = %Star1
@onready var _star_2: Label = %Star2
@onready var _star_3: Label = %Star3

const STAR_SOLID: String = "\u2605"
const STAR_OUTLINE: String = "\u2606"
var GOLD := Color(1.0, 0.84, 0.0)
var GRAY := Color(0.5, 0.5, 0.5, 0.6)

## Total time in seconds for the bar to fully drain.
@export var duration_seconds: float = 240.0

## Star positions as percentages (0.0 to 1.0). Weighted left.
var star_positions: Array[float] = [0.10, 0.40, 0.70]

var _stars: Array[Label] = []
var _star_active: Array[bool] = [true, true, true]
var _elapsed: float = 0.0
var _running: bool = false


func _ready() -> void:
	_stars = [_star_1, _star_2, _star_3]
	for star in _stars:
		star.text = STAR_SOLID
		star.add_theme_color_override("font_color", GOLD)

	_progress_bar.min_value = 0.0
	_progress_bar.max_value = 1.0
	_progress_bar.value = 1.0

	# Gold fill style
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = GOLD
	fill_style.corner_radius_top_left = 3
	fill_style.corner_radius_top_right = 3
	fill_style.corner_radius_bottom_left = 3
	fill_style.corner_radius_bottom_right = 3
	_progress_bar.add_theme_stylebox_override("fill", fill_style)

	# Dark background
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	bg_style.corner_radius_top_left = 3
	bg_style.corner_radius_top_right = 3
	bg_style.corner_radius_bottom_left = 3
	bg_style.corner_radius_bottom_right = 3
	_progress_bar.add_theme_stylebox_override("background", bg_style)


func start_timer() -> void:
	_elapsed = 0.0
	_running = true
	_progress_bar.value = 1.0
	for i in range(3):
		_star_active[i] = true
		_stars[i].text = STAR_SOLID
		_stars[i].add_theme_color_override("font_color", GOLD)


func stop_timer() -> void:
	_running = false


func get_stars_earned() -> int:
	var count: int = 0
	for active in _star_active:
		if active:
			count += 1
	return count


func _process(delta: float) -> void:
	if not _running:
		return
	_elapsed += delta
	var fill: float = clamp(1.0 - (_elapsed / duration_seconds), 0.0, 1.0)
	_progress_bar.value = fill

	# Check each star: if fill dropped below star's position, lose that star
	for i in range(star_positions.size()):
		if _star_active[i] and fill < star_positions[i]:
			_star_active[i] = false
			_stars[i].text = STAR_OUTLINE
			_stars[i].add_theme_color_override("font_color", GRAY)
			_animate_star_loss(_stars[i])

	if fill <= 0.0:
		_running = false


func _animate_star_loss(star: Label) -> void:
	star.pivot_offset = star.size / 2.0
	var t := create_tween()
	t.tween_property(star, "scale", Vector2(1.3, 1.3), 0.1)
	t.tween_property(star, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT)
