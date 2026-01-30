# CLAUDE.md

## Project
WordRun! — Visual Game Development (Godot 4.5 mobile word puzzle game)

## Project State

### Current Workflow Phase
- [x] **Idea & Validation**: Core concept defined and documented
- [x] **Research**: Stack, architecture, features, and pitfalls researched
- [x] **Planning**: 9-phase roadmap, 117 requirements, state tracking established
- [ ] **Phase 1: Foundation and Validation Spikes**: Export pipeline and plugin validation
- [ ] **Phase 2: Core Puzzle Loop**: Word-pair solving mechanic
- [ ] **Phase 3: Game Feel**: Surge momentum system
- [ ] **Phase 4: Obstacles & Content**: Obstacle system and word validation pipeline
- [ ] **Phase 5: Progression & Economy**: Hearts, currency, boss levels, inventory
- [ ] **Phase 6: World Map & Tutorial**: 25 lands, Ruut navigation, progressive teaching
- [ ] **Phase 7: Backend & Monetization**: Firebase, IAP, ads, cloud sync
- [ ] **Phase 8: Soft Launch**: Test market, analytics, tuning
- [ ] **Phase 9: Post-Launch**: Vs mode, skins, content expansion

**Current Phase:** Pre-Phase 1 (planning complete, ready to begin Phase 1)

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
- **Version:** v0.0.02 (foundation/planning phase)
- **Versioning:** v0.0.XX during foundation, v0.X.XX during pre-release, v1.0.0 at launch
- **Director Preferences:** Professional code quality (no shortcuts), AI-assisted assets (art, animation), documentation-first during foundation
- **Architecture:** Layered (scenes/scripts/data/assets), autoloads (EventBus, GameManager, PlatformServices, SaveData)

## Source of Truth
- This repository is the only source of truth
- Ignore all archived projects, repos, and prior implementations
- If something is not present in this repository, it does not exist

## Working Instructions

### Current Focus
**Phase 1 Planning**: Break Foundation and Validation Spikes into executable plans

**Phase 1 Goals:**
1. Validate Godot export to physical iOS device
2. Validate Godot export to physical Android device
3. Spike AdMob plugin: test ad on both platforms
4. Spike IAP plugin: sandbox purchase on both platforms
5. Implement architecture shell: EventBus, GameManager, PlatformServices, SaveData autoloads
6. Build banner ad region test screen with collapsible behavior

**Blockers to Resolve:**
- Godot 4.5 plugin compatibility (AdMob, Firebase, IAP) - single biggest unknown

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
