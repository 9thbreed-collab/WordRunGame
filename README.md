# WordRun!

A mobile word puzzle game where momentum creates the rush.

## Overview

WordRun! is a timed word puzzle game built in Godot 4.5 for iOS and Android. Players solve chains of word-pair puzzles in a scrolling window while managing a surge momentum system that creates strategic risk/reward tension. The game combines word puzzle mechanics with RPG-style progression, obstacles, power boosts, and a narrative world map across multiple nations.

**Core Mechanic:** Solve compound phrases and common two-word expressions (e.g., "car > door", "door > stop") by filling letters one at a time. Build surge momentum for score multipliers, but risk busting if you push too far. Navigate obstacles like padlocks, virus blocks, and sand that add variety and strategic depth.

## Current Status

**Version:** v0.0.07
**Phase:** Phase 4 In Progress (Obstacles, Boosts, and Content Pipeline)
**Progress:** 48 of 117 v1 requirements complete

Phase 4 Plan 04-01 is **COMPLETE** with significant expansion into bonus mode, hints, and content pipeline. The project has a **fully functional obstacle system** with three v1 obstacles, **bonus mode with purple surge bar**, **hint system with 3 hints per level**, and **JSON-based content loading** via ContentCache autoload.

### Playable Flow
1. **Menu Screen** - Launch app, tap Play button
2. **Gameplay Screen** - Solve 15-word chain puzzle with surge momentum and obstacles
3. **Results Screen** - View score, time, stars, replay or return to menu

### Key Accomplishments (Phase 4 - Plan 04-01 Complete + Expansions)
- Obstacle system architecture: ObstacleBase, ObstacleManager, ObstacleConfig resource pattern
- Template architecture validated: new obstacles require only config + script, no code changes
- Multi-obstacle support: multiple obstacles can coexist on same word and across level
- **Padlock obstacle:** Skip locked word, auto-unlock after solving next word, backtrack to solve
- **Virus obstacle:** Gradual spread (1 block/2sec), round-robin distribution, 100% virus auto-solves with zero points
- **Sand obstacle:** Gradual fill on 1-5 words simultaneously, 100% sand makes word unsolvable
- **Lock Key boost:** Clears any padlock in level (works even when word is skipped)
- **Block Breaker boost:** Clears all virus blocks from all words instantly
- **Bucket of Water boost:** Clears sand from 3 words around current word
- **Bonus mode:** Purple surge bar, 50-second fixed timer, bonus words 13-15 unlocked at word 12 if surge ≥ 60
- **Hint system:** 3 hints per level, reveals random unrevealed letters, disabled when word complete
- **ContentCache autoload:** JSON-based level loading from data/baseline/ with .tres fallback
- LetterSlot visual states: 11 states (includes BONUS_EMPTY, BONUS_FILLED, BONUS_CORRECT)
- Caret glow: Pulsing sky blue indicator on current input slot for visual clarity
- Results screen: Displays score, time, stars, and words solved progress metric
- Configurable level structure: base_word_count and bonus_word_count for variable level lengths

### Key Accomplishments (Phase 3 - Complete)
- SurgeSystem with state machine (IDLE, FILLING, IMMINENT, BUSTED) and threshold detection
- SurgeBar UI with threshold markers and smooth value tweening
- Real-time score calculation with surge multiplier system (1.0x → 3.0x)
- AudioManager autoload with 10-player SFX pool and dual BGM crossfade
- Haptic feedback for letter tap, word complete, surge events, level events
- Animation polish: letter pop-in, word celebration, surge pulse, bust flash
- Bonus gate logic (bonus words unlock if surge meets threshold at word 12)
- Star bar tracking level performance (1-3 stars based on completion time)
- ResultsScreen wired with actual score, time, and star rating

### Key Accomplishments (Phase 2 - Complete)
- WordPair and LevelData custom resource data model with typed arrays
- LetterSlot UI component with 4 base visual states
- WordRow component with dynamic letter slot generation and shake animation feedback
- OnScreenKeyboard QWERTY layout with auto-connected buttons
- GameplayScreen with full puzzle loop: scrolling word display, timer, input handling
- MenuScreen and ResultsScreen with event-driven navigation
- GameManager routing based on EventBus gameplay signals
- Polish: word chain test level, auto-submit on last letter, native keyboard support
- Word display panel with auto-scroll (cubic easing, triggers after 4th word)

### Key Accomplishments (Phase 1 - Complete)
- Architecture skeleton: EventBus, GameManager, PlatformServices, SaveData autoloads
- PlatformServices abstraction layer for plugin resilience
- BannerAdRegion component with collapsible behavior and test screen
- AdMob v5.3 and godot-iap v1.2.3 plugins installed and integrated
- FeatureFlags system for runtime feature control
- Export pipeline documented (iOS/Android export presets guide created)

