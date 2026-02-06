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
- [x] **Phase 4: Obstacles & Content**: Plan 04-01 Complete (all 3 v1 obstacles + boosts working)
- [ ] **Phase 5: Progression & Economy**: Hearts, currency, boss levels, inventory
- [ ] **Phase 6: World Map & Tutorial**: 25 lands, Ruut navigation, progressive teaching
- [ ] **Phase 7: Backend & Monetization**: Firebase, IAP, ads, cloud sync
- [ ] **Phase 8: Soft Launch**: Test market, analytics, tuning
- [ ] **Phase 9: Post-Launch**: Vs mode, skins, content expansion

**Current Phase:** Phase 4 In Progress (Obstacles, Boosts, and Content Pipeline - Plan 04-01 Complete, Plan 04-02 or 04-03 next)

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
- **Version:** v0.0.06 (Phase 4 Plan 04-01 complete - all 3 v1 obstacles + boosts working)
- **Versioning:** v0.0.XX during foundation, v0.X.XX during pre-release, v1.0.0 at launch
- **Director Preferences:** Professional code quality (no shortcuts), AI-assisted assets (art, animation), documentation-first during foundation
- **Architecture:** Layered (scenes/scripts/data/assets), autoloads (EventBus, GameManager, PlatformServices, SaveData, AudioManager)

## Source of Truth
- This repository is the only source of truth
- Ignore all archived projects, repos, and prior implementations
- If something is not present in this repository, it does not exist

## Working Instructions

### Current Focus
**Phase 4 Execution**: Obstacles, Boosts, and Content Pipeline (Plan 04-01 COMPLETE)

**Current Plan Status (04-01 COMPLETE):**
- Obstacle system architecture complete (ObstacleBase, ObstacleManager, ObstacleConfig)
- Multi-obstacle support enabled (multiple obstacles can coexist on same word)
- Padlock obstacle complete with skip/backtrack mechanic (tested, working)
- Virus (Random Blocks) obstacle complete with gradual spread mechanics (tested, working)
- Sand obstacle complete with gradual fill mechanics (tested, working)
- All three counter-boosts functional and tested: Lock Key, Block Breaker, Bucket of Water
- 8 LetterSlot visual states: EMPTY, FILLED, CORRECT, INCORRECT, LOCKED, VIRUS, SAND, CARET
- Caret glow implemented (pulsing sky blue indicator on current input slot)

**Immediate Next Steps:**
1. Choose next plan: 04-02 (Obstacle animations/polish) or 04-03 (Content pipeline)
2. Recommendation: Start with 04-03 (Content pipeline) to unblock level design and playtesting
3. Build word-pair validation system (dictionary check, compound phrase validation)
4. Implement themed word pools for Nation 1 lands
5. Set up cloud storage for word pairs (Firebase or alternative)
6. Create local caching for offline play

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

### Session 2026-02-06 (v0.0.06)
- **Phase:** Phase 4 In Progress (Obstacles, Boosts, and Content Pipeline - Plan 04-01 COMPLETE)
- **Accomplishments:**
  - Implemented Virus (Random Blocks) obstacle with gradual spread mechanics
  - Virus spreads 1 block every 2 seconds with even distribution across words
  - 100% virus word auto-solves with zero points (penalty for spread)
  - Implemented Sand obstacle with gradual fill on 1-5 words simultaneously
  - Sand fills 1 random slot every 2 seconds per affected word
  - 100% sand word becomes unsolvable (level failure if current word)
  - Extended ObstacleManager to support multiple obstacles per word (compound key: type+index)
  - Added 3 new LetterSlot states: VIRUS (dark red with X), SAND (tan), CARET (sky blue glow)
  - Implemented caret glow with pulsing animation (1.5s cycle) for current input position
  - All three counter-boosts tested and working: Lock Key, Block Breaker, Bucket of Water
  - Lock Key clears any padlock in level (works even when word is skipped)
  - Block Breaker clears all virus blocks from all words instantly
  - Bucket of Water clears sand from 3 words around current word
  - Fixed multi-obstacle interaction bugs (virus/sand with padlock state)
  - Fixed caret advancement after auto-solve (virus or sand completing word)
  - Added EventBus.boost_used signal for future analytics and UI feedback
  - Re-enabled all three obstacles in test level (padlock @ word 5, virus @ word 2, sand @ words 3-7)
- **Key Decisions:**
  - Multi-obstacle architecture: ObstacleManager uses compound key (type+index) to allow multiple obstacles per word
  - Virus spread respects padlock state (won't add blocks to locked words)
  - Sand fill respects padlock state (won't fill locked words)
  - Visual state priority: LOCKED > CARET > VIRUS/SAND > FILLED > EMPTY
  - Caret glow always visible on current input slot regardless of other states
  - Virus auto-solve gives zero points (penalty, not reward)
  - Sand unsolvable triggers immediate level failure if current word
  - Boost animations and obstacle drop effects deferred to Plan 04-02
- **Requirements Completed:** OBST-03, OBST-04, OBST-08, OBST-09, OBST-10, OBST-11 (6 new requirements, 11 total for Phase 4 Plan 04-01)
- **Next Steps:**
  - Choose Plan 04-02 (obstacle animations/polish) or Plan 04-03 (content pipeline)
  - Recommendation: Start with 04-03 to unblock level design with real word variety
  - Build word-pair validation system and themed word pools
  - Set up cloud storage and local caching for word content

### Session 2026-02-05 (v0.0.05)
- **Phase:** Phase 4 In Progress (Obstacles, Boosts, and Content Pipeline - Plan 04-01 partial)
- **Accomplishments:**
  - Implemented padlock skip/backtrack mechanic in GameplayScreen
  - Extended LetterSlot with LOCKED state (dark gray styling, input blocking)
  - Extended WordRow with lock support (set_locked(), is_locked(), modulate tinting)
  - Padlock auto-skip: when reaching locked word, caret advances to word+1
  - Backtrack after word+1 completion: obstacle clears, caret returns to locked word
  - Resume at word+2 after backtracked word solved (prevents loop)
  - Disabled Random Blocks and Sand in test level for incremental testing
  - Validated obstacle system architecture (ObstacleBase, ObstacleManager, factory pattern)
- **Key Decisions:**
  - Padlock auto-skip is automatic (no player choice, deterministic mechanic)
  - Backtrack is automatic after solving word+1 (no modal dialogs)
  - Single `_skipped_padlock_word` variable (only one padlock pending at a time)
  - Resume point after backtrack is word+2 (word+1 already solved)
  - Incremental testing: one obstacle type enabled at a time
  - Visual polish deferred to Phase 8 (no padlock icon overlay, no lock/unlock animation)
- **Requirements Completed:** OBST-01, OBST-02, OBST-05, OBST-06, OBST-07 (5 new requirements)
- **Next Steps:**
  - Re-enable and test Random Blocks obstacle
  - Re-enable and test Sand obstacle
  - Test boost functionality (Lock Key, Block Breaker, Bucket of Water)
  - Fix integration issues, complete Plan 04-01
  - Proceed to Plan 04-02 or 04-03

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
