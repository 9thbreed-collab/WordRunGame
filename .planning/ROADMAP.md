# Roadmap: WordRun!

## Overview

WordRun! ships as a single-player-first commercial mobile word puzzle game built in Godot 4.5 for iOS and Android. The roadmap follows a strict dependency chain: validate the mobile pipeline and plugin ecosystem first, then build the core puzzle loop, layer on the surge momentum system that makes it feel like a "rush," add obstacles and content, wire up progression and economy, construct the world map and tutorial, and finally integrate backend, auth, and monetization to make it a commercial product. Phases 1-7 deliver a shippable v1. Phase 8 covers polish and soft launch tuning. Phase 9 captures post-launch features (v2 scope).

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Foundation and Validation Spikes** (In progress) - Validate mobile export pipeline, plugin compatibility, and project architecture before writing game code
- [ ] **Phase 2: Core Puzzle Loop** - Build the atomic word-pair solving mechanic and validate it on touch devices
- [ ] **Phase 3: Game Feel -- Surge, Score, and Audio** - Add the surge momentum system, scoring, and audio/visual feedback that create the "rush"
- [ ] **Phase 4: Obstacles, Boosts, and Content Pipeline** - Build the extensible obstacle/boost system and the word-pair content validation pipeline
- [ ] **Phase 5: Progression, Economy, and Retention** - Add hearts/hints/lives, dual currency, boss levels, inventory, and login streaks
- [ ] **Phase 6: World Map, Navigation, and Tutorial** - Build the world map, Ruut avatar navigation, progressive tutorial system, and name generator
- [ ] **Phase 7: Backend, Auth, Monetization, and Store** - Integrate Firebase backend, authentication, cloud sync, IAP, ads, store, and settings
- [ ] **Phase 8: Polish, Soft Launch, and Tuning** - Final polish, soft launch in a test market, data-driven tuning of economy and difficulty
- [ ] **Phase 9: Post-Launch Features** - Vs Mode, alternative input modes, character skins, expanded content (v2 scope)

## Phase Details

### Phase 1: Foundation and Validation Spikes

**Goal:** Eliminate the two highest-risk unknowns -- mobile export pipeline and monetization plugin compatibility -- before writing any game code. Every subsequent phase depends on these working.

**Depends on:** Nothing (first phase)

**Requirements:**
- FNDN-01: Godot project exports and runs on a physical iOS device
- FNDN-02: Godot project exports and runs on a physical Android device
- FNDN-03: AdMob plugin loads and displays a test ad on both platforms
- FNDN-04: IAP plugin completes a sandbox purchase on both platforms
- FNDN-05: Project directory structure follows the layered architecture (scenes/, scripts/, data/, assets/)
- FNDN-06: EventBus autoload relays signals between decoupled scenes
- FNDN-07: GameManager autoload manages app state transitions (loading, auth, menu, playing, paused, results, store)
- FNDN-08: All screen layouts reserve a collapsible bottom banner ad region that refluxes when toggled off

**Success Criteria** (what must be TRUE):
1. A Godot project builds, exports, and runs on a physical iOS device and a physical Android device
2. A test interstitial ad from AdMob displays on both platforms
3. A sandbox IAP transaction completes on both platforms
4. The project directory follows the layered architecture and EventBus + GameManager autoloads are functional shells
5. A test screen demonstrates the collapsible banner ad region (visible when toggled on, layout reflows when toggled off)

**Pitfalls to Avoid:**
- C1 (Export pipeline blindsides): Export to both platforms in the first week, even if just a splash screen
- C4 (Plugin ecosystem gaps): Build the monetization spike before committing the architecture
- N3 (Policy compliance): Set up Apple Developer account and Google Play Console early
- N5 (Version churn): Pin to Godot 4.5, do not upgrade without cause

**Estimated Complexity:** High

**Plans:** 4 plans

Plans:
- [x] 01-01-PLAN.md -- Core architecture skeleton (directory structure, EventBus, GameManager, SaveData, FeatureFlags)
- [ ] 01-02-PLAN.md -- PlatformServices autoload, banner ad region, and test screen
- [ ] 01-03-PLAN.md -- Export pipeline validation on physical iOS and Android devices (bare project, no plugins)
- [ ] 01-04-PLAN.md -- Monetization plugin spike (AdMob + IAP installation, wiring, and device validation)

---

### Phase 2: Core Puzzle Loop

