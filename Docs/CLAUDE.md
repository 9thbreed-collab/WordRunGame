# CLAUDE.md

## Project
WordRun! — Visual Game Development (Godot 4.5 mobile word puzzle game)

## Project State

### Current Workflow Phase
- [x] **Idea & Validation**: Core concept defined and documented
- [x] **Research**: Stack, architecture, features, and pitfalls researched
- [x] **Planning**: 9-phase roadmap, 117 requirements, state tracking established
- [x] **Phase 1: Foundation and Validation Spikes**: Code complete (4/4 plans, device testing deferred)
- [x] **Phase 2: Core Puzzle Loop**: Complete (4/4 plans, fully playable end-to-end flow)
- [x] **Phase 3: Game Feel**: Complete (3/3 plans, surge momentum system, scoring, audio/haptics)
- [ ] **Phase 4: Obstacles & Content**: Obstacle system and word validation pipeline
- [ ] **Phase 5: Progression & Economy**: Hearts, currency, boss levels, inventory
- [ ] **Phase 6: World Map & Tutorial**: 25 lands, Ruut navigation, progressive teaching
- [ ] **Phase 7: Backend & Monetization**: Firebase, IAP, ads, cloud sync
- [ ] **Phase 8: Soft Launch**: Test market, analytics, tuning
- [ ] **Phase 9: Post-Launch**: Vs mode, skins, content expansion

**Current Phase:** Phase 3 Complete (Game Feel - surge momentum, scoring with multipliers, audio/haptic feedback, animation polish)

### Key Decisions & Context

#### Idea & Validation
- **Core Concept:** Word puzzle game where surge momentum creates "rush" - strategic risk/reward tension
- **Target Audience:** Mobile casual gamers who enjoy word puzzles with progression depth
- **Validation Status:** Concept documented, ready to validate through Phase 1 technical spikes

#### Research Insights
- **Tech Stack:** Godot 4.5 for iOS/Android mobile development
- **Backend Strategy:** Firebase recommended (Phase 1 must validate Godot 4.5 plugin compatibility)
- **Critical Risk:** AdMob + IAP plugin compatibility on Godot 4.5 is blocking unknown
- **Content Strategy:** AI-generated word-pair validation pipeline, cloud storage for 3,000+ level capacity

#### Creative Strategy
- **Core Value:** "The word-pair puzzle with the surge momentum system must feel like a rush"
- **Approach:** Component-Driven Development (CDD) for UI/UX resilience and emotional design integration
- **Hook:** Blackjack-style surge mechanic - solve fast for multipliers but risk busting
- **Naming:** WordRun! (exclamation mark part of brand)

#### Production Notes
- **Version:** v0.0.04 (Phase 3 complete - surge momentum system working)
- **Versioning:** v0.0.XX during foundation, v0.X.XX during pre-release, v1.0.0 at launch
- **Director Preferences:** Professional code quality (no shortcuts), AI-assisted assets (art, animation), documentation-first during foundation
- **Architecture:** Layered (scenes/scripts/data/assets), autoloads (EventBus, GameManager, PlatformServices, SaveData, AudioManager)

## Source of Truth
- This repository is the only source of truth
- Ignore all archived projects, repos, and prior implementations
- If something is not present in this repository, it does not exist

## Working Instructions

### Current Focus
**Phase 4 Planning**: Obstacles, Boosts, and Content Pipeline

**Phase 4 Goals:**
1. Define obstacle system architecture (template pattern, not hard-coded types)
2. Implement 3 v1 obstacles: Padlock (blocks word), Random Blocks (random slots), Sand (timing effect)
3. Create counter-boost system (inventory items consumed to neutralize obstacles)
4. Build word-pair content pipeline (AI generation → validation → cloud storage)
5. Integrate themed word pools (Nation 1: Nature/Outdoor theme)

**Phase 3 Completion Status:**
- Complete (3/3 plans executed, 12 commits + 3 tuning commits)
- Surge momentum system with state machine (IDLE, FILLING, IMMINENT, BUSTED)
- Real-time scoring with multiplier system (1.0x → 3.0x based on surge thresholds)
- AudioManager with SFX pool, BGM crossfade, haptic feedback
- Animation polish: letter pop, word celebration, threshold pulse, bust flash
- Bonus gate working (bonus words unlock if surge ≥ threshold at word 12)
- ResultsScreen wired with actual score, time, and star rating

### Working Rules
- Do not assume tools, libraries, or architecture unless explicitly defined in this file or .planning/ docs
- Prefer minimal changes and explicit confirmation before major decisions
- Avoid speculative code or premature optimization
- Documentation-first during foundation phase
- All changes must trace to requirements in .planning/REQUIREMENTS.md
- Component-driven approach for all UI/UX work (see COMPONENT_DRIVEN_ARCHITECTURE_GUIDE.md)

