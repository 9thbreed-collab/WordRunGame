# Project Research Summary

**Project:** WordRun!
**Domain:** Commercial F2P mobile word puzzle game (Godot 4.5, iOS/Android)
**Researched:** 2026-01-29
**Confidence:** MEDIUM-HIGH (strong consensus across all 4 research dimensions; key gaps are Godot 4.5 plugin verification and live market data)

---

## Executive Summary

WordRun! is a timed word-pair chain puzzle game that differentiates itself through a surge momentum system, obstacle/power-boost economy, and world map progression -- mechanics borrowed from action and match-3 genres but novel in the word puzzle space. Research across stack, features, architecture, and pitfalls converges on a clear conclusion: **the game should ship as a single-player-first product built on Godot 4.5 (GDScript, GL Compatibility renderer) with Firebase as the backend, launching with 3 obstacle types across 25 lands and deferring Vs Mode, custom ad network, and alternative input modes to post-launch updates.** The architecture should follow a layered pattern (Presentation / Game Systems / Data) with 8 focused autoloads, an EventBus for cross-scene communication, and a resource-based template system for obstacles that scales to 9+ types without new code paths.

The recommended approach prioritizes the core puzzle loop and surge mechanic above all else -- if the word-pair solving and momentum "rush" do not feel excellent on mobile touch devices, nothing else matters. The build order follows strict dependency layers: core puzzle, then game feel (surge/audio), then obstacles, then progression/economy, then world map, then backend, then monetization. This ordering surfaces the highest-risk unknowns (touch input feel, surge tuning, plugin compatibility) earliest when they are cheapest to fix.

The top risks are: (1) mobile export pipeline blindsides from never testing on physical devices early, (2) touch input feeling wrong because development happens on desktop, (3) word-pair content validation gaps shipping offensive or invalid content, (4) Godot plugin ecosystem gaps for AdMob/IAP requiring fallback to native wrappers or REST APIs, (5) required authentication creating a first-launch churn wall that kills 50-80% of downloads, and (6) cloud content delivery introducing latency into core gameplay if offline-first caching is not designed from the start. All six critical pitfalls have documented prevention strategies; the key is executing them early rather than bolting them on late.

---

## Cross-Cutting Themes

Four themes emerged independently across multiple research dimensions:

### 1. Offline-First Is Non-Negotiable

- **ARCHITECTURE** prescribes local-first persistence with background cloud sync
- **PITFALLS** (C6) warns cloud content delivery introduces latency that destroys the "rush"
- **STACK** recommends Firestore's built-in offline persistence
- **FEATURES** (TS-9) flags offline capability as a gap in current planning

**Consensus:** Design every system to work without a network connection for single-player content. Cache aggressively. Sync in the background. Never block gameplay on a network call.

### 2. Test on Physical Mobile Devices From Day One

- **PITFALLS** (C1, C2) ranks export pipeline and touch input as the top two critical risks
- **ARCHITECTURE** specifies touch-first design with minimum 48-52dp touch targets
- **STACK** details iOS/Android export requirements that trip up first-time mobile developers
- **FEATURES** (TS-1) requires sub-50ms tap-to-visual response for the "rush" feel

**Consensus:** Export to both platforms in Week 1. Acquire a budget Android test device. Test touch input before building any system on top of it.

### 3. Defer High-Complexity Features to Post-Launch

All four research files independently recommend deferring the same features:

| Feature | STACK | FEATURES | ARCHITECTURE | PITFALLS |
|---------|-------|----------|--------------|----------|
| Vs Mode multiplayer | -- | Defer (D-4) | Off critical path | M5: matchmaking needs player base |
| Custom ad network | Separate system | Defer (D-10) | -- | N1: scope creep |
| Alt input modes (radial, tiles) | -- | Defer (D-7) | Off critical path | -- |
| Character skins | -- | Defer (D-5) | -- | -- |
| Referral system | -- | Defer | -- | -- |

**Consensus:** Ship single-player excellence first. Add social/multiplayer/cosmetic features as post-launch updates when player data justifies investment.

### 4. The Surge + Obstacle + Hearts Interaction Is the Hardest Design Problem