**Goal:** The word-pair solving mechanic is the atomic unit of the entire game. Players can solve chains of word pairs through a scrolling window with on-screen keyboard input, and it feels right on mobile touch devices.

**Depends on:** Phase 1

**Requirements:**
- PUZL-01: Player sees a scrolling window displaying 4-5 word rows at a time
- PUZL-02: Each word row shows blank letter slots that the player fills one letter at a time
- PUZL-03: Word pairs form compound phrases or common two-word expressions
- PUZL-04: Correctly completed words auto-submit and the window auto-advances to the next word
- PUZL-05: Incorrect letter input provides immediate visual/audio feedback
- PUZL-06: On-screen keyboard captures player input (default input mode)
- PUZL-07: Standard level contains 12 base words plus 3 bonus words
- PUZL-08: Bonus words are gated by active surge momentum at word 12
- PUZL-09: Level has a countdown timer visible to the player
- PUZL-10: Touch targets are minimum 48dp and responsive across mobile screen sizes

**Success Criteria** (what must be TRUE):
1. A player can launch a level, see a scrolling window of word rows, and fill in letters one at a time using an on-screen keyboard
2. Correctly completed words auto-submit and the window scrolls to the next word without player action
3. Incorrect letter input triggers immediate visual feedback (wrong answer state)
4. The on-screen keyboard feels responsive on physical iOS and Android devices with no perceptible input lag
5. Touch targets are large enough for comfortable use on small-screen devices (iPhone SE class)

**Pitfalls to Avoid:**
- C2 (Touch input feels wrong): Test on physical devices from Day 1 of input implementation; design touch-first with 48dp+ targets
- N4 (Visual chaos): Establish visual hierarchy -- word text is always the most readable element

**Estimated Complexity:** High

**Plans:** TBD

Plans:
- [ ] 02-01: TBD
- [ ] 02-02: TBD

---

### Phase 3: Game Feel -- Surge, Score, and Audio

**Goal:** The surge momentum system transforms the word puzzle into a "rush." Players experience rising tension from drain mechanics, threshold multipliers, and bust risk, reinforced by sound effects, haptics, and animation polish.

**Depends on:** Phase 2

**Requirements:**
- SRGE-01: Surge bar displays on screen during gameplay with visible threshold segments
- SRGE-02: Surge bar progressively drains toward zero when not being filled
- SRGE-03: Consecutive correct answers fill the surge bar
- SRGE-04: Crossing threshold segments increases the active point multiplier
- SRGE-05: Passing the final threshold enters "imminent drain" with a faster drain rate
- SRGE-06: If surge drops below the imminent threshold after entering it, an unrecoverable bust occurs (bar drains fully)
- SRGE-07: Current multiplier and score are visible to the player during gameplay
- SRGE-08: Surge values (drain rates, thresholds, bust timing) are configurable per level via data resources
- AUDP-01: Sound effects play for key actions: letter input, correct word, incorrect input, surge fill, surge bust, obstacle trigger, boost activation, level complete
- AUDP-02: Background music plays during gameplay and world map with distinct themes
- AUDP-03: Haptic feedback triggers on key touch interactions (letter tap, word complete, boost use)
- AUDP-04: Visual animations for letter placement, word completion, scroll advance, and surge bar movement

**Success Criteria** (what must be TRUE):
1. The surge bar visually fills with consecutive correct answers and visibly drains when the player pauses, creating palpable tension
2. Crossing surge thresholds triggers a noticeable multiplier increase with visual and audio feedback
3. Entering imminent drain and busting produces a dramatic, unmistakable feedback sequence (visual + audio + haptic)
4. Sound effects fire on every key action (letter tap, correct word, incorrect input, surge events) and background music plays during gameplay
5. The combined surge + score + audio experience feels like a "rush" on physical mobile devices -- solving fast is exciting, busting is dramatic

**Pitfalls to Avoid:**
- M1 (Surge feels unfair): Playtest the bust mechanic with non-developers; tune drain rates per difficulty tier
- M8 (Low-end performance): Test animations and audio on a budget Android device

**Estimated Complexity:** Very High

**Plans:** TBD

Plans:
- [ ] 03-01: TBD
- [ ] 03-02: TBD

---

### Phase 4: Obstacles, Boosts, and Content Pipeline

**Goal:** Three obstacle types and their counter-boosts add strategic depth to the puzzle loop, and a validated content pipeline ensures 250+ levels of safe, high-quality word-pair content.

**Depends on:** Phase 3

