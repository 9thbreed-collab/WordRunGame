# WordRun!

A mobile word puzzle game where momentum creates the rush.

## Overview

WordRun! is a timed word puzzle game built in Godot 4.5 for iOS and Android. Players solve chains of word-pair puzzles in a scrolling window while managing a surge momentum system that creates strategic risk/reward tension. The game combines word puzzle mechanics with RPG-style progression, obstacles, power boosts, and a narrative world map across multiple nations.

**Core Mechanic:** Solve compound phrases and common two-word expressions (e.g., "car > door", "door > stop") by filling letters one at a time. Build surge momentum for score multipliers, but risk busting if you push too far.

## Current Status

**Version:** v0.0.02
**Phase:** Phase 1 Complete (Foundation and Validation Spikes)
**Progress:** 4 of 117 v1 requirements complete (8 partially addressed)

Phase 1 code is complete. The project has established architecture foundation (autoloads, PlatformServices abstraction, feature flags) and integrated monetization plugins (AdMob v5.3, godot-iap v1.2.3). Physical device validation is deferred due to hardware constraints but does not block Phase 2-6 development.

### Key Accomplishments
- Architecture skeleton: EventBus, GameManager, PlatformServices, SaveData autoloads
- PlatformServices abstraction layer for plugin resilience
- BannerAdRegion component with collapsible behavior and test screen
- AdMob v5.3 plugin installed and wired into PlatformServices
- godot-iap v1.2.3 plugin installed and wired into PlatformServices
- FeatureFlags system for runtime feature control
- Export pipeline documented (iOS/Android export presets guide created)

### Requirements Complete
- FNDN-05: Autoload architecture implemented
- FNDN-06: PlatformServices abstraction layer
- FNDN-07: Banner ad region component
- FNDN-08: FeatureFlags system

### Requirements Code-Ready (Device Validation Pending)
- FNDN-03: AdMob plugin integrated (awaiting physical device test)
- FNDN-04: IAP plugin integrated (awaiting physical device test)
- FNDN-01: iOS export configured (device testing deferred)
- FNDN-02: Android export configured (device testing deferred)

### Next Milestone
Phase 2: Implement core puzzle loop (WordPair data model, LetterSlot/WordRow UI components, GameplayScreen with keyboard and timer, end-to-end routing).

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
3. Current state: minimal scaffold with main.tscn scene
4. Export targets not yet configured (Phase 1 pending)

**Note:** No gameplay implemented yet. Project is in planning phase with documentation and structure established.

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

**Current Phase:** Phase 1 Complete (Phase 2 planning ready to begin)

## Contributing

This is a solo creator project currently in foundation phase. Contributions are not being accepted at this time.

## License

Proprietary - All rights reserved.

---

**Last Updated:** 2026-01-31
**Project Started:** 2026-01-22
**Engine:** Godot 4.5
