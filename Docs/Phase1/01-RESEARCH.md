# Phase 1: Foundation and Validation Spikes - Research

**Researched:** 2026-01-29
**Domain:** Godot 4.5 mobile export pipeline, AdMob/IAP plugin ecosystem, project architecture patterns
**Confidence:** MEDIUM (plugin ecosystem is the weakest link; core Godot patterns are HIGH)

## Summary

This research investigates the five technical domains required to plan Phase 1: (1) Godot 4.5 mobile export pipeline for iOS and Android, (2) AdMob plugin selection and integration, (3) IAP plugin selection and integration, (4) project architecture patterns (autoloads, EventBus, state machine, safe area layout), and (5) feature flags and local persistence stubs.

The standard approach is to use Godot 4.5 stable (released September 15, 2025) with the GL Compatibility renderer (already configured in project.godot), the godot-sdk-integrations/godot-admob plugin (v5.3, tested with Godot 4.5.1) for ads, and a combination of platform-specific IAP plugins behind a PlatformServices abstraction layer. The project architecture uses four autoloads (EventBus, GameManager, PlatformServices, SaveData) with a layered directory structure.

The single biggest risk is the IAP plugin landscape, which is fragmented. There is no single battle-tested cross-platform IAP plugin for Godot 4.5. The godot-iap (OpenIAP) project (v1.2.3, January 2026) is the most promising unified solution but is new. The fallback strategy is separate platform-specific plugins (godot-google-play-billing for Android, godot_ios_plugin_iap for iOS) behind the PlatformServices abstraction. A secondary risk is the Godot 4.5 + Xcode 26 iOS export issue (GitHub #111213), which appears plugin-related rather than systemic and has a known workaround (disable problematic plugins during export).

**Primary recommendation:** Validate the export pipeline on BOTH platforms within the first 2-3 days using a minimal splash screen, before investing in plugin integration. Use godot-sdk-integrations/godot-admob v5.3 for ads. For IAP, attempt godot-iap first as the unified solution; fall back to separate platform plugins if it fails. Wrap all plugin calls in PlatformServices from day one.

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Godot Engine | 4.5 stable (Sept 2025) | Game engine | Already initialized; pinned per project constraint |
| GL Compatibility renderer | (built-in) | Mobile rendering | Already configured in project.godot; supports OpenGL ES 3.0 on mobile; broadest device compatibility |

### Monetization Plugins

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| godot-sdk-integrations/godot-admob | v5.3 | AdMob ads (banner, interstitial, rewarded) | Tested with Godot 4.5.1; Android SDK 24.9.0, iOS SDK 12.14.0; actively maintained; supports all ad formats including collapsible banners |
| godot-iap (hyochan/godot-iap) | v1.2.3 | Cross-platform IAP (Primary) | OpenIAP protocol; Godot 4.3+; iOS + Android; released Jan 2026; unified API |
| godot-sdk-integrations/godot-google-play-billing | v3.1.0 | Android IAP (Fallback) | Official Godot SDK integration; compiled with Godot 4.5; Google Play Billing v7 support via PR |
| hrk4649/godot_ios_plugin_iap | v0.3.0 | iOS IAP (Fallback) | StoreKit 2 (Swift); confirmed working Godot 4.6; latest update Jan 26, 2026; requires iOS 15+ |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| code-with-max/godot-google-play-iapp | latest | Android IAP alternative | If godot-google-play-billing lacks Billing Library v7.1.1 support; explicitly tested with Godot 4.5 |
| Notchz (lunsokhasovan) | v1.2.1 | Safe area / notch handling | Consider if DisplayServer.get_display_safe_area() proves unreliable across devices |

### Installation

```bash
# AdMob: Install via Godot AssetLib (search "Admob") or download from:
# https://github.com/godot-sdk-integrations/godot-admob/releases (v5.3)
# Extract to project root, enable in Project Settings > Plugins

# IAP (Primary - godot-iap): Download from:
# https://github.com/hyochan/godot-iap/releases (v1.2.3)
# Extract addons/godot-iap/ into project's addons/ folder
# Enable in Project Settings > Plugins

# IAP (Fallback Android - Google Play Billing):
# https://github.com/godot-sdk-integrations/godot-google-play-billing/releases (v3.1.0)

# IAP (Fallback iOS):
# https://github.com/hrk4649/godot_ios_plugin_iap (v0.3.0)
# Install via Godot AssetLib, enable "Ios In App Purchase" in export settings
```

## Architecture Patterns

### Recommended Project Structure

```
res://
├── addons/                  # Third-party plugins (AdMob, IAP, etc.)
│   ├── godot-admob/
│   └── godot-iap/
├── assets/                  # Raw assets (already exists)
│   ├── audio/
│   ├── fonts/
│   ├── sprites/
│   └── ui/
├── data/                    # Game data resources, config files
│   └── feature_flags.tres   # Feature flags resource
├── scenes/                  # All .tscn scene files
│   ├── main.tscn            # Root scene (already exists)
│   ├── screens/             # Full-screen UI scenes
│   │   └── test_screen.tscn
│   └── ui/                  # Reusable UI components
│       └── banner_ad_region.tscn
├── scripts/                 # All .gd script files
│   ├── autoloads/           # Singleton autoload scripts
│   │   ├── event_bus.gd
│   │   ├── game_manager.gd
│   │   ├── platform_services.gd
│   │   └── save_data.gd
│   ├── ui/                  # UI-related scripts
│   │   └── banner_ad_region.gd
│   └── resources/           # Custom Resource class definitions
│       └── feature_flags.gd
├── project.godot
└── export_presets.cfg        # Export presets (do NOT commit credentials)
```

### Pattern 1: EventBus Autoload (Signal Relay)

**What:** A globally-accessible autoload node that declares signals any node can emit or connect to, decoupling distant nodes.
**When to use:** When nodes in different branches of the scene tree need to communicate without direct references.

```gdscript
# scripts/autoloads/event_bus.gd
extends Node

# --- Ad lifecycle signals ---
signal ad_banner_loaded
signal ad_banner_failed(error_code: int)
signal ad_interstitial_loaded
signal ad_interstitial_closed
signal ad_rewarded_earned(reward_type: String, amount: int)

# --- IAP signals ---
signal iap_purchase_completed(product_id: String)
signal iap_purchase_failed(product_id: String, error: String)
signal iap_restore_completed

# --- App state signals ---
signal app_state_changed(old_state: String, new_state: String)
signal screen_changed(screen_name: String)

# --- Banner region signals ---
signal banner_region_show
signal banner_region_hide

# --- Feature flag signals ---
signal feature_flag_changed(flag_name: String, value: bool)
```

### Pattern 2: GameManager State Machine (Enum-Based)

**What:** An autoload that tracks the app's top-level state using an enum and a `match` statement.

```gdscript
# scripts/autoloads/game_manager.gd
extends Node

enum AppState {
    LOADING, AUTH, MENU, PLAYING, PAUSED, RESULTS, STORE,
}

var current_state: AppState = AppState.LOADING

func transition_to(new_state: AppState) -> void:
    var old_state := current_state
    current_state = new_state
    EventBus.app_state_changed.emit(
        AppState.keys()[old_state],
        AppState.keys()[new_state]
    )
    _handle_state_entry(new_state)
```

### Pattern 3: PlatformServices Abstraction Layer

**What:** An autoload that wraps all monetization plugin calls behind a stable internal API. Game code never calls plugin methods directly.

```gdscript
# scripts/autoloads/platform_services.gd
extends Node

func has_ads() -> bool:
    return FeatureFlags.get_flag("ads_enabled") and _admob_initialized

func show_interstitial() -> void:
    if not has_ads():
        return
    # Plugin-specific call wrapped here

func show_banner() -> void:
    if not has_ads():
        return
    EventBus.banner_region_show.emit()

func hide_banner() -> void:
    EventBus.banner_region_hide.emit()

func purchase(product_id: String) -> void:
    if not has_iap():
        EventBus.iap_purchase_failed.emit(product_id, "IAP not available")
        return
```

### Pattern 4: Feature Flags (Local Config Dictionary)

**What:** A simple resource that holds boolean flags for enabling/disabling features at runtime.

```gdscript
# scripts/resources/feature_flags.gd
class_name FeatureFlags
extends Resource

static var instance: FeatureFlags

@export var ads_enabled: bool = true
@export var iap_enabled: bool = true
@export var banner_ads_enabled: bool = true
@export var interstitial_ads_enabled: bool = true
@export var rewarded_ads_enabled: bool = true

static func get_flag(flag_name: String) -> bool:
    if instance == null:
        return true
    return instance.get(flag_name) if instance.get(flag_name) != null else true
```

### Pattern 5: Banner Ad Region (Safe-Area-Aware Container)

**What:** A bottom-anchored MarginContainer that reserves space for banner ads, respects safe area insets, and collapses with layout reflow.

```gdscript
# scripts/ui/banner_ad_region.gd
extends MarginContainer

@export var default_height: int = 80
@export var show_artwork_fallback: bool = true

func _ready() -> void:
    _apply_safe_area_bottom()
    EventBus.banner_region_show.connect(_on_show)
    EventBus.banner_region_hide.connect(_on_hide)

func _on_show() -> void:
    visible = true
    custom_minimum_size.y = default_height

func _on_hide() -> void:
    visible = false
    custom_minimum_size.y = 0
```

## Common Pitfalls

### Pitfall 1: Xcode 26 + Godot 4.5 iOS Export Failure
Export fails with misleading "code 0" error. Caused by certain plugins. **Fix:** Export with NO plugins first, add one at a time. Use "create only project file" and build in Xcode directly as workaround.

### Pitfall 2: Google Play Billing Library Version Rejection
Google deprecated pre-v6 Billing Library. **Fix:** Verify plugin includes Billing Library v7+. The AndroidIAPP plugin (code-with-max) explicitly supports v7.1.1.

### Pitfall 3: iOS Plugin Undefined Symbol Errors
Plugins compiled against wrong Godot version cause linker errors. **Fix:** Only use plugins explicitly tested with Godot 4.5.

### Pitfall 4: DisplayServer Safe Area Bugs
Known bugs on Pixel 9 and desktop. **Fix:** Always test on physical devices. Add manual inset override for debugging. Consider Notchz plugin as fallback.

### Pitfall 5: Mixing Automatic and Manual iOS Signing
Setting both creates conflicts. **Fix:** Use automatic signing only -- set Team ID, leave provisioning profile blank.

### Pitfall 6: C# Mobile Export Trap
C# mobile export is experimental. **Fix:** Use GDScript exclusively (already configured).

### Pitfall 7: Not Pinning Godot Version
Upgrading breaks plugin compatibility. **Fix:** Pin to Godot 4.5 stable. Do NOT upgrade to 4.6 without verifying all plugins.

## Open Questions

1. **godot-iap production readiness** -- v1.2.3 released Jan 2026, 16 stars, 44 commits. Attempt first, fall back within 2 days.
2. **godot-google-play-billing v7 status** -- Check build.gradle for actual Billing Library version.
3. **Xcode 26 compatibility** -- Issue #111213 OPEN. Test base export first, add plugins incrementally.
4. **DisplayServer safe area reliability** -- Known bugs. Implement manual inset override for debugging.
5. **godot_ios_plugin_iap on Godot 4.5** -- Claims 4.6 support. Test explicitly on 4.5.

## Confidence Breakdown

| Area | Level | Reason |
|------|-------|--------|
| Standard stack (Godot 4.5, renderer) | HIGH | project.godot confirms; official docs verified |
| AdMob plugin selection | HIGH | v5.3 release notes explicitly state Godot 4.5.1 compatibility |
| IAP plugin selection | LOW | Fragmented ecosystem; godot-iap is new (16 stars) |
| Architecture patterns | HIGH | Well-established community patterns |
| Safe area / banner layout | MEDIUM | Official API exists; known device-specific bugs |
| Export pipeline (iOS) | MEDIUM | Documented process works; Xcode 26 issue OPEN |
| Export pipeline (Android) | HIGH | Well-documented; auto-generated keystore since 4.3 |

**Research date:** 2026-01-29
**Valid until:** 2026-02-28 (30 days -- plugin ecosystem moves fast)
