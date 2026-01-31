---
phase: 01-foundation-and-validation-spikes
plan: "04"
subsystem: monetization-plugins
tags: [admob, iap, platform-services, plugin-integration, billing-v7, gdextension]
dependency-graph:
  requires: ["01-02", "01-03"]
  provides: ["AdMob plugin wired into PlatformServices", "IAP plugin wired into PlatformServices", "plugin compatibility findings"]
  affects: ["07-*"]
tech-stack:
  added:
    - "godot-sdk-integrations/godot-admob v5.3 (Android SDK 24.9.0, iOS SDK 12.14.0)"
    - "hyochan/godot-iap v1.2.3 (OpenIAP, Google Play Billing v7.1.1, StoreKit 2)"
  patterns: ["Admob node in scene tree for ad lifecycle", "GodotIapPlugin autoload for cross-platform IAP", "deferred initialization for plugin detection"]
key-files:
  created:
    - addons/AdmobPlugin/ (27 files -- GDScript plugin, model classes, export config)
    - addons/godot-iap/ (6 files -- wrapper, types, plugin, gdextension, gdap)
  modified:
    - scripts/autoloads/platform_services.gd
    - scenes/screens/test_screen.tscn
    - project.godot
    - .gitignore
decisions:
  - id: "01-04-D1"
    summary: "Ad unit IDs stored on Admob node properties (is_real=false uses built-in Google test IDs) -- never hardcoded in PlatformServices"
  - id: "01-04-D2"
    summary: "IAP uses godot-iap unified cross-platform plugin (not separate platform plugins) -- fallback strategy documented if it fails on devices"
  - id: "01-04-D3"
    summary: "Plugin binary artifacts (.aar, .framework) excluded from git via .gitignore -- must be downloaded from releases for builds"
  - id: "01-04-D4"
    summary: "PlatformServices uses deferred initialization (call_deferred) to ensure scene tree is built before searching for plugin nodes"
metrics:
  duration: "19m 35s"
  completed: "2026-01-31"
  status: "PARTIAL (Tasks 1-2 complete, Task 3 deferred)"
---

# Phase 1 Plan 4: Monetization Plugin Spike Summary

**AdMob v5.3 and godot-iap v1.2.3 installed and wired into PlatformServices with real plugin calls replacing all stubs; ad lifecycle and IAP signals routed to EventBus; graceful desktop/editor degradation. Task 3 (device validation) deferred due to hardware blocker.**

## What Was Built

### Task 1: AdMob Plugin Installation and Wiring (COMPLETE)

**Plugin installed:** godot-sdk-integrations/godot-admob v5.3 (Multi -- Android + iOS)
- `addons/AdmobPlugin/` -- 27 GDScript files (Admob node, model classes, export config, mediation support)
- `ios/framework/` -- GoogleMobileAds.xcframework and UserMessagingPlatform.xcframework (gitignored)
- `addons/AdmobPlugin/bin/` -- Android AAR files for debug and release (gitignored)

**PlatformServices AdMob wiring:**
- `_init_ads()` searches scene tree for Admob node, connects 10 lifecycle signals, calls `initialize()`
- On `initialization_completed`: sets `_admob_initialized = true`, pre-loads interstitial and rewarded ads
- `show_interstitial()`: checks `has_interstitial_ads()` and `_interstitial_loaded`, calls `_admob_node.show_interstitial_ad()`
- `show_banner()`: emits `EventBus.banner_region_show` first (Decision 01-02-D1), then loads/shows banner via plugin
- `hide_banner()`: always emits `EventBus.banner_region_hide` (Decision 01-02-D2), then hides via plugin
- `show_rewarded()`: checks `_rewarded_loaded`, calls `_admob_node.show_rewarded_ad()`
- After interstitial/rewarded ads are dismissed, the next ad is automatically pre-loaded
- All ad lifecycle events emit corresponding EventBus signals

**Admob node configuration:**
- Added to test_screen.tscn as a child Node with the Admob script
- `is_real = false` -- uses Google's built-in test ad unit IDs (no hardcoded IDs in PlatformServices)
- `banner_position = 1` (BOTTOM)
- The Admob node's `_ready()` auto-selects platform-appropriate test ad unit IDs

**Desktop/editor behavior:**
- When `Engine.has_singleton("AdmobPlugin")` is false (desktop), the Admob node's `_plugin_singleton` remains null
- PlatformServices detects this and logs: "AdMob node not found in scene tree -- ads disabled"
- All PlatformServices ad methods gracefully return or emit appropriate EventBus signals

### Task 2: IAP Plugin Installation and Wiring (COMPLETE)

**Plugin installed:** hyochan/godot-iap v1.2.3 (OpenIAP cross-platform)
- `addons/godot-iap/godot_iap.gd` -- GodotIapWrapper class (Node) with unified API
- `addons/godot-iap/types.gd` -- Full OpenIAP type definitions (ProductRequest, PurchaseProps, etc.)
- `addons/godot-iap/godot_iap_plugin.gd` -- EditorPlugin that registers "GodotIapPlugin" autoload
- `addons/godot-iap/bin/godot_iap.gdextension` -- GDExtension for iOS/macOS (compatibility_minimum = "4.3")
- `addons/godot-iap/android/GodotIap.gdap` -- Android plugin descriptor
- Android AAR files and iOS/macOS frameworks gitignored (binary artifacts)

