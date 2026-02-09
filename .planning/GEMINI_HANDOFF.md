# Gemini Handoff: WordRun! Phase 4 Continuation

## Quick Start for Gemini

Read these files in order to understand the project:
1. `.planning/PROJECT.md` - Project overview and key decisions
2. `.planning/ROADMAP.md` - Full roadmap with phases and requirements
3. `.planning/STATE.md` - Current execution state
4. `.planning/phases/04-obstacles-boosts-content/04-02-PLAN.md` - Remaining obstacles + boosts
5. `.planning/phases/04-obstacles-boosts-content/04-03-PLAN.md` - Content pipeline

## Current Phase: 4 - Obstacles, Boosts, and Content Pipeline

### What's DONE:
- ObstacleConfig, ObstacleBase, ObstacleManager (scripts/gameplay/)
- All 3 obstacles: Padlock, RandomBlocks (Virus), Sand
- BoostConfig, BoostManager, BoostPanel
- All 3 boosts: Lock Key, Block Breaker, Bucket of Water
- ContentCache autoload with JSON loading
- EventBus signals for obstacles/boosts/content
- Multiple bug fixes (virus round-robin, sand count, blink animation, scroll timing)

### What REMAINS:
1. **Verify 04-02 and 04-03 completion** - Check codebase against plan requirements
2. **Cloud database design** - Move word content to cloud (Firebase Firestore recommended)
3. **Content expansion** - Populate Grasslands with 10 levels of validated word pairs
4. **Mark Phase 4 complete** in ROADMAP.md

## Key Files Reference

| Category | Path | Purpose |
|----------|------|---------|
| Obstacles | `scripts/gameplay/obstacles/` | Padlock, RandomBlocks, Sand |
| Boosts | `scripts/gameplay/boost_manager.gd` | Boost orchestration |
| Content | `scripts/autoloads/content_cache.gd` | JSON level loading |
| Level Data | `data/baseline/` | JSON content files |
| Test Level | `data/levels/test_level_01.tres` | Legacy .tres format |
| Gameplay | `scripts/screens/gameplay_screen.gd` | Main game orchestration |

## Requirements Checklist (Phase 4)

### Obstacles (OBST-01 through OBST-07)
- [x] OBST-01: Resource-based template architecture
- [x] OBST-02: Padlock locks word, unlocks on next word solve or Key boost
- [x] OBST-03: Random Blocks fills spaces, auto-solves at 0 points if all blocked
- [x] OBST-04: Sand fills 1 random space in 1-5 words slowly
- [x] OBST-05: Distinct visual animations per obstacle
- [x] OBST-06: Obstacles at predetermined points in level data
- [x] OBST-07: New obstacle = new config + script, no code path changes

### Boosts (BOST-01 through BOST-06)
- [x] BOST-01: Lock Key counters Padlock
- [x] BOST-02: Block Breaker counters Random Blocks
- [x] BOST-03: Bucket of Water clears up to 3 words of sand
- [x] BOST-04: Boost without matching obstacle = score bonus
- [ ] BOST-05: Loadout selection before level (Phase 5 - inventory screen)
- [x] BOST-06: Boosts consumed on use

### Content (CONT-01 through CONT-07)
- [ ] CONT-01: Word content in cloud/database, not app binary
- [x] CONT-02: Content cached locally (ContentCache exists)
- [ ] CONT-03: 250 levels validated content (needs authoring)
- [ ] CONT-04: Automated dictionary checking (WordValidator exists, needs integration)
- [ ] CONT-05: Profanity filtering (ProfanityFilter exists, needs integration)
- [ ] CONT-06: Content versioned with OTA updates (Phase 7 - backend)
- [ ] CONT-07: Words themed per land

## Cloud Database Design (Firebase Firestore + Cloud Storage)

**COMPLETED:** See `.planning/CLOUD_SCHEMA.md` for full design.

Architecture:
- **Cloud Storage**: Bulk content (lands/{land_id}/content.json) - downloaded once per land
- **Firestore**: Metadata only (content_versions, profanity_filter) - 1-2 reads/session
- **Local Cache**: user://content_cache/ - ZERO network during gameplay

Key Design Decisions:
- All gameplay reads from local cache (zero latency)
- Version check on app launch triggers background download
- Word metadata stays in cloud (build-time validation only)
- Profanity filter downloaded once, cached indefinitely

## Validation Filters (Content Authoring Pipeline)

Four filters for word pair selection:

1. **Difficulty**
   - Length (short 3-4, medium 5-7, long 8+)
   - Ambiguity (unique vs multiple valid answers)
   - Typing complexity (common keys vs awkward patterns)

2. **Rarity**
   - Frequency rank from word corpus
   - Commonness tier (1=everyday, 4=rare)

3. **Lore** (Nation/Land Theming)
   - Word pool tags matching nation theme
   - Excluded tags (e.g., "dark" excluded from Grasslands)
   - Mood progression (cheerful → tense → mysterious)

4. **Profanity**
   - Direct word blocks
   - Pattern matching
   - Safe exceptions (words containing profane substrings)
   - Compound combination checks (word_a + word_b)

## Coding Standards (Godot 4.5 GDScript)

- Use `class_name` for all custom classes
- Typed variables: `var _name: Type = value`
- Private vars/funcs prefixed with `_`
- Signals use snake_case: `signal word_completed`
- Resources use PascalCase: `LevelData`, `ObstacleConfig`
- EventBus autoload for cross-scene communication
- No hardcoded magic numbers - use constants

## Testing Commands

```bash
# Run Godot headless to check for parse errors
godot --headless --quit

# Check specific script
godot --headless --script scripts/path/to/script.gd --quit
```

## Git Workflow

- Branch: `master` (main branch is `main`)
- Commit format: `type: description`
- Types: feat, fix, docs, refactor, test, tune
- Co-author: `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>` or Gemini equivalent
