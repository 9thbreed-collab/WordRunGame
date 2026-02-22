# WordRun!

A mobile word puzzle game where momentum creates the rush.

## Overview

WordRun! is a timed word puzzle game built in Godot 4.5 for iOS and Android. Players solve chains of word-pair puzzles in a scrolling window while managing a surge momentum system that creates strategic risk/reward tension. The game combines word puzzle mechanics with RPG-style progression, obstacles, power boosts, and a narrative world map across 9 Nations and 3 Acts.

**Core Mechanic:** Solve compound phrases and common two-word expressions (e.g., "fire truck", "truck bed") by filling letters one at a time. Build surge momentum for score multipliers, but risk busting if you push too far. Navigate obstacles like padlocks, virus blocks, and sand that add variety and strategic depth.

## Current Status

**Version:** v0.0.08
**Phase:** Phase 4 Extended - Content Pipeline and Level Generation
**Progress:** 48 of 117 v1 requirements complete

The core gameplay loop is **fully functional** with obstacles, bonus mode, and hints. This session's major milestone is the **ContentRuleDoc content pipeline** - a deterministic, rule-based system for scoring phrases, building a phrase graph, and generating valid 16-word level chains at scale.

### Playable Flow

1. **Menu Screen** - Launch app, select level from dropdown, tap Play
2. **Gameplay Screen** - Solve 16-word chain puzzle with surge momentum and obstacles
3. **Results Screen** - View score, time, stars, replay or return to menu

### Key Accomplishments This Session

**ContentRuleDoc System (New):**
- Complete deterministic content rules document (`ContentRuleDoc/ContentRuleDoc.md` v2.1)
- Five independent axes: Difficulty, Tier, Tone, Nation abstraction, Industry word pools
- Phrase Frequency Score (PFS) system replacing deprecated word-level Zipf heuristics
- PFS derived from spoken American English corpora (COCA Spoken, SUBTLEX-US, Google Ngrams)
- 33-category semantic master list (locked, no dynamic invention)
- Tone cap functions per Act (Act 1: 0-33.33, Act 2: 33-80, Act 3: 80-100)
- Nation-scoped theme keyword lexicons (Adultery for Corinthia, Drunkenness for Carnea, etc.)
- Directed phrase graph construction (word2 → word1 edges)
- 10 global difficulty tiers across 3,024 total levels

**Phrase Database (New):**
- 6 thematic batch CSVs: household, food/drink, transport/outdoor, school/social, commerce/work, abstraction (~500 phrases each)
- `phrases_master_pfs.csv`: 3,184 phrases with full PFS, CES, difficulty, entropy, tone scoring
- `phrases_early_game.csv`: Early-game filtered subset
- `ngram_cache.json`: Spoken corpus bigram cache for fast PFS lookups

**Python Pipeline Scripts (New):**
- `pathfinder.py`: Backtracking DFS (depth=16) for chain building
- `early_filter.py`: PFS + entropy + compound-word filtering
- `generate_early_levels.py`: Level generation orchestrator
- `calculate_pfs.py`, `calculate_ces.py`: Score calculators
- `merge_phrases.py`: Batch CSV merger and deduplicator
- `spoken_pfs.py`: Spoken corpus processor

**Level Data:**
- `data/baseline/corinthia.json`: 3 validated 16-phrase chains for Corinthia
  - Level 1: avg PFS 3.53 (house → ... → letter)
  - Level 2: avg PFS 3.47 (credit → ... → lime)
  - Level 3: avg PFS 3.20 (dry → ... → rack)
- No compound words, no repeated bigrams across levels, all chains pass Compound Word Gate

### Key Accomplishments (Phase 4 - Plan 04-01 + Expansions)
- Obstacle system: ObstacleBase, ObstacleManager, ObstacleConfig template architecture
- Padlock: skip locked word, auto-unlock after solving next word, backtrack mechanic
- Virus: gradual spread (1 block/2sec), round-robin distribution, zero-point auto-solve
- Sand: gradual fill on 1-5 words, fully filled word is unsolvable (level failure)
- Lock Key, Block Breaker, Bucket of Water counter-boosts all functional
- Bonus mode: purple surge bar, 50-second timer, bonus words 13-15 at word 12
- Hint system: 3 hints per level, reveals one random unrevealed letter
- ContentCache autoload: JSON level loading with .tres fallback
- LetterSlot: 11 visual states including BONUS and CARET glow states
- Level selector dropdown in menu (test any level without code edits)

### Key Accomplishments (Phase 3 - Complete)
- SurgeSystem state machine (IDLE, FILLING, IMMINENT, BUSTED)
- SurgeBar with threshold markers and smooth tweening
- Real-time score with surge multiplier (1.0x to 3.0x)
- AudioManager with 10-player SFX pool and dual BGM crossfade
- Haptic feedback for all key events
- Star bar (1-3 stars based on completion time)

### Key Accomplishments (Phase 2 - Complete)
- WordPair and LevelData custom resources
- LetterSlot, WordRow, OnScreenKeyboard UI components
- Full puzzle loop: scrolling window, timer, auto-submit, auto-scroll
- MenuScreen, GameplayScreen, ResultsScreen with GameManager routing

