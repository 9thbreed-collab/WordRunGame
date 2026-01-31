# Plan 01-01: Core Architecture Skeleton

**Wave:** 1 | **Depends on:** Nothing | **Autonomous:** Yes

## Objective

Create the project directory structure and core autoload skeleton (EventBus, GameManager, SaveData, FeatureFlags) that all subsequent plans depend on. Register autoloads in project.godot in the correct initialization order.

## Requirements Covered

- **FNDN-05:** Project directory structure follows layered architecture
- **FNDN-06:** EventBus autoload relays signals between decoupled scenes
- **FNDN-07:** GameManager autoload manages app state transitions

## Files Modified

| File | Purpose |
|------|---------|
| scripts/autoloads/event_bus.gd | Global signal relay for decoupled communication |
| scripts/autoloads/game_manager.gd | App state machine with enum-based transitions |
| scripts/autoloads/save_data.gd | Local persistence stub and FeatureFlags loader |
| scripts/resources/feature_flags.gd | Boolean feature flag system with static access |
| data/feature_flags.tres | Default feature flags resource (all enabled) |
| project.godot | Autoload registrations + mobile display settings |

## Tasks

### Task 1: Create directory structure and all autoload scripts

Create the layered directory structure:
- scripts/autoloads/, scripts/resources/, scripts/ui/
- data/, scenes/screens/, scenes/ui/, addons/

Create all 4 GDScript files following the research patterns:
- **event_bus.gd** -- 12+ signals (ads, IAP, app state, banner region, feature flags). Pure relay, no logic.
- **feature_flags.gd** -- class_name FeatureFlags, static instance, @export booleans, get_flag/set_flag methods
- **save_data.gd** -- Loads/creates FeatureFlags on _ready(), save_game/load_game stubs
- **game_manager.gd** -- AppState enum (LOADING, AUTH, MENU, PLAYING, PAUSED, RESULTS, STORE), transition_to(), change_screen()

### Task 2: Register autoloads in project.godot

Register in order (order matters):
1. EventBus
2. SaveData
3. GameManager

PlatformServices is NOT registered here -- created in Plan 02.

Add mobile display settings: 1080x1920 portrait, canvas_items stretch, expand aspect.

## Success Criteria

1. All directories exist
2. All autoload scripts contain the documented patterns
3. project.godot registers 3 autoloads in correct order
4. project.godot has mobile display settings (portrait, 1080x1920)
5. No GDScript syntax errors
