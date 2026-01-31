# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-29)

**Core value:** The word-pair puzzle with the surge momentum system must feel like a "rush" -- the tension between solving fast for multipliers and risking a bust, combined with obstacle anticipation, is the experience that makes WordRun! unique.
**Current focus:** Phase 2 in progress -- Core Puzzle Loop UI components (3/4 plans complete). Playable puzzle loop with keyboard, scrolling word display, and timer now functional.

## Current Position

Phase: 2 of 9 (Core Puzzle Loop)
Plan: 3 of 4 in current phase
Status: In progress
Last activity: 2026-01-31 -- Completed 02-03-PLAN.md (OnScreenKeyboard and GameplayScreen)

Progress: [###.......] 21%

## Performance Metrics

**Velocity:**
- Total plans completed: 6 (+2 partial/deferred tasks)
- Average duration: 6 minutes
- Total execution time: 0.78 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 4/4 (2 with deferred tasks) | 31m | 7.8m |
| 2 | 3/4 | 11m | 3.7m |

**Recent Trend:**
- Last 5 plans: 01-04 (19.5m), 02-01 (2m), 02-02 (8m), 02-03 (1m)
- Trend: Phase 2 accelerating (data models and UI components integrating smoothly); plugin integration slower

*Updated after each plan completion*

## Phase Status

| Phase | Name | Status | Requirements |
|-------|------|--------|--------------|
| 1 | Foundation and Validation Spikes | Code complete (4/4 plans, device testing deferred) | 8 items |
| 2 | Core Puzzle Loop | In progress (3/4 plans complete) | 10 items |
| 3 | Game Feel -- Surge, Score, and Audio | Not started | 12 items |
| 4 | Obstacles, Boosts, and Content Pipeline | Not started | 20 items |
| 5 | Progression, Economy, and Retention | Not started | 25 items |
| 6 | World Map, Navigation, and Tutorial | Not started | 17 items |
| 7 | Backend, Auth, Monetization, and Store | Not started | 25 items |
| 8 | Polish, Soft Launch, and Tuning | Not started | Cross-cutting |
| 9 | Post-Launch Features | Not started | v2 scope |

## Key Metrics

- Total v1 requirements: 117
- Requirements complete: 14 (FNDN-05, FNDN-06, FNDN-07, FNDN-08, PUZL-01, PUZL-02, PUZL-03, PUZL-04, PUZL-05, PUZL-06, PUZL-07, PUZL-08, PUZL-09, PUZL-10)
- Requirements partially addressed: 2 (FNDN-03, FNDN-04 -- code wired, device validation deferred)
- Requirements deferred: 2 (FNDN-01, FNDN-02 -- device testing blocked by hardware)
- Current phase progress: 75% (3/4 plans)

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Init]: 9-phase roadmap adopted from research synthesis (7 critical path + soft launch + post-launch)
- [Init]: Firebase recommended as backend; Godot 4.5 plugin compatibility is blocking unknown for Phase 1
- [01-01-D1]: Autoload order: EventBus -> SaveData -> GameManager (later autoloads depend on earlier ones)
- [01-01-D2]: FeatureFlags uses static instance + static methods with string-based flag names (enables runtime Remote Config lookup)
- [01-01-D3]: Portrait 1080x1920 with canvas_items stretch and expand aspect (standard mobile 2D)
- [01-02-D1]: PlatformServices emits banner_region_show BEFORE plugin call so UI appears immediately
- [01-02-D2]: hide_banner() always emits hide signal regardless of plugin/flag state
- [01-02-D3]: VBoxContainer reflow pattern for banner collapse (visible=false + min_size.y=0)
- [01-02-D4]: Test screen set as main_scene for direct architecture validation
- [01-04-D1]: Ad unit IDs stored on Admob node properties (is_real=false uses built-in Google test IDs)
- [01-04-D2]: godot-iap as unified cross-platform IAP plugin (fallback to separate plugins if device testing fails)
- [01-04-D3]: Plugin binaries excluded from git via .gitignore
- [01-04-D4]: Deferred initialization via call_deferred for plugin detection
- [02-01-D1]: WordPair uses word_a (clue) and word_b (answer) terminology
- [02-01-D2]: LevelData uses typed Array[WordPair] for type safety
- [02-01-D3]: Test level follows 12 base + 3 bonus word structure (indices 12-14)
- [02-01-D4]: Gameplay signals in EventBus follow existing pattern (signals only, no logic)
- [02-02-D1]: StyleBoxFlat created programmatically in _ready() rather than in editor for maintainability
- [02-02-D2]: Incorrect input flashes red for 0.2s then clears slot, providing immediate feedback
- [02-02-D3]: Shake uses elastic easing with 5-step oscillation for satisfying physical feel
- [02-03-D1]: OnScreenKeyboard uses dynamic iteration in _ready() to auto-connect all buttons (no manual connections needed)
- [02-03-D2]: Auto-scroll uses cubic easing over 0.4s for natural feel
- [02-03-D3]: Bonus gate stub at word 11 (not 12) because word_pairs is zero-indexed
- [02-03-D4]: ScrollContainer vertical_scroll_mode = 2 (show scrollbar when needed)

### Pending Todos

None.

### Blockers/Concerns

- **HARDWARE BLOCKER**: MacBook Air Mid-2013 (macOS Big Sur 11.7.10 max) cannot run Xcode 14+ needed for iPhone 14 (iOS 16+). Cloud Mac (MacinCloud ~$1/hr) identified as viable alternative. Free Apple ID sufficient for USB testing; $99/yr Apple Developer needed for TestFlight/IAP sandbox.
- **PLUGIN VERIFICATION PENDING**: AdMob v5.3 and godot-iap v1.2.3 code-wired but not yet validated on physical devices. Both plugins claim Godot 4.5 compatibility. Billing Library v7.1.1 confirmed (Pitfall 2 resolved).
- FNDN-01, FNDN-02 (device export validation) deferred until hardware blocker resolved
- FNDN-03, FNDN-04 (plugin device validation) deferred until hardware blocker resolved

## Session Continuity

Last session: 2026-01-31
Stopped at: Completed 02-03-PLAN.md (OnScreenKeyboard and GameplayScreen)
Resume file: None
Next action: Continue Phase 2 execution (plan 02-04 remaining - result screens)
