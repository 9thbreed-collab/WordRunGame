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

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| godot-iap (cross-platform) | Separate platform plugins | More code, but each plugin is closer to native APIs and more mature |
| godot-sdk-integrations/godot-admob | poingstudios/godot-admob-plugin | Poing Studios plugin reported broken on Godot 4.3+; less actively maintained |
| Notchz plugin | Manual DisplayServer API | Manual approach is lighter but requires handling edge cases per device |
| Custom Resource saves | ConfigFile or JSON | ConfigFile is simpler for stub phase; Custom Resources better for complex data later |

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
# Source: GDQuest EventBus pattern (https://www.gdquest.com/tutorial/godot/design-patterns/event-bus-singleton/)
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

**Emitting (Godot 4 syntax):**
```gdscript
EventBus.ad_interstitial_closed.emit()
EventBus.app_state_changed.emit("menu", "playing")
```

**Connecting (Godot 4 syntax):**
```gdscript
func _ready() -> void:
    EventBus.ad_interstitial_closed.connect(_on_interstitial_closed)

func _on_interstitial_closed() -> void:
    pass # handle event
```

### Pattern 2: GameManager State Machine (Enum-Based)

**What:** An autoload that tracks the app's top-level state using an enum and a `match` statement. Handles scene routing.
**When to use:** For managing global app state transitions (loading -> menu -> playing, etc.).

```gdscript
# scripts/autoloads/game_manager.gd
extends Node

enum AppState {
    LOADING,
    AUTH,
    MENU,
    PLAYING,
    PAUSED,
    RESULTS,
    STORE,
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

func _handle_state_entry(state: AppState) -> void:
    match state:
        AppState.LOADING:
            pass # show loading screen
        AppState.MENU:
            pass # load menu scene
        AppState.PLAYING:
            pass # load gameplay scene
        _:
            pass

func change_screen(scene_path: String) -> void:
    get_tree().change_scene_to_file(scene_path)
    EventBus.screen_changed.emit(scene_path)
```

### Pattern 3: PlatformServices Abstraction Layer

**What:** An autoload that wraps all monetization plugin calls behind a stable internal API. Game code never calls plugin methods directly.
**When to use:** Always -- this is the single point of contact for ads and IAP.

```gdscript
# scripts/autoloads/platform_services.gd
extends Node

# --- Feature capability checks ---
func has_ads() -> bool:
    return FeatureFlags.get_flag("ads_enabled") and _admob_initialized

func has_iap() -> bool:
    return FeatureFlags.get_flag("iap_enabled") and _iap_initialized

# --- Ads interface ---
func show_interstitial() -> void:
    if not has_ads():
        return
    # Plugin-specific call wrapped here
    pass

func show_rewarded() -> void:
    if not has_ads():
        return
    pass

func show_banner() -> void:
    if not has_ads():
        return
    EventBus.banner_region_show.emit()
    pass

func hide_banner() -> void:
    EventBus.banner_region_hide.emit()
    pass

# --- IAP interface ---
func purchase(product_id: String) -> void:
    if not has_iap():
        EventBus.iap_purchase_failed.emit(product_id, "IAP not available")
        return
    pass

func restore_purchases() -> void:
    if not has_iap():
        return
    pass

# --- Internals ---
var _admob_initialized := false
var _iap_initialized := false

func _ready() -> void:
    _init_ads()
    _init_iap()

func _init_ads() -> void:
    pass # Initialize AdMob plugin, connect signals

func _init_iap() -> void:
    pass # Initialize IAP plugin, connect signals
```

### Pattern 4: Feature Flags (Local Config Dictionary)

**What:** A simple autoload or resource that holds boolean flags for enabling/disabling features at runtime.
**When to use:** To disable broken surfaces (e.g., banner ads on iOS) without code changes.