**Requirements:**
- OBST-01: Obstacle system uses a resource-based template architecture (ObstacleConfig + ObstacleBase)
- OBST-02: Padlock obstacle locks each letter of a target word; the word is unavailable unless the next word is solved or Lock Key boost is used
- OBST-03: Random Blocks obstacle fills letter spaces with wood-grain blocks without warning; if the whole word fills, it self-solves for zero points
- OBST-04: Sand obstacle fills 1 random space in 1-5 random words slowly; trickles down on scroll; can make words unsolvable if fully filled
- OBST-05: Each obstacle type has distinct visual animations
- OBST-06: Obstacles appear at predetermined points within levels according to level data
- OBST-07: Adding a new obstacle type requires only a new config resource and visual scene, not new code paths
- BOST-01: Lock Key boost counters Padlock obstacle (unlocks locked word)
- BOST-02: Block Breaker boost counters Random Blocks obstacle (clears all blocks)
- BOST-03: Bucket of Water boost counters Sand obstacle (clears sand from up to 3 words)
- BOST-04: Using a power boost when no corresponding obstacle is present grants a score bonus
- BOST-05: Player selects boosts from inventory before starting a level (loadout system)
- BOST-06: Boosts are consumed on use
- CONT-01: Word-pair content is stored in cloud/database, not bundled in the app binary
- CONT-02: Content is cached locally so gameplay never blocks on a network call
- CONT-03: Minimum 250 levels of validated word-pair content available at launch
- CONT-04: Word pairs are validated through automated dictionary checking
- CONT-05: Word pairs are filtered for profanity and sensitivity (including compound combinations)
- CONT-06: Content is versioned with the ability to update without an app release
- CONT-07: Words are themed per land to align with narrative context

**Success Criteria** (what must be TRUE):
1. A Padlock obstacle locks a word during gameplay; the player can counter it with the Lock Key boost or by solving the next word
2. Random Blocks fill letter spaces mid-level; the player can counter them with Block Breaker or by typing correct letters to break individual blocks
3. Sand slowly fills word spaces and trickles on scroll; the player can counter it with Bucket of Water (clearing up to 3 words)
4. A new obstacle type can be added by creating only a config resource and a visual scene -- no new GDScript code paths
5. The content pipeline produces 250+ validated, profanity-filtered, themed word-pair levels that load from cloud storage and cache locally

**Pitfalls to Avoid:**
- C3 (Word validation gaps): Build multi-layer validation pipeline (automated dictionary, compound profanity filter, human review, versioned rollback)
- M2 (Too many mechanics): Ship exactly 3 obstacles; do not commit to more until these 3 are balanced
- M7 (Impossible boss combos): Design the obstacle template with surge interaction in mind

**Estimated Complexity:** Very High

**Plans:** TBD

Plans:
- [ ] 04-01: TBD
- [ ] 04-02: TBD
- [ ] 04-03: TBD

---

### Phase 5: Progression, Economy, and Retention

**Goal:** Players have a structured progression through hearts, hints, lives, dual currency, boss levels, inventory loadout, and login streaks that gives the puzzle loop purpose and retention.

**Depends on:** Phase 4

**Requirements:**
- PROG-01: Hearts are an in-level resource; count carries across levels until boss level or time-based recovery
- PROG-02: Losing all hearts in a level ends the attempt
- PROG-03: Hints replenish each level; when depleted, a rewarded ad recovers one extra hint
- PROG-04: Lives are displayed on the world map; losing all hearts costs a life
- PROG-05: After ad recovery is used, a cooldown penalty box timer activates before another recovery
- PROG-06: Level completion records stars earned, score, and time
- PROG-07: Player progress persists locally between sessions
- PROG-08: Completed levels can be replayed
- ECON-01: Stars (non-premium currency) are earned through gameplay based on performance challenges (time, boost usage)
- ECON-02: Stars function as progression gates (minimum stars required to unlock certain levels/lands)
- ECON-03: Stars are spendable in the store
- ECON-04: Diamonds (premium currency) are discovered through stellar gameplay with a tutorial on first discovery
- ECON-06: Diamonds are earned in smaller quantities through gameplay and world map promo challenges
- BOSS-01: Boss level appears at the end of each Land
- BOSS-02: Boss levels contain more words than standard levels (up to 20)
- BOSS-03: Boss levels have randomized challenge conditions drawn from a constrained set
- BOSS-04: Boss levels feature more aggressive obstacle frequency
- BOSS-05: Completing a boss level grants special rewards (boosts, currency, or progression unlocks)
- BOSS-06: Boss NPC character is visible on screen during boss levels
- RETN-01: Login streaks track consecutive days the player opens the app
- RETN-02: Login streak rewards increase with streak length (boosts, currency, lower-tier premium packs)
- RETN-03: Streak rewards are displayed on login with a claim interaction
- INVT-01: Player has an inventory of owned boosts and items
- INVT-02: Player selects a loadout of boosts before starting a level
- INVT-03: Loadout can be changed between levels without returning to store