### Key Accomplishments (Phase 1 - Complete)
- EventBus, GameManager, PlatformServices, SaveData autoloads
- AdMob v5.3 and godot-iap v1.2.3 integrated
- FeatureFlags system and export pipeline documented

## Technology Stack

**Engine:** Godot 4.5 (GL Compatibility renderer for mobile)
**Platforms:** iOS, Android
**Backend:** TBD (Firebase under evaluation)
**Languages:** GDScript (game), Python (content pipeline)
**Architecture:** Component-Driven Development (CDD)

### Planned Integrations
- AdMob (interstitial + rewarded ads)
- In-App Purchases (platform IAP)
- Cloud content delivery for word-pair data
- Firebase Auth and cloud save

## How to Run

**Requirements:**
- Godot 4.5 or later (for game)
- Python 3.10+ (for content pipeline scripts)

**Game:**
1. Clone repository
2. Open project in Godot 4.5
3. Press F5 to launch
4. Current state: Fully playable puzzle loop with obstacles and level selector

**Content Pipeline:**
```bash
cd ContentRuleDoc/scripts
python generate_early_levels.py   # Generate levels from phrase bank
python pathfinder.py              # Build phrase chains
python early_filter.py            # Filter phrases for early game
```

## Key Features

### Core Gameplay
- Word-pair chain puzzle in scrolling window (4-5 visible words)
- Surge momentum with threshold multipliers and bust mechanic
- 16 base words per level (configurable)
- Three v1 obstacles: Padlock, Virus, Sand
- Three counter-boosts: Lock Key, Block Breaker, Bucket of Water
- On-screen QWERTY keyboard with native keyboard support

### Content System
- 3,184 scored phrases in master database
- PFS (Phrase Frequency Score) for spoken familiarity filtering
- Entropy-based difficulty (how many valid continuations exist at each word)
- 10 global difficulty tiers across 3,024 total levels
- 9 Nations with distinct semantic themes and industry word pools
- 3 Acts with escalating tone caps

### Progression (Planned)
- 9 Nations, 3 Acts, 3,024 total levels
- Hearts/lives system with rewarded ad recovery
- Dual currency: Stars (earned) and Diamonds (premium)
- Boss levels with randomized challenges
- Inventory loadout for power boosts

## Project Structure

```
WordRunGame/
├── .planning/               # Roadmap, requirements, state tracking
│   ├── PROJECT.md
│   ├── ROADMAP.md
│   ├── REQUIREMENTS.md
│   ├── STATE.md
│   ├── archive/word-system-v1/  # Archived LAS-based system
│   └── phases/
├── ContentRuleDoc/          # Content pipeline system
│   ├── ContentRuleDoc.md    # Master rules document (v2.1)
│   ├── KEYWORD_LEXICONS_DRAFT.md
│   ├── NATION_FILTERS.md
│   ├── TONE_SCORE_RULES.md
│   ├── data/
│   │   ├── phrases/         # Phrase CSVs and Godot translation artifacts
│   │   ├── graphs/          # Directed phrase graph JSON
│   │   ├── levels/          # Generated test levels
│   │   └── *.md             # Audit and validation reports
│   └── scripts/             # Python pipeline scripts
├── scenes/                  # Godot scene files
├── scripts/                 # GDScript files
│   ├── autoloads/           # EventBus, GameManager, ContentCache, etc.
│   ├── gameplay/            # Obstacle and boost system
│   ├── resources/           # Custom resource definitions
│   ├── screens/             # Screen controllers
│   └── ui/                  # UI components
├── data/
│   └── baseline/
│       └── corinthia.json   # Corinthia land 1 levels (3 x 16-phrase chains)
├── Docs/                    # Documentation and session summaries
│   ├── sessions/            # Per-session summaries
│   ├── CLAUDE.md            # AI agent context
│   ├── AGENTS.md            # Multi-agent context
│   └── GEMINI.md            # Gemini agent context
└── project.godot            # Godot project configuration
```

## Roadmap

**9 Phases (v1 through soft launch):**
1. Foundation and Validation Spikes (validate pipeline, plugins, architecture shell) - Complete
2. Core Puzzle Loop (word-pair solving, scrolling window, touch input) - Complete
3. Game Feel - Surge, Score, and Audio (momentum system, multipliers, feedback) - Complete
4. Obstacles, Boosts, and Content Pipeline (3 obstacles, counter-boosts, word validation) - In Progress
5. Progression, Economy, and Retention (hearts/lives, currency, boss levels, inventory)
6. World Map, Navigation, and Tutorial (9 Nations, Ruut avatar, progressive teaching)
7. Backend, Auth, Monetization, and Store (Firebase, IAP, ads, cloud sync)
8. Polish, Soft Launch, and Tuning (test market, analytics, economy tuning)
9. Post-Launch Features (Vs mode, skins, Nations 4-9, expanded content)

**Current Phase:** Phase 4 Extended - Content pipeline infrastructure complete, level generation proven

**Next Milestone:** Populate Corinthia levels 4-23 OR begin Phase 5 (hearts/lives system)

## Contributing

This is a solo creator project in foundation phase. Contributions are not being accepted at this time.

## License

Proprietary - All rights reserved.

---

**Last Updated:** 2026-02-22
**Project Started:** 2026-01-22
**Engine:** Godot 4.5