```gdscript
# scripts/resources/feature_flags.gd
class_name FeatureFlags
extends Resource

# Static instance (set by SaveData autoload on startup)
static var instance: FeatureFlags

@export var ads_enabled: bool = true
@export var iap_enabled: bool = true
@export var banner_ads_enabled: bool = true
@export var interstitial_ads_enabled: bool = true
@export var rewarded_ads_enabled: bool = true

static func get_flag(flag_name: String) -> bool:
    if instance == null:
        return true  # Default: all enabled
    return instance.get(flag_name) if instance.get(flag_name) != null else true

static func set_flag(flag_name: String, value: bool) -> void:
    if instance == null:
        return
    instance.set(flag_name, value)
    EventBus.feature_flag_changed.emit(flag_name, value)
```

### Pattern 5: Banner Ad Region (Safe-Area-Aware Container)

**What:** A bottom-anchored MarginContainer that reserves space for banner ads, respects safe area insets, and collapses with layout reflow.
**When to use:** On every screen that displays a banner ad region.

```gdscript
# scripts/ui/banner_ad_region.gd
extends MarginContainer

@export var default_height: int = 80  # Approximate banner height in dp
@export var show_artwork_fallback: bool = true

var _is_collapsed: bool = false

func _ready() -> void:
    _apply_safe_area_bottom()
    EventBus.banner_region_show.connect(_on_show)
    EventBus.banner_region_hide.connect(_on_hide)
    # Default: show artwork placeholder
    if show_artwork_fallback:
        _show_artwork()

func _apply_safe_area_bottom() -> void:
    var screen_size := DisplayServer.screen_get_size()
    var safe_area := DisplayServer.get_display_safe_area()
    var bottom_inset: int = screen_size.y - (safe_area.position.y + safe_area.size.y)
    # Add bottom_inset as additional padding below the banner
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
    pass  # Load game artwork with subtle idle animation
```

### Anti-Patterns to Avoid

- **Calling plugin methods directly from game code:** Always go through PlatformServices. Direct calls create tight coupling and make platform fallbacks impossible.
- **Bloated EventBus:** Only add signals that cross scene boundaries. Local parent-child communication should use direct signal connections.
- **Over-engineering the state machine:** Phase 1 needs an enum-based FSM, not a node-based hierarchical state machine. Keep it simple; upgrade in later phases if needed.
- **Hardcoding ad unit IDs in scripts:** Store test and production IDs in a configuration resource or the AdMob node properties, never inline in GDScript.
- **Skipping safe area on desktop testing:** The safe area API returns zero insets on desktop. Test with real devices or configure manual inset overrides for desktop debugging.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| AdMob integration | Custom HTTP ad fetching | godot-sdk-integrations/godot-admob v5.3 | Google Mobile Ads SDK handles mediation, consent (UMP), GDPR compliance, and ad format lifecycle |
| In-app purchases | Custom StoreKit/Play Billing wrapper | godot-iap or platform-specific plugins | Receipt validation, subscription management, sandbox testing, and platform policy compliance are complex |
| Safe area insets | Manual pixel calculations per device | DisplayServer.get_display_safe_area() | OS provides authoritative inset values; manual values break on new device form factors |
| Debug keystore generation | Manual keytool commands | Godot 4.5 auto-generates debug keystores | Since Godot 4.3, debug keystores are generated automatically by the editor |
| Export template management | Manual download and placement | Editor > Manage Export Templates | Built-in template manager handles versioning and placement |

**Key insight:** The mobile monetization stack (ads + IAP) involves native platform SDKs, policy compliance, receipt validation, and consent management. Every one of these is a rabbit hole. Use maintained plugins and wrap them in an abstraction layer.

## Common Pitfalls

