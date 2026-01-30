---
phase: 01-foundation-and-validation-spikes
plan: 01
subsystem: architecture
tags: [autoload, event-bus, game-manager, save-data, feature-flags, godot-4.5]

dependency-graph:
  requires: []
  provides:
    - EventBus autoload (global signal relay)
    - GameManager autoload (app state machine)
    - SaveData autoload (persistence stub, FeatureFlags loader)
    - FeatureFlags resource (static boolean flag system)
    - Layered directory structure
  affects:
    - 01-02 (PlatformServices depends on EventBus + FeatureFlags)
    - 01-03 (export pipeline needs project.godot configured)
    - All future phases (autoloads are the communication backbone)

tech-stack:
  added: []
  patterns:
    - EventBus singleton pattern (signal-only relay node)
    - Enum-based state machine (AppState with transition_to)
    - Resource-based configuration (FeatureFlags as .tres)
    - Static accessor pattern (FeatureFlags.get_flag/set_flag)

file-tracking:
  key-files:
    created:
      - scripts/autoloads/event_bus.gd
      - scripts/autoloads/save_data.gd
      - scripts/autoloads/game_manager.gd
      - scripts/resources/feature_flags.gd
      - data/feature_flags.tres
    modified:
      - project.godot

decisions:
  - id: "01-01-D1"
    decision: "Autoload order: EventBus -> SaveData -> GameManager"
    rationale: "Later autoloads depend on earlier ones. SaveData needs EventBus (via FeatureFlags). GameManager needs EventBus."
  - id: "01-01-D2"
    decision: "FeatureFlags uses static instance + static methods with string-based flag names"
    rationale: "Allows any script to query flags without injecting dependencies. String names enable runtime flag lookup from Remote Config."
  - id: "01-01-D3"
    decision: "Portrait 1080x1920 with canvas_items stretch and expand aspect"
    rationale: "Standard mobile portrait resolution. canvas_items stretch mode is the Godot standard for 2D mobile. Expand aspect handles different device ratios."

metrics:
  duration: "5 minutes"
  completed: "2026-01-30"
---

# Phase 1 Plan 01: Core Architecture Skeleton Summary

**One-liner:** EventBus signal relay, GameManager state machine, SaveData persistence stub, and FeatureFlags boolean toggle system -- the autoload backbone for all WordRun! systems.

## What Was Done

### Task 1: Create directory structure and all autoload scripts

Created the layered directory structure and all core scripts:

**Directory structure:**
- `scripts/autoloads/` -- Autoload singletons
- `scripts/resources/` -- Resource class definitions
- `scripts/ui/` -- UI script components (empty, ready for Phase 2+)
- `data/` -- Default resource files
- `scenes/screens/` -- Screen scenes (empty, ready for Phase 2+)
- `scenes/ui/` -- UI component scenes (empty, ready for Phase 2+)
- `addons/` -- Third-party plugins (empty, ready for Phase 1 Plan 04)

**EventBus (`scripts/autoloads/event_bus.gd`):**
- 13 signals declared across 5 categories
- Ad lifecycle: ad_banner_loaded, ad_banner_failed, ad_interstitial_loaded, ad_interstitial_closed, ad_rewarded_earned
- IAP: iap_purchase_completed, iap_purchase_failed, iap_restore_completed
- App state: app_state_changed, screen_changed
- Banner region: banner_region_show, banner_region_hide
- Feature flags: feature_flag_changed
- Pure signal relay -- zero logic

**GameManager (`scripts/autoloads/game_manager.gd`):**
- AppState enum with 7 states: LOADING, AUTH, MENU, PLAYING, PAUSED, RESULTS, STORE
- `transition_to()` emits `EventBus.app_state_changed` with string state names
- `_handle_state_entry()` match statement with stubs for each state
- `change_screen()` calls `get_tree().change_scene_to_file()` and emits `EventBus.screen_changed`

**SaveData (`scripts/autoloads/save_data.gd`):**
- Loads FeatureFlags from `user://feature_flags.tres` on `_ready()`
- Creates default FeatureFlags and saves if no file exists
- `save_game()` / `load_game()` stubs for future implementation

**FeatureFlags (`scripts/resources/feature_flags.gd`):**
- `class_name FeatureFlags extends Resource`
- Static `instance` variable set by SaveData on startup
- 5 exported boolean flags: ads_enabled, iap_enabled, banner_ads_enabled, interstitial_ads_enabled, rewarded_ads_enabled
- `get_flag(flag_name)` static method with unknown-flag warning
- `set_flag(flag_name, value)` static method emitting `EventBus.feature_flag_changed`

**Default resource (`data/feature_flags.tres`):**
- All 5 flags set to `true` (everything enabled by default)

### Task 2: Register autoloads in project.godot

- Added 3 autoloads in initialization order: EventBus, SaveData, GameManager
- Set `run/main_scene="res://scenes/main.tscn"`
- Configured mobile display: 1080x1920 viewport, portrait orientation, canvas_items stretch, expand aspect

## Deviations from Plan

None -- plan executed exactly as written.

## Requirements Coverage

| Requirement | Status | Evidence |
|------------|--------|----------|
| FNDN-05: Layered directory structure | Covered | 7 directories created matching architecture |
| FNDN-06: EventBus signal relay | Covered | 13 signals across 5 categories, registered as autoload |
| FNDN-07: GameManager app state transitions | Covered | AppState enum (7 states), transition_to() emits via EventBus |

## Commit Log

| Task | Commit | Message |
|------|--------|---------|
| 1 | 2023416 | feat(01-01): create directory structure and core autoload scripts |
| 2 | 754ab6b | feat(01-01): register autoloads and configure mobile display settings |

## Key Links Established

| From | To | Via |
|------|----|-----|
| GameManager | EventBus | `EventBus.app_state_changed.emit()` in `transition_to()` |
| SaveData | FeatureFlags | `FeatureFlags.instance` assignment in `_ready()` |
| FeatureFlags | EventBus | `EventBus.feature_flag_changed.emit()` in `set_flag()` |

## Next Plan Readiness

Plan 01-02 (PlatformServices, banner ad region, test screen) can proceed immediately. It depends on:
- EventBus (created and registered)
- FeatureFlags (created, loaded by SaveData)
- GameManager (created and registered)
- Directory structure (scenes/screens/, scenes/ui/ ready for .tscn files)

No blockers or concerns for the next plan.