**Success Criteria** (what must be TRUE):
1. Hearts deplete during gameplay, carry across levels, and losing all hearts ends the attempt and costs a life
2. Stars are earned based on performance, gate progression to new lands, and accumulate in a visible balance
3. Diamonds appear through exceptional gameplay with a clear discovery moment and tutorial
4. Boss levels at the end of each Land feature more words, aggressive obstacles, constrained-random conditions, and a visible boss NPC
5. The player can manage an inventory of boosts, select a loadout before each level, and change loadout between levels

**Pitfalls to Avoid:**
- M3 (Economy collapse): Design all economy values to be server-configurable from day one
- M4 (Hearts punish engagement): Implement new-player protection; keep penalty box cooldowns short
- M7 (Impossible boss combos): Use a difficulty-budget system and forbidden-combination matrix for boss randomization

**Estimated Complexity:** Very High

**Plans:** TBD

Plans:
- [ ] 05-01: TBD
- [ ] 05-02: TBD
- [ ] 05-03: TBD

---

### Phase 6: World Map, Navigation, and Tutorial

**Goal:** Players navigate a world map of 3 Nations and 25 Lands, with Ruut avatar walking between level nodes, and a progressive tutorial system that teaches one mechanic at a time over the first 30-50 levels. Name generator provides safe display names.

**Depends on:** Phase 5

**Requirements:**
- WMAP-01: World map displays 3 Nations, each containing multiple Lands
- WMAP-02: 25 Lands total are navigable across the 3 Nations
- WMAP-03: Each Land contains a path of level nodes the player progresses through
- WMAP-04: Ruut avatar walks between level nodes on the world map
- WMAP-05: Tapping a level node launches the puzzle for that level
- WMAP-06: Completed levels show star ratings on the map
- WMAP-07: Progression gates visually indicate star requirements to advance
- WMAP-08: Lives remaining are displayed on the world map screen
- TUTR-01: First 5 levels teach only core puzzle mechanics (no obstacles, no surge complexity)
- TUTR-02: New mechanics are introduced one at a time with contextual overlays when first encountered
- TUTR-03: Surge system is introduced after core puzzle is established (~level 6-10)
- TUTR-04: Each obstacle type is introduced with a dedicated tutorial moment in its Nation
- TUTR-05: Economy mechanics (stars, diamonds, store) are introduced progressively as they become relevant
- TUTR-06: Tutorials do not replay once completed (one-time triggers per mechanic)
- AUTH-06: Name generator assigns a display name from categories (silly, cool, heroic, whimsical, fun)
- AUTH-07: Generated names are unique across all players (no duplicates)
- AUTH-08: No user-typed names are permitted

**Success Criteria** (what must be TRUE):
1. The world map displays 3 Nations with 25 Lands, each containing a path of level nodes that the player taps to launch puzzles
2. Ruut avatar visibly walks between level nodes on the world map as the player progresses
3. Completed levels display star ratings; progression gates show star requirements; lives are visible on the map
4. The first 5 levels teach only the core puzzle with no obstacles or surge; new mechanics are introduced one at a time via contextual overlays that fire only once
5. The name generator assigns a unique, safe display name from curated categories with no user-typed input allowed

**Pitfalls to Avoid:**
- M6 (Tutorial overwhelm): One system per tutorial moment; first 5 levels are core puzzle only; just-in-time teaching
- C5 (Auth churn wall): Name generator should be quick and delightful, not a friction barrier
- N2 (Name generator combinations): Curate all name components; test combinatorial space for offensive outputs

**Estimated Complexity:** High

**Plans:** TBD

Plans:
- [ ] 06-01: TBD
- [ ] 06-02: TBD
- [ ] 06-03: TBD

---

### Phase 7: Backend, Auth, Monetization, and Store

**Goal:** The game becomes a commercial product: players authenticate, progress syncs to the cloud, IAP and ads generate revenue, and the store sells diamond packs, power packs, and upgrades. All economy and ad values are server-configurable.

**Depends on:** Phase 6