### Pitfall 1: Xcode 26 + Godot 4.5 iOS Export Failure
**What goes wrong:** Export fails with "Xcode build: failed to run xcodebuild with code 0" error.
**Why it happens:** Certain plugins enabled in the export preset cause xcodebuild failures. The misleading error code (0 normally means success) masks the real cause.
**How to avoid:**
1. First export with NO plugins enabled to confirm the base pipeline works.
2. Add plugins one at a time and re-export to isolate failures.
3. Use "create only project file" option and build in Xcode directly as a workaround.
4. Ensure xcode-select points to correct path: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
**Warning signs:** Any iOS export error mentioning "code 0" or "undefined symbols" after adding plugins.
**Source:** [GitHub #111213](https://github.com/godotengine/godot/issues/111213)

### Pitfall 2: Google Play Billing Library Version Rejection
**What goes wrong:** Google Play Store rejects app submission because the Google Play Billing Library is too old (pre-v6 deprecated).
**Why it happens:** The official godot-google-play-billing plugin historically shipped with Billing Library v5.x.
**How to avoid:** Verify the plugin version includes Billing Library v7+ before starting IAP integration. The AndroidIAPP plugin (code-with-max) explicitly supports v7.1.1 and is tested with Godot 4.5.
**Warning signs:** Play Console warnings about deprecated billing library during app review.

### Pitfall 3: iOS Plugin Undefined Symbol Errors
**What goes wrong:** Xcode build fails with "Undefined symbol" errors (e.g., `StringName::assign_static_unique_class_name`) after adding plugins.
**Why it happens:** Plugins compiled against one Godot version may have binary incompatibilities with another. Godot 4.5 introduced breaking iOS changes.
**How to avoid:** Only use plugins explicitly tested with Godot 4.5. The godot-admob v5.3 release notes state "tested against Godot 4.5.1". Check release notes for every plugin.
**Warning signs:** "Undefined symbol" or linker errors mentioning Godot engine symbols.
**Source:** [Godot Forum](https://forum.godotengine.org/t/godot-4-5-ios-export-gives-undefined-symbols-errors-in-xcode-due-to-not-updated-plugin/125054)

### Pitfall 4: DisplayServer Safe Area Bugs
**What goes wrong:** `DisplayServer.get_display_safe_area()` returns incorrect values -- too small on some Android phones in certain orientations, or incorrectly accounting for Windows taskbar during desktop testing.
**Why it happens:** Known Godot bugs: the Android implementation double-subtracts insets in some cases (GitHub #105462). Desktop returns misleading values.
**How to avoid:**
1. Always test safe area layout on physical devices, not desktop.
2. Add manual inset override capability for debugging.
3. Consider the Notchz plugin as a fallback if built-in API proves unreliable.
**Warning signs:** Banner ad region overlapping navigation bar or appearing too small on specific devices.

### Pitfall 5: Mixing Automatic and Manual iOS Signing
**What goes wrong:** Export fails with "conflicting provisioning settings" error.
**Why it happens:** Setting both automatic signing (App Store Team ID) AND manual signing fields (Provisioning Profile UUID, Codesign Identity) creates a conflict.
**How to avoid:** Choose ONE signing mode. For Phase 1 spike, use automatic signing -- only set App Store Team ID (10-character code like ABCDE12XYZ from developer.apple.com), leave other fields blank.
**Warning signs:** Xcode error about "automatically signed but provisioning profile has been manually specified."

### Pitfall 6: C# Mobile Export Trap
**What goes wrong:** Choosing C# (Mono) for development, then discovering mobile export is experimental with significant limitations.
**Why it happens:** Godot 4.5 C# mobile export is explicitly marked experimental. iOS requires NativeAOT (.NET 8.0+), Android requires .NET 7.0+.
**How to avoid:** Use GDScript exclusively for this project. The project.godot already uses the standard (non-Mono) Godot build.
**Warning signs:** Export tab showing "experimental" warning for iOS/Android.

### Pitfall 7: Not Pinning Godot Version
**What goes wrong:** Upgrading Godot mid-project breaks plugin compatibility.
**Why it happens:** Godot 4.5 introduced breaking iOS changes. Plugins must be recompiled for each Godot minor version.
**How to avoid:** Pin to Godot 4.5 stable. Do NOT upgrade to 4.6 (currently RC2) without verifying all plugin compatibility. Document the pinned version in project README.
**Warning signs:** Plugin "undefined symbol" errors after engine upgrade.

## Code Examples

### AdMob Initialization and Interstitial Display

```gdscript
# Source: godot-sdk-integrations/godot-admob README
# (https://github.com/godot-sdk-integrations/godot-admob)

# In PlatformServices._init_ads():
func _init_ads() -> void:
    var admob_node = get_node_or_null("/root/MainScene/Admob")
    if admob_node == null:
        push_warning("AdMob node not found -- ads disabled")
        return

    admob_node.initialization_completed.connect(_on_admob_initialized)
    admob_node.initialize()

func _on_admob_initialized() -> void:
    _admob_initialized = true
    _load_interstitial()

func _load_interstitial() -> void:
    var admob_node = get_node_or_null("/root/MainScene/Admob")
    if admob_node:
        admob_node.interstitial_ad_loaded.connect(_on_interstitial_loaded)
        admob_node.interstitial_ad_failed_to_load.connect(_on_interstitial_failed)
        admob_node.load_interstitial_ad()

func _on_interstitial_loaded() -> void:
    pass  # Ready to show

func _on_interstitial_failed(error_code: int) -> void:
    push_warning("Interstitial failed to load: %d" % error_code)

func show_interstitial() -> void:
    if not has_ads():
        return
    var admob_node = get_node_or_null("/root/MainScene/Admob")
    if admob_node:
        admob_node.interstitial_ad_closed.connect(_on_interstitial_closed, CONNECT_ONE_SHOT)
        admob_node.show_interstitial_ad()

func _on_interstitial_closed() -> void:
    EventBus.ad_interstitial_closed.emit()
    _load_interstitial()  # Pre-load next one
```

### iOS Export Configuration Steps

```
# Source: Godot 4.5 official docs
# (https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_ios.html)

1. macOS required (cannot export iOS from Windows/Linux)
2. Install Xcode, launch once, install iOS support
3. Fix xcode-select if needed:
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
4. In Godot: Editor > Manage Export Templates > Download for 4.5
5. Project > Export > Add... > iOS
6. Set App Store Team ID (10-char code from developer.apple.com)
7. Set Bundle Identifier (e.g., com.yourcompany.wordrun)
8. Export Project > select empty output folder
9. Open .xcodeproj in Xcode > Build & Run on device

For faster iteration: link Godot project folder into Xcode via
Finder drag > "Reference files in place" > "Create folders"
```

### Android Export Configuration Steps

```
# Source: Godot 4.5 official docs
# (https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_android.html)

1. Install OpenJDK 17
2. Install Android SDK via Android Studio (version 2023.2.1+)
   - Ensure Platform-Tools 35.0.0+ installed
3. In Godot: Editor > Editor Settings > Android
   - Set Java SDK Path (e.g., /Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home)
   - Set Android SDK Path (e.g., /Users/$USER/Library/Android/sdk)
4. Debug keystore: auto-generated by Godot 4.5 (no manual step needed)
5. Project > Export > Add... > Android
6. For development: select only arm64 architecture to reduce build time
7. For release: select all architectures (arm64 + armeabi-v7a required by Google Play)
8. Install Android Build Template: Project > Install Android Build Template
9. Export as APK for device testing or AAB for Play Store
```

### SaveData Autoload Stub

```gdscript
# scripts/autoloads/save_data.gd
extends Node

const SAVE_PATH := "user://save_data.tres"
const FLAGS_PATH := "user://feature_flags.tres"

func _ready() -> void:
    _load_feature_flags()

func _load_feature_flags() -> void:
    if ResourceLoader.exists(FLAGS_PATH):
        FeatureFlags.instance = ResourceLoader.load(FLAGS_PATH) as FeatureFlags
    else:
        FeatureFlags.instance = FeatureFlags.new()
        _save_feature_flags()

func _save_feature_flags() -> void:
    if FeatureFlags.instance:
        ResourceSaver.save(FeatureFlags.instance, FLAGS_PATH)

func save_game() -> void:
    pass  # Stub -- will be implemented in later phases

func load_game() -> void:
    pass  # Stub -- will be implemented in later phases
```

### Autoload Registration Order

```
# In Project Settings > Autoload tab, register in this order:
# (order matters -- later autoloads can reference earlier ones)

1. EventBus       -> res://scripts/autoloads/event_bus.gd
2. SaveData       -> res://scripts/autoloads/save_data.gd
3. GameManager    -> res://scripts/autoloads/game_manager.gd
4. PlatformServices -> res://scripts/autoloads/platform_services.gd
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| OS.get_window_safe_area() | DisplayServer.get_display_safe_area() | Godot 4.0 | All safe area code must use DisplayServer API |
| Godot 3.x plugin architecture | Godot 4.2+ Android plugin v2 architecture | Godot 4.2 | Plugins must be compiled for v2 architecture; old plugins will not work |
| StoreKit 1 (iOS IAP) | StoreKit 2 (Swift) | Apple ongoing | Newer iOS IAP plugins use StoreKit 2; official godot-ios-plugins still on StoreKit 1 |
| Google Play Billing v5.x | Google Play Billing v7.x | 2024 | Google deprecated pre-v6; apps using old libraries will be rejected |
| Manual debug keystore | Auto-generated by editor | Godot 4.3 | No manual keytool step needed for development builds |
| connect(signal_name, target, method) | signal.connect(callable) | Godot 4.0 | All signal connection code uses Godot 4 callable syntax |

**Deprecated/outdated:**
- `OS.get_window_safe_area()`: Removed in Godot 4. Use `DisplayServer.get_display_safe_area()`.
- Shin-NiL/Godot-Android-Admob-Plugin: Godot 3.x only; do not use.
- poingstudios/godot-admob-plugin: Reported broken on Godot 4.3+; use godot-sdk-integrations fork.
- Official godot-ios-plugins InAppStore: Still uses StoreKit 1; use hrk4649's plugin for StoreKit 2.

## Open Questions

1. **godot-iap production readiness**
   - What we know: v1.2.3 released Jan 25, 2026; supports Godot 4.3+; iOS + Android; 16 GitHub stars, 44 commits.
   - What's unclear: Whether it has been shipped in a production app. Documentation site exists but full API docs were not fetchable.
   - Recommendation: Attempt godot-iap as primary IAP solution during the spike. If it fails validation on either platform within 2 days, fall back to separate platform plugins. The PlatformServices abstraction makes this swap low-cost.

2. **godot-google-play-billing v7 status**
   - What we know: PR #67 submitted to update from v5.2.1 to v7.0.0. Latest release (v3.1.0) compiled with Godot 4.5.
   - What's unclear: Whether v3.1.0 actually includes Billing Library v7, or still ships v5.x.
   - Recommendation: Check the actual Billing Library version in the plugin's build.gradle before using. If it's still v5.x, use code-with-max/godot-google-play-iapp (explicitly v7.1.1) instead.

3. **Xcode 26 compatibility**
   - What we know: Issue #111213 is OPEN. The problem appears plugin-related. Workaround: export as project file only, build in Xcode manually. Disabling problematic addons resolves it.
   - What's unclear: Whether this affects the specific AdMob/IAP plugins we plan to use.
   - Recommendation: Test base export (no plugins) first. Then add plugins incrementally. If Xcode 26 causes issues, use Xcode 16.x (still downloadable from Apple) as fallback.

4. **DisplayServer safe area reliability**
   - What we know: Known bugs on certain Android phones (Pixel 9) and misleading values on desktop.
   - What's unclear: Whether the bugs affect our target device set.
   - Recommendation: Implement manual inset override for debugging. Test on at least 2 physical devices per platform. Keep Notchz plugin as backup.

5. **godot_ios_plugin_iap confirmed Godot version**
   - What we know: v0.3.0 README says "confirmed working with Godot 4.6", updated Jan 26, 2026.
   - What's unclear: Whether it works with Godot 4.5 specifically (it claims 4.6, which is higher).
   - Recommendation: If using as iOS fallback, test with Godot 4.5 explicitly. The plugin uses GDExtension (Swift) which may have version-specific bindings.

## Sources

### Primary (HIGH confidence)
- Godot 4.5 official docs: [Exporting for iOS](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_ios.html) -- export pipeline steps, signing
- Godot 4.5 official docs: [Exporting for Android](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_android.html) -- SDK setup, keystore, templates
- Godot official docs: [Project organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html) -- directory structure patterns
- godot-sdk-integrations/godot-admob GitHub: [v5.3 release](https://github.com/godot-sdk-integrations/godot-admob/releases) -- tested with Godot 4.5.1, API, ad formats
- godot-sdk-integrations/godot-google-play-billing GitHub: [v3.1.0](https://github.com/godot-sdk-integrations/godot-google-play-billing) -- compiled with Godot 4.5, Android IAP

### Secondary (MEDIUM confidence)
- hyochan/godot-iap GitHub: [v1.2.3](https://github.com/hyochan/godot-iap) -- OpenIAP cross-platform IAP, Godot 4.3+
- hrk4649/godot_ios_plugin_iap GitHub: [v0.3.0](https://github.com/hrk4649/godot_ios_plugin_iap) -- StoreKit 2, confirmed Godot 4.6
- code-with-max/godot-google-play-iapp GitHub: [Billing v7.1.1](https://github.com/code-with-max/godot-google-play-iapp) -- tested Godot 4.5
- GDQuest EventBus tutorial: [Event bus singleton](https://www.gdquest.com/tutorial/godot/design-patterns/event-bus-singleton/) -- pattern and code examples
- GDQuest Save Systems: [Save and Load cheat sheet](https://www.gdquest.com/library/cheatsheet_save_systems/) -- ConfigFile, Resources, JSON comparison
- Godot Forum: [Safe area / notch handling](https://forum.godotengine.org/t/simple-way-to-manage-the-notch-on-ios-and-android-mobile-devices/86971)
- DisplayServer API: [Official docs](https://docs.godotengine.org/en/stable/classes/class_displayserver.html) -- get_display_safe_area()
- GitHub Issue [#111213](https://github.com/godotengine/godot/issues/111213) -- Xcode 26 + Godot 4.5 export failure (OPEN, plugin-related)

### Tertiary (LOW confidence)
- Medium blog: [OpenIAP for Godot](https://medium.com/dooboolab/building-in-app-purchases-for-godot-engine-the-openiap-journey-112c98c765fd) -- godot-iap announcement (single source, Jan 2026)
- Notchz Asset Library: [v1.2.1](https://godotengine.org/asset-library/asset/3926) -- safe area plugin (listed as Godot 4.0 compatible, untested on 4.5)
- Community blog: [Using AdMob on Godot 4.3+](https://palawenos.com/2025/03/21/using-admob-on-godot-4-3/) -- confirms godot-sdk-integrations plugin works

## Metadata

**Confidence breakdown:**
- Standard stack (Godot 4.5, renderer): HIGH -- project.godot confirms config, official docs verified
- AdMob plugin selection: HIGH -- v5.3 release notes explicitly state Godot 4.5.1 compatibility
- IAP plugin selection: LOW -- fragmented ecosystem, godot-iap is new (16 stars), fallback options exist but each has caveats
- Architecture patterns (autoloads, EventBus, state machine): HIGH -- well-established Godot community patterns, verified via GDQuest and official docs
- Safe area / banner layout: MEDIUM -- DisplayServer API is official but has known bugs on specific devices
- Feature flags: MEDIUM -- no built-in Godot system; custom implementation is straightforward but unverified pattern
- Export pipeline (iOS): MEDIUM -- documented process works, but Xcode 26 issue is OPEN
- Export pipeline (Android): HIGH -- well-documented, auto-generated keystore since 4.3

**Research date:** 2026-01-29
**Valid until:** 2026-02-28 (30 days -- plugin ecosystem moves fast; re-verify before Phase 2)