- **FEATURES** (D-1) identifies surge as the core differentiator requiring extensive playtesting
- **PITFALLS** (M1, M2, M4) warns that surge, obstacles, and hearts compound into "unfair" moments
- **ARCHITECTURE** places SurgeManager and ObstacleManager as scene-local systems that must interact carefully
- **PITFALLS** interaction risks section explicitly calls out the surge+obstacle+hearts triple as the most dangerous compound risk

**Consensus:** These three systems must be designed, tested, and tuned together -- not in isolation. Budget significant playtesting time. Track bust rates, heart consumption rates, and penalty box churn in analytics from soft launch.

---

## Key Findings

### Recommended Stack

Godot 4.5 with GDScript and the GL Compatibility renderer is confirmed as the correct foundation. Firebase is recommended as the primary backend for auth, database (Firestore), cloud functions (IAP validation, matchmaking), storage (content delivery), and analytics. AdMob via a community plugin (Poing Studios or equivalent, verify for 4.5) handles standard ads. Platform-native plugins handle IAP with mandatory server-side receipt validation.

**Core technologies:**
- **Godot 4.5 (GDScript, GL Compatibility):** Game engine -- open source, no revenue share, excellent for 2D mobile, already initialized in the project
- **Firebase (Auth, Firestore, Cloud Functions, Storage, Analytics, Crashlytics):** Backend -- best auth breadth, Firestore fits game data model, largest Godot community adoption, generous free tier
- **AdMob (community plugin):** Advertising -- industry standard, best Godot plugin support; verify plugin maintenance status for 4.5
- **Platform-native IAP plugins + Cloud Functions validation:** Monetization -- server-side receipt validation is mandatory; never trust the client
- **Gut (GDScript):** Testing framework -- most documented Godot unit testing option
- **GitHub Actions + godot-ci:** CI/CD -- automate builds and tests

**Critical verification required before implementation:**
- GodotFirebase plugin compatibility with Godot 4.5
- AdMob plugin compatibility with Godot 4.5
- IAP plugin landscape for Godot 4.5 (Android + iOS)
- Fallback plan: Firebase REST API via HTTPRequest if no maintained plugin exists

### Expected Features

**Must have (table stakes) -- blocks release if missing:**
1. Core word-pair puzzle with scrolling window and keyboard input (TS-1)
2. Surge momentum system with thresholds, imminent drain, bust (D-1 -- core differentiator)
3. 3 obstacle types with counter power boosts (D-3, scoped for v1)
4. World map with nation/land/level progression (TS-3)
5. Dual currency: Stars (soft) + Diamonds (premium) (TS-6)
6. Hints system with rewarded ad recovery (TS-4)
7. Hearts/lives system with penalty box (TS-4)
8. AdMob integration: interstitial + rewarded (TS-10)
9. IAP integration: diamond packs, power packs (TS-6)
10. Cloud save via authentication (TS-9)
11. Sound design and haptic feedback (TS-1 -- gap identified)
12. Phased tutorial over 20+ levels (TS-7)
13. 250+ levels of validated word-pair content (TS-2)
14. Name generator for safe profiles (AF-5)

**Should have (strong improvement, not blocking):**
- Boss levels at end of each Land (D-8)
- Inventory/loadout system (D-6)
- Login streaks with daily rewards (TS-5)
- Ruut avatar walking world map (D-5)
- Level completion screen with score breakdown (TS-2)
- Settings (sound, account, notifications) (TS-8)

**Defer to post-launch:**
- Vs Mode multiplayer (D-4) -- needs player base for matchmaking
- Radial and scrambled tile input modes (D-7)
- Character skins (D-5)
- Custom ad network with geo-targeting (D-10) -- separate product
- NPC dialogue / narrative (D-9)
- Referral system -- needs player base for viral mechanics
- Daily challenges -- add after analyzing retention data
- Accessibility features (flagged as gap, important for store featuring)

**Identified gaps in current planning:**
- Sound design and haptics not explicitly planned (critical for "rush" feel)
- Daily challenges absent (strong retention driver in every competitor)
- Accessibility features absent (increasingly required for App Store featuring)
- Offline play not explicitly designed (critical for mobile)
- Ad-free purchase option not planned (expected by players, $4.99-$6.99 one-time)
- Level replay for completed levels not mentioned

### Architecture Approach

