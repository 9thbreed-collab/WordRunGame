# Architecture Patterns

**Domain:** Commercial mobile word puzzle game (Godot 4.5, iOS/Android)
**Project:** WordRun!
**Researched:** 2026-01-29
**Overall confidence:** HIGH (Godot 4.x patterns are well-established; domain patterns draw from Candy Crush/Wordscapes category conventions)

---

## Table of Contents

1. [Recommended Architecture Overview](#recommended-architecture-overview)
2. [Godot Scene Tree Structure](#godot-scene-tree-structure)
3. [Autoload Singletons (Global Systems)](#autoload-singletons-global-systems)
4. [Signal Architecture](#signal-architecture)
5. [Component Boundaries](#component-boundaries)
6. [Data Flow](#data-flow)
7. [Obstacle Template System Architecture](#obstacle-template-system-architecture)
8. [Cloud vs Local Data Separation](#cloud-vs-local-data-separation)
9. [Directory Structure](#directory-structure)
10. [Patterns to Follow](#patterns-to-follow)
11. [Anti-Patterns to Avoid](#anti-patterns-to-avoid)
12. [Build Order and Dependencies](#build-order-and-dependencies)
13. [Scalability Considerations](#scalability-considerations)
14. [Sources and Confidence](#sources-and-confidence)

---

## Recommended Architecture Overview

WordRun! should use a **layered architecture** with three distinct layers communicating through Godot's signal system and a thin autoload singleton layer:

```
+---------------------------------------------------------------+
|                     PRESENTATION LAYER                        |
|  (Scenes: Puzzle, WorldMap, Store, Menus, Vs Mode)            |
|  Owns: visuals, animations, input handling, UI layout         |
+---------------------------------------------------------------+
        |  signals up  |              |  calls down  |
+---------------------------------------------------------------+
|                     GAME SYSTEMS LAYER                        |
|  (Autoloads: GameManager, AudioManager, EventBus, etc.)       |
|  Owns: state machines, session lifecycle, transitions         |
+---------------------------------------------------------------+
        |  signals up  |              |  calls down  |
+---------------------------------------------------------------+
|                       DATA LAYER                              |
|  (Autoloads: DataManager, ProgressionManager, EconomyManager) |
|  Owns: persistence, cloud sync, content loading, economy      |
+---------------------------------------------------------------+
```

**Why this structure:**
- Godot's scene tree is the presentation layer naturally. Scenes are the UI/gameplay.
- Autoload singletons persist across scene changes, making them the right home for state that survives scene transitions (player data, audio, connectivity).
- Separating data concerns from game logic concerns in the autoload layer prevents the "god autoload" anti-pattern where one Manager does everything.

**Key principle from the project's own COMPONENT_DRIVEN_ARCHITECTURE_GUIDE.md:** Components are independent but interdependent through clear interfaces. This architecture respects that -- scenes are self-contained components that communicate through the EventBus, not direct references to each other.

---

## Godot Scene Tree Structure

### Runtime Scene Tree (what exists in memory during puzzle gameplay)

```
root (Viewport)
|
+-- EventBus              (autoload)
+-- GameManager            (autoload)
+-- AudioManager           (autoload)
+-- DataManager            (autoload)
+-- ProgressionManager     (autoload)
+-- EconomyManager         (autoload)
+-- AdManager              (autoload)
+-- NetworkManager         (autoload)
|
+-- Main                   (current scene root, swapped by GameManager)
    |
    +-- PuzzleScreen       (example: active gameplay scene)
        |
        +-- HUD
        |   +-- SurgeBar
        |   +-- ScoreDisplay
        |   +-- HeartDisplay
        |   +-- HintDisplay
        |   +-- TimerDisplay (Vs mode)
        |   +-- PowerBoostSlots
        |       +-- BoostSlot1
        |       +-- BoostSlot2
        |       +-- BoostSlot3
        |
        +-- ScrollingWindow
        |   +-- WordRow (x 4-5 visible)
        |   |   +-- LetterSlot (x N per word)
        |   |   +-- ObstacleOverlay (optional, per-word)
        |   +-- StarterWordRow
        |
        +-- InputSystem
        |   +-- OnScreenKeyboard (default)
        |   +-- RadialInput      (unlockable, swapped in)
        |   +-- ScrambledTiles   (unlockable, swapped in)
        |
        +-- ObstacleManager (scene-local, not autoload)
        |   +-- ActiveObstacle (instantiated from template)
        |
        +-- EffectsLayer
        |   +-- ParticleEffects
        |   +-- ScreenShake
        |
        +-- PauseOverlay
        +-- ResultsOverlay
```

### Scene File Organization

Each major screen is its own `.tscn` scene file, loaded/swapped by GameManager:

| Scene File | When Active | Root Node Type |
|-----------|-------------|----------------|
| `puzzle_screen.tscn` | During gameplay | Control |
| `world_map.tscn` | Between levels, navigation | Node2D |
| `store_screen.tscn` | Shopping | Control |
| `vs_mode_screen.tscn` | Multiplayer matches | Control |
| `auth_screen.tscn` | Login/signup | Control |
| `main_menu.tscn` | App launch (post-auth) | Control |
| `loading_screen.tscn` | Scene transitions | Control |
| `tutorial_overlay.tscn` | Overlaid on other scenes | CanvasLayer |
| `settings_screen.tscn` | Settings/options | Control |
| `inventory_screen.tscn` | Pre-game loadout | Control |
| `boss_intro.tscn` | Boss level intro | Control |

**Why Control as root for UI-heavy scenes:** WordRun is a 2D UI-driven game. `Control` nodes support Godot's layout containers (VBoxContainer, HBoxContainer, MarginContainer), which are essential for responsive mobile layouts across different screen sizes. The world map uses `Node2D` because it needs 2D spatial positioning for the map, avatar movement, and camera panning.

### Sub-Scene Composition

Reusable components are their own scenes, instantiated where needed:

```
scenes/
  components/
    word_row.tscn              # Single word row with letter slots
    letter_slot.tscn           # Single letter input space
    surge_bar.tscn             # The momentum bar
    power_boost_slot.tscn      # One boost in the HUD
    heart_display.tscn         # Hearts counter
    hint_display.tscn          # Hints counter
    obstacle_overlay.tscn      # Base obstacle visual (subclassed per type)
    npc_dialogue_box.tscn      # Dialogue UI for world map
    level_node.tscn            # Clickable level on world map
    currency_display.tscn      # Stars/diamonds counter (reused in HUD + store)
    store_item_card.tscn       # One item in the store grid
    avatar.tscn                # Ruut character (used on map + gameplay)
```

**This matters for the roadmap:** Each of these sub-scenes can be built and tested independently. The word_row + letter_slot scenes are the atomic units of the entire game and should be built first.

---

## Autoload Singletons (Global Systems)

Autoloads are registered in `project.godot` under `[autoload]`. They persist across scene changes. Use them ONLY for state/logic that must survive scene transitions.

### Recommended Autoloads

| Autoload Name | Responsibility | GDScript File |
|--------------|----------------|---------------|
| `EventBus` | Global signal relay. No logic, just signal declarations. | `scripts/autoloads/event_bus.gd` |
| `GameManager` | Scene transitions, game state machine (menu/playing/paused/results), session lifecycle | `scripts/autoloads/game_manager.gd` |
| `AudioManager` | Music/SFX playback, crossfades, volume. Persists audio across scene changes. | `scripts/autoloads/audio_manager.gd` |
| `DataManager` | Local save/load (JSON or SQLite), cloud sync orchestration, content cache | `scripts/autoloads/data_manager.gd` |
| `ProgressionManager` | Hearts/hints/lives state, stars/diamonds balances, level unlock status, login streaks | `scripts/autoloads/progression_manager.gd` |
| `EconomyManager` | IAP flow, store transactions, currency spend/earn validation | `scripts/autoloads/economy_manager.gd` |
| `AdManager` | AdMob integration, rewarded ad callbacks, custom ad network, geo-targeting | `scripts/autoloads/ad_manager.gd` |
| `NetworkManager` | HTTP requests, WebSocket for Vs mode, connectivity status, auth tokens | `scripts/autoloads/network_manager.gd` |

### What is NOT an Autoload

These are scene-local, not global:

| System | Why Not Autoload | Where It Lives |
|--------|-----------------|----------------|
| `ObstacleManager` | Only exists during puzzle gameplay. No reason to persist. | Child of `PuzzleScreen` |
| `SurgeManager` | Only exists during puzzle gameplay. Resets per level. | Child of `PuzzleScreen` |
| `WordManager` | Manages the current level's word list. Per-session. | Child of `PuzzleScreen` |
| `InputManager` | Manages keyboard/radial/tile input mode. Per-session. | Child of `PuzzleScreen` |
| `TutorialManager` | Could be autoload, but better as overlay scene instantiated by GameManager | Instantiated as CanvasLayer overlay |
| `VsMatchManager` | Only exists in Vs mode. Handles turn logic, clocks. | Child of `VsModeScreen` |

**Why this split matters:** A common Godot anti-pattern is making everything an autoload. This leads to autoloads referencing each other in complex webs, initialization order bugs, and difficulty testing. Only promote to autoload when state MUST survive scene changes.

---

## Signal Architecture

### The EventBus Pattern

Godot's built-in signal system is node-to-node: a node emits, connected nodes receive. For a game this complex, direct signal connections between distant nodes create brittle coupling. The EventBus pattern solves this.

**EventBus is a pure signal declaration autoload. It has no logic.**

```gdscript
# scripts/autoloads/event_bus.gd
extends Node

# === Puzzle Events ===
signal letter_submitted(letter: String, slot_index: int, word_index: int)
signal word_completed(word_index: int, word: String, was_correct: bool)
signal word_failed(word_index: int, word: String)
signal puzzle_completed(score: int, stars_earned: int)
signal puzzle_failed(reason: String)
signal bonus_round_started()
signal bonus_round_ended(words_completed: int)

# === Surge Events ===
signal surge_updated(current_value: float, threshold: int)
signal surge_threshold_crossed(new_threshold: int, multiplier: float)
signal surge_imminent_drain_started()
signal surge_busted()

# === Obstacle Events ===
signal obstacle_spawned(obstacle_type: String, target_word_index: int)
signal obstacle_countered(obstacle_type: String, method: String)
signal obstacle_effect_applied(obstacle_type: String, affected_words: Array)

# === Power Boost Events ===
signal boost_activated(boost_type: String, target_word_index: int)
signal boost_consumed(boost_type: String, remaining: int)
signal boost_score_bonus(boost_type: String, bonus_points: int)

# === Economy Events ===
signal currency_changed(currency_type: String, new_amount: int, delta: int)
signal purchase_completed(item_id: String)
signal purchase_failed(item_id: String, reason: String)

# === Progression Events ===
signal heart_changed(current: int, max_val: int)
signal hint_changed(current: int, max_val: int)
signal life_lost(remaining: int)
signal level_unlocked(nation: int, land: int, level: int)
signal login_streak_updated(days: int)

# === Navigation Events ===
signal scene_change_requested(scene_name: String, transition: String)
signal scene_loaded(scene_name: String)

# === Ad Events ===
signal rewarded_ad_completed(reward_type: String)
signal rewarded_ad_cancelled()
signal interstitial_closed()

# === Vs Mode Events ===
signal vs_turn_started(player_id: String)
signal vs_turn_ended(player_id: String, words_solved: int)
signal vs_match_ended(winner_id: String)

# === Tutorial Events ===
signal tutorial_triggered(tutorial_id: String)
signal tutorial_completed(tutorial_id: String)
```

### Signal Flow Rules

**Rule 1: Signals go UP, calls go DOWN.**
- A child node emits a signal. Its parent (or any connected node) handles it.
- A parent node calls methods on its children directly (it owns them, it knows they exist).
- Siblings NEVER call each other directly. They communicate through their common parent or the EventBus.

**Rule 2: Scene-internal signals use direct connections. Cross-scene signals use EventBus.**
- Within `PuzzleScreen`, `LetterSlot` emits directly to `WordRow` (parent-child).
- `WordRow` emits to `PuzzleScreen` (parent-child).
- `PuzzleScreen` uses `EventBus` to notify `ProgressionManager` that a level completed (cross-scene/autoload boundary).

**Rule 3: Autoloads listen to EventBus. Scenes emit to EventBus.**
- Scenes do: `EventBus.puzzle_completed.emit(score, stars)`
- Autoloads do: `EventBus.puzzle_completed.connect(_on_puzzle_completed)` in their `_ready()`

**Rule 4: No circular signal chains.**
- If A signals B and B signals A, you have a loop. Restructure so one direction uses a direct call instead.

### Connection Lifecycle

```gdscript
# In a scene's script:
func _ready():
    # Connect to EventBus signals this scene cares about
    EventBus.obstacle_spawned.connect(_on_obstacle_spawned)
    EventBus.surge_busted.connect(_on_surge_busted)

func _exit_tree():
    # Godot 4 auto-disconnects signals when nodes are freed,
    # BUT only if using Callable connections (not string-based).
    # Since we use Callable syntax above, cleanup is automatic.
    pass

# Emitting to EventBus:
func _on_word_completed(word_index: int, word: String):
    EventBus.word_completed.emit(word_index, word, true)
```

---

## Component Boundaries

### Boundary Map

This table defines what each major component owns, what it exposes, and what it depends on.

| Component | Owns | Exposes (Signals/Methods) | Depends On |
|-----------|------|---------------------------|------------|
| **PuzzleScreen** | Level session state, word list for current level, scroll position | `puzzle_completed`, `puzzle_failed` via EventBus | DataManager (level data), ProgressionManager (hearts/hints), GameManager (scene lifecycle) |
| **ScrollingWindow** | Visual scroll position, visible word rows, word advancement | `scroll_position_changed` (local signal) | PuzzleScreen (word data), ObstacleManager (overlay placement) |
| **WordRow** | Letter slots for one word, completion state, visual state (frozen, locked, etc.) | `word_submitted(word, correct)` local signal to parent | ScrollingWindow (position), ObstacleOverlay (visual effects) |
| **LetterSlot** | Single letter state (empty, filled, correct, incorrect), cursor state | `letter_entered(letter)` local signal | WordRow (validation context) |
| **SurgeBar** | Current surge value, drain rate, threshold state | `surge_updated`, `surge_busted` via EventBus | PuzzleScreen (correct/incorrect events to feed surge) |
| **ObstacleManager** | Active obstacles for this level, spawn timing, template instantiation | `obstacle_spawned`, `obstacle_countered` via EventBus | DataManager (obstacle config), WordRow (target words) |
| **ObstacleInstance** | Single obstacle lifecycle: animation, effect, counter condition | `effect_applied`, `countered` local signals | ObstacleManager (lifecycle), WordRow (target) |
| **InputSystem** | Current input mode, key presses, letter selection | `letter_selected(letter)` local signal | PuzzleScreen (routing to active LetterSlot) |
| **PowerBoostSlots** | Equipped boost inventory for this session | `boost_activated` via EventBus | ProgressionManager (inventory), ObstacleManager (boost targets) |
| **WorldMap** | Camera position, avatar position, visible nations/lands/levels | `level_selected(nation, land, level)` via EventBus | DataManager (map structure), ProgressionManager (unlock state) |
| **StoreScreen** | Item catalog display, purchase flow UI | `purchase_requested` via EventBus | EconomyManager (transactions), ProgressionManager (balances) |
| **VsModeScreen** | Match state, turn management, dual clocks | `vs_turn_started`, `vs_match_ended` via EventBus | NetworkManager (multiplayer), PuzzleScreen (embeds puzzle gameplay) |
| **GameManager** | Current scene, state machine, transitions | `scene_loaded` via EventBus, `change_scene()` method | All autoloads (orchestrates them) |
| **DataManager** | Local cache, cloud sync, content fetch | `data_loaded`, `sync_completed` via EventBus | NetworkManager (cloud calls) |
| **ProgressionManager** | Player progress state, currency balances, hearts/hints/lives | `heart_changed`, `currency_changed` via EventBus | DataManager (persistence) |
| **EconomyManager** | IAP validation, transaction processing | `purchase_completed` via EventBus | NetworkManager (store APIs), ProgressionManager (balance updates) |

### Boundary Enforcement Rules

1. **Scenes never import other scene scripts.** They communicate through EventBus or parent-child relationships.
2. **Autoloads may reference other autoloads** but only through their public API (methods/signals), never internal state.
3. **No scene holds a reference to another scene.** If PuzzleScreen needs to open the Store, it emits `EventBus.scene_change_requested.emit("store", "slide_left")` and GameManager handles the transition.
4. **Data flows one way through the stack:** DataManager -> ProgressionManager -> Scenes. Scenes never write to DataManager directly; they emit events that ProgressionManager processes, and ProgressionManager calls DataManager to persist.

---

## Data Flow

### Puzzle Session Data Flow (the core loop)

```
LEVEL START:
  GameManager.start_level(nation, land, level)
    -> DataManager.load_level_data(nation, land, level) -> returns LevelData resource
    -> ProgressionManager.get_equipped_boosts() -> returns Array[BoostData]
    -> ProgressionManager.get_hearts() -> returns int
    -> GameManager.change_scene("puzzle_screen", {level_data, boosts, hearts})
    -> PuzzleScreen._ready() receives data, builds word rows, initializes surge bar

DURING PLAY:
  Player taps letter on InputSystem
    -> InputSystem emits letter_selected("A") (local signal)
    -> PuzzleScreen routes to active LetterSlot
    -> LetterSlot.set_letter("A") updates visual
    -> If word complete: WordRow validates against answer
       -> If correct: WordRow emits word_submitted(word, true)
          -> PuzzleScreen advances cursor to next word
          -> PuzzleScreen calls SurgeBar.add_correct()
          -> SurgeBar updates value, checks thresholds
          -> If threshold crossed: EventBus.surge_threshold_crossed.emit(...)
          -> ScrollingWindow scrolls up
       -> If incorrect: WordRow emits word_submitted(word, false)
          -> PuzzleScreen clears non-first letters
          -> PuzzleScreen calls SurgeBar.add_incorrect()
          -> SurgeBar drains faster

OBSTACLE SPAWN:
  ObstacleManager checks spawn conditions each word advancement
    -> If spawn triggered: instantiates ObstacleInstance from template
    -> ObstacleInstance plays entrance animation
    -> EventBus.obstacle_spawned.emit(type, target_word_index)
    -> WordRow receives, applies visual overlay
    -> ObstacleInstance applies mechanical effect (lock word, fill spaces, etc.)

POWER BOOST USE:
  Player taps PowerBoostSlot
    -> If obstacle active on current word: applies counter effect
       -> EventBus.boost_activated.emit(boost_type, target)
       -> ObstacleInstance receives, plays counter animation
       -> EventBus.obstacle_countered.emit(type, "boost")
       -> EventBus.boost_consumed.emit(boost_type, remaining)
    -> If no obstacle: applies score bonus
       -> EventBus.boost_score_bonus.emit(boost_type, bonus)
       -> EventBus.boost_consumed.emit(boost_type, remaining)

LEVEL END:
  PuzzleScreen detects all 12 words solved (or fail condition)
    -> If momentum qualifies: enters bonus round (3 more words)
    -> Calculates final score with multipliers
    -> EventBus.puzzle_completed.emit(score, stars_earned)
    -> ProgressionManager.record_level_completion(nation, land, level, score, stars)
    -> ProgressionManager updates hearts carry-over
    -> DataManager.save_progress() (local first, then cloud sync)
    -> PuzzleScreen shows ResultsOverlay
    -> Player taps continue -> EventBus.scene_change_requested.emit("world_map")
```

### Economy Data Flow

```
EARN CURRENCY:
  EventBus.puzzle_completed -> ProgressionManager
    -> ProgressionManager.add_stars(earned_stars)
    -> ProgressionManager.check_diamond_discovery(score) -> first stellar play triggers tutorial
    -> EventBus.currency_changed.emit("stars", new_total, +earned)
    -> DataManager.save_progress()

SPEND CURRENCY:
  StoreScreen: player taps "Buy Power Pack (50 stars)"
    -> StoreScreen emits EventBus.purchase_requested("power_pack_basic", "stars", 50)
    -> EconomyManager validates balance via ProgressionManager.get_stars()
    -> If sufficient: EconomyManager.process_purchase()
       -> ProgressionManager.deduct_stars(50)
       -> ProgressionManager.add_boosts(pack_contents)
       -> EventBus.purchase_completed.emit("power_pack_basic")
       -> DataManager.save_progress()
    -> If insufficient: EventBus.purchase_failed.emit("power_pack_basic", "insufficient_stars")

IAP (Real Money):
  StoreScreen: player taps "Buy 500 Diamonds ($4.99)"
    -> EconomyManager initiates platform IAP flow (App Store / Google Play)
    -> Platform returns receipt
    -> NetworkManager.validate_receipt(receipt) -> server-side validation
    -> If valid: ProgressionManager.add_diamonds(500)
    -> EventBus.purchase_completed.emit("diamonds_500")
    -> DataManager.save_progress()
```

### State Persistence Flow

```
LOCAL SAVE (immediate, every state change):
  ProgressionManager state change
    -> DataManager.save_local(progress_data)
    -> Writes to user://save_data.json (encrypted)

CLOUD SYNC (periodic + on key events):
  Key events: level_completed, purchase_completed, app_backgrounded
    -> DataManager.sync_to_cloud(progress_data)
    -> NetworkManager.post("/api/progress", data)
    -> On success: DataManager.mark_synced()
    -> On failure: DataManager.queue_for_retry()

CLOUD LOAD (app launch):
  DataManager._ready()
    -> Load local save
    -> NetworkManager.get("/api/progress")
    -> Compare timestamps
    -> Use newer data (with conflict resolution for currencies: always use server)
    -> Merge into ProgressionManager
```

---

## Obstacle Template System Architecture

This is one of the most architecturally important systems in WordRun because it must support 9 obstacle types total (3 in v1, 6 in future Nations) without requiring new code paths for each.

### Design: Resource-Based Configuration + Polymorphic Scenes

**The Template Pattern:**

Each obstacle type is defined by two things:
1. A `Resource` file (`.tres`) containing all configuration data
2. A scene file (`.tscn`) containing only the visual/animation differences

The obstacle logic is shared across all types through a base class.

### Configuration Resource

```gdscript
# scripts/resources/obstacle_config.gd
class_name ObstacleConfig
extends Resource

## Identity
@export var obstacle_id: String                  # "padlock", "sand", "random_blocks"
@export var display_name: String                 # "Padlock"
@export var nation_introduced: int               # 1, 2, 3...

## Targeting
@export var target_mode: String                  # "single_word", "multi_word", "area"
@export var target_count_min: int = 1            # Min words affected
@export var target_count_max: int = 1            # Max words affected
@export var target_selection: String             # "next_unsolved", "random", "range"

## Effect
@export var effect_type: String                  # "lock", "fill_spaces", "obscure", "timed_destroy"
@export var effect_params: Dictionary = {}       # Type-specific params
# Examples:
#   padlock:       { "unlock_method": "solve_next_word" }
#   random_blocks: { "fill_rate": 0.3, "self_solve_on_full": true, "zero_points_on_self_solve": true }
#   sand:          { "fill_rate": 0.1, "trickle_on_scroll": true, "max_affected_words": 5 }

## Counter Conditions
@export var counter_conditions: Array[Dictionary] = []
# Each: { "method": "solve_consecutive", "count": 3 }
# Or:   { "method": "solve_next_word" }
# Or:   { "method": "solve_affected_fast", "time_limit": 10.0 }

## Power Boost Interaction
@export var counter_boost_id: String             # "lock_key", "block_breaker", "bucket_of_water"
@export var boost_max_targets: int = 1           # bucket_of_water: 3

## Visual
@export var entrance_animation: String           # "fall_from_top", "rise_from_bottom", "appear"
@export var idle_animation: String               # "pulse", "drip", "shake"
@export var counter_animation: String            # "shatter", "drain", "dissolve"
@export var particle_effect: String              # "snowflakes", "sand_grains", "sparks"

## Audio
@export var spawn_sfx: String                    # "res://assets/audio/sfx/obstacle_padlock_spawn.ogg"
@export var idle_sfx: String
@export var counter_sfx: String

## Timing
@export var spawn_earliest_word: int = 3         # Don't spawn before word 3
@export var spawn_probability_base: float = 0.15 # Base chance per word advancement
@export var spawn_probability_growth: float = 0.05  # Increase per Nation progression
@export var max_simultaneous: int = 1            # How many can be active at once
```

### Obstacle Base Class

```gdscript
# scripts/obstacles/obstacle_base.gd
class_name ObstacleBase
extends Node2D

var config: ObstacleConfig
var target_word_indices: Array[int] = []
var is_active: bool = false
var is_countered: bool = false

# Visual components (overridden by specific obstacle scenes)
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func initialize(obstacle_config: ObstacleConfig, targets: Array[int]) -> void:
    config = obstacle_config
    target_word_indices = targets
    is_active = true
    _play_entrance()

func _play_entrance() -> void:
    if animation_player.has_animation(config.entrance_animation):
        animation_player.play(config.entrance_animation)
    await animation_player.animation_finished
    _apply_effect()
    EventBus.obstacle_spawned.emit(config.obstacle_id, target_word_indices[0])

func _apply_effect() -> void:
    # Base implementation dispatches to effect handlers
    match config.effect_type:
        "lock":
            _apply_lock_effect()
        "fill_spaces":
            _apply_fill_effect()
        "obscure":
            _apply_obscure_effect()
        "timed_destroy":
            _apply_timed_destroy_effect()

func check_counter_condition(event: String, data: Dictionary) -> bool:
    for condition in config.counter_conditions:
        if _evaluate_condition(condition, event, data):
            return true
    return false

func counter_with_boost(boost_type: String) -> void:
    if boost_type == config.counter_boost_id:
        _counter()

func _counter() -> void:
    is_countered = true
    is_active = false
    if animation_player.has_animation(config.counter_animation):
        animation_player.play(config.counter_animation)
    EventBus.obstacle_countered.emit(config.obstacle_id, "countered")
    await animation_player.animation_finished
    queue_free()

# Override these in subclass scenes only for unique visual behavior
func _apply_lock_effect() -> void:
    EventBus.obstacle_effect_applied.emit(config.obstacle_id, target_word_indices)

func _apply_fill_effect() -> void:
    EventBus.obstacle_effect_applied.emit(config.obstacle_id, target_word_indices)

# ... etc
```

### Per-Obstacle Scenes (Visual Only)

```
scenes/obstacles/
  obstacle_padlock.tscn     -> ObstacleBase script (or tiny extension)
    +-- Sprite2D (padlock graphic)
    +-- AnimationPlayer (fall, lock, shatter animations)
    +-- AudioStreamPlayer2D

  obstacle_random_blocks.tscn
    +-- Sprite2D (wood block graphic)
    +-- AnimationPlayer (appear, fill, break animations)
    +-- AudioStreamPlayer2D

  obstacle_sand.tscn
    +-- Sprite2D (sand particle graphic)
    +-- GPUParticles2D (trickling sand)
    +-- AnimationPlayer (pour, settle, wash animations)
    +-- AudioStreamPlayer2D
```

### Configuration Files (Data-Driven)

```
data/obstacles/
  padlock.tres        -> ObstacleConfig resource
  random_blocks.tres  -> ObstacleConfig resource
  sand.tres           -> ObstacleConfig resource
  # Future:
  ice.tres
  charcoal.tres
  acid.tres
  flood.tres
  acorn.tres
  magnet.tres
```

### Adding a New Obstacle (Nations 4-9)

To add the "Ice" obstacle for Nation 4:

1. Create `data/obstacles/ice.tres` with ObstacleConfig values (no code)
2. Create `scenes/obstacles/obstacle_ice.tscn` with the snowflake sprites and animations (no code, or minimal visual script extending ObstacleBase)
3. Add art assets: `assets/sprites/obstacles/ice_snowflake.png`, etc.
4. Add audio: `assets/audio/sfx/obstacle_ice_spawn.ogg`, etc.
5. Register in `data/obstacles/obstacle_registry.tres` (a simple array of which obstacles are active)

**Zero new GDScript code paths required.** The base system handles targeting, effect application, counter conditions, and boost interactions entirely from the config resource. Only truly unique visual behavior (like the acorn's growing tree) would need a small script extension.

### ObstacleManager (Scene-Local)

```gdscript
# scripts/puzzle/obstacle_manager.gd
class_name ObstacleManager
extends Node

var obstacle_registry: Array[ObstacleConfig] = []
var active_obstacles: Array[ObstacleBase] = []
var current_nation: int = 1

func _ready():
    # Load obstacle configs for current nation
    var configs = DataManager.get_obstacle_configs(current_nation)
    obstacle_registry = configs
    EventBus.word_completed.connect(_on_word_completed)

func _on_word_completed(word_index: int, word: String, correct: bool):
    # Check if existing obstacles are countered
    for obstacle in active_obstacles:
        if obstacle.check_counter_condition("word_completed", {
            "word_index": word_index, "correct": correct
        }):
            obstacle._counter()
            active_obstacles.erase(obstacle)

    # Check if new obstacle should spawn
    if correct and _should_spawn(word_index):
        _spawn_obstacle(word_index)

func _should_spawn(word_index: int) -> bool:
    if active_obstacles.size() >= _max_simultaneous():
        return false
    var probability = _calculate_spawn_probability(word_index)
    return randf() < probability

func _spawn_obstacle(after_word_index: int) -> void:
    var config = _select_obstacle_type()
    var targets = _select_targets(config, after_word_index)
    var scene_path = "res://scenes/obstacles/obstacle_%s.tscn" % config.obstacle_id
    var obstacle_scene = load(scene_path).instantiate()
    add_child(obstacle_scene)
    obstacle_scene.initialize(config, targets)
    active_obstacles.append(obstacle_scene)
```

---

## Cloud vs Local Data Separation

### What Lives Where

| Data Category | Local | Cloud | Sync Strategy |
|--------------|-------|-------|---------------|
| **Player progress** (level completion, stars earned per level) | Yes (primary for gameplay) | Yes (authoritative for conflicts) | Bidirectional, server wins on conflict |
| **Currency balances** (stars, diamonds) | Yes (cache) | Yes (authoritative, always) | Server authoritative. Local is display cache. All mutations go through server. |
| **Inventory** (owned boosts, skins) | Yes (cache) | Yes (authoritative) | Server authoritative |
| **Level content** (word pairs, level configs) | Yes (cached after first fetch) | Yes (source of truth) | Pull on demand, cache locally, version-check for updates |
| **Obstacle configs** | Bundled with app | Cloud for balance updates | App ships defaults. Cloud overrides enable hotfix balancing. |
| **Player preferences** (volume, input mode) | Yes (only) | No | Local only. Lost on reinstall. Acceptable tradeoff. |
| **Auth tokens** | Yes (Keychain/Keystore) | N/A | Standard OAuth token refresh flow |
| **IAP receipts** | No | Yes (server validates) | Client sends receipt, server validates and records |
| **Vs mode match state** | No | Yes (real-time) | Server authoritative. Client is thin display. |
| **Ad configuration** | No | Yes | Pulled at app launch, cached briefly |
| **World map state** (current position, NPC flags) | Yes (cache) | Yes (authoritative) | Sync on session boundaries |

### DataManager Architecture

```gdscript
# scripts/autoloads/data_manager.gd
extends Node

# Local persistence
var local_store: LocalStore  # Wraps FileAccess with encryption

# Cloud interface
var cloud_client: CloudClient  # Wraps NetworkManager HTTP calls

# Content cache
var level_cache: Dictionary = {}  # nation_land_level -> LevelData
var obstacle_cache: Dictionary = {}  # obstacle_id -> ObstacleConfig

# Sync state
var pending_sync: Array[Dictionary] = []  # Queue of changes to push
var last_sync_timestamp: int = 0

func _ready():
    local_store = LocalStore.new()
    cloud_client = CloudClient.new()
    _load_local_state()
    _attempt_cloud_sync()

func save_progress(progress: Dictionary) -> void:
    # Always save locally first (instant, works offline)
    local_store.save("progress", progress)
    # Queue for cloud sync
    pending_sync.append({"type": "progress", "data": progress, "timestamp": Time.get_unix_time_from_system()})
    _attempt_cloud_sync()

func load_level_data(nation: int, land: int, level: int) -> LevelData:
    var key = "%d_%d_%d" % [nation, land, level]
    if level_cache.has(key):
        return level_cache[key]
    # Try local cache
    var local = local_store.load("levels/%s" % key)
    if local:
        level_cache[key] = local
        return local
    # Fetch from cloud
    var cloud = await cloud_client.get_level(nation, land, level)
    if cloud:
        local_store.save("levels/%s" % key, cloud)
        level_cache[key] = cloud
        return cloud
    # Fallback: return null, handle in UI
    return null
```

### Offline-First Principle

The game must be playable offline for single-player content. This means:

1. **Level data is pre-fetched and cached.** When a player enters a new Land on the world map, DataManager fetches all level data for that Land (batch of ~10-15 levels) and caches locally.
2. **Progress saves locally first, syncs when online.** The player never waits for a network call to continue playing.
3. **Currency operations that require server validation (IAP, diamond spends) are online-only.** Star spends can work offline with local validation and server reconciliation later.
4. **Vs mode is online-only.** Obvious -- it is multiplayer.
5. **Rewarded ads require connectivity.** If offline, show the cooldown penalty box instead.

---

## Directory Structure

### Recommended `res://` Structure

```
res://
|
+-- project.godot
+-- icon.svg
|
+-- scenes/
|   +-- main.tscn                           # Entry point, managed by GameManager
|   +-- screens/
|   |   +-- puzzle_screen.tscn
|   |   +-- world_map.tscn
|   |   +-- store_screen.tscn
|   |   +-- vs_mode_screen.tscn
|   |   +-- auth_screen.tscn
|   |   +-- main_menu.tscn
|   |   +-- loading_screen.tscn
|   |   +-- settings_screen.tscn
|   |   +-- inventory_screen.tscn
|   |   +-- boss_intro.tscn
|   |
|   +-- components/
|   |   +-- puzzle/
|   |   |   +-- scrolling_window.tscn
|   |   |   +-- word_row.tscn
|   |   |   +-- letter_slot.tscn
|   |   |   +-- surge_bar.tscn
|   |   |   +-- power_boost_slot.tscn
|   |   |
|   |   +-- hud/
|   |   |   +-- heart_display.tscn
|   |   |   +-- hint_display.tscn
|   |   |   +-- score_display.tscn
|   |   |   +-- timer_display.tscn
|   |   |   +-- currency_display.tscn
|   |   |
|   |   +-- world_map/
|   |   |   +-- level_node.tscn
|   |   |   +-- avatar.tscn
|   |   |   +-- npc_dialogue_box.tscn
|   |   |   +-- nation_region.tscn
|   |   |
|   |   +-- store/
|   |   |   +-- store_item_card.tscn
|   |   |   +-- purchase_confirmation.tscn
|   |   |
|   |   +-- shared/
|   |       +-- popup_dialog.tscn
|   |       +-- loading_spinner.tscn
|   |       +-- transition_overlay.tscn
|   |       +-- penalty_box.tscn
|   |
|   +-- obstacles/
|   |   +-- obstacle_padlock.tscn
|   |   +-- obstacle_random_blocks.tscn
|   |   +-- obstacle_sand.tscn
|   |
|   +-- input/
|   |   +-- on_screen_keyboard.tscn
|   |   +-- radial_input.tscn
|   |   +-- scrambled_tiles.tscn
|   |
|   +-- overlays/
|       +-- tutorial_overlay.tscn
|       +-- results_overlay.tscn
|       +-- pause_overlay.tscn
|       +-- rewarded_ad_prompt.tscn
|
+-- scripts/
|   +-- autoloads/
|   |   +-- event_bus.gd
|   |   +-- game_manager.gd
|   |   +-- audio_manager.gd
|   |   +-- data_manager.gd
|   |   +-- progression_manager.gd
|   |   +-- economy_manager.gd
|   |   +-- ad_manager.gd
|   |   +-- network_manager.gd
|   |
|   +-- screens/
|   |   +-- puzzle_screen.gd
|   |   +-- world_map.gd
|   |   +-- store_screen.gd
|   |   +-- vs_mode_screen.gd
|   |   +-- auth_screen.gd
|   |   +-- main_menu.gd
|   |   +-- inventory_screen.gd
|   |
|   +-- puzzle/
|   |   +-- scrolling_window.gd
|   |   +-- word_row.gd
|   |   +-- letter_slot.gd
|   |   +-- surge_manager.gd
|   |   +-- obstacle_manager.gd
|   |   +-- word_validator.gd
|   |   +-- bonus_round.gd
|   |
|   +-- obstacles/
|   |   +-- obstacle_base.gd
|   |   +-- effects/
|   |       +-- lock_effect.gd
|   |       +-- fill_effect.gd
|   |       +-- obscure_effect.gd
|   |       +-- timed_destroy_effect.gd
|   |
|   +-- input/
|   |   +-- input_base.gd
|   |   +-- on_screen_keyboard.gd
|   |   +-- radial_input.gd
|   |   +-- scrambled_tiles.gd
|   |
|   +-- world_map/
|   |   +-- map_camera.gd
|   |   +-- avatar_controller.gd
|   |   +-- level_node.gd
|   |   +-- npc_controller.gd
|   |
|   +-- resources/
|   |   +-- obstacle_config.gd
|   |   +-- level_data.gd
|   |   +-- boost_data.gd
|   |   +-- store_item_data.gd
|   |   +-- player_progress.gd
|   |
|   +-- utils/
|       +-- local_store.gd
|       +-- cloud_client.gd
|       +-- encryption_helper.gd
|       +-- screen_size_helper.gd
|
+-- data/
|   +-- obstacles/
|   |   +-- padlock.tres
|   |   +-- random_blocks.tres
|   |   +-- sand.tres
|   |
|   +-- boosts/
|   |   +-- lock_key.tres
|   |   +-- block_breaker.tres
|   |   +-- bucket_of_water.tres
|   |
|   +-- themes/
|   |   +-- nation_1_theme.tres
|   |   +-- nation_2_theme.tres
|   |   +-- nation_3_theme.tres
|   |
|   +-- tutorials/
|       +-- tutorial_basic_input.tres
|       +-- tutorial_surge.tres
|       +-- tutorial_obstacle_padlock.tres
|       +-- tutorial_boost.tres
|       +-- tutorial_diamonds.tres
|
+-- assets/
|   +-- fonts/
|   |   +-- primary.ttf
|   |   +-- score.ttf
|   |
|   +-- sprites/
|   |   +-- obstacles/
|   |   +-- boosts/
|   |   +-- world_map/
|   |   +-- characters/
|   |   +-- puzzle/
|   |
|   +-- audio/
|   |   +-- music/
|   |   +-- sfx/
|   |
|   +-- ui/
|   |   +-- buttons/
|   |   +-- panels/
|   |   +-- icons/
|   |
|   +-- themes/
|       +-- default_theme.tres        # Godot Theme resource for consistent UI styling
|
+-- addons/                           # Third-party Godot plugins
    +-- (admob plugin)
    +-- (auth plugin, if using one)
```

### Why This Structure

- **scripts/ mirrors scenes/ categories** so you can find the script for any scene predictably.
- **resources/ under scripts/** because custom Resource classes are GDScript files, not scenes.
- **data/ at top level** because `.tres` resource files are content, not code. Designers and content tools write to `data/`, developers write to `scripts/`.
- **assets/ organized by type then category** because Godot's import system works per-file, and you want all sprites together for import settings consistency.
- **addons/ for third-party** keeps external code separate. Godot's plugin system expects this location.

---

## Patterns to Follow

### Pattern 1: Resource-as-Configuration

**What:** Use Godot's custom `Resource` classes for all game data that could vary between instances (levels, obstacles, boosts, store items). Resources are `.tres` files editable in Godot's inspector.

**When:** Any data that defines "what something is" rather than "how something behaves."

**Why:** Resources are lightweight, serializable, editable in-editor, and hot-reloadable. They separate data from logic cleanly. They can be loaded from disk or received from cloud and instantiated identically.

```gdscript
# Define once:
class_name LevelData
extends Resource

@export var nation: int
@export var land: int
@export var level: int
@export var starter_word: String
@export var word_pairs: Array[Dictionary]  # [{word: "door", pair_with: "car"}, ...]
@export var bonus_words: Array[Dictionary]
@export var obstacle_pool: Array[String]   # ["padlock"] for Nation 1
@export var star_thresholds: Array[int]    # [1000, 2500, 5000] for 1/2/3 stars
@export var is_boss: bool = false
@export var boss_config: Dictionary = {}

# Use everywhere:
var level: LevelData = load("res://data/levels/1_1_1.tres")
# Or from cloud:
var level: LevelData = DataManager.load_level_data(1, 1, 1)
```

### Pattern 2: State Machine for Game Flow

**What:** GameManager uses an explicit state machine for the overall app state. No ad-hoc boolean flags.

**When:** Managing which screen is active, what transitions are valid, what should happen on app background/foreground.

```gdscript
enum GameState {
    LOADING,
    AUTH,
    MAIN_MENU,
    WORLD_MAP,
    INVENTORY,
    PUZZLE_PLAYING,
    PUZZLE_PAUSED,
    PUZZLE_RESULTS,
    STORE,
    VS_LOBBY,
    VS_PLAYING,
    SETTINGS,
}

var current_state: GameState = GameState.LOADING

func transition_to(new_state: GameState, data: Dictionary = {}) -> void:
    var old_state = current_state
    if not _is_valid_transition(old_state, new_state):
        push_warning("Invalid state transition: %s -> %s" % [
            GameState.keys()[old_state], GameState.keys()[new_state]
        ])
        return
    current_state = new_state
    _on_exit_state(old_state)
    _on_enter_state(new_state, data)
```

### Pattern 3: Scene Swap via GameManager

**What:** All major screen transitions go through GameManager, which handles the scene tree swap, transition animations, and loading screens.

**When:** Any time the player moves between major screens (map -> puzzle, puzzle -> results, menu -> store).

```gdscript
# In GameManager:
func change_scene(scene_path: String, transition: String = "fade", data: Dictionary = {}) -> void:
    var tree = get_tree()
    # Play transition out
    await _play_transition_out(transition)
    # Remove current scene
    var current = tree.current_scene
    current.queue_free()
    # Load new scene
    var new_scene = load(scene_path).instantiate()
    tree.root.add_child(new_scene)
    tree.current_scene = new_scene
    # Pass data to new scene
    if new_scene.has_method("initialize"):
        new_scene.initialize(data)
    # Play transition in
    await _play_transition_in(transition)
    EventBus.scene_loaded.emit(scene_path)
```

**For larger scenes, use `ResourceLoader` for background loading:**

```gdscript
func change_scene_async(scene_path: String, data: Dictionary = {}) -> void:
    # Show loading screen
    _show_loading_screen()
    # Start background load
    ResourceLoader.load_threaded_request(scene_path)
    # Poll until ready
    while true:
        var status = ResourceLoader.load_threaded_get_status(scene_path)
        if status == ResourceLoader.THREAD_LOAD_LOADED:
            break
        elif status == ResourceLoader.THREAD_LOAD_FAILED:
            push_error("Failed to load scene: %s" % scene_path)
            return
        await get_tree().process_frame
    # Instantiate and swap
    var packed = ResourceLoader.load_threaded_get(scene_path)
    # ... (same swap logic as above)
```

### Pattern 4: Composition Over Inheritance for Gameplay Components

**What:** Build complex behaviors by composing nodes, not deep inheritance chains.

**When:** Word rows, letter slots, obstacles -- anything where behavior varies but structure is similar.

```
WordRow (script: word_row.gd)
  +-- LetterSlot (x N, instances of letter_slot.tscn)
  +-- ObstacleOverlay (optional child, added/removed dynamically)
  +-- AnimationPlayer (for row-level animations)
  +-- AudioStreamPlayer2D (for row-level sounds)
```

WordRow does not inherit from anything complex. It composes LetterSlot children and an optional ObstacleOverlay. The overlay is its own scene with its own script. This means you can change obstacle visuals without touching WordRow code.

### Pattern 5: Responsive Layout with Control Containers

**What:** Use Godot's layout containers (VBoxContainer, HBoxContainer, MarginContainer, AspectRatioContainer) for all UI, not manual positioning.

**When:** All screens, all HUD elements, all menus.

**Why:** Mobile games run on hundreds of different screen sizes and aspect ratios. Manual positioning breaks on different devices. Container-based layout adapts automatically.

```
PuzzleScreen (Control, anchors: full rect)
  +-- MarginContainer (safe area padding)
      +-- VBoxContainer (vertical stack)
          +-- HUD (HBoxContainer, size_flags_vertical: 0)
          |   +-- HeartDisplay
          |   +-- ScoreDisplay
          |   +-- SurgeBar (size_flags_horizontal: EXPAND_FILL)
          +-- ScrollingWindow (Control, size_flags_vertical: EXPAND_FILL)
          +-- InputSystem (VBoxContainer, size_flags_vertical: 0)
              +-- OnScreenKeyboard
```

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: The God Autoload

**What:** Putting all game logic in a single autoload like "GameManager" that handles scenes, saves, economy, audio, progression, ads, and networking.

**Why bad:** Becomes an unmaintainable 2000+ line file. Every change risks breaking unrelated systems. Impossible to test in isolation. Initialization order becomes a nightmare.

**Instead:** Split into focused autoloads (as recommended above). Each autoload has ONE domain. GameManager handles scene flow. DataManager handles persistence. ProgressionManager handles player state. They talk through EventBus, not direct references to each other's internals.

### Anti-Pattern 2: Direct Node Path References Across Scenes

**What:** Using `get_node("/root/PuzzleScreen/HUD/SurgeBar")` from inside a different scene or autoload.

**Why bad:** Breaks instantly when scene tree structure changes. Creates invisible coupling. The calling code "knows" the internal structure of a scene it does not own.

**Instead:** Use EventBus signals for cross-scene communication. Use `@onready var` for within-scene references (parent knows its children). Use `get_tree().get_nodes_in_group("surge_bar")` if you must find a node dynamically (but prefer signals).

### Anti-Pattern 3: Storing Game State in Scene Nodes

**What:** Keeping the player's star count as a variable on the HUD's `ScoreDisplay` node, or the player's hearts as a variable on the `HeartDisplay`.

**Why bad:** When the scene is freed (scene change), that state is lost. You have to reconstruct it from save data every time. Bugs arise when display state and actual state diverge.

**Instead:** State lives in autoloads (ProgressionManager). Display nodes READ from ProgressionManager and LISTEN to EventBus signals for updates. Display is a projection of state, not the state itself.

### Anti-Pattern 4: Hardcoded Obstacle Behavior

**What:** Writing a separate script for each obstacle type with unique logic paths: `padlock_obstacle.gd`, `sand_obstacle.gd`, `ice_obstacle.gd`, each implementing their own spawn/effect/counter logic.

**Why bad:** 9 obstacle types means 9 scripts with duplicated boilerplate. Bug fixes have to be applied 9 times. Adding a new obstacle requires understanding all existing scripts.

**Instead:** The Resource-based template system described above. One `ObstacleBase` script with configuration-driven behavior. New obstacles = new `.tres` config + new `.tscn` visuals. Zero new logic code for most obstacles.

### Anti-Pattern 5: Synchronous Cloud Calls

**What:** Blocking gameplay while waiting for a cloud response: `var data = await NetworkManager.get(url)` in `_ready()` before anything renders.

**Why bad:** On poor connections (common on mobile), the game freezes. Users see a blank screen. App store reviewers reject apps that hang.

**Instead:** Local-first. Load from local cache, render immediately, sync in background. If cloud data differs, merge/update after the fact. The player's experience is never gated on network availability for single-player content.

### Anti-Pattern 6: Polling in _process() for Rare Events

**What:** Checking every frame whether an obstacle should spawn, whether a purchase completed, whether the surge busted.

**Why bad:** Wastes CPU (mobile battery life matters). Most frames, nothing happens.

**Instead:** Use signals for events. Use timers (Godot's `Timer` node or `create_tween()`) for time-based checks. Reserve `_process()` for things that genuinely need per-frame updates: surge bar drain animation, obstacle idle animations, scroll interpolation.

---

## Build Order and Dependencies

This is the critical section for roadmap creation. Systems are ordered by dependency -- you cannot build a later system without the earlier ones existing.

### Dependency Graph

```
Layer 0 (Foundation - no dependencies):
  EventBus
  GameManager (shell: scene swapping only)
  DataManager (shell: local save/load only)

Layer 1 (Core Puzzle - depends on Layer 0):
  LetterSlot scene + script
  WordRow scene + script
  ScrollingWindow scene + script
  InputSystem (on-screen keyboard only)
  PuzzleScreen (assembles above components)
  Word validation logic

Layer 2 (Game Feel - depends on Layer 1):
  SurgeBar + SurgeManager
  Score calculation
  AudioManager (basic SFX for typing, correct, incorrect)
  Animation polish (letter pop, word slide, scroll)
  Bonus round logic

Layer 3 (Obstacles & Boosts - depends on Layer 1, 2):
  ObstacleConfig resource class
  ObstacleBase script
  ObstacleManager
  Padlock obstacle (scene + config)
  Random Blocks obstacle (scene + config)
  Sand obstacle (scene + config)
  Power boost system (BoostData, activation, consumption)
  Lock Key, Block Breaker, Bucket of Water (scenes + configs)

Layer 4 (Progression & Economy - depends on Layer 0, can parallel Layer 2-3):
  ProgressionManager
  Hearts/Hints/Lives system
  Stars earning + tracking
  Diamonds earning + tracking
  Penalty box (cooldown timer)
  Level completion recording

Layer 5 (World Map - depends on Layer 4):
  World map scene
  Nation/Land/Level node structure
  Avatar + movement
  Level selection -> puzzle launch flow
  NPC dialogue (basic)
  Progression gates (star requirements)

Layer 6 (Backend Integration - depends on Layer 4, can parallel Layer 5):
  NetworkManager
  Auth system (magic email, OAuth, email/password)
  Cloud save/load
  Content delivery (level data from cloud)
  DataManager cloud sync upgrade

Layer 7 (Monetization - depends on Layer 4, 6):
  EconomyManager
  Store screen
  IAP integration (App Store, Google Play)
  Inventory screen
  AdManager
  Rewarded ads (heart/hint/life recovery)
  Interstitial ads

Layer 8 (Multiplayer - depends on Layer 1, 2, 6):
  Vs mode screen
  Turn-based logic
  Matchmaking
  Friend invites
  Dual clock system

Layer 9 (Polish & Content - depends on all above):
  Tutorial system
  Boss levels
  Login streaks
  Name generator
  Additional input modes (radial, scrambled tiles)
  Narrative/themed word pools
  Ruut onboarding
  9 more obstacle types (Nations 4-9 content)
```

### Build Order Rationale for Roadmap

**Phase 1: Core Loop (Layers 0-1)**
Build the word puzzle first. This is the core value proposition. If the word-pair mechanics and scrolling window do not feel right, nothing else matters. This phase should end with a playable puzzle: you can type letters, words auto-submit, the window scrolls, correct/incorrect feedback works. No obstacles, no surge, no progression -- just the raw puzzle.

**Phase 2: Game Feel (Layer 2)**
Add the surge bar and score system. This is what makes the puzzle a "rush" rather than just a word game. The surge mechanic is the differentiator. Build and tune it before adding complexity on top. Phase ends with: puzzle + surge + scoring + basic sound = the core experience loop is playable and fun.

**Phase 3: Obstacles & Boosts (Layer 3)**
Now layer on the v1 obstacle template system with the first 3 obstacles. This requires the puzzle to be stable (obstacles modify word state). Build the template system extensibly from day one -- do not hardcode the first 3 and refactor later. Phase ends with: obstacles spawn, affect words, can be countered by solving or boosts.

**Phase 4: Progression (Layer 4)**
Hearts, hints, lives, stars, diamonds, level completion tracking. This can start in parallel with Phase 3 if the team is larger than one person. Phase ends with: playing a level earns stars, costs hearts on mistakes, progress persists locally.

**Phase 5: World Map & Navigation (Layer 5)**
The world map requires progression data (which levels are unlocked, how many stars earned). Phase ends with: player navigates map, selects level, plays puzzle, returns to map with updated progress.

**Phase 6: Backend (Layer 6)**
Auth, cloud storage, content delivery. This can start in parallel with Phase 5. Phase ends with: player logs in, progress syncs to cloud, level content loads from cloud.

**Phase 7: Monetization (Layer 7)**
Store, IAP, ads. Requires both economy system (Layer 4) and backend (Layer 6) to be functional. Phase ends with: player can buy diamonds, watch rewarded ads, purchase items in store.

**Phase 8: Multiplayer (Layer 8)**
Vs mode. Requires core puzzle (Layer 1), game feel (Layer 2), and networking (Layer 6). This is a high-complexity feature that should not block the single-player launch path. Phase ends with: two players can match and play a turn-based word game.

**Phase 9: Polish (Layer 9)**
Tutorials, boss levels, additional input modes, narrative, content expansion. These are all "on top of" the existing systems and can be developed incrementally.

### Critical Path

The absolute minimum path to a shippable v1:

```
EventBus -> Core Puzzle -> Surge/Score -> Obstacles -> Progression
  -> World Map -> Auth/Cloud -> Store/Ads -> Polish/Tutorials
```

**Vs Mode is OFF the critical path.** It can ship in v1.1 or later without blocking launch.

---

## Scalability Considerations

| Concern | At Launch (25 Lands) | At 100 Lands | At 3,000+ Levels |
|---------|---------------------|--------------|-------------------|
| **Level data loading** | Pre-fetch per Land (~15 levels), cache locally. Fast. | Same pattern, just more cache. Implement LRU eviction for older Lands. | Must lazy-load. Only cache current Land + adjacent. Cloud fetch on demand. |
| **World map rendering** | Render all 25 lands, no performance issue | Render visible nations only. Camera culling. | Paginate by Nation. Load Nation map scene on demand. |
| **Obstacle configs** | 3 configs in memory. Trivial. | 9 configs. Still trivial. | 9 configs. Still trivial. Obstacles do not scale with levels. |
| **Save data size** | ~25 levels of completion data. Tiny. | ~500 levels. Still small (< 100KB JSON). | ~3,000 levels. Consider binary format or SQLite instead of JSON. Or paginate cloud sync. |
| **Cloud sync frequency** | Every level completion. Fine. | Same. Fine. | Same per-event sync. Batch sync for bulk operations. |
| **App binary size** | Small. Text data + sprites for 3 Nations. | Moderate. On-demand asset downloading for Nations 4-9. | Asset bundles per Nation. Download when player reaches new Nation. |

### Performance-Critical Systems

1. **ScrollingWindow:** The scrolling must be 60fps smooth on low-end devices. Use `_process()` for scroll interpolation, not `_physics_process()`. Pre-render word rows off-screen and slide them in -- do not instantiate on demand during scroll.

2. **SurgeBar:** Visual drain is per-frame. Use a `Tween` for smooth drain animation rather than raw `_process()` manipulation. Tween-based animation is GPU-accelerated and battery-friendly.

3. **ObstacleAnimations:** Particle effects (sand grains, snowflakes) must be budgeted. Use `GPUParticles2D` with low particle counts. Profile on target devices. Fallback to `CPUParticles2D` if GPU particles cause issues on older devices.

4. **InputLatency:** Letter input must feel instant. No await, no network call, no heavy computation between tap and visual feedback. Validation (is the word correct?) happens after all letters are placed, not per-letter.

---

## Sources and Confidence

| Claim | Confidence | Source |
|-------|------------|--------|
| Godot 4.x autoload singleton pattern | HIGH | Godot official documentation (singletons_autoload), well-established pattern |
| EventBus/signal bus pattern in Godot | HIGH | Widely documented Godot community pattern, recommended by GDQuest and official best practices |
| Custom Resource for game data configuration | HIGH | Godot official docs (custom_resources), core engine feature since Godot 3.x |
| ResourceLoader.load_threaded for async scene loading | HIGH | Godot 4.x official API, replaces Godot 3 ResourceInteractiveLoader |
| GL Compatibility renderer for mobile | HIGH | Already configured in project.godot; correct choice for broad mobile compatibility |
| Control-based layout with containers for mobile UI | HIGH | Godot official docs (size_flags, containers), standard for responsive UI |
| GPUParticles2D compatibility on mobile | MEDIUM | Works on most modern devices with GL Compatibility renderer; may need CPUParticles2D fallback for very old devices |
| Scene swap via get_tree().current_scene | HIGH | Standard Godot pattern documented in official scene tree tutorial |
| Template/configuration-driven obstacle system recommendation | HIGH (architectural pattern) | Standard game architecture pattern; not Godot-specific. Confidence is in the pattern, not a specific Godot implementation. |
| Offline-first with local-then-cloud sync pattern | HIGH (pattern) | Standard mobile game architecture. No Godot-specific implementation to verify. |
| IAP receipt server-side validation requirement | HIGH | Apple/Google both require or strongly recommend server-side receipt validation for production apps |

### Gaps and Uncertainties

- **Backend choice (Firebase vs Supabase vs custom):** Not covered in this architecture doc. This is a STACK.md decision. The architecture is backend-agnostic by design -- `NetworkManager` and `CloudClient` abstract the specific backend.
- **AdMob Godot 4 plugin maturity:** The AdMob plugin ecosystem for Godot 4.x has been evolving. The architecture assumes a plugin exists in `addons/` but the specific plugin choice needs STACK.md research. Confidence: MEDIUM.
- **Godot 4.5 specific APIs:** Project uses Godot 4.5 (per project.godot `config/features`). Some APIs may have changed between 4.3 and 4.5. Specific API calls in code examples are based on Godot 4.x general knowledge and should be verified against 4.5 docs during implementation. Confidence: MEDIUM for exact syntax, HIGH for patterns.
- **WebSocket support for Vs mode:** Godot 4.x has built-in WebSocketPeer. Whether this is sufficient for turn-based multiplayer or whether a higher-level solution (like Firebase Realtime Database or Supabase Realtime) is better is a STACK.md decision. Architecture is agnostic.

---

## Summary: Architecture at a Glance

| Aspect | Recommendation |
|--------|---------------|
| **Overall pattern** | Layered: Presentation (scenes) -> Game Systems (autoloads) -> Data (autoloads + cloud) |
| **Scene structure** | One `.tscn` per screen, composed from reusable component sub-scenes |
| **Global state** | 8 focused autoloads, not one God Manager |
| **Communication** | EventBus for cross-scene signals; direct signals for parent-child; calls go down, signals go up |
| **Data configuration** | Custom Resource classes (`.tres` files) for levels, obstacles, boosts, store items |
| **Obstacle extensibility** | Template pattern: shared ObstacleBase + per-type ObstacleConfig resource + per-type visual scene |
| **Persistence** | Local-first (JSON/encrypted), cloud sync on key events, server authoritative for currency |
| **Input** | Pluggable: InputBase interface with OnScreenKeyboard/RadialInput/ScrambledTiles implementations |
| **Build order** | Core Puzzle -> Surge -> Obstacles -> Progression -> World Map -> Backend -> Monetization -> Multiplayer -> Polish |
| **Critical path** | Puzzle + Surge + Obstacles + Progression + Map + Auth + Store/Ads |
| **Off critical path** | Vs Mode, Boss Levels, Additional Input Modes, Nations 4-9 |
