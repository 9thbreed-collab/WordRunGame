# Plan 01-04: Monetization Plugin Spike

**Wave:** 4 | **Depends on:** Plan 01-03 | **Autonomous:** No (human checkpoint)

## Objective

Install the AdMob and IAP plugins, wire them into PlatformServices (replacing stubs with real plugin calls), and validate that a test interstitial ad displays and a sandbox IAP purchase flow initiates on both physical devices.

This is the monetization validation spike -- the highest-risk unknown in the project.

## Requirements Covered

- **FNDN-03:** AdMob plugin loads and displays a test ad on both platforms
- **FNDN-04:** IAP plugin completes a sandbox purchase on both platforms

## User Setup Required

### AdMob
- Test ad unit IDs are built into the Google Mobile Ads SDK -- no account needed for spike
- Create AdMob account later for production IDs (admob.google.com)

### Google Play Console (for IAP)
- Create developer account ($25 one-time fee)
- Create internal test app listing
- Add test account email to License Testing
- Create at least one managed in-app product

### App Store Connect (for IAP)
- Create app record in App Store Connect
- Create sandbox tester account
- Create at least one in-app purchase product

## Tasks

### Task 1: Install AdMob plugin and wire into PlatformServices

Install godot-sdk-integrations/godot-admob v5.3 into addons/godot-admob/.

Wire into PlatformServices:
- Replace _init_ads() stub with real AdMob initialization
- Use Google's TEST ad unit IDs (ca-app-pub-3940256099942544/...)
- Connect AdMob lifecycle signals to EventBus
- Do NOT hardcode ad unit IDs in scripts

**Fallback:** If godot-admob v5.3 fails within 1 day, leave stubs and document failure.

### Task 2: Install IAP plugin and wire into PlatformServices

**Primary:** Install godot-iap v1.2.3 into addons/godot-iap/.

Wire into PlatformServices:
- Replace _init_iap() stub with real initialization
- Connect purchase/restore signals to EventBus

**Fallback strategy (if godot-iap fails within 2 days):**
1. Remove addons/godot-iap/
2. Android: godot-google-play-billing v3.1.0 or code-with-max/godot-google-play-iapp (Billing v7.1.1)
3. iOS: hrk4649/godot_ios_plugin_iap v0.3.0
4. Use OS.get_name() to route to correct platform plugin
5. PlatformServices interface does NOT change

**If ALL plugins fail:** `FeatureFlags.set_flag("iap_enabled", false)` -- disables IAP without touching other code.

### Task 3: Validate monetization plugins on physical devices (HUMAN CHECKPOINT)

**Android device:**
1. Export APK, install, launch
2. Tap "Test Interstitial" -- Google test ad should display
3. Tap "Show Banner" -- test banner should appear
4. Tap "Test IAP" -- Google Play purchase dialog should appear

**iOS device:**
1. Export Xcode project, build and run
2. Same verification as Android
3. IAP requires sandbox tester Apple ID on device

**Expected results:**
- FNDN-03 PASS: Test interstitial displays on BOTH platforms
- FNDN-04 PASS: IAP purchase dialog appears on BOTH platforms

**Acceptable partial results:**
- AdMob works on both but IAP only works on one platform -- use feature flag to disable on broken platform
- IAP flow initiates but doesn't complete (sandbox config, not plugin issue) -- PASS
- Banner ads display but look wrong -- PASS (visual polish is later)

## Success Criteria

1. AdMob test interstitial displays on at least one physical device (both ideal)
2. IAP sandbox purchase flow initiates on at least one physical device
3. All plugin calls go through PlatformServices -- no direct plugin access
4. Feature flags can disable ads or IAP at runtime
5. If any plugin fails: fallback documented, feature flag disables broken surface
