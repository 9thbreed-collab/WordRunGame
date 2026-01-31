# Phase 1: Foundation and Validation Spikes - Context

**Gathered:** 2026-01-29
**Status:** Ready for planning

## Phase Boundary

Validate that the Godot 4.5 mobile export pipeline, AdMob, and IAP plugins work on physical iOS and Android devices. Establish the minimal project architecture skeleton (autoloads that prevent future refactors) and a banner ad layout contract. No gameplay code -- this phase proves the pipeline before game code begins.

## Implementation Decisions

### Monetization Integration Philosophy
- Use maintained, version-compatible Godot mobile plugins for Ads + IAP
- Insulate game code via a tiny internal interface layer (PlatformServices autoload) so plugins can be swapped later without touching gameplay/UI code
- "Swap" means at build/update time -- never downloading or executing new code after release
- The abstraction layer is the primary long-term strategy, not a temporary workaround

### Plugin Fallback Strategy (ordered)
1. **Primary:** Plugin + abstraction layer (lowest friction long-term)
2. **Backup A:** Temporarily disable the broken surface (e.g., banners on iOS) via feature flags and ship only what's stable (rewarded/interstitial). Troubleshoot the broken surface separately -- do not block release on it

### Banner Ad Region
- Bottom-anchored reserved container
- Must not cover gameplay touch targets
- Must respect safe area insets and notches
- Must behave predictably across aspect ratios (phones, tablets, notched/notchless)
- Default content when no ad is served: game artwork with subtle idle movement (so the space looks intentional before ads are live, and transitions naturally when an ad replaces it)
- Collapsed state: space fully reclaimed, layout reflows

### Architecture Shell Depth
- **Lean approach:** Only build autoloads that prevent refactors in later phases
- **EventBus:** Signals/events only (pure relay, no logic)
- **GameManager:** Scene routing + top-level state machine
- **PlatformServices:** Ads/IAP interface + capability checks (the abstraction layer for monetization plugins)
- **SaveData:** Read/write stubs for local persistence
- **Everything else:** Stubs only if needed to avoid blocking; do not over-build

### Test Device Strategy
- Validate on physical iOS device + physical Android device
- Use emulator/simulator for quick iteration during development
- Validation goals on physical devices:
  - Export/install loop works end-to-end on both platforms
  - Touch input registers correctly
  - Banner region respects safe area
  - At least one ad format displays (interstitial or rewarded)
  - At least one IAP sandbox flow completes

### Claude's Discretion
- Specific plugin selection for AdMob and IAP (choose best-maintained for Godot 4.5)
- Directory structure specifics within the layered architecture convention
- CI/CD pipeline approach (if included in this phase)
- GameManager state enum values and transition logic
- EventBus initial signal definitions
- SaveData file format and encryption approach

## Specific Ideas

- PlatformServices is a new autoload concept (not in the original 8-autoload research). It replaces direct plugin calls throughout the codebase with a stable internal API. Research should determine how to structure this interface for Ads (show interstitial, show rewarded, show banner, hide banner, check capability) and IAP (purchase, restore, check receipt).
- The banner artwork fallback (game art with subtle idle movement) is a deliberate design choice so players never see an empty/broken ad space. The transition from artwork to live ad should be seamless.
- Feature flags for disabling broken surfaces means the flag system (even if just a local config dictionary initially) must be in place in Phase 1.

## Deferred Ideas

None -- discussion stayed within phase scope.

---

*Phase: 01-foundation-and-validation-spikes*
*Context gathered: 2026-01-29*
