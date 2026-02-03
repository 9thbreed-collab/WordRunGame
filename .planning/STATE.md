# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-01-29)

**Core value:** The word-pair puzzle with the surge momentum system must feel like a "rush" -- the tension between solving fast for multipliers and risking a bust, combined with obstacle anticipation, is the experience that makes WordRun! unique.
**Current focus:** Phase 3 complete -- Game Feel delivered. Surge momentum system with scoring, audio/haptic feedback, and animation polish creates the strategic risk/reward tension at the heart of WordRun's unique experience.

## Current Position

Phase: 3 of 9 (Game Feel - Surge, Score, and Audio)
Plan: 3 of 3 in current phase
Status: Phase complete
Last activity: 2026-02-02 -- Completed 03-03-PLAN.md (Animation Polish) plus post-phase tuning

Progress: [#####.....] 35%

## Performance Metrics

**Velocity:**
- Total plans completed: 10 (+2 partial/deferred tasks)
- Average duration: 4.6 minutes
- Total execution time: 1.24 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 1 | 4/4 (2 with deferred tasks) | 31m | 7.8m |
| 2 | 4/4 | 13m | 3.3m |
| 3 | 3/3 | 15m (est) | 5.0m |

**Recent Trend:**
- Last 5 plans: 03-01 (6m est), 03-02 (5m est), 03-03 (4m est), 02-03 (1m), 02-04 (2m)
- Trend: Phase 3 complete with strong velocity (avg 5.0m est); surge system complexity handled efficiently with established patterns

*Updated after each plan completion*

## Phase Status

| Phase | Name | Status | Requirements |
|-------|------|--------|--------------|
| 1 | Foundation and Validation Spikes | Code complete (4/4 plans, device testing deferred) | 8 items |
| 2 | Core Puzzle Loop | Complete (4/4 plans) | 10 items |
| 3 | Game Feel -- Surge, Score, and Audio | Complete (3/3 plans) | 12 items |
| 4 | Obstacles, Boosts, and Content Pipeline | Not started | 20 items |
| 5 | Progression, Economy, and Retention | Not started | 25 items |
| 6 | World Map, Navigation, and Tutorial | Not started | 17 items |
| 7 | Backend, Auth, Monetization, and Store | Not started | 25 items |
| 8 | Polish, Soft Launch, and Tuning | Not started | Cross-cutting |
| 9 | Post-Launch Features | Not started | v2 scope |

## Key Metrics

- Total v1 requirements: 117
- Requirements complete: 26 (FNDN-05 through FNDN-08, PUZL-01 through PUZL-10, FEEL-01 through FEEL-12)
- Requirements partially addressed: 2 (FNDN-03, FNDN-04 -- code wired, device validation deferred)
- Requirements deferred: 2 (FNDN-01, FNDN-02 -- device testing blocked by hardware)
- Current phase progress: 100% (3/3 plans - Phase 3 complete)

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
- [02-04-D1]: MenuScreen and ResultsScreen transition to their AppState in _ready() before user interaction
- [02-04-D2]: GameManager routes both level_completed and level_failed to ResultsScreen (single screen handles both states)
- [02-04-D3]: GameplayScreen already decoupled (only emits EventBus signals, no direct screen changes)
- [02-04-D4]: project.godot main_scene points to menu_screen (app launches into menu not test screen)
- [03-01-D1]: SurgeSystem is a child node of GameplayScreen, not autoload (level-specific configuration)
- [03-01-D2]: Bust triggers only when player reaches IMMINENT (≥90) then falls below it (strategic risk/reward)
- [03-01-D3]: Bonus gate checks surge value at word 12 index (word 13 in 1-indexed display)
- [03-01-D4]: Score uses integer math (base * multiplier) for clear calculation
- [03-02-D1]: AudioManager is autoload (global audio control, persists across scenes)
- [03-02-D2]: SFX pool of 10 players allows concurrent sounds without instantiation during gameplay
- [03-02-D3]: Haptic calls co-located with SFX in AudioManager (feedback is one concept)
- [03-02-D4]: Placeholder audio files used initially, real assets sourced in Phase 8 (Polish)
- [03-03-D1]: Tweens for all animations (no AnimationPlayer needed at this stage)
- [03-03-D2]: Letter pop skipped on reveal (only user-typed letters pop)
- [03-03-D3]: Bust sequence is brief (~0.5s) to avoid frustrating gameplay interruption
- [03-03-D4]: Staggered letter celebration adds polish without complexity
- [Tuning-D1]: Drain rate reduced from 3.0/sec to 1.2/sec for better player control
- [Tuning-D2]: Star bar duration extended to 7 minutes (was implicit, now explicit)
- [Tuning-D3]: Star thresholds adjusted for achievable targets: 1★ @ 5min, 2★ @ 3min, 3★ @ 7min completion

### Pending Todos

None.

### Blockers/Concerns

- **HARDWARE BLOCKER**: MacBook Air Mid-2013 (macOS Big Sur 11.7.10 max) cannot run Xcode 14+ needed for iPhone 14 (iOS 16+). Cloud Mac (MacinCloud ~$1/hr) identified as viable alternative. Free Apple ID sufficient for USB testing; $99/yr Apple Developer needed for TestFlight/IAP sandbox.
- **PLUGIN VERIFICATION PENDING**: AdMob v5.3 and godot-iap v1.2.3 code-wired but not yet validated on physical devices. Both plugins claim Godot 4.5 compatibility. Billing Library v7.1.1 confirmed (Pitfall 2 resolved).
- FNDN-01, FNDN-02 (device export validation) deferred until hardware blocker resolved
- FNDN-03, FNDN-04 (plugin device validation) deferred until hardware blocker resolved

## Session Continuity

Last session: 2026-02-02
Stopped at: Completed 03-03-PLAN.md (Animation Polish) plus post-phase tuning -- Phase 3 complete
Resume file: None
Next action: Begin Phase 4 planning (Obstacles, Boosts, and Content Pipeline)
