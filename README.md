# WordRun!

A mobile word puzzle game where momentum creates the rush.

## Overview

WordRun! is a timed word puzzle game built in Godot 4.5 for iOS and Android. Players solve chains of word-pair puzzles in a scrolling window while managing a surge momentum system that creates strategic risk/reward tension. The game combines word puzzle mechanics with RPG-style progression, obstacles, power boosts, and a narrative world map across multiple nations.

**Core Mechanic:** Solve compound phrases and common two-word expressions (e.g., "car > door", "door > stop") by filling letters one at a time. Build surge momentum for score multipliers, but risk busting if you push too far.

## Current Status

**Version:** v0.0.05
**Phase:** Phase 4 In Progress (Obstacles, Boosts, and Content Pipeline)
**Progress:** 31 of 117 v1 requirements complete (2 partially addressed)

Phase 4 is underway. The project has a **working obstacle system** with resource-based architecture and the Padlock obstacle fully implemented with skip/backtrack mechanic. Random Blocks and Sand obstacles are implemented but testing in progress. The boost system (Lock Key, Block Breaker, Bucket of Water) is wired and ready for validation.

### Playable Flow
1. **Menu Screen** - Launch app, tap Play button
2. **Gameplay Screen** - Solve 15-word chain puzzle with surge momentum system
3. **Results Screen** - View score, time, stars, replay or return to menu

### Key Accomplishments (Phase 4 - In Progress)
- Obstacle system architecture: ObstacleBase, ObstacleManager, ObstacleConfig resource pattern
- Template architecture validated: new obstacles require only config + script, no code changes
- Padlock obstacle with skip/backtrack mechanic (auto-skip locked word, solve word+1 to unlock, backtrack)
- LetterSlot LOCKED state with visual styling (dark gray, ghosted appearance)
- WordRow lock support with input guards and modulate tinting
- BoostManager and BoostPanel UI integration for manual boost usage
- Three v1 obstacles implemented: Padlock (tested), Random Blocks (testing), Sand (testing)
- Three counter-boosts wired: Lock Key, Block Breaker, Bucket of Water

### Key Accomplishments (Phase 3)
- SurgeSystem with state machine (IDLE, FILLING, IMMINENT, BUSTED) and threshold detection
- SurgeBar UI with threshold markers and smooth value tweening
- Real-time score calculation with surge multiplier system (1.0x → 3.0x)
- AudioManager autoload with 10-player SFX pool and dual BGM crossfade
- Haptic feedback for letter tap, word complete, surge events, level events
- Animation polish: letter pop-in, word celebration, surge pulse, bust flash
- Bonus gate logic (bonus words unlock if surge meets threshold at word 12)
- Star bar tracking level performance (1-3 stars based on completion time)
- ResultsScreen wired with actual score, time, and star rating

### Key Accomplishments (Phase 2)
- WordPair and LevelData custom resource data model with typed arrays
- LetterSlot UI component with 4 visual states (empty, filled, correct, incorrect)
- WordRow component with dynamic letter slot generation and shake animation feedback
- OnScreenKeyboard QWERTY layout with auto-connected buttons
- GameplayScreen with full puzzle loop: scrolling word display, timer, input handling
- MenuScreen and ResultsScreen with event-driven navigation
- GameManager routing based on EventBus gameplay signals
- Polish: word chain test level, auto-submit on last letter, native keyboard support
- Word display panel with auto-scroll (cubic easing, triggers after 4th word)

### Key Accomplishments (Phase 1)
- Architecture skeleton: EventBus, GameManager, PlatformServices, SaveData autoloads
- PlatformServices abstraction layer for plugin resilience
- BannerAdRegion component with collapsible behavior and test screen
- AdMob v5.3 and godot-iap v1.2.3 plugins installed and integrated
- FeatureFlags system for runtime feature control
- Export pipeline documented (iOS/Android export presets guide created)

### Requirements Complete
**Phase 4 (OBST) - Partial:**
- OBST-01: Obstacle system architecture defined
- OBST-02: Obstacle trigger system implemented
- OBST-05: Padlock obstacle complete with skip/backtrack
- OBST-06: ObstacleConfig resource integration
- OBST-07: Template architecture validated

**Phase 3 (FEEL):**
- FEEL-01: Surge momentum counter display
- FEEL-02: Surge fill/drain mechanics
- FEEL-03: Threshold markers on surge bar
- FEEL-04: Bonus gate surge requirement
- FEEL-05: Score calculation with multipliers
- FEEL-06: Score display in HUD
- FEEL-07: Audio feedback system
- FEEL-08: Haptic feedback
- FEEL-09: ResultsScreen score/time/stars
- FEEL-10: Letter pop-in animation
- FEEL-11: Word completion celebration
- FEEL-12: Surge threshold animations

**Phase 2 (PUZL):**
- PUZL-01 through PUZL-10: Core puzzle loop (all requirements complete)

**Phase 1 (FNDN):**
- FNDN-05 through FNDN-08: Foundation architecture (all requirements complete)

### Requirements Code-Ready (Device Validation Pending)
- FNDN-03: AdMob plugin integrated (awaiting physical device test)
- FNDN-04: IAP plugin integrated (awaiting physical device test)

### Next Milestone
Complete Phase 4: Test Random Blocks and Sand obstacles, validate boost functionality, build word-pair content validation pipeline.