A three-layer architecture -- Presentation (Godot scenes), Game Systems (8 focused autoloads), Data (persistence + cloud sync) -- communicating through an EventBus signal relay. Scenes are self-contained components; autoloads own cross-session state; data flows unidirectionally downward with signals flowing upward. The obstacle system uses a resource-based template pattern where new obstacle types require only a `.tres` config file and a visual `.tscn` scene, with zero new GDScript code paths. The directory structure mirrors scenes and scripts for predictability, with a separate `data/` directory for content-as-configuration.

**Major components:**
1. **EventBus (autoload)** -- Pure signal declaration relay; no logic; decouples all cross-scene communication
2. **GameManager (autoload)** -- State machine for app flow (loading/auth/menu/playing/paused/results/store); scene transitions
3. **DataManager (autoload)** -- Local-first persistence (encrypted JSON), cloud sync orchestration, content caching with version checks
4. **ProgressionManager (autoload)** -- Player state: hearts, hints, lives, currency balances, level unlock status, login streaks
5. **EconomyManager (autoload)** -- IAP flow, store transactions, currency validation
6. **PuzzleScreen (scene)** -- Level session: assembles ScrollingWindow, WordRows, LetterSlots, SurgeBar, ObstacleManager, InputSystem
7. **ObstacleManager (scene-local)** -- Spawns obstacles from ObstacleConfig resources, manages lifecycle, checks counter conditions
8. **WorldMap (scene)** -- Nation/Land/Level navigation, Ruut avatar, NPC points, progression gates

**Key architectural decisions:**
- Signals up, calls down; siblings never call each other directly
- State lives in autoloads, never in display nodes (display is a projection of state)
- Resource-as-configuration for all game data (levels, obstacles, boosts, store items)
- Composition over inheritance for gameplay components
- Responsive layout with Control containers for mobile screen diversity

### Critical Pitfalls

The top 6 pitfalls (all rated CRITICAL) with prevention strategies:

1. **Mobile export pipeline blindsides (C1)** -- Export to both iOS and Android in Week 1, even if just the default splash screen. Set up Apple Developer account and Google Play Console early. Store the Android release keystore with backups.

2. **Touch input feels wrong (C2)** -- Design touch-first with 48-52dp minimum touch targets. Test on physical devices from Day 1. Disable system virtual keyboard. Implement haptic feedback. Test on small-screen and budget devices.

3. **Word pair validation gaps (C3)** -- Build a multi-layer validation pipeline: automated dictionary check, profanity/sensitivity filter (compound combinations, not just individual words), human review of every chain in sequence, beta tester flagging. Version content database with instant rollback capability.

4. **Plugin ecosystem gaps for monetization (C4)** -- Build a "monetization spike" early: one test interstitial and one test IAP exported to both platforms on physical devices. Budget time for plugin maintenance. Implement Apple ATT prompt. Plan for native wrapper fallback.

5. **Required auth creates churn wall (C5)** -- Strongly recommend deferred auth: let players play immediately with anonymous profile, trigger auth when needed (first cloud save, first IAP, first multiplayer). If auth is required, use one-tap OAuth (Sign in with Apple + Google), not magic link or email/password.

6. **Cloud content delivery latency (C6)** -- Implement aggressive content caching: pre-fetch entire Land on entry (100+ levels, only a few MB). Design for offline-first. Never block level start on a network call. Sync in background during non-gameplay moments.

**Compound risk warning:** Surge + Obstacles + Hearts interact to create "unfair" moments. Auth + Tutorial + Economy Introduction stack into an onboarding wall. Cloud Content + Ad SDK + Particle Effects compete for resources on low-end devices. These interaction risks are more dangerous than any individual pitfall.

---

## Implications for Roadmap

Based on combined research, the following 9-phase structure is recommended. Phases 1-7 are the critical path to a shippable v1. Phases 8-9 are post-launch.

