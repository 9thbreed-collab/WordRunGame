# Plan 01-02: PlatformServices, Banner Region, and Test Screen

**Wave:** 2 | **Depends on:** Plan 01-01 | **Autonomous:** Yes

## Objective

Create the PlatformServices autoload (abstraction layer for all monetization plugins), the collapsible banner ad region UI component, and a test screen that demonstrates banner toggle with layout reflow.

## Requirements Covered

- **FNDN-08:** All screen layouts reserve a collapsible bottom banner ad region that refluxes when toggled off
- PlatformServices foundation (prerequisite for FNDN-03 and FNDN-04 in later plans)

## Files Modified

| File | Purpose |
|------|---------|
| scripts/autoloads/platform_services.gd | Abstraction layer for all monetization plugin calls |
| scripts/ui/banner_ad_region.gd | Safe-area-aware collapsible banner container |
| scenes/ui/banner_ad_region.tscn | Reusable banner ad region scene |
| scenes/screens/test_screen.tscn | Test screen demonstrating banner toggle and layout reflow |
| scenes/main.tscn | Root scene loading test screen |
| project.godot | Add PlatformServices as 4th autoload |

## Tasks

### Task 1: Create PlatformServices autoload

Complete ads/IAP interface with stubs:
- **Capability checks:** has_ads(), has_iap(), has_banner_ads(), has_interstitial_ads(), has_rewarded_ads()
- **Ads interface:** show_interstitial(), show_rewarded(), show_banner(), hide_banner()
- **IAP interface:** purchase(product_id), restore_purchases()
- All methods check FeatureFlags before operating
- show_banner/hide_banner emit EventBus signals
- All stubs use push_warning() (visible in output, don't crash)

Register as 4th autoload. Order: EventBus, SaveData, GameManager, PlatformServices.

### Task 2: Create banner ad region and test screen

**Banner ad region (MarginContainer):**
- Bottom-anchored, 80px default height
- Safe area via DisplayServer.get_display_safe_area()
- EventBus-driven show/hide
- When hidden: visible=false AND custom_minimum_size.y=0 (enables reflow)
- Artwork placeholder (ColorRect with "Ad Space" label)

**Test screen (VBoxContainer):**
- ContentArea (expands to fill) + BannerAdRegion (bottom)
- Autoload status labels (EventBus, GameManager, SaveData, PlatformServices)
- Buttons: Show Banner, Hide Banner, Test Interstitial, Test IAP
- State display from GameManager

The VBoxContainer layout ensures ContentArea expands when banner collapses -- this IS the reflow behavior.

## Success Criteria

1. PlatformServices has complete ads/IAP interface with FeatureFlag checks
2. Banner ad region shows at bottom, hides with layout reflow
3. Test screen renders with autoload status and toggle buttons
4. All 4 autoloads registered in correct order
5. Project launches to test screen without errors