**Requirements:**
- AUTH-01: Player can sign in with Sign in with Apple (iOS)
- AUTH-02: Player can sign in with Google Sign-In (Android and iOS)
- AUTH-03: Player can sign in with magic email link
- AUTH-04: Player can sign in with email and password
- AUTH-05: Player session persists across app restarts
- BACK-01: Player progress syncs to cloud on key events (level completion, purchase, login)
- BACK-02: Cloud save loads on login and resolves conflicts (server-authoritative for currency, high-water-mark for progress)
- BACK-03: Content delivery serves word-pair data and level configurations from cloud storage
- BACK-04: Pre-fetching caches an entire Land of content on entry (offline-first)
- BACK-05: Single-player gameplay functions fully without network connectivity
- BACK-06: Server-side receipt validation for all IAP transactions
- BACK-07: Remote Config enables feature flags and economy value tuning without app updates
- MNTZ-01: Interstitial ads display between levels at configurable frequency
- MNTZ-02: Rewarded ads recover hearts, hints, or lives when player opts in
- MNTZ-03: Banner ads display in reserved bottom region during non-gameplay screens
- MNTZ-04: Banner region collapses and layout refluxes when ads are off (ad-free purchase or server toggle)
- MNTZ-05: Diamond packs are purchasable via platform IAP (Apple App Store / Google Play)
- MNTZ-06: Ad-free purchase option removes interstitial and banner ads permanently
- MNTZ-07: Ad frequency and placement are server-configurable
- ECON-05: Diamonds are purchasable via IAP
- ECON-07: Store offers power packs (bundles of boosts)
- ECON-08: Store offers upgrades (input modes as unlockable purchases)
- ECON-09: Economy values (earn rates, prices, gate thresholds) are server-configurable without app updates
- ECON-10: Currency transactions are server-authoritative to prevent client-side manipulation
- AUDP-05: Player can toggle sound effects, music, and haptics independently in settings

**Success Criteria** (what must be TRUE):
1. A player can sign in with Sign in with Apple, Google Sign-In, magic email link, or email/password, and their session persists across app restarts
2. Player progress syncs to the cloud on level completion, purchase, and login; cloud save resolves conflicts using server-authoritative currency and high-water-mark progress
3. The game functions fully offline for single-player content with pre-fetched, cached level data
4. Diamond packs are purchasable through platform IAP with server-side receipt validation; the store sells power packs and upgrades
5. Interstitial, rewarded, and banner ads display correctly; ad frequency is server-configurable; an ad-free purchase removes interstitials and banners permanently

**Pitfalls to Avoid:**
- C5 (Auth churn wall): Lead with one-tap OAuth (Sign in with Apple + Google); minimize steps before first puzzle
- C6 (Cloud content latency): Pre-fetch entire Land on entry; never block level start on a network call
- M9 (Data sync conflicts): Server-authoritative currency; high-water-mark for progress; never last-write-wins
- C4 (Plugin gaps): Leverage Phase 1 spike validation; have REST API fallback ready

**Estimated Complexity:** Very High

**Plans:** TBD

Plans:
- [ ] 07-01: TBD
- [ ] 07-02: TBD
- [ ] 07-03: TBD
- [ ] 07-04: TBD

---

### Phase 8: Polish, Soft Launch, and Tuning

**Goal:** The game is polished to release quality, soft launched in a test market to gather real player data, and economy/difficulty values are tuned based on live metrics before global launch.

**Depends on:** Phase 7

**Requirements:** No specific requirement IDs -- this phase is cross-cutting refinement and validation of all prior phases.

**Delivers:**
- Soft launch build submitted to a test market (e.g., Philippines, New Zealand, or Canada)
- Analytics dashboards tracking: download-to-auth-to-first-puzzle-to-level-10-to-first-spend funnel
- Economy tuning based on real player data (star earn rates, diamond pricing, gate thresholds)
- Surge and obstacle difficulty tuning (drain rates, obstacle frequency, bust rates per level)
- Performance optimization for low-end Android devices
- App Store / Play Store compliance (privacy manifests, ATT prompt, data safety declarations)
- Bug fixes and edge case resolution from soft launch feedback

**Success Criteria** (what must be TRUE):
1. The game is accepted and live in at least one test market on both iOS and Android
2. Analytics confirm the download-to-first-puzzle funnel retains at least 60% of users
3. Economy values have been adjusted based on real player spending and progression data
4. Surge bust rates and heart consumption rates are within target ranges across all levels
5. The game runs at stable frame rates on budget Android devices (3GB RAM, 2-3 year old chipset)