### Phase 1: Foundation and Validation Spikes
**Rationale:** Eliminate the two highest-risk unknowns (mobile export pipeline, monetization plugin compatibility) before writing game code. Every subsequent phase depends on these working.
**Delivers:** Validated mobile export pipeline (both platforms, physical devices), validated AdMob + IAP plugin compatibility, project structure, EventBus + GameManager + DataManager shells, CI/CD pipeline skeleton.
**Addresses:** Project setup, export validation, plugin feasibility
**Avoids:** C1 (export blindsides), C4 (plugin gaps discovered late)
**Architecture:** Layer 0 (EventBus, GameManager shell, DataManager shell)
**Banner Ad Layout Note:** Establish the global banner ad layout strategy in this phase. All screen layouts from Phase 2 onward must reserve space for a persistent banner ad region (typically bottom-of-screen, standard 320x50 or adaptive banner). This region must be toggleable: visible when ads are active, collapsed (with layout reflowing proportionally to reclaim the space) when the player has purchased ad-free or when banner ads are turned off globally via server-side config. The AdManager autoload should expose a `banner_visible: bool` state that all screens observe. This is a layout contract, not an ad SDK integration -- the actual ad content comes later in Phase 7, but the reserved space must be baked into every screen from the start. The creator retains full discretion over what banner ads to place (AdMob, custom creatives, promotional content, or nothing) and can toggle banners on/off universally via Remote Config without an app update.

### Phase 2: Core Puzzle Loop
**Rationale:** The word-pair solving mechanic is the atomic unit of the entire game. If this does not feel right on touch devices, nothing else matters. Build and validate before adding complexity.
**Delivers:** Playable word-pair puzzle: LetterSlot, WordRow, ScrollingWindow, on-screen keyboard input, word validation, auto-advance, correct/incorrect feedback. Tested on physical mobile devices.
**Addresses:** TS-1 (core puzzle loop), D-2 (word-pair chain mechanic), touch-first input
**Avoids:** C2 (touch input feels wrong -- validate immediately on physical devices)
**Architecture:** Layer 1 (LetterSlot, WordRow, ScrollingWindow, InputSystem, PuzzleScreen, word validation)

### Phase 3: Game Feel -- Surge, Score, and Audio
**Rationale:** The surge momentum system is the core differentiator. It transforms a word puzzle into a "rush." Build and tune it on top of the stable puzzle loop before adding obstacles that interact with it.
**Delivers:** Surge bar with drain, thresholds, multipliers, imminent drain, bust mechanic. Score calculation. Basic SFX (typing, correct, incorrect, surge tension). Bonus round logic. Animation polish (letter pop, word slide, scroll).
**Addresses:** D-1 (surge momentum -- core differentiator), TS-1 (sound design -- identified gap)
**Avoids:** M1 (surge unfairness -- extensive playtesting with non-developers begins here)
**Architecture:** Layer 2 (SurgeBar, SurgeManager, AudioManager, score system, bonus round)

### Phase 4: Obstacles, Boosts, and Content Pipeline
**Rationale:** Obstacles and boosts build on the stable puzzle + surge foundation. The template architecture must be built extensibly from the start -- not hardcoded for 3 and refactored later. Content validation pipeline is equally critical: bad word content is a CRITICAL pitfall.
**Delivers:** ObstacleConfig resource system, ObstacleBase shared logic, 3 obstacle scenes (Padlock, Random Blocks, Sand), 3 counter power boosts (Lock Key, Block Breaker, Bucket of Water), boost activation/consumption, score bonus for unused boosts. Word-pair content validation pipeline (automated + human review). Initial 250+ levels of validated content.
**Addresses:** D-3 (obstacle/boost economy), D-2 (word-pair content at scale)
**Avoids:** C3 (word validation gaps), M2 (too many mechanics -- ship only 3), M7 (boss impossibility -- constrained randomization)
**Architecture:** Layer 3 (ObstacleConfig, ObstacleBase, ObstacleManager, BoostData, power boost system)

### Phase 5: Progression, Economy, and Retention
**Rationale:** With the core gameplay loop complete (puzzle + surge + obstacles), add the systems that give it structure: hearts, hints, lives, currency, level tracking. These can partially parallel Phase 4 if capacity allows.
**Delivers:** ProgressionManager with hearts/hints/lives, Stars earning + tracking, Diamonds earning + discovery mechanic, penalty box with cooldown, level completion recording, local persistence. Boss levels (at least at end of each Land). Inventory/loadout screen. Login streaks with daily rewards.
**Addresses:** TS-4 (hints), TS-6 (dual currency), D-6 (inventory/loadout), D-8 (boss levels), TS-5 (login streaks)
**Avoids:** M3 (economy collapse -- design with server-side tunability from day one), M4 (hearts punishing engagement -- new player protection, short cooldowns)
**Architecture:** Layer 4 (ProgressionManager, EconomyManager shell, hearts/hints/lives, penalty box)