### Key Files & References
- `.planning/PROJECT.md` - Project overview, core value, constraints, key decisions
- `.planning/ROADMAP.md` - 9-phase execution plan with dependencies and success criteria
- `.planning/REQUIREMENTS.md` - 117 v1 requirements across 16 categories
- `.planning/STATE.md` - Current position, velocity metrics, phase status
- `.planning/phases/01-foundation-and-validation-spikes/01-CONTEXT.md` - Phase 1 implementation decisions
- `VisionPageWordRun!.md` - Original vision document from creator
- `COMPONENT_DRIVEN_ARCHITECTURE_GUIDE.md` - UI/UX architecture principles

### Monetization Integration Approach
- **Primary Strategy:** PlatformServices abstraction layer insulates game code from direct plugin dependencies
- **Fallback:** Feature flags to disable broken surfaces (e.g., banners on iOS) and ship only stable functionality
- **Philosophy:** Abstraction layer is long-term strategy, not temporary workaround
- **Banner Design:** Bottom-anchored, safe-area-aware, collapsible with layout reflow, game artwork fallback when no ad served

### Content Pipeline Principles
- Word pairs must form compound phrases or common two-word expressions
- Multi-layer validation: automated dictionary, compound profanity filter, human review, versioned rollback
- Content stored in cloud/database, cached locally for offline play
- Themed word pools per land for narrative alignment

## Session History

### Session 2026-02-01 to 2026-02-02 (v0.0.04)
- **Phase:** Phase 3 Complete (Game Feel - Surge, Score, and Audio)
- **Accomplishments:**
  - Completed all 3 Phase 3 plans (03-01 through 03-03) with 12 commits
  - Created SurgeConfig resource with configurable thresholds and multipliers
  - Implemented SurgeSystem node with state machine (IDLE, FILLING, IMMINENT, BUSTED)
  - Built SurgeBar UI with threshold markers and smooth tweened animations
  - Added real-time score calculation and HUD display with surge multipliers
  - Created AudioManager autoload with 10-player SFX pool and dual BGM crossfade
  - Integrated haptic feedback for letter tap, word complete, surge events, level complete
  - Added animation polish: letter pop-in, word celebration, threshold pulse, bust flash
  - Wired bonus gate logic (bonus words unlock if surge ≥ threshold at word 12)
  - Built star bar tracking level performance (1-3 stars based on completion time)
  - Updated ResultsScreen with actual score, time, and star rating passthrough
  - Post-phase tuning: 1.7x slower drain, 7-min star bar, 70% bigger stars, split bar layout
- **Key Decisions:**
  - SurgeSystem is child node of GameplayScreen (level-specific config, not autoload)
  - Bust triggers when player reaches IMMINENT (≥90) then falls below final threshold
  - Score uses integer math: base_points * current_multiplier
  - AudioManager co-locates haptics with SFX (feedback is one concept)
  - Placeholder audio infrastructure proven, real assets deferred to Phase 8
  - Tweens for all animations (no AnimationPlayer needed yet)
  - Bust sequence brief (~0.5s) to avoid frustrating interruption
  - Drain rate tuned to 1.2/sec for better player control
- **Requirements Completed:** FEEL-01 through FEEL-12 (all game feel requirements)
- **Next Steps:**
  - Plan Phase 4 (Obstacles, Boosts, and Content Pipeline)
  - Define obstacle system template architecture
  - Implement 3 v1 obstacles with counter-boost system
  - Build word-pair content validation pipeline

### Session 2026-01-31 Late (v0.0.03)
- **Phase:** Phase 2 Complete (Core Puzzle Loop)
- **Accomplishments:**
  - Completed all 4 Phase 2 plans (02-01 through 02-04) with 13 commits
  - Created WordPair and LevelData custom resources with typed arrays
  - Built LetterSlot UI component with 4 visual states (empty, filled, correct, incorrect)
  - Created WordRow with dynamic letter slot generation and shake animation feedback
  - Implemented OnScreenKeyboard component with QWERTY layout and auto-connected buttons
  - Built GameplayScreen with full puzzle loop, scrolling, timer, and level completion
  - Created MenuScreen and ResultsScreen for complete navigation flow
  - Wired GameManager for event-driven routing based on gameplay signals
  - Polish pass: word chain level data, auto-submit on last letter, native keyboard support, scroll behavior refinement
  - Updated main_scene to launch into menu instead of test screen
- **Key Decisions:**
  - WordPair uses word_a (clue) and word_b (answer) terminology
  - Full-word auto-submit on last letter (not per-letter validation)
  - Wrong answer flashes red, shakes, then clears user-typed letters for retry
  - Backspace works but cannot delete revealed letters
  - Auto-scroll triggers only after 4th word solved, one row at a time with cubic easing
  - Timer counts up from 00:00 (changed from countdown)
  - GameManager routes both level_completed and level_failed to single ResultsScreen
  - Bonus gate stub at word index 11, ready for Phase 3 surge integration