**Key compatibility finding:** Google Play Billing Library v7.1.1 confirmed in GodotIap.gdap -- satisfies Pitfall 2 concern about deprecated billing library version rejection.

**PlatformServices IAP wiring:**
- `_init_iap()` looks for "GodotIapPlugin" autoload at `/root/GodotIapPlugin`
- Connects `purchase_updated`, `purchase_error`, and `connected` signals
- Calls `init_connection()` to establish store connection
- `purchase(product_id)` builds platform-specific request via `OS.get_name()`:
  - Android: `{ "type": "in-app", "requestPurchase": { "google": { "skus": [product_id] } } }`
  - iOS: `{ "type": "in-app", "requestPurchase": { "apple": { "sku": product_id } } }`
  - Desktop: emits `iap_purchase_failed` with platform not supported message
- `restore_purchases()` delegates to plugin's `restore_purchases()` method
- IAP signals routed to EventBus: `purchase_updated` -> `iap_purchase_completed`, `purchase_error` -> `iap_purchase_failed`

**Desktop/editor behavior:**
- godot-iap has built-in mock mode: when native plugin is absent, it prints "[GodotIap] Native plugin not available - running in mock mode"
- `init_connection()` returns true in mock mode, emitting `connected` signal
- Purchase operations return mock responses

### Task 3: Device Validation (DEFERRED)

**Same hardware blocker as Plan 01-03:** MacBook Air Mid-2013 (macOS Big Sur 11.7.10 max) cannot run Xcode 14+ required for iOS device testing. Android testing requires Android SDK setup.

**What will be validated when hardware is available:**
- AdMob test interstitial displays on physical Android and iOS devices
- AdMob test banner loads in banner region
- IAP sandbox purchase flow initiates on both platforms
- All plugin calls route through PlatformServices abstraction

## Plugin Compatibility Findings

| Plugin | Godot Compat | Billing/SDK Version | Status |
|--------|-------------|---------------------|--------|
| godot-admob v5.3 | Tested with 4.5.1 | Android SDK 24.9.0, iOS SDK 12.14.0 | Installed, code wired |
| godot-iap v1.2.3 | GDExtension min 4.3 | Google Play Billing v7.1.1 | Installed, code wired |

**Pitfall status:**
- Pitfall 2 (Billing Library version): RESOLVED -- godot-iap uses v7.1.1
- Pitfall 3 (iOS undefined symbols): UNKNOWN until device testing
- Pitfall 7 (Version churn): Both plugins confirmed compatible with Godot 4.5

## Requirements Addressed

| Requirement | Status | Notes |
|-------------|--------|-------|
| FNDN-03 | PARTIALLY ADDRESSED | Code wired, device validation deferred |
| FNDN-04 | PARTIALLY ADDRESSED | Code wired, device validation deferred |

## Decisions Made

| ID | Decision | Rationale |
|----|----------|-----------|
| 01-04-D1 | Ad unit IDs stored on Admob node properties, not in PlatformServices | Plugin has built-in debug/real ID separation via `is_real` flag; keeps IDs out of game code |
| 01-04-D2 | Use godot-iap as unified IAP plugin (not separate per-platform plugins) | Provides single API for Android (Billing v7.1.1) and iOS (StoreKit 2); fallback to separate plugins if device testing reveals issues |
| 01-04-D3 | Plugin binaries excluded from git | AAR files (226KB), iOS frameworks (~13MB) are too large for git; documented in .gitignore with download instructions |
| 01-04-D4 | Deferred initialization via call_deferred | Ensures scene tree nodes (Admob, GodotIapPlugin autoload) are fully ready before PlatformServices searches for them |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed .gitignore android/ pattern too broad**
- **Found during:** Task 2
- **Issue:** The root-level `android/` gitignore pattern was matching `addons/godot-iap/android/` directory, preventing the GodotIap.gdap manifest from being committed
- **Fix:** Changed `android/` to `/android/` to scope it to root-level only (Godot's Android build template output)
- **Files modified:** .gitignore
- **Commit:** 42f9bc7

**2. [Rule 3 - Blocking] Refined gitignore for godot-iap bin directory**
- **Found during:** Task 2
- **Issue:** `addons/godot-iap/bin/` gitignore excluded the godot_iap.gdextension file needed by Godot to locate native libraries
- **Fix:** Changed to exclude only `addons/godot-iap/bin/ios/` and `addons/godot-iap/bin/macos/` (the actual framework binaries)
- **Files modified:** .gitignore
- **Commit:** 42f9bc7

## Commits

| Hash | Type | Description |
|------|------|-------------|
| 0a6eb4b | feat | Install AdMob plugin v5.3 and wire into PlatformServices |
| 42f9bc7 | feat | Install godot-iap v1.2.3 and wire into PlatformServices |

## Next Phase Readiness

**Task 3 deferred** -- device validation of both plugins requires physical iOS and Android devices with proper SDK setup. Same hardware blocker as Plan 01-03.

**Before Phase 7:**
- Device testing must validate that AdMob test ads display on both platforms
- Device testing must validate that IAP sandbox purchase flow initiates on both platforms
- If godot-iap fails on devices, the fallback strategy is documented: use godot-google-play-billing (Android) + godot_ios_plugin_iap (iOS) behind the same PlatformServices interface

**For Phase 2-6 development:**
- All game code uses PlatformServices API -- no direct plugin access
- FeatureFlags can disable ads or IAP at runtime
- Desktop/editor testing works with graceful degradation (push_warning stubs and mock mode)
- No blockers for game code development