### Phase 6: World Map, Navigation, and Tutorial
**Rationale:** The world map requires progression data (which levels are unlocked, star counts). The tutorial must be designed alongside the first 50 levels because progressive disclosure affects level design. Ruut avatar adds personality to navigation.
**Delivers:** World map scene with Nation/Land/Level node structure, Ruut avatar walking between nodes, level selection launching puzzle, return to map with updated progress, progression gates (star requirements), NPC dialogue points (basic). Phased tutorial system across first 30-50 levels. Name generator for profiles.
**Addresses:** TS-3 (world map), TS-7 (tutorial), D-5 (Ruut avatar), TS-2 (progressive difficulty)
**Avoids:** M6 (tutorial overwhelm -- one system per tutorial moment, first 5 levels teach only core puzzle), C5 (auth churn wall -- design onboarding flow to minimize friction)
**Architecture:** Layer 5 (WorldMap, LevelNode, AvatarController, TutorialManager overlay)

### Phase 7: Backend, Auth, Monetization, and Store
**Rationale:** Backend integration, authentication, and monetization are grouped because they are interdependent: IAP requires server-side validation, cloud save requires auth, the store requires economy + backend. This is the phase that makes the game a commercial product.
**Delivers:** NetworkManager with Firebase integration, auth system (OAuth: Sign in with Apple + Google, magic link fallback), cloud save/load with conflict resolution, content delivery from Cloud Storage, EconomyManager with IAP flow (platform-native billing + Cloud Functions validation), StoreScreen (diamond packs, power packs, ad-free purchase), AdManager with AdMob (interstitial + rewarded + banner), banner ad population and toggling, settings screen (sound, account, notifications). Remote Config for feature flags and economy tuning.
**Addresses:** TS-9 (cloud save), TS-10 (ads), TS-6 (IAP), TS-8 (settings)
**Avoids:** C4 (plugin gaps -- spike already validated in Phase 1), C5 (auth wall -- OAuth first, defer name generation), C6 (cloud latency -- offline-first caching architecture), M9 (data sync -- server-authoritative currency, high-water-mark progress)
**Architecture:** Layers 6-7 (NetworkManager, auth, cloud sync, EconomyManager, AdManager, StoreScreen)

### Phase 8: Polish, Soft Launch, and Tuning
**Rationale:** Before global launch, soft launch in a small market to gather real player data. Economy tuning, surge difficulty curves, penalty box durations, and ad frequency caps all require live data. This phase also covers final polish.
**Delivers:** Soft launch build, analytics dashboards (funnel: download > auth > first puzzle > level 10 > first spend), economy tuning based on real data, surge/obstacle balance tuning, performance optimization for low-end Android, accessibility features (colorblind mode, font sizing), level replay functionality, App Store / Play Store compliance (privacy manifests, ATT, data safety declarations).
**Addresses:** All gaps identified in research: accessibility, daily challenges consideration, ad-free purchase, performance on budget devices
**Avoids:** M3 (economy collapse -- live data tuning), M8 (low-end Android performance), N3 (policy compliance), M1 (surge unfairness -- data-driven tuning)

### Phase 9: Post-Launch Features (v1.1+)
**Rationale:** These features are high-value but either require a proven player base or represent scope that should not block launch.
**Delivers (incrementally):**
- **Vs Mode** with async competition first (same puzzle, leaderboard comparison), then friend invites, then stranger matchmaking with bot fallback (D-4, M5)
- **Alternative input modes** -- radial wheel, scrambled tiles (D-7)
- **Character skins** for Ruut (D-5)
- **Daily challenges** (gap identified in FEATURES -- strong retention driver)
- **NPC dialogue and narrative** (D-9)
- **Referral system** (needs player base)
- **Custom ad network** with geo-targeting (D-10, N1 -- separate project, only when DAU justifies)
- **Additional obstacle types** for Nations 4-9 (leveraging template architecture)

### Phase Ordering Rationale