## Technology Stack

**Engine:** Godot 4.5 (GL Compatibility renderer for mobile)
**Platforms:** iOS, Android
**Backend:** TBD (Firebase under evaluation)
**Languages:** GDScript
**Architecture:** Component-Driven Development (CDD), layered scenes/scripts/data/assets

### Planned Integrations
- AdMob (interstitial + rewarded ads)
- In-App Purchases (platform IAP)
- Cloud content delivery for word-pair data
- Firebase Auth (Sign in with Apple, Google Sign-In, email/password)
- Cloud save synchronization

## Key Features (Planned)

### Core Gameplay
- Word-pair puzzle with scrolling window (4-5 visible words)
- Surge momentum system with threshold multipliers and bust mechanic
- 12 base words + 3 bonus words per level (bonus gated by momentum)
- On-screen keyboard input with unlockable alternatives (radial, scrambled tiles)

### Progression
- 25 lands across 3 Nations (v1 scope)
- Boss levels with randomized challenges
- Hearts/hints/lives system with rewarded ad recovery
- Dual currency: Stars (earned) and Diamonds (premium + earned)
- Inventory loadout system for power boosts

### Obstacles & Power Boosts
- 3 obstacle types (v1): Padlock, Random Blocks, Sand
- Corresponding counter-boosts: Lock Key, Block Breaker, Bucket of Water
- Template architecture for extending obstacles in future Nations

### World & Narrative
- World map with Ruut avatar navigation
- Progressive narrative through themed word pools and NPC dialogue
- Login streaks with rewards
- Progressive tutorial system (one mechanic at a time)

### Monetization
- In-App Purchases: diamond packs, power packs, upgrades
- Ads: interstitial (between levels), rewarded (recovery), banner (collapsible)
- Server-configurable economy and ad frequency

## How to Run

**Requirements:**
- Godot 4.5 or later
- iOS development: Xcode, Apple Developer account
- Android development: Android SDK, JDK

**Steps:**
1. Clone repository
2. Open project in Godot 4.5
3. Press F5 or click Play to launch
4. Current state: Playable puzzle loop (Menu -> Gameplay -> Results)

**Test the Puzzle Loop:**
- Tap Play button on menu screen
- Solve word chain: SNOW → ball → park → bench → press → conference → room → mate → check → point → guard → rail → road → trip → wire → less → careless → whisper → good → morning → sickness → benefit → cost → front → line
- Use on-screen QWERTY keyboard or native keyboard (A-Z, Backspace)
- First letter of each word is pre-revealed
- Wrong answer flashes red and shakes, then clears for retry
- Auto-scroll after 4th word solved
- Complete level or let timer run out to see results screen

## Project Structure

```
WordRunGame/
├── .planning/               # Roadmap, requirements, state tracking
│   ├── PROJECT.md          # Project overview and core value
│   ├── ROADMAP.md          # 9-phase execution plan
│   ├── REQUIREMENTS.md     # 117 v1 requirements
│   ├── STATE.md            # Project position and metrics
│   ├── research/           # Stack, features, architecture research
│   └── phases/             # Per-phase context and planning
├── scenes/                 # Godot scene files
├── scripts/                # GDScript files (pending)
├── data/                   # Game data resources (pending)
├── assets/                 # Audio, fonts, sprites, UI
│   ├── audio/
│   ├── fonts/
│   ├── sprites/
│   └── ui/
├── Docs/                   # Documentation and session summaries
│   ├── sessions/           # Per-session summaries
│   ├── CLAUDE.md           # AI agent context
│   └── VGD_WORKFLOW.md     # Visual game development workflow
└── project.godot           # Godot project configuration
```

## Development Approach

**Philosophy:** Documentation-first during foundation, component-driven for UI/UX, offline-first for gameplay.

**Session Versioning:** v0.0.XX during foundation, v0.X.XX during pre-release phases, v1.0.0 at launch.

**Source of Truth:** This repository is the only source of truth. Ignore all archived projects, repos, and prior implementations.

**Risk Mitigation:** Phase 1 validates highest-risk unknowns (mobile pipeline, plugin compatibility) before game code begins.

## Roadmap

**9 Phases (v1 through soft launch):**
1. Foundation and Validation Spikes (validate pipeline, plugins, architecture shell)
2. Core Puzzle Loop (word-pair solving, scrolling window, touch input)
3. Game Feel - Surge, Score, and Audio (momentum system, multipliers, feedback)
4. Obstacles, Boosts, and Content Pipeline (3 obstacles, counter-boosts, word validation)
5. Progression, Economy, and Retention (hearts/lives, currency, boss levels, inventory)
6. World Map, Navigation, and Tutorial (25 lands, Ruut avatar, progressive teaching)
7. Backend, Auth, Monetization, and Store (Firebase, IAP, ads, cloud sync)
8. Polish, Soft Launch, and Tuning (test market, analytics, economy tuning)
9. Post-Launch Features (Vs mode, skins, Nations 4-9, expanded content)

**Current Phase:** Phase 3 Complete (Phase 4 planning ready to begin)

## Contributing

This is a solo creator project currently in foundation phase. Contributions are not being accepted at this time.

## License

Proprietary - All rights reserved.

---

**Last Updated:** 2026-02-05
**Project Started:** 2026-01-22
**Engine:** Godot 4.5