**Pitfalls to Avoid:**
- M3 (Economy collapse): Use live data to tune, not developer intuition
- M1 (Surge unfairness): Track bust rates per level; adjust drain tuning for high-bust levels
- M8 (Low-end Android): Test on budget devices; configure effect quality tiers
- N3 (Policy compliance): Complete privacy manifests, ATT, and data safety before submission

**Estimated Complexity:** High

**Plans:** TBD

Plans:
- [ ] 08-01: TBD
- [ ] 08-02: TBD

---

### Phase 9: Post-Launch Features

**Goal:** High-value features that require a proven player base or represent scope that should not block launch. Delivered incrementally as post-launch updates.

**Depends on:** Phase 8

**Requirements:** v2 scope -- not in the v1 roadmap. Categories include:

- **Multiplayer** (MULT-01 through MULT-07): Vs mode, matchmaking, friend invites, async competition
- **Alternative Input Modes** (INPT-01, INPT-02): Radial wheel, scrambled tiles
- **Cosmetics** (COSM-01, COSM-02): Character skins for Ruut
- **Narrative** (NARR-01 through NARR-03): NPC dialogue, story, deeper theming
- **Social** (SOCL-01 through SOCL-03): Referral program, daily challenges, personality insights
- **Accessibility** (ACCS-01 through ACCS-04): Colorblind mode, font sizing, screen reader, reduced motion
- **Expanded Content** (XCON-01 through XCON-03): Nations 4-9, victory lap levels, custom ad network

**Success Criteria** (what must be TRUE):
1. Vs mode async competition is playable (same puzzle, leaderboard comparison) before real-time matchmaking is attempted
2. At least one post-launch content update (new Nation or feature) ships within 60 days of global launch

**Pitfalls to Avoid:**
- M5 (Matchmaking cold start): Ship async competition first; add stranger matchmaking only when DAU supports it
- N1 (Custom ad network scope creep): Treat geo-targeted ad network as a separate product, not a game feature

**Estimated Complexity:** Very High (cumulative across multiple updates)

**Plans:** TBD (planned after global launch)

---

## Coverage Summary

**v1 Requirements:** 117 total
**Mapped to Phases 1-7:** 117 (100%)
**Unmapped:** 0

| Phase | Requirements | Count |
|-------|-------------|-------|
| 1 - Foundation | FNDN-01 through FNDN-08 | 8 |
| 2 - Core Puzzle | PUZL-01 through PUZL-10 | 10 |
| 3 - Game Feel | SRGE-01 through SRGE-08, AUDP-01 through AUDP-04 | 12 |
| 4 - Obstacles/Boosts/Content | OBST-01 through OBST-07, BOST-01 through BOST-06, CONT-01 through CONT-07 | 20 |
| 5 - Progression/Economy/Retention | PROG-01 through PROG-08, ECON-01 through ECON-04, ECON-06, BOSS-01 through BOSS-06, RETN-01 through RETN-03, INVT-01 through INVT-03 | 25 |
| 6 - World Map/Tutorial | WMAP-01 through WMAP-08, TUTR-01 through TUTR-06, AUTH-06 through AUTH-08 | 17 |
| 7 - Backend/Auth/Monetization | AUTH-01 through AUTH-05, BACK-01 through BACK-07, MNTZ-01 through MNTZ-07, ECON-05, ECON-07 through ECON-10, AUDP-05 | 25 |
| **Total** | | **117** |

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9

| Phase | Plans Complete | Status | Completed |
|-------|---------------|--------|-----------|
| 1. Foundation and Validation Spikes | 1/4 | In progress | 2026-01-30 |
| 2. Core Puzzle Loop | 0/TBD | Not started | - |
| 3. Game Feel -- Surge, Score, and Audio | 0/TBD | Not started | - |
| 4. Obstacles, Boosts, and Content Pipeline | 0/TBD | Not started | - |
| 5. Progression, Economy, and Retention | 0/TBD | Not started | - |
| 6. World Map, Navigation, and Tutorial | 0/TBD | Not started | - |
| 7. Backend, Auth, Monetization, and Store | 0/TBD | Not started | - |
| 8. Polish, Soft Launch, and Tuning | 0/TBD | Not started | - |
| 9. Post-Launch Features | 0/TBD | Not started | - |

---
*Roadmap created: 2026-01-29*
*Last updated: 2026-01-30*