### Requirements Complete
**Phase 4 (OBST + CONT) - Plan 04-01 Complete + Expansions:**
- OBST-01 through OBST-11: All Plan 04-01 requirements ✓
- OBST-12: Bonus mode implementation (partial - surge mechanics complete) ✓
- OBST-13: Hint system (3 hints per level with single letter reveal) ✓
- CONT-01: JSON-based level loading (ContentCache autoload) ✓
- CONT-02: Themed word pools (grasslands.json template) ✓
- CONT-03: Local caching (.tres fallback for offline play) ✓

**Phase 3 (FEEL) - Complete:**
- FEEL-01 through FEEL-12: All surge, score, and audio requirements ✓

**Phase 2 (PUZL) - Complete:**
- PUZL-01 through PUZL-10: All core puzzle loop requirements ✓

**Phase 1 (FNDN) - Complete:**
- FNDN-05 through FNDN-08: All foundation architecture requirements ✓

### Requirements Code-Ready (Device Validation Pending)
- FNDN-03: AdMob plugin integrated (awaiting physical device test)
- FNDN-04: IAP plugin integrated (awaiting physical device test)

### Next Milestone
Begin Phase 5 (Progression & Economy): Implement hearts/lives system, boost inventory, dual currency (Stars/Diamonds), and boss levels. Or continue Phase 4 content expansion: populate lands 1-10 with JSON level data.

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
- Three v1 obstacles: Padlock, Virus (Random Blocks), Sand
- Three counter-boosts: Lock Key, Block Breaker, Bucket of Water
- On-screen keyboard input with unlockable alternatives (radial, scrambled tiles)

### Progression
- 25 lands across 3 Nations (v1 scope)
- Boss levels with randomized challenges
- Hearts/hints/lives system with rewarded ad recovery
- Dual currency: Stars (earned) and Diamonds (premium + earned)
- Inventory loadout system for power boosts

### Obstacles & Power Boosts
- **Padlock:** Locks word, requires solving next word to unlock (or use Lock Key boost)
- **Virus (Random Blocks):** Spreads gradually across words, 100% virus auto-solves with zero points (or use Block Breaker boost)
- **Sand:** Gradually fills 1-5 words, 100% sand makes word unsolvable (or use Bucket of Water boost)
- Template architecture supports adding new obstacle types in future Nations

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
4. Current state: Playable puzzle loop with obstacles (Menu -> Gameplay -> Results)

**Test the Full Feature Set:**
- Tap Play button on menu screen
- Solve word chain: SNOW → ball → park → bench → ... (15 words total)
- Use on-screen QWERTY keyboard or native keyboard (A-Z, Backspace)
- First letter of each word is pre-revealed
- Watch caret glow pulse on current input slot (sky blue)
- Encounter obstacles:
  - **Padlock at word 5:** Word auto-skips, solve word 6 to unlock, backtrack to solve word 5
  - **Virus at word 2:** Spreads gradually to nearby words, use Block Breaker boost to clear
  - **Sand at words 3-7:** Fills random slots over time, use Bucket of Water boost to clear
- Use boost buttons in top panel: Lock Key, Block Breaker, Bucket of Water
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
├── scripts/                # GDScript files
│   ├── autoloads/         # Global singleton nodes
│   ├── gameplay/          # Obstacle system, boost system
│   ├── resources/         # Custom resource definitions
│   ├── screens/           # Screen controllers
│   └── ui/                # UI components
├── data/                   # Game data resources
│   └── levels/            # LevelData resources
├── assets/                 # Audio, fonts, sprites, UI
│   ├── audio/
│   ├── fonts/
│   ├── sprites/
│   └── ui/
├── Docs/                   # Documentation and session summaries
│   ├── sessions/           # Per-session summaries
│   ├── CLAUDE.md           # AI agent context
│   ├── AGENTS.md           # Multi-agent context
│   ├── GEMINI.md           # Gemini agent context
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
1. Foundation and Validation Spikes (validate pipeline, plugins, architecture shell) ✓
2. Core Puzzle Loop (word-pair solving, scrolling window, touch input) ✓
3. Game Feel - Surge, Score, and Audio (momentum system, multipliers, feedback) ✓
4. Obstacles, Boosts, and Content Pipeline (3 obstacles, counter-boosts, word validation) - In Progress
5. Progression, Economy, and Retention (hearts/lives, currency, boss levels, inventory)
6. World Map, Navigation, and Tutorial (25 lands, Ruut avatar, progressive teaching)
7. Backend, Auth, Monetization, and Store (Firebase, IAP, ads, cloud sync)
8. Polish, Soft Launch, and Tuning (test market, analytics, economy tuning)
9. Post-Launch Features (Vs mode, skins, Nations 4-9, expanded content)

**Current Phase:** Phase 4 In Progress (Plan 04-01 Complete, Plan 04-02 or 04-03 next)

## Contributing

This is a solo creator project currently in foundation phase. Contributions are not being accepted at this time.

## License

Proprietary - All rights reserved.

---

**Last Updated:** 2026-02-09
**Project Started:** 2026-01-22
**Engine:** Godot 4.5
