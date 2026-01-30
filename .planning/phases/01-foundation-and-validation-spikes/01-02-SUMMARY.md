---
phase: 01-foundation-and-validation-spikes
plan: "02"
subsystem: monetization-abstraction
tags: [platform-services, banner-ads, autoload, test-screen, ui-component]
dependency-graph:
  requires: ["01-01"]
  provides: ["PlatformServices autoload", "BannerAdRegion component", "test screen"]
  affects: ["01-03", "01-04", "07-*"]
tech-stack:
  added: []
  patterns: ["abstraction layer for plugin isolation", "EventBus-driven UI region toggle", "safe-area-aware layout", "VBoxContainer reflow pattern"]
key-files:
  created:
    - scripts/autoloads/platform_services.gd
    - scripts/ui/banner_ad_region.gd
    - scenes/ui/banner_ad_region.tscn
    - scripts/screens/test_screen.gd
    - scenes/screens/test_screen.tscn
  modified:
    - project.godot
decisions:
  - id: "01-02-D1"
    summary: "PlatformServices emits banner_region_show BEFORE plugin call so UI region appears immediately"
  - id: "01-02-D2"
    summary: "hide_banner() always emits hide signal regardless of plugin/FeatureFlag state"
  - id: "01-02-D3"
    summary: "Banner region uses VBoxContainer reflow (visible=false + min_size.y=0) instead of anchored overlay"
  - id: "01-02-D4"
    summary: "Test screen set as main_scene for direct architecture validation"
metrics:
  duration: "3m 25s"
  completed: "2026-01-30"
---

# Phase 1 Plan 2: PlatformServices, Banner Ad Region, and Test Screen Summary

**PlatformServices autoload with stubbed ads/IAP interface, collapsible safe-area-aware banner ad region using EventBus-driven VBoxContainer reflow, and architecture validation test screen.**

## What Was Built

### PlatformServices Autoload (`scripts/autoloads/platform_services.gd`)
- Abstraction layer for all monetization plugins (AdMob, IAP)
- Complete public API: `show_banner()`, `hide_banner()`, `show_interstitial()`, `show_rewarded()`, `purchase()`, `restore_purchases()`
- Granular capability checks: `has_ads()`, `has_iap()`, `has_banner_ads()`, `has_interstitial_ads()`, `has_rewarded_ads()`
- Every method consults FeatureFlags before operating
- `show_banner()` emits `EventBus.banner_region_show` before plugin call for immediate UI response
- `hide_banner()` always emits hide signal regardless of flag/plugin state
- All plugin calls are stubs with `push_warning()` -- ready for real plugin wiring in Phase 1 Plan 4
- Registered as 4th autoload in project.godot (order: EventBus, SaveData, GameManager, PlatformServices)

### Banner Ad Region Component
- `scripts/ui/banner_ad_region.gd` -- MarginContainer with show/hide via EventBus signals
- `scenes/ui/banner_ad_region.tscn` -- Reusable scene with dark placeholder ColorRect and "Ad Space" label
- Safe-area-aware: reads `DisplayServer.get_display_safe_area()` for bottom inset on notched devices
- On hide: sets `visible = false` and `custom_minimum_size.y = 0` so parent VBoxContainer reflows content area to fill full screen height
- On show: restores visibility and 80px minimum height
- Designed as a reusable component that every future screen will include

### Test Screen
- `scripts/screens/test_screen.gd` -- Architecture validation logic
- `scenes/screens/test_screen.tscn` -- Full validation screen layout
- Displays autoload status for all 4 autoloads (EventBus, SaveData, GameManager, PlatformServices)
- Banner toggle buttons: "Show Banner" / "Hide Banner" wired to PlatformServices
- Test buttons: "Test Interstitial" / "Test IAP" for stub validation
- State label updates on `EventBus.app_state_changed` signals
- Calls `GameManager.transition_to(MENU)` on ready to demonstrate state machine
- All button touch targets at 56px height (exceeds 48dp minimum for mobile)
- Set as `run/main_scene` in project.godot for direct launch

## Requirements Addressed

| Requirement | Status | Notes |
|-------------|--------|-------|
| FNDN-08 | Addressed | Banner ad region with collapsible reflow via VBoxContainer layout |

## Decisions Made

| ID | Decision | Rationale |
|----|----------|-----------|
| 01-02-D1 | show_banner() emits EventBus signal BEFORE plugin call | UI region appears immediately; plugin call may be async |
| 01-02-D2 | hide_banner() always emits hide signal | Ensures UI cleanup even if plugin state is inconsistent |
| 01-02-D3 | VBoxContainer reflow pattern for banner collapse | Simpler and more robust than anchored overlay; content area auto-expands |
| 01-02-D4 | Test screen as main_scene | Direct architecture validation without navigation scaffolding |

## Deviations from Plan

None -- plan executed exactly as written.

## Commits

| Hash | Type | Description |
|------|------|-------------|
| b6d5265 | feat | Create PlatformServices autoload and register as 4th autoload |
| a94c969 | feat | Create banner ad region component, test screen, update main_scene |

## Next Phase Readiness

**Ready for Plan 01-03** (Export pipeline validation):
- All autoloads registered and functional (stubs)
- Test screen provides visual validation target for export testing
- Banner region demonstrates UI component pattern for mobile layout

**Ready for Plan 01-04** (Monetization plugin spike):
- PlatformServices provides the exact API surface that plugins will wire into
- Banner region is ready to display real ads once AdMob is integrated
- FeatureFlags provide runtime toggling for plugin availability

**No blockers identified.**
