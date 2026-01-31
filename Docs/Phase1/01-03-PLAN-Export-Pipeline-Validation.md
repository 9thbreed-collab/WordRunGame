# Plan 01-03: Export Pipeline Validation

**Wave:** 3 | **Depends on:** Plan 01-02 | **Autonomous:** No (human checkpoint)

## Objective

Configure export presets for iOS and Android, export the bare project (no monetization plugins yet), and validate the entire pipeline on physical devices. This is the critical risk-elimination step.

## Requirements Covered

- **FNDN-01:** Godot project exports and runs on a physical iOS device
- **FNDN-02:** Godot project exports and runs on a physical Android device
- **FNDN-08:** Banner ad region visible + reflow validated on physical hardware

## User Setup Required

### Apple Developer
- Obtain App Store Team ID (10-character code from developer.apple.com)
- Ensure Xcode is installed with iOS support
- Configure xcode-select: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`

### Android SDK
- Install Android Studio and Android SDK (Platform-Tools 35.0.0+)
- Install OpenJDK 17
- Configure Godot Editor Settings with Java SDK and Android SDK paths

## Tasks

### Task 1: Configure export presets

**Android preset:**
- Bundle ID: com.wordrun.game
- Architectures: arm64 only (development)
- Min SDK: 24, Target SDK: 34
- Portrait orientation
- Install Android Build Template via Godot editor

**iOS preset:**
- Bundle ID: com.wordrun.game
- App Store Team ID (user's 10-char code)
- Automatic signing ONLY (no manual provisioning -- avoids Pitfall 5)
- Portrait orientation

**CRITICAL:** Do NOT commit export_presets.cfg or keystores to git.

### Task 2: Validate bare export on physical devices (HUMAN CHECKPOINT)

**Android verification:**
1. Export APK from Godot editor
2. Install via `adb install -r wordrun-test.apk`
3. Verify: portrait orientation, test screen displays, all 4 autoloads loaded, banner shows/hides with reflow, no navigation bar overlap

**iOS verification:**
1. Export Xcode project from Godot editor
2. Open .xcodeproj in Xcode, Build and Run on device
3. Verify same items as Android + safe area respected on notched/Dynamic Island devices

**Common fixes if export fails:**
- Android "no export template": Editor > Manage Export Templates > Download
- iOS "code signing": Check Team ID; ensure valid Apple Developer membership
- iOS Xcode build failure "code 0": Export as project file only, build in Xcode (Pitfall 1)

## Success Criteria

1. export_presets.cfg exists with both presets
2. Android APK installs and runs on physical device
3. iOS Xcode project builds and runs on physical device
4. Banner region shows/hides with reflow on both platforms
5. Safe area respected on notched devices
6. No monetization plugins present (clean pipeline validation)