- **Dependency-driven:** Each phase depends on the previous. You cannot build obstacles without a stable puzzle. You cannot build progression without obstacles affecting hearts. You cannot build a store without an economy. You cannot monetize without a backend.
- **Risk-front-loaded:** The highest-risk unknowns (export pipeline, touch input, plugin compatibility, surge tuning) are surfaced in Phases 1-3 when they are cheapest to fix. Discovering touch input feels wrong in Phase 7 would require reworking the entire UI layer.
- **Architecture-aligned:** Phase boundaries match the architecture's layer boundaries (Layers 0-1-2-3-4-5-6/7), ensuring each phase produces a stable, testable increment.
- **Pitfall-aware:** Every phase explicitly lists which pitfalls it must avoid, with prevention strategies from PITFALLS.md baked into the phase deliverables.
- **Single-player-first:** Vs Mode is off the critical path. The game ships as a complete single-player experience. Multiplayer arrives when the player base can sustain matchmaking.

### Research Flags

**Phases likely needing deeper research during planning:**
- **Phase 1 (Foundation):** Godot 4.5 plugin verification -- AdMob, Firebase, IAP plugin current maintenance status. This is a blocking unknown.
- **Phase 4 (Obstacles):** Obstacle interaction matrix design -- how do obstacles interact with each other, with surge, and with boss conditions? Requires design research, not just technical research.
- **Phase 7 (Backend/Monetization):** Firebase integration patterns for Godot -- whether to use a plugin or REST API, auth flow specifics, Firestore data model validation. Also: Apple ATT implementation, App Store / Play Store submission requirements.
- **Phase 8 (Soft Launch):** Soft launch market selection, analytics tool selection, economy modeling methodology.

**Phases with standard, well-documented patterns (likely skip deep research):**
- **Phase 2 (Core Puzzle):** Standard Godot UI/input patterns. Well-documented.
- **Phase 3 (Game Feel):** Standard Godot animation/audio patterns. Surge is novel design but uses standard Godot Tween/Timer APIs.
- **Phase 5 (Progression):** Standard F2P economy patterns. Well-documented in industry literature.
- **Phase 6 (World Map):** Standard Godot Node2D scene with camera. Well-documented Godot patterns.

---

## Top 10 Actionable Insights for Roadmap Creation

Ranked by impact on project success:

1. **Export to physical devices in Week 1.** Validate the full iOS and Android export pipeline before writing any game code. This single action prevents the #1 and #2 critical pitfalls (C1, C2). Non-negotiable.

2. **Build the surge mechanic as a standalone tunable system, not hardcoded into the puzzle.** The surge bar is the game's identity. It needs drain rates, threshold values, bust timing, and grace periods to be tunable -- ideally server-side via Remote Config. Expect to iterate on surge tuning through soft launch.

3. **Design every screen layout with a reservable banner ad region from the start.** All screens must account for a bottom-of-screen banner ad space that collapses proportionally when ads are off (player purchased ad-free, or creator has globally disabled banners via server config). This is a layout contract established in Phase 1 and honored by every screen built afterward. The creator retains discretion over banner content and can toggle banners universally without an app update.

4. **Build the obstacle template system extensibly from Day 1.** Use the Resource-based ObstacleConfig + ObstacleBase pattern. Do not hardcode 3 obstacles and plan to refactor for 9. The cost of extensibility is near-zero upfront; the cost of refactoring is high.

5. **Ship with AdMob only. Defer the custom ad network entirely.** The geo-targeted custom ad network is a separate product (ad server, campaign management, impression tracking, fraud prevention). It has no place in v1. Use AdMob's built-in geo-targeting for any location-based needs.

6. **Defer Vs Mode to post-launch.** Matchmaking requires a critical mass of concurrent players that a new game does not have. Ship async competition (same puzzle, leaderboard) or friend-invite-only multiplayer first. Add stranger matchmaking when DAU data supports it.

7. **Implement deferred authentication.** Let players play immediately with an anonymous/local profile. Trigger auth when they need cloud save, IAP, or multiplayer. This prevents the 50-80% churn rate that required-auth-before-gameplay causes. If deferred auth is rejected, use one-tap OAuth (Apple + Google) as the primary path -- not magic link, not email/password.

8. **Build the word-pair content validation pipeline before generating content at scale.** The pipeline needs automated dictionary checking, compound-phrase profanity filtering (check pairs and chains, not just individual words), human review of every chain, and versioned content with instant rollback. Bad content is an existential risk for a word game.

9. **Design for offline-first from the architecture level.** Cache content aggressively (entire Land on entry, a few MB). Save locally first, sync in background. Never gate level start on a network call. Word data is tiny -- there is no reason not to pre-cache hundreds of levels.