- **Requirements Completed:** PUZL-01 through PUZL-10 (all core puzzle loop requirements)
- **Next Steps:**
  - Plan Phase 3 (Game Feel - Surge, Score, and Audio)
  - Implement surge momentum system and wire bonus gate
  - Add scoring calculation with multipliers
  - Integrate audio feedback layer

### Session 2026-01-31 Early (v0.0.02)
- **Phase:** Phase 1 Complete / Phase 2 Transition
- **Accomplishments:**
  - Verified Phase 1 completion status (4/4 plans complete, device testing deferred)
  - Updated planning configuration to use "budget" model profile
  - Added Phase 2 plan outline to ROADMAP.md (4 plans for Core Puzzle Loop)
  - Created 01-03-SUMMARY.md to document export pipeline plan deferral
  - Updated project documentation to reflect Phase 1 completion
- **Key Decisions:**
  - Planning model switched to "budget" for cost optimization
  - Phase 2 structured as 4 sequential plans (data model → UI components → gameplay screen → routing)
  - Device testing deferred to pre-Phase 7 checkpoint (non-blocking for Phase 2-6 development)
- **Next Steps:**
  - Plan Phase 2 (Core Puzzle Loop) - research and planning phase
  - Begin Phase 2-01: WordPair/LevelData data model and EventBus gameplay signals

### Session 2026-01-30 (v0.0.02)
- **Phase:** Phase 1 Execution (Foundation and Validation Spikes)
- **Accomplishments:**
  - Completed all 4 Phase 1 plans (01-01 through 01-04)
  - Implemented architecture skeleton: EventBus, GameManager, PlatformServices, SaveData autoloads
  - Created FeatureFlags resource system for runtime feature control
  - Built BannerAdRegion component with collapsible behavior and test screen
  - Installed and wired AdMob v5.3 plugin into PlatformServices
  - Installed and wired godot-iap v1.2.3 plugin into PlatformServices
  - Configured export presets for iOS and Android
  - Created EXPORT_SETUP_GUIDE.md with step-by-step instructions
- **Key Decisions:**
  - Deferred physical device validation (Plans 01-03 Task 2, 01-04 Task 3) due to hardware blocker
  - Hardware constraint documented: MacBook Air Mid-2013 cannot run Xcode 14+ for iOS 16+ devices
  - Mitigation identified: Cloud Mac service (~$1/hr) for future device testing
  - Risk assessed as low for Phases 2-6 (all run in Godot editor)
- **Next Steps:**
  - Phase 1 code complete
  - Ready for Phase 2 planning

### Session 2026-01-29 (v0.0.02)
- **Phase:** Foundation & Planning
- **Accomplishments:**
  - Created comprehensive 9-phase roadmap with 117 requirements
  - Completed research synthesis (stack, features, architecture, pitfalls)
  - Initialized Godot 4.5 project with directory structure
  - Captured Phase 1 context with monetization integration strategy
  - Documented Component-Driven Architecture as core UI/UX principle
  - Defined PlatformServices abstraction pattern for plugin resilience
- **Key Decisions:**
  - v1 ships 25 lands / 3 Nations (250+ levels)
  - Required auth (no guest mode) for progress sync and multiplayer
  - Name generator instead of user-typed names
  - Cloud-stored content for lightweight app and OTA updates
  - Template architecture for obstacles (config + visuals, not new code paths)
- **Next Steps:**
  - Plan Phase 1 validation spikes (export, AdMob, IAP, architecture shell)
  - Research Godot 4.5 plugin options for AdMob and IAP
  - Define PlatformServices interface API

### Session 2026-01-22 (v0.0.01)
- **Phase:** Foundation initialization
- **Accomplishments:**
  - Created documentation structure (README, VGD_WORKFLOW, PROMPTS)
  - Established session versioning system
  - Documented source of truth rules
- **Next Steps:**
  - Consolidate project research
  - Define roadmap and requirements

---

## When to Use Gemini CLI

Use `gemini -p` when:
- Analyzing entire codebases or large directories
- Comparing multiple large files
- Need to understand project-wide patterns or architecture
- Current context window is insufficient for the task
- Working with files totaling more than 100KB
- Verifying if specific features, patterns, or security measures are implemented
- Checking for the presence of certain coding patterns across the entire codebase

**Important Notes:**
- Paths in @ syntax are relative to your current working directory when invoking gemini
- The CLI will include file contents directly in the context
- No need for -yolo flag for read-only analysis
- Gemini's context window can handle entire codebases that would overflow Claude's context
- When checking implementations, be specific about what you're looking for to get accurate results
