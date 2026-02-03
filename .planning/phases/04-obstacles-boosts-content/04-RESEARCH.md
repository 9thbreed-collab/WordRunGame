# Phase 4 Research: Obstacles, Boosts, and Content Pipeline

**Phase:** 04-obstacles-boosts-content
**Game:** WordRun! - Mobile Word Puzzle Game
**Engine:** Godot 4.5
**Date:** 2026-02-02

---

## Table of Contents

1. [Overview](#overview)
2. [Obstacle System Architecture](#obstacle-system-architecture)
3. [Boost System Design](#boost-system-design)
4. [Content Pipeline Architecture](#content-pipeline-architecture)
5. [Integration with Existing Systems](#integration-with-existing-systems)
6. [Implementation Recommendations](#implementation-recommendations)
7. [References](#references)

---

## Overview

Phase 4 introduces three major systems to WordRun!:

1. **Obstacles** - Visual/mechanical impediments that make word-solving harder (Padlock, Random Blocks, Sand)
2. **Boosts** - Player-activated power-ups that counter obstacles or grant score bonuses
3. **Content Pipeline** - Cloud-based word-pair delivery with local caching, validation, and OTA updates

### Core Requirements Summary

**Obstacles:**
- Resource-based template architecture (config + scene)
- Three types: Padlock, Random Blocks, Sand
- Distinct visual animations
- Zero new code paths for new obstacle types

**Boosts:**
- Three types: Lock Key, Block Breaker, Bucket of Water
- Pre-level loadout selection
- Score bonus when used without corresponding obstacle
- Single-use consumption

**Content Pipeline:**
- Cloud/database storage (not bundled)
- Local caching (gameplay never blocks on network)
- 250+ validated levels at launch
- Automated dictionary validation
- Profanity and sensitivity filtering
- Versioned content with OTA updates
- Themed words per land

---

## Obstacle System Architecture

### 1. Resource-Based Plugin Pattern

The obstacle system uses Godot 4's Resource system to create a data-driven, extensible architecture where new obstacles require only configuration and visual assets—no new code paths.

#### Architecture Overview

```
ObstacleConfig (Resource)
├── obstacle_type: String (e.g., "padlock", "random_blocks", "sand")
├── display_name: String
├── description: String
├── visual_scene: PackedScene
├── activation_timing: Dictionary
│   ├── word_index: int (which word triggers it)
│   ├── delay_seconds: float (optional delay after trigger)
│   └── trigger_type: String ("word_start", "word_complete", "section_complete")
└── effect_data: Dictionary (type-specific params)
    └── [varies by obstacle type]
```

**Key Godot 4 Resource Best Practices** ([source](https://medium.com/@sfmayke/resource-based-architecture-for-godot-4-25bd4b2d9018)):
- Resources provide a data-driven approach for minimizing node dependencies
- Use `.tres` format for version control (human-readable Git diffs)
- Resources can store custom classes, enabling flyweight and type object patterns
- Prefer Resources over static data when you need instance-specific variations

#### ObstacleBase (Abstract Base Class)

```gdscript
## ObstacleBase -- Abstract base class for all obstacles.
## Defines lifecycle hooks that obstacle implementations override.
class_name ObstacleBase
extends Node2D

signal obstacle_activated
signal obstacle_cleared
signal obstacle_expired

var config: ObstacleConfig
var target_word_row: WordRow

## Override in subclasses
func activate() -> void:
	pass

## Override in subclasses
func clear() -> void:
	pass

## Override in subclasses (for obstacles with time limits)
func _process(delta: float) -> void:
	pass

## Override if obstacle affects input handling
func can_accept_input() -> bool:
	return true
```

#### ObstacleManager (Orchestrator)

The ObstacleManager sits in the GameplayScreen and handles obstacle lifecycle:

```gdscript
## ObstacleManager -- Handles spawning, activation, and clearing of obstacles.
class_name ObstacleManager
extends Node

var _active_obstacles: Dictionary = {}  # word_index: ObstacleBase
var _level_obstacles: Array[ObstacleConfig] = []

func load_level_obstacles(level_data: LevelData) -> void:
	_level_obstacles = level_data.obstacle_configs

func check_trigger(word_index: int, trigger_type: String) -> void:
	for config in _level_obstacles:
		if config.activation_timing.word_index == word_index:
			if config.activation_timing.trigger_type == trigger_type:
				_spawn_obstacle(config, word_index)

func _spawn_obstacle(config: ObstacleConfig, word_index: int) -> void:
	var obstacle_scene = config.visual_scene.instantiate()
	obstacle_scene.config = config
	obstacle_scene.target_word_row = _get_word_row(word_index)
	_active_obstacles[word_index] = obstacle_scene
	add_child(obstacle_scene)
	obstacle_scene.activate()

func clear_obstacle(word_index: int, boost_used: String = "") -> void:
	if _active_obstacles.has(word_index):
		var obstacle = _active_obstacles[word_index]
		obstacle.clear()
		obstacle.queue_free()
		_active_obstacles.erase(word_index)
```

### 2. Specific Obstacle Implementations

#### Padlock Obstacle

**Mechanics:**
- Locks entire word (all letter slots unavailable)
- Word cannot be interacted with until:
  - Player solves the word BEFORE the locked word, OR
  - Player uses Lock Key boost
- Visual: Padlock icon overlay on WordRow with locked slot states

**Implementation:**

```gdscript
class_name PadlockObstacle
extends ObstacleBase

var _locked: bool = true

func activate() -> void:
	target_word_row.set_locked(true)
	_show_padlock_animation()
	obstacle_activated.emit()

func clear() -> void:
	target_word_row.set_locked(false)
	_show_unlock_animation()
	obstacle_cleared.emit()

func can_accept_input() -> bool:
	return not _locked

func _show_padlock_animation() -> void:
	# Scale + rotation animation of padlock icon
	var padlock = $PadlockIcon
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(padlock, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(padlock, "rotation", deg_to_rad(10), 0.1)
	tween.tween_property(padlock, "rotation", deg_to_rad(-10), 0.1)
	tween.tween_property(padlock, "rotation", 0, 0.1)

func _show_unlock_animation() -> void:
	# Padlock shakes, then pops open and fades
	var padlock = $PadlockIcon
	var tween = create_tween()
	tween.tween_property(padlock, "rotation", deg_to_rad(30), 0.15)
	tween.tween_property(padlock, "modulate:a", 0.0, 0.2)
```

**WordRow Integration:**

```gdscript
# Add to WordRow class
var _is_locked: bool = false

func set_locked(locked: bool) -> void:
	_is_locked = locked
	if locked:
		modulate = Color(0.5, 0.5, 0.5, 0.7)
		for slot in _letter_slots:
			slot.set_state(LetterSlot.State.LOCKED)  # New state
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)

func handle_input(letter: String) -> bool:
	if _is_locked:
		return false
	# ... existing input logic
```

**LetterSlot New State:**

```gdscript
# Add to LetterSlot.State enum
enum State { EMPTY, FILLED, CORRECT, INCORRECT, LOCKED }

# Add locked style in _create_styles()
_style_locked = StyleBoxFlat.new()
_style_locked.bg_color = Color(0.3, 0.3, 0.3, 1)  # Dark gray
_style_locked.border_color = Color(0.5, 0.5, 0.5, 1)
# ... borders and corners
```

#### Random Blocks Obstacle

**Mechanics:**
- Fills 1-5 random letter slots with wood-grain blocks
- Slots become unavailable for input
- If ALL slots fill, word auto-solves for 0 points (penalty)
- Blocks appear suddenly (no warning)
- Clear with Block Breaker boost or solve around them

**Implementation:**

```gdscript
class_name RandomBlocksObstacle
extends ObstacleBase

var _blocked_slots: Array[int] = []
var _block_count: int = 0

func activate() -> void:
	_block_count = config.effect_data.get("block_count", randi_range(1, 5))
	_place_random_blocks()
	obstacle_activated.emit()

func _place_random_blocks() -> void:
	var available_slots = []
	for i in range(target_word_row._letter_slots.size()):
		if target_word_row._letter_slots[i].get_letter() == "":
			available_slots.append(i)

	available_slots.shuffle()
	var slots_to_block = min(_block_count, available_slots.size())

	for i in range(slots_to_block):
		var slot_index = available_slots[i]
		_blocked_slots.append(slot_index)
		target_word_row._letter_slots[slot_index].set_blocked(true)
		_animate_block_appear(slot_index)

	# Check if word is fully blocked
	if slots_to_block == target_word_row._letter_slots.size():
		_trigger_zero_point_solve()

func _animate_block_appear(slot_index: int) -> void:
	var slot = target_word_row._letter_slots[slot_index]
	var block_sprite = slot.get_node("BlockSprite")
	block_sprite.visible = true
	block_sprite.scale = Vector2.ZERO

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(block_sprite, "scale", Vector2.ONE, 0.3)
	# Add wood-grain texture animation/shader effect

func _trigger_zero_point_solve() -> void:
	await get_tree().create_timer(0.5).timeout
	target_word_row.auto_solve_zero_points()
	clear()

func clear() -> void:
	for slot_index in _blocked_slots:
		target_word_row._letter_slots[slot_index].set_blocked(false)
		_animate_block_break(slot_index)
	_blocked_slots.clear()
	obstacle_cleared.emit()

func _animate_block_break(slot_index: int) -> void:
	var slot = target_word_row._letter_slots[slot_index]
	var block_sprite = slot.get_node("BlockSprite")

	# Shake + particle explosion + fade
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(block_sprite, "rotation", deg_to_rad(15), 0.1)
	tween.tween_property(block_sprite, "modulate:a", 0.0, 0.2)

	# Spawn wood chip particles
	var particles = GPUParticles2D.new()
	slot.add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	await get_tree().create_timer(1.0).timeout
	particles.queue_free()
```

**LetterSlot Integration:**

```gdscript
# Add to LetterSlot
var _is_blocked: bool = false

func set_blocked(blocked: bool) -> void:
	_is_blocked = blocked
	if blocked:
		$BlockSprite.visible = true
		# Disable input acceptance
	else:
		$BlockSprite.visible = false

func can_accept_input() -> bool:
	return not _is_blocked
```

#### Sand Obstacle

**Mechanics:**
- Fills 1 random slot in 1-5 random words slowly (animated trickle)
- Persists and "trickles down" when words scroll
- Can make words unsolvable if fully filled
- Most complex visual effect (particle system)
- Clear with Bucket of Water boost (up to 3 words)

**Implementation:**

```gdscript
class_name SandObstacle
extends ObstacleBase

var _sanded_words: Dictionary = {}  # word_index: [slot_indices]
var _trickle_timer: Timer
var _scroll_offset: float = 0.0

func activate() -> void:
	_trickle_timer = Timer.new()
	_trickle_timer.wait_time = config.effect_data.get("trickle_interval", 2.0)
	_trickle_timer.timeout.connect(_on_trickle_tick)
	add_child(_trickle_timer)
	_trickle_timer.start()

	var word_count = config.effect_data.get("word_count", randi_range(1, 5))
	_initialize_sand_targets(word_count)
	obstacle_activated.emit()

func _initialize_sand_targets(count: int) -> void:
	var available_words = []
	for i in range(12):  # Only target base words, not bonus
		available_words.append(i)
	available_words.shuffle()

	for i in range(min(count, available_words.size())):
		var word_index = available_words[i]
		_sanded_words[word_index] = []

func _on_trickle_tick() -> void:
	# Pick one sanded word and add sand to one slot
	if _sanded_words.size() == 0:
		return

	var word_indices = _sanded_words.keys()
	word_indices.shuffle()
	var target_word = word_indices[0]

	var word_row = _get_word_row(target_word)
	var available_slots = []
	for i in range(word_row._letter_slots.size()):
		if not _sanded_words[target_word].has(i):
			available_slots.append(i)

	if available_slots.size() > 0:
		available_slots.shuffle()
		var slot_index = available_slots[0]
		_sanded_words[target_word].append(slot_index)
		_add_sand_to_slot(word_row, slot_index)

		# Check if word is fully sanded
		if _sanded_words[target_word].size() == word_row._letter_slots.size():
			_trigger_unsolvable(target_word)

func _add_sand_to_slot(word_row: WordRow, slot_index: int) -> void:
	var slot = word_row._letter_slots[slot_index]

	# Create sand particle system
	var sand_particles = GPUParticles2D.new()
	sand_particles.name = "SandParticles"
	sand_particles.amount = 20
	sand_particles.lifetime = 1.5
	sand_particles.one_shot = false
	sand_particles.emitting = true

	# Configure particle material for sand trickle
	var particle_mat = ParticleProcessMaterial.new()
	particle_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particle_mat.emission_box_extents = Vector3(10, 2, 1)
	particle_mat.direction = Vector3(0, 1, 0)  # Downward
	particle_mat.spread = 15.0
	particle_mat.initial_velocity_min = 20.0
	particle_mat.initial_velocity_max = 40.0
	particle_mat.gravity = Vector3(0, 98, 0)
	particle_mat.color = Color(0.8, 0.7, 0.5, 1)  # Sandy color
	sand_particles.process_material = particle_mat

	slot.add_child(sand_particles)

	# Gradually fill slot with sand color
	var fill_tween = create_tween()
	fill_tween.tween_method(_set_sand_fill_level.bind(slot), 0.0, 1.0, 1.5)

	slot.set_state(LetterSlot.State.SANDED)  # New state

func _set_sand_fill_level(level: float, slot: LetterSlot) -> void:
	# Shader parameter to show sand filling from bottom
	if slot.material:
		slot.material.set_shader_parameter("sand_level", level)

func _trigger_unsolvable(word_index: int) -> void:
	# Word becomes unsolvable - emit warning event
	EventBus.word_unsolvable.emit(word_index)
	# Could auto-skip or give player option to use boost

func _process(delta: float) -> void:
	# Handle trickle-down on scroll
	var current_scroll = _get_scroll_position()
	if current_scroll != _scroll_offset:
		_update_sand_positions(current_scroll - _scroll_offset)
		_scroll_offset = current_scroll

func _update_sand_positions(delta_scroll: float) -> void:
	# Animate sand particles "trickling down" as screen scrolls
	for word_index in _sanded_words.keys():
		var word_row = _get_word_row(word_index)
		for slot_index in _sanded_words[word_index]:
			var slot = word_row._letter_slots[slot_index]
			var particles = slot.get_node_or_null("SandParticles")
			if particles:
				# Offset particle position to simulate trickle during scroll
				particles.position.y += delta_scroll * 0.3

func clear() -> void:
	# Used by Bucket of Water boost (clears up to 3 words)
	var cleared_count = 0
	for word_index in _sanded_words.keys():
		if cleared_count >= 3:
			break
		_clear_word_sand(word_index)
		cleared_count += 1
	obstacle_cleared.emit()

func _clear_word_sand(word_index: int) -> void:
	if not _sanded_words.has(word_index):
		return

	var word_row = _get_word_row(word_index)
	for slot_index in _sanded_words[word_index]:
		var slot = word_row._letter_slots[slot_index]
		_animate_sand_clear(slot)

	_sanded_words.erase(word_index)

func _animate_sand_clear(slot: LetterSlot) -> void:
	# Water wash effect
	var particles = slot.get_node_or_null("SandParticles")
	if particles:
		particles.emitting = false
		particles.queue_free()

	# Fade out sand fill
	var clear_tween = create_tween()
	clear_tween.tween_method(_set_sand_fill_level.bind(slot), 1.0, 0.0, 0.5)
	await clear_tween.finished
	slot.set_state(LetterSlot.State.EMPTY)
```

**Particle System Considerations** ([source](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html)):
- Use GPUParticles2D for performance on mobile
- Configure ParticleProcessMaterial for sand physics (gravity, velocity, spread)
- Keep particle counts low (20-50 per slot) to maintain 60fps on mobile
- Use one_shot for burst effects, continuous for trickle
- Consider custom shader for sand fill level visualization

### 3. Decoupling Strategy

**Key Integration Points:**

1. **EventBus Signals** (add to `/Users/nathanielgiddens/WordRunGame/scripts/autoloads/event_bus.gd`):
```gdscript
# --- Obstacle signals ---
signal obstacle_triggered(word_index: int, obstacle_type: String)
signal obstacle_cleared(word_index: int, obstacle_type: String)
signal word_unsolvable(word_index: int)
signal boost_used(boost_type: String, word_index: int)
```

2. **GameplayScreen Integration**:
```gdscript
# Add to GameplayScreen._ready()
@onready var _obstacle_manager: ObstacleManager = %ObstacleManager

func _ready() -> void:
	# ... existing setup
	_obstacle_manager.load_level_obstacles(_level_data)

func _on_word_completed(word_index: int) -> void:
	# ... existing logic
	_obstacle_manager.check_trigger(word_index + 1, "word_start")

	# Check if next word is padlocked, auto-unlock
	if _obstacle_manager.has_obstacle(word_index + 1, "padlock"):
		_obstacle_manager.clear_obstacle(word_index + 1)
```

3. **LevelData Extension**:
```gdscript
# Add to LevelData class
@export var obstacle_configs: Array[ObstacleConfig] = []
```

---

## Boost System Design

### 1. Boost Architecture

Boosts use a similar resource-based pattern to obstacles, but are player-activated rather than level-triggered.

#### BoostConfig Resource

```gdscript
class_name BoostConfig
extends Resource

@export var boost_id: String  # "lock_key", "block_breaker", "bucket_of_water"
@export var display_name: String
@export var description: String
@export var icon_texture: Texture2D
@export var counters_obstacle: String  # Empty if no specific counter
@export var score_bonus: int = 500  # Bonus when used without obstacle
@export var usage_animation_scene: PackedScene
```

#### BoostInventory (SaveData Integration)

```gdscript
# Add to SaveData autoload
var boost_inventory: Dictionary = {
	"lock_key": 3,
	"block_breaker": 2,
	"bucket_of_water": 1
}

func consume_boost(boost_id: String) -> bool:
	if boost_inventory.get(boost_id, 0) > 0:
		boost_inventory[boost_id] -= 1
		save_game()
		return true
	return false

func add_boost(boost_id: String, amount: int = 1) -> void:
	boost_inventory[boost_id] = boost_inventory.get(boost_id, 0) + amount
	save_game()
```

### 2. Boost Loadout System

**Pre-Level Loadout Screen:**

Before starting a level, players see a loadout screen showing:
- Available boosts in inventory
- Slots for 3 boost selections
- Drag-and-drop or tap to equip
- Level preview showing obstacle types (so players can plan)

```gdscript
class_name BoostLoadoutScreen
extends Control

signal loadout_confirmed(selected_boosts: Array[String])

var _selected_boosts: Array[String] = []
var _max_slots: int = 3

@onready var _boost_inventory_grid: GridContainer = %BoostInventoryGrid
@onready var _loadout_slots: Array = [%LoadoutSlot1, %LoadoutSlot2, %LoadoutSlot3]

func _ready() -> void:
	_populate_inventory()
	_setup_loadout_slots()

func _populate_inventory() -> void:
	for boost_id in SaveData.boost_inventory.keys():
		var count = SaveData.boost_inventory[boost_id]
		if count > 0:
			var boost_button = _create_boost_button(boost_id, count)
			_boost_inventory_grid.add_child(boost_button)

func _on_boost_selected(boost_id: String) -> void:
	if _selected_boosts.size() < _max_slots:
		_selected_boosts.append(boost_id)
		_update_loadout_display()
	else:
		# Show "loadout full" feedback
		_shake_loadout_slots()

func _on_start_level_pressed() -> void:
	loadout_confirmed.emit(_selected_boosts)
```

**Mobile UX Patterns** ([source](https://pixune.com/blog/best-examples-mobile-game-ui-design/)):
- **Minimalist approach**: Clean, unobstructed views with contextual prompts
- **Environmental integration**: Subtle UI that doesn't overwhelm gameplay
- **Gestural guides**: Multi-touch gestures for drag-and-drop boost selection
- **Neon-style overlays**: Modern dashboard aesthetics for boost inventory

### 3. Boost Activation During Gameplay

**BoostPanel UI:**

```gdscript
class_name BoostPanel
extends HBoxContainer

var _loadout: Array[String] = []

func setup(loadout: Array[String]) -> void:
	_loadout = loadout
	for i in range(_loadout.size()):
		var boost_button = get_child(i)
		boost_button.setup(_loadout[i])
		boost_button.pressed.connect(_on_boost_pressed.bind(_loadout[i]))

func _on_boost_pressed(boost_id: String) -> void:
	# Activate boost
	var success = BoostManager.use_boost(boost_id)
	if success:
		EventBus.boost_used.emit(boost_id, GameplayScreen._current_word_index)
		_disable_button(boost_id)
```

**BoostManager (Game Logic):**

```gdscript
class_name BoostManager
extends Node

func use_boost(boost_id: String) -> bool:
	var obstacle_manager = get_node("/root/GameplayScreen/ObstacleManager")
	var current_word_index = get_node("/root/GameplayScreen")._current_word_index

	match boost_id:
		"lock_key":
			return _use_lock_key(obstacle_manager, current_word_index)
		"block_breaker":
			return _use_block_breaker(obstacle_manager, current_word_index)
		"bucket_of_water":
			return _use_bucket_of_water(obstacle_manager, current_word_index)

	return false

func _use_lock_key(om: ObstacleManager, word_index: int) -> bool:
	if om.has_obstacle_type(word_index, "padlock"):
		om.clear_obstacle(word_index, "lock_key")
		return true
	else:
		# No padlock - grant score bonus
		EventBus.score_updated.emit(GameplayScreen._score + 500)
		_show_bonus_effect()
		return true

func _use_block_breaker(om: ObstacleManager, word_index: int) -> bool:
	if om.has_obstacle_type(word_index, "random_blocks"):
		om.clear_obstacle(word_index, "block_breaker")
		return true
	else:
		EventBus.score_updated.emit(GameplayScreen._score + 500)
		_show_bonus_effect()
		return true

func _use_bucket_of_water(om: ObstacleManager, word_index: int) -> bool:
	var sand_obstacles = om.get_obstacles_by_type("sand")
	if sand_obstacles.size() > 0:
		# Clear up to 3 sanded words
		for i in range(min(3, sand_obstacles.size())):
			sand_obstacles[i].clear()
		return true
	else:
		EventBus.score_updated.emit(GameplayScreen._score + 500)
		_show_bonus_effect()
		return true

func _show_bonus_effect() -> void:
	# Sparkle animation + "+500" floating text
	var bonus_label = Label.new()
	bonus_label.text = "+500 BONUS!"
	# ... animation
```

### 4. Boost Visual Feedback

**Lock Key Animation:**
- Key icon flies to padlock
- Unlock click sound
- Padlock pops open and fades
- Word row pulses to indicate availability

**Block Breaker Animation:**
- Hammer icon swings across word row
- Each block shatters with particle explosion
- Wood chip particles scatter
- Slots pulse as they become available

**Bucket of Water Animation:**
- Water splash effect from top of screen
- Blue water particles cascade down sanded words
- Sand particles wash away (fade + drift down)
- Clean slots pulse to indicate restoration

---

## Content Pipeline Architecture

### 1. System Overview

The content pipeline separates word-pair data from the game binary, enabling:
- Continuous content updates without app store releases
- A/B testing of word difficulty
- Seasonal/themed word sets
- Profanity filter updates
- Content versioning and rollback

**Architecture Diagram:**

```
[Cloud Database/API]
       ↓
   (HTTPS GET)
       ↓
[HTTPRequest + JSON Parser]
       ↓
[Validation Layer]
   ├─ Dictionary Validation
   ├─ Profanity Filter
   └─ Compound Word Check
       ↓
[Local Cache (user://)]
   ├─ content_version.json
   ├─ word_pairs_land_1.json
   ├─ word_pairs_land_2.json
   └─ profanity_filter_v3.json
       ↓
[LevelData Builder]
       ↓
[GameplayScreen]
```

### 2. Cloud Storage & Versioning

**Content Versioning Strategy** ([source](https://appcircle.io/blog/codepush-the-game-changer-for-over-the-air-mobile-app-updates)):
- Use semantic versioning for content (v1.2.3)
- Store version manifest in cloud
- Client checks version on startup
- Download only changed files (delta updates)
- Fallback to bundled baseline content if network fails

**CDN Caching** ([source](https://medium.com/@abijith.b/how-we-reduced-our-apps-ota-update-costs-by-90-6648939c886b)):
- Configure CloudFlare or similar CDN for blob storage
- Cache JSON responses for 1 hour
- Use cache-busting query params for forced updates
- Reduces bandwidth costs by 90%

**Example Manifest:**

```json
{
  "content_version": "1.4.2",
  "min_app_version": "1.0.0",
  "lands": [
    {
      "land_id": "grasslands",
      "display_name": "Grasslands",
      "word_pairs_url": "https://cdn.wordrun.com/content/v1.4.2/grasslands.json",
      "level_count": 50,
      "checksum": "a3d8f9e2..."
    },
    {
      "land_id": "desert",
      "display_name": "Desert",
      "word_pairs_url": "https://cdn.wordrun.com/content/v1.4.2/desert.json",
      "level_count": 50,
      "checksum": "b7c4e1f3..."
    }
  ],
  "profanity_filter_url": "https://cdn.wordrun.com/filters/profanity_v3.json",
  "profanity_version": "3.1.0"
}
```

### 3. Local Caching Implementation

**Godot Best Practices** ([source](https://www.gdquest.com/library/save_game_godot4/)):
- Store user data in `user://` path (becomes read-only in `res://` on export)
- Use ResourceSaver/ResourceLoader for native Godot objects
- For JSON, use FileAccess with CACHE_MODE_IGNORE to avoid stale data
- Prefer `.tres` for version control, but JSON for cloud compatibility

**ContentCache Class:**

```gdscript
class_name ContentCache
extends Node

const CACHE_DIR = "user://content_cache/"
const MANIFEST_FILE = "user://content_cache/manifest.json"

var _cached_manifest: Dictionary = {}
var _http_request: HTTPRequest

func _ready() -> void:
	_ensure_cache_directory()
	_load_cached_manifest()
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

func _ensure_cache_directory() -> void:
	if not DirAccess.dir_exists_absolute(CACHE_DIR):
		DirAccess.make_dir_absolute(CACHE_DIR)

func _load_cached_manifest() -> void:
	if FileAccess.file_exists(MANIFEST_FILE):
		var file = FileAccess.open(MANIFEST_FILE, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			_cached_manifest = json.data

func check_for_updates() -> void:
	var manifest_url = "https://cdn.wordrun.com/content/manifest.json"
	_http_request.request(manifest_url)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		EventBus.content_update_failed.emit()
		return

	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		EventBus.content_update_failed.emit()
		return

	var new_manifest = json.data

	# Compare versions
	if new_manifest.get("content_version") != _cached_manifest.get("content_version"):
		_download_updated_content(new_manifest)
	else:
		EventBus.content_up_to_date.emit()

func _download_updated_content(manifest: Dictionary) -> void:
	# Download each land's word pairs
	for land in manifest.lands:
		_download_land_content(land)

	# Download updated profanity filter
	_download_profanity_filter(manifest.profanity_filter_url)

	# Save new manifest
	_save_manifest(manifest)

func _download_land_content(land_config: Dictionary) -> void:
	var url = land_config.word_pairs_url
	var land_id = land_config.land_id

	# Use multiple HTTPRequest nodes for parallel downloads
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_land_downloaded.bind(land_id, land_config.checksum, http))
	http.request(url)

func _on_land_downloaded(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, land_id: String, expected_checksum: String, http_node: HTTPRequest) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		EventBus.content_download_failed.emit(land_id)
		http_node.queue_free()
		return

	# Verify checksum
	var actual_checksum = body.get_string_from_utf8().md5_text()
	if actual_checksum != expected_checksum:
		EventBus.content_checksum_failed.emit(land_id)
		http_node.queue_free()
		return

	# Save to cache
	var file_path = CACHE_DIR + land_id + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(body.get_string_from_utf8())
	file.close()

	EventBus.content_downloaded.emit(land_id)
	http_node.queue_free()

func get_land_content(land_id: String) -> Array:
	var file_path = CACHE_DIR + land_id + ".json"

	if not FileAccess.file_exists(file_path):
		# Fallback to bundled baseline
		file_path = "res://data/baseline/" + land_id + ".json"

	if not FileAccess.file_exists(file_path):
		return []

	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result == OK:
		return json.data.get("word_pairs", [])

	return []
```

**HTTPRequest Best Practices** ([source](https://godotforums.org/d/35067-best-practices-around-httprequest)):
- Create one HTTPRequest per concurrent download
- Use signals for async handling (never block gameplay)
- Implement timeout handling
- Cache responses to avoid repeated network calls
- Consider a manager pattern for multiple endpoints

### 4. Word Validation Pipeline

**Multi-Layer Validation:**

```gdscript
class_name WordValidator
extends Node

var _dictionary_api: DictionaryAPI
var _profanity_filter: ProfanityFilter
var _compound_checker: CompoundWordChecker

func validate_word_pair(word_a: String, word_b: String) -> Dictionary:
	var result = {
		"valid": true,
		"errors": []
	}

	# Layer 1: Dictionary validation
	if not _dictionary_api.is_valid_word(word_a):
		result.valid = false
		result.errors.append("Word A not in dictionary: " + word_a)

	if not _dictionary_api.is_valid_word(word_b):
		result.valid = false
		result.errors.append("Word B not in dictionary: " + word_b)

	# Layer 2: Compound word validation
	var compound = word_a + word_b
	if not _compound_checker.is_valid_compound(compound):
		result.valid = false
		result.errors.append("Invalid compound: " + compound)

	# Layer 3: Profanity filter (check all combinations)
	var combinations = [word_a, word_b, compound]
	for word in combinations:
		if _profanity_filter.contains_profanity(word):
			result.valid = false
			result.errors.append("Profanity detected: " + word)

	return result

func validate_level_batch(word_pairs: Array[Dictionary]) -> Dictionary:
	var results = {
		"valid_count": 0,
		"invalid_count": 0,
		"errors": []
	}

	for pair in word_pairs:
		var validation = validate_word_pair(pair.word_a, pair.word_b)
		if validation.valid:
			results.valid_count += 1
		else:
			results.invalid_count += 1
			results.errors.append_array(validation.errors)

	return results
```

**Dictionary APIs** ([source](https://www.wordgamedictionary.com/api/)):
- **Word Game Dictionary API**: Validates against TWL, SOWPODS, ENABLE wordlists
  - Free for non-commercial use (100 calls/24hrs)
  - Commercial license available
- **Merriam-Webster API**: Free tier with 1000 queries/day
  - Comprehensive definitions for educational context
- **WordsAPI**: 325,000+ words, purchase for local hosting
  - Best for offline validation (no network dependency)

**Recommended Approach:**
1. Bundle WordsAPI dataset (or similar) for offline validation
2. Use cloud API for periodic validation during content creation
3. Cache validation results to minimize API calls

### 5. Profanity Filtering for Compound Words

**Challenge:** Standard profanity filters fail on compound words where innocent words combine to form offensive terms (e.g., "mass" + "acre" = problematic).

**Solution: Multi-Pass Compound Filter**

```gdscript
class_name ProfanityFilter
extends Node

var _profanity_list: PackedStringArray = []
var _safe_word_list: PackedStringArray = []

func load_filter_data(json_path: String) -> void:
	var file = FileAccess.open(json_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	json.parse(json_string)
	var data = json.data

	_profanity_list = data.get("profanity", [])
	_safe_word_list = data.get("safe_words", [])

func contains_profanity(text: String) -> bool:
	var lower = text.to_lower()

	# Check if entire text is in safe word list
	if _safe_word_list.has(lower):
		return false

	# Check for exact matches
	if _profanity_list.has(lower):
		return true

	# Check for substring matches (compound word case)
	for profane in _profanity_list:
		if lower.contains(profane):
			# Verify not a false positive from safe words
			if not _is_safe_context(lower, profane):
				return true

	return false

func _is_safe_context(text: String, profane_substring: String) -> bool:
	# Check if profane substring is part of known safe word
	for safe_word in _safe_word_list:
		if safe_word.contains(profane_substring) and text.contains(safe_word):
			return true
	return false
```

**Profanity Filter Libraries** ([source](https://github.com/2Toad/Profanity)):
- **@2toad/Profanity (TypeScript)**: Analyzes compound words with configurable boundaries
- **PurgoMalum API**: Free REST API with safe word exclusions
- **Neutrino API**: NLP-based detection with obfuscation handling
- **profanity-filter (Python)**: Levenshtein automata for derivative detection

**Recommended Implementation:**
1. Use **@2toad/Profanity** pattern with GDScript port
2. Maintain curated safe word list for common false positives
3. Manual review for edge cases during content creation
4. Update filter via OTA when new patterns discovered

**Example Filter Data Structure:**

```json
{
  "version": "3.1.0",
  "profanity": [
    "badword1",
    "badword2",
    "substring3"
  ],
  "safe_words": [
    "class",
    "assassin",
    "basement",
    "therapist"
  ],
  "compound_exceptions": [
    {
      "word_a": "mass",
      "word_b": "acre",
      "allowed": false,
      "reason": "Compound forms offensive term"
    }
  ]
}
```

### 6. Themed Word Sets Per Land

**Land-Based Content Organization:**

```json
{
  "land_id": "grasslands",
  "theme": "nature, animals, plants",
  "word_pairs": [
    {
      "word_a": "grass",
      "word_b": "hopper",
      "theme_tags": ["insects", "nature"],
      "difficulty": 1
    },
    {
      "word_a": "butter",
      "word_b": "fly",
      "theme_tags": ["insects", "nature"],
      "difficulty": 1
    },
    {
      "word_a": "sun",
      "word_b": "flower",
      "theme_tags": ["plants", "nature"],
      "difficulty": 2
    }
  ]
}
```

**Benefits:**
- Thematic coherence improves player immersion
- Easier to curate 50 levels per theme than 250 generic levels
- Enables educational contexts (nature land teaches biology terms)
- Supports seasonal events (winter land during holidays)

---

## Integration with Existing Systems

### 1. Extended LevelData Structure

```gdscript
class_name LevelData
extends Resource

@export var level_name: String = ""
@export var time_limit_seconds: int = 180
@export var word_pairs: Array[WordPair] = []
@export var surge_config: SurgeConfig

# Phase 4 additions:
@export var obstacle_configs: Array[ObstacleConfig] = []
@export var recommended_boosts: Array[String] = []  # UI hints
@export var land_theme: String = ""  # "grasslands", "desert", etc.
@export var difficulty_rating: int = 1  # 1-5 stars
```

### 2. GameplayScreen Modifications

```gdscript
# Add to GameplayScreen
@onready var _obstacle_manager: ObstacleManager = %ObstacleManager
@onready var _boost_panel: BoostPanel = %BoostPanel

var _active_boosts: Array[String] = []

func _ready() -> void:
	# ... existing setup

	# Phase 4 setup
	_obstacle_manager.load_level_obstacles(_level_data)
	_boost_panel.setup(_active_boosts)

	# Connect obstacle events
	EventBus.obstacle_triggered.connect(_on_obstacle_triggered)
	EventBus.boost_used.connect(_on_boost_used)

func setup_level(level_data: LevelData, boosts: Array[String]) -> void:
	_level_data = level_data
	_active_boosts = boosts
	# Proceed with normal level setup

func _on_word_completed(word_index: int) -> void:
	# ... existing logic

	# Trigger obstacles for next word
	_obstacle_manager.check_trigger(word_index + 1, "word_start")

	# Auto-unlock padlock if next word solved
	if _obstacle_manager.has_obstacle(word_index + 1, "padlock"):
		_obstacle_manager.clear_obstacle(word_index + 1)
```

### 3. EventBus Extensions

```gdscript
# Add to event_bus.gd

# --- Obstacle signals ---
signal obstacle_triggered(word_index: int, obstacle_type: String)
signal obstacle_cleared(word_index: int, obstacle_type: String)
signal word_unsolvable(word_index: int)

# --- Boost signals ---
signal boost_used(boost_type: String, word_index: int)
signal boost_loadout_changed(boosts: Array[String])

# --- Content pipeline signals ---
signal content_update_available(version: String)
signal content_update_started
signal content_downloaded(land_id: String)
signal content_download_failed(land_id: String)
signal content_checksum_failed(land_id: String)
signal content_up_to_date
signal content_update_failed
```

### 4. SaveData Integration

```gdscript
# Add to save_data.gd

var boost_inventory: Dictionary = {
	"lock_key": 3,
	"block_breaker": 2,
	"bucket_of_water": 1
}

var content_version: String = "1.0.0"
var cached_lands: Array[String] = []

func consume_boost(boost_id: String) -> bool:
	if boost_inventory.get(boost_id, 0) > 0:
		boost_inventory[boost_id] -= 1
		save_game()
		return true
	return false

func add_boost(boost_id: String, amount: int = 1) -> void:
	boost_inventory[boost_id] = boost_inventory.get(boost_id, 0) + amount
	save_game()

func update_content_version(version: String) -> void:
	content_version = version
	save_game()
```

---

## Implementation Recommendations

### Phase 4A: Obstacle System Foundation (Week 1)
1. Create ObstacleConfig and ObstacleBase resources
2. Implement ObstacleManager
3. Build Padlock obstacle as template
4. Extend LetterSlot with LOCKED state
5. Test obstacle spawning and clearing

### Phase 4B: Remaining Obstacles (Week 2)
1. Implement Random Blocks obstacle
2. Implement Sand obstacle with particle system
3. Create visual scenes for each obstacle
4. Test obstacle interactions with WordRow
5. Performance profiling on mobile device

### Phase 4C: Boost System (Week 3)
1. Create BoostConfig resources
2. Implement BoostLoadoutScreen
3. Build BoostPanel in-game UI
4. Implement BoostManager logic
5. Create boost activation animations
6. Test boost-obstacle interactions

### Phase 4D: Content Pipeline (Week 4)
1. Set up ContentCache system
2. Implement HTTPRequest handlers
3. Build WordValidator with dictionary API
4. Integrate ProfanityFilter
5. Create baseline bundled content
6. Test OTA update flow

### Phase 4E: Content Creation & Validation (Week 5)
1. Develop content creation tool (editor script)
2. Generate 250+ validated word pairs
3. Organize into themed land sets
4. Run profanity filter on all compounds
5. Manual review of flagged combinations
6. Export to JSON format

### Phase 4F: Integration & Polish (Week 6)
1. Extend LevelData with obstacle configs
2. Update GameplayScreen with all systems
3. Test full level flow with obstacles + boosts
4. Performance optimization (particle counts, cache efficiency)
5. Analytics integration (obstacle difficulty, boost usage)
6. Bug fixes and edge case handling

### Critical Path Items
- **Particle system performance**: Sand trickle effect must maintain 60fps on low-end devices
- **Content pipeline reliability**: Must gracefully handle network failures, never block gameplay
- **Profanity filter coverage**: Manual review required for all 250+ level word combinations
- **Boost economy balance**: Test boost consumption rates vs. obstacle frequency

### Testing Priorities
1. Obstacle visual clarity on small screens (mobile)
2. Boost UI accessibility (large touch targets)
3. Network failure scenarios (airplane mode, slow connection)
4. Content cache corruption recovery
5. Performance with 3+ active sand obstacles on screen

---

## References

### Godot Architecture
- [Resource-based architecture for Godot 4](https://medium.com/@sfmayke/resource-based-architecture-for-godot-4-25bd4b2d9018)
- [Resources — Godot Engine documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Godot Architecture Organization Advice](https://github.com/abmarnie/godot-architecture-organization-advice)
- [Best practices — Godot Engine documentation](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html)

### Mobile Game UI/UX
- [Best Examples in Mobile Game UI Designs (2026 Review)](https://pixune.com/blog/best-examples-mobile-game-ui-design/)
- [Top 7 Stunning Mobile Game UI Designs](https://allclonescript.com/blog/mobile-game-app-ui-designs)
- [Gamification in UI/UX: The Ultimate Guide](https://www.mockplus.com/blog/post/gamification-ui-ux-design-guide)
- [Game UI Database](https://www.gameuidatabase.com/)

### Content Pipeline & OTA Updates
- [Mastering Expo EAS: Submit, OTA Updates, and Workflow Automation](https://procedure.tech/blogs/mastering-expo-eas-submit-ota-updates-and-workflow-automation)
- [CodePush: The Game-Changer for Over-the-Air Mobile App Updates](https://appcircle.io/blog/codepush-the-game-changer-for-over-the-air-mobile-app-updates)
- [How We Reduced Our App's OTA Update Costs by 90%](https://medium.com/@abijith.b/how-we-reduced-our-apps-ota-update-costs-by-90-6648939c886b)

### Profanity Filtering
- [GitHub - 2Toad/Profanity](https://github.com/2Toad/Profanity)
- [profanity-filter · PyPI](https://pypi.org/project/profanity-filter/)
- [PurgoMalum — Free Profanity Filter Web Service](https://www.purgomalum.com/)
- [Fast, Open-Source Profanity API](https://www.profanity.dev/)
- [Bad Word Filter API - Neutrino](https://www.neutrinoapi.com/api/bad-word-filter/)

### Dictionary & Word Validation
- [Word Game Dictionary API](https://www.wordgamedictionary.com/api/)
- [Merriam-Webster Dictionary API](https://dictionaryapi.com/)
- [Free Dictionary API](https://dictionaryapi.dev/)
- [WordsAPI](https://www.wordsapi.com/)
- [Wordnik API Showcase](https://developer.wordnik.com/showcase)

### Godot File I/O & HTTP
- [Best practices around HTTPRequest - Godot Forums](https://godotforums.org/d/35067-best-practices-around-httprequest)
- [Saving and Loading Games in Godot 4 (with resources)](https://www.gdquest.com/library/save_game_godot4/)
- [Choosing the right save game format](https://www.gdquest.com/tutorial/godot/best-practices/save-game-formats/)
- [Saving/loading data :: Godot 4 Recipes](https://kidscancode.org/godot_recipes/4.x/basics/file_io/index.html)

### Godot Particle Systems
- [2D particle systems — Godot Engine documentation](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html)
- [Particle systems (3D) — Godot Engine documentation](https://docs.godotengine.org/en/stable/tutorials/3d/particles/index.html)
- [State of particles and future updates – Godot Engine](https://godotengine.org/article/progress-report-state-of-particles/)

---

## Appendix: Code Snippets

### LetterSlot State Extensions

```gdscript
# Add to LetterSlot class

enum State { EMPTY, FILLED, CORRECT, INCORRECT, LOCKED, BLOCKED, SANDED }

var _is_locked: bool = false
var _is_blocked: bool = false
var _sand_level: float = 0.0

func set_locked(locked: bool) -> void:
	_is_locked = locked
	if locked:
		set_state(State.LOCKED)

func set_blocked(blocked: bool) -> void:
	_is_blocked = blocked
	if blocked:
		set_state(State.BLOCKED)

func set_sand_level(level: float) -> void:
	_sand_level = level
	if level > 0:
		set_state(State.SANDED)
	# Update shader parameter for sand fill visualization
	if material and material is ShaderMaterial:
		material.set_shader_parameter("sand_level", level)

func can_accept_input() -> bool:
	return not (_is_locked or _is_blocked or _sand_level >= 1.0)
```

### ObstacleConfig Example Resources

```gdscript
# res://data/obstacles/padlock_config.tres
[gd_resource type="Resource" script_class="ObstacleConfig" load_steps=2 format=3]

[ext_resource type="PackedScene" path="res://scenes/obstacles/padlock_obstacle.tscn" id="1"]

[resource]
obstacle_type = "padlock"
display_name = "Padlock"
description = "Locks the word until previous word is solved"
visual_scene = ExtResource("1")
activation_timing = {
	"word_index": 5,
	"trigger_type": "word_start",
	"delay_seconds": 0.0
}
effect_data = {}
```

### Content JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["land_id", "theme", "word_pairs"],
  "properties": {
    "land_id": { "type": "string" },
    "theme": { "type": "string" },
    "word_pairs": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["word_a", "word_b"],
        "properties": {
          "word_a": { "type": "string", "minLength": 2 },
          "word_b": { "type": "string", "minLength": 2 },
          "theme_tags": { "type": "array", "items": { "type": "string" } },
          "difficulty": { "type": "integer", "minimum": 1, "maximum": 5 }
        }
      }
    }
  }
}
```

---

**End of Research Document**
