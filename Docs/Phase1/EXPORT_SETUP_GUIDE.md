# Export Pipeline Setup Guide

Phase 1, Plan 01-03: Export preset configuration for iOS and Android.

## Prerequisites

### 1. Install Godot Export Templates

Export templates for Godot 4.5 must be installed before exporting.

**Check:** Look for files at `~/Library/Application Support/Godot/export_templates/4.5.stable/`

**Install (if missing):**
1. Open Godot Editor
2. Editor menu > Manage Export Templates
3. Click "Download and Install"
4. Wait for download to complete (several hundred MB)

### 2. Android SDK Setup

- Install Android Studio (or standalone SDK)
- SDK path typically: `~/Library/Android/sdk`
- Install SDK Platform 34 (Android 14)
- Install Build Tools 34.x
- In Godot: Editor > Editor Settings > Export > Android
  - Set Android SDK Path
  - Set Debug Keystore path (auto-generated at `~/.android/debug.keystore`)

### 3. iOS / Xcode Setup

- Install Xcode from Mac App Store (latest version)
- Open Xcode once to accept license and install components
- Ensure you have an Apple Developer account (free or paid)
  - Free: Can test on personal device only
  - Paid ($99/yr): Required for App Store distribution

## Android Export Preset Configuration

In Godot Editor:

1. **Project > Export > Add Preset > Android**

2. **Configure these settings:**

| Setting | Value |
|---------|-------|
| Preset Name | Android |
| Unique Name (Bundle ID) | com.wordrun.game |
| Architectures | arm64 (uncheck arm32 for dev builds) |
| Min SDK Version | 24 (Android 7.0) |
| Target SDK Version | 34 (Android 14) |
| Screen Orientation | Portrait |
| Fullscreen | true |
| Internet Permission | Enabled (needed for ads later) |

3. **Export path:** Set to project root, filename `wordrun-test.apk`

4. **Debug keystore:** Should auto-detect. If not, point to `~/.android/debug.keystore` (password: `android`)

### Android Export & Test

```bash
# Export from Godot Editor: Project > Export > Android > Export Project

# Install via ADB (device connected with USB debugging enabled):
adb install -r wordrun-test.apk

# Or for fresh install:
adb install wordrun-test.apk

# View logs:
adb logcat -s godot
```

## iOS Export Preset Configuration

In Godot Editor:

1. **Project > Export > Add Preset > iOS**

2. **Configure these settings:**

| Setting | Value |
|---------|-------|
| Preset Name | iOS |
| Bundle Identifier | com.wordrun.game |
| App Store Team ID | Your 10-character Team ID |
| Code Sign Identity Debug | iPhone Developer |
| Code Sign Identity Release | iPhone Distribution |
| Provisioning Profile | Automatic (leave empty for auto-signing) |
| Orientation Portrait | ON |
| Orientation Landscape Left | OFF |
| Orientation Landscape Right | OFF |
| Orientation Portrait Upside Down | OFF |
| Launch Screen Storyboard | Leave default |

3. **Finding your Team ID:**
   - Open Xcode > Preferences > Accounts
   - Select your Apple ID
   - Your Team ID is the 10-character alphanumeric code

### iOS Export & Test

```bash
# 1. Export from Godot: Project > Export > iOS > Export Project
#    Select an EMPTY folder (e.g., ios_build/)

# 2. Open the generated Xcode project:
open ios_build/WordRun.xcodeproj

# 3. In Xcode:
#    - Select your physical device as target (not simulator)
#    - Under Signing & Capabilities, check "Automatically manage signing"
#    - Select your Team
#    - Click Run (Cmd+R)
```

## Verification Checklist

After installing on a physical device, verify:

- [ ] App opens in portrait orientation
- [ ] Test screen displays "WordRun! Test Screen"
- [ ] All 4 autoload status labels show "loaded"
- [ ] Banner ad region visible at bottom with placeholder
- [ ] Tap "Hide Banner" -- banner region disappears, content expands
- [ ] Tap "Show Banner" -- banner region reappears, content shrinks
- [ ] On notched/Dynamic Island device: safe area respected, banner does not overlap navigation bar

## Common Issues

### Android

| Issue | Fix |
|-------|-----|
| "No export template found" | Editor > Manage Export Templates > Download |
| "JDK not found" | Install JDK 17, set path in Editor Settings |
| "Android SDK not found" | Set SDK path in Editor > Editor Settings > Export > Android |
| "Debug keystore not found" | Run: `keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"` |
| Black screen on device | Check that main_scene is set in project.godot |

### iOS

| Issue | Fix |
|-------|-----|
| "Code signing" error | Check Team ID; ensure valid Apple Developer membership |
| Xcode build fails "code 0" | Export as "project file only", build directly in Xcode |
| "Provisioning profile" error | In Xcode, enable "Automatically manage signing" |
| App won't install on device | Trust the developer: Settings > General > VPN & Device Management |
| Safe area not respected | Verify window/stretch settings in project.godot |

## Files Excluded from Git

The following are excluded via `.gitignore`:

- `export_presets.cfg` -- Contains signing configuration (machine-specific)
- `*.keystore` / `*.jks` -- Android signing keys (secret)
- `android/` -- Android export build directory
- `ios_build/` -- iOS export build directory
- `*.apk` / `*.aab` / `*.ipa` -- Built binaries