10. **Test the surge + obstacle + hearts interaction as a compound system.** These three systems create the most dangerous interaction risk in the game. A locked word draining surge, causing a bust, costing hearts, triggering penalty box -- this sequence must be designed, tested, and tuned as a unit. Track bust rates, heart consumption, and penalty-box-to-uninstall rates from soft launch.

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | MEDIUM | Core Godot/Firebase recommendations are HIGH confidence. Specific plugin compatibility with Godot 4.5 is unverified -- this is the single biggest unknown. Fallback (REST API) is documented. |
| Features | MEDIUM-HIGH | Table stakes and anti-features are well-grounded in stable industry patterns. Competitor feature sets may have evolved since mid-2025. Revenue estimates are directional only. |
| Architecture | HIGH | Godot patterns (autoloads, signals, resources, scene composition) are well-established and officially documented. Architecture is backend-agnostic by design. Obstacle template pattern is standard game architecture. |
| Pitfalls | MEDIUM-HIGH | Core pitfalls (export pipeline, touch input, content validation, economy design, matchmaking math) are stable, well-documented problems. Godot 4.5-specific issues need re-verification. Mobile platform policies (ATT, Privacy Manifests, billing library versions) should be checked against current docs. |

**Overall confidence:** MEDIUM-HIGH

The research is thorough and internally consistent. The main confidence gap is the Godot 4.5 plugin ecosystem: if AdMob, Firebase, and IAP plugins do not have maintained Godot 4.5 versions, the project must fall back to Firebase REST API and custom native wrappers, adding weeks of development. This is why Phase 1 includes validation spikes -- to resolve this unknown before committing the architecture.

### Gaps to Address

- **Godot 4.5 plugin verification:** Must check current GitHub/Asset Library for AdMob, Firebase, and IAP plugin maintenance status. Blocking for Phase 1.
- **Sound design and haptics:** Not mentioned in project planning docs. Critical for the "rush" feel. Needs design attention in Phase 3.
- **Daily challenges:** Absent from current planning. Every major competitor has them. Strong retention driver. Recommend adding to Phase 8 or 9.
- **Accessibility features:** Not mentioned. Increasingly important for App Store featuring. Recommend Phase 8.
- **Ad-free purchase option:** Not mentioned. Expected by players ($4.99-$6.99 one-time). Recommend Phase 7.
- **Soft launch strategy:** No market identified. Economy tuning requires live data. Recommend planning in Phase 8.
- **COPPA compliance decision:** Is this a 13+ game or all-ages? Word games attract younger players. This decision affects ad networks, analytics, and authentication. Needs early resolution.
- **Economy modeling:** No simulation of player progression curves for free/minnow/dolphin/whale segments. Needs attention before soft launch.
- **Banner ad layout contract:** Established as an architecture-level requirement. Every screen from Phase 2 onward must reserve collapsible banner space. Creator retains full discretion over banner content and universal on/off toggle via server config. Log this for adjustment during detailed phase planning.

---

## Sources

### Primary (HIGH confidence)
- Godot Engine official documentation: autoloads, signals, custom resources, scene tree, Control layout, mobile export
- GDQuest and Godot community best practices: EventBus pattern, composition over inheritance, resource-as-configuration
- Apple App Store Review Guidelines and Google Play Developer Policy Center (principles stable; verify specifics)
- Firebase official documentation: Auth, Firestore, Cloud Functions, Cloud Storage, Analytics
- F2P monetization literature: Candy Crush analysis, mobile game economy design (GDC, Deconstructor of Fun)

### Secondary (MEDIUM confidence)
- Community plugin ecosystem status (GodotFirebase, Poing AdMob, IAP plugins) -- assessed as of mid-2025, needs re-verification
- Competitor feature analysis (Wordscapes, Word Cookies, CodyCross, Word Villas) -- games update frequently, verify current state
- Mobile ad revenue benchmarks (eCPM rates, monetization percentages) -- directional from training data
- Sensor Tower / data.ai industry reports -- figures are estimates, not verified

### Tertiary (LOW confidence)
- Godot 4.5-specific API syntax -- based on 4.x general knowledge, exact calls should be verified against 4.5 docs
- Revenue estimates for competitor games -- order-of-magnitude only
- RevenueCat Godot SDK availability -- check if released since mid-2025

---

*Research completed: 2026-01-29*
*Ready for roadmap: yes*
