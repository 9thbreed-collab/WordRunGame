# Requirements: WordRun!

**Defined:** 2026-01-29
**Core Value:** The word-pair puzzle with the surge momentum system must feel like a "rush" -- the tension between solving fast for multipliers and risking a bust, combined with obstacle anticipation, is the experience that makes WordRun! unique.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Foundation

- [ ] **FNDN-01**: Godot project exports and runs on a physical iOS device
- [ ] **FNDN-02**: Godot project exports and runs on a physical Android device
- [ ] **FNDN-03**: AdMob plugin loads and displays a test ad on both platforms
- [ ] **FNDN-04**: IAP plugin completes a sandbox purchase on both platforms
- [ ] **FNDN-05**: Project directory structure follows the layered architecture (scenes/, scripts/, data/, assets/)
- [ ] **FNDN-06**: EventBus autoload relays signals between decoupled scenes
- [ ] **FNDN-07**: GameManager autoload manages app state transitions (loading, auth, menu, playing, paused, results, store)
- [ ] **FNDN-08**: All screen layouts reserve a collapsible bottom banner ad region that refluxes when toggled off

### Core Puzzle

- [ ] **PUZL-01**: Player sees a scrolling window displaying 4-5 word rows at a time
- [ ] **PUZL-02**: Each word row shows blank letter slots that the player fills one letter at a time
- [ ] **PUZL-03**: Word pairs form compound phrases or common two-word expressions (e.g., "car > door", "door > stop")
- [ ] **PUZL-04**: Correctly completed words auto-submit and the window auto-advances to the next word
- [ ] **PUZL-05**: Incorrect letter input provides immediate visual/audio feedback
- [ ] **PUZL-06**: On-screen keyboard captures player input (default input mode)
- [ ] **PUZL-07**: Standard level contains 12 base words plus 3 bonus words
- [ ] **PUZL-08**: Bonus words are gated by active surge momentum at word 12
- [ ] **PUZL-09**: Level has a countdown timer visible to the player
- [ ] **PUZL-10**: Touch targets are minimum 48dp and responsive across mobile screen sizes

### Surge System

- [ ] **SRGE-01**: Surge bar displays on screen during gameplay with visible threshold segments
- [ ] **SRGE-02**: Surge bar progressively drains toward zero when not being filled
- [ ] **SRGE-03**: Consecutive correct answers fill the surge bar
- [ ] **SRGE-04**: Crossing threshold segments increases the active point multiplier
- [ ] **SRGE-05**: Passing the final threshold enters "imminent drain" with a faster drain rate
- [ ] **SRGE-06**: If surge drops below the imminent threshold after entering it, an unrecoverable bust occurs (bar drains fully)
- [ ] **SRGE-07**: Current multiplier and score are visible to the player during gameplay
- [ ] **SRGE-08**: Surge values (drain rates, thresholds, bust timing) are configurable per level via data resources

### Obstacles

- [ ] **OBST-01**: Obstacle system uses a resource-based template architecture (ObstacleConfig + ObstacleBase)
- [ ] **OBST-02**: Padlock obstacle locks each letter of a target word; the word is unavailable unless the next word is solved or Lock Key boost is used
- [ ] **OBST-03**: Random Blocks obstacle fills letter spaces with wood-grain blocks without warning; if the whole word fills, it self-solves for zero points
- [ ] **OBST-04**: Sand obstacle fills 1 random space in 1-5 random words slowly; trickles down on scroll; can make words unsolvable if fully filled
- [ ] **OBST-05**: Each obstacle type has distinct visual animations
- [ ] **OBST-06**: Obstacles appear at predetermined points within levels according to level data
- [ ] **OBST-07**: Adding a new obstacle type requires only a new config resource and visual scene, not new code paths

### Power Boosts

- [ ] **BOST-01**: Lock Key boost counters Padlock obstacle (unlocks locked word)
- [ ] **BOST-02**: Block Breaker boost counters Random Blocks obstacle (clears all blocks)
- [ ] **BOST-03**: Bucket of Water boost counters Sand obstacle (clears sand from up to 3 words)
- [ ] **BOST-04**: Using a power boost when no corresponding obstacle is present grants a score bonus
- [ ] **BOST-05**: Player selects boosts from inventory before starting a level (loadout system)
- [ ] **BOST-06**: Boosts are consumed on use

### Content

- [ ] **CONT-01**: Word-pair content is stored in cloud/database, not bundled in the app binary
- [ ] **CONT-02**: Content is cached locally so gameplay never blocks on a network call
- [ ] **CONT-03**: Minimum 250 levels of validated word-pair content available at launch
- [ ] **CONT-04**: Word pairs are validated through automated dictionary checking
- [ ] **CONT-05**: Word pairs are filtered for profanity and sensitivity (including compound combinations)
- [ ] **CONT-06**: Content is versioned with the ability to update without an app release
- [ ] **CONT-07**: Words are themed per land to align with narrative context

### Progression

- [ ] **PROG-01**: Hearts are an in-level resource; count carries across levels until boss level or time-based recovery
- [ ] **PROG-02**: Losing all hearts in a level ends the attempt
- [ ] **PROG-03**: Hints replenish each level; when depleted, a rewarded ad recovers one extra hint
- [ ] **PROG-04**: Lives are displayed on the world map; losing all hearts costs a life
- [ ] **PROG-05**: After ad recovery is used, a cooldown penalty box timer activates before another recovery
- [ ] **PROG-06**: Level completion records stars earned, score, and time
- [ ] **PROG-07**: Player progress persists locally between sessions
- [ ] **PROG-08**: Completed levels can be replayed

### Economy

- [ ] **ECON-01**: Stars (non-premium currency) are earned through gameplay based on performance challenges (time, boost usage)
- [ ] **ECON-02**: Stars function as progression gates (minimum stars required to unlock certain levels/lands)
- [ ] **ECON-03**: Stars are spendable in the store
- [ ] **ECON-04**: Diamonds (premium currency) are discovered through stellar gameplay with a tutorial on first discovery
- [ ] **ECON-05**: Diamonds are purchasable via IAP
- [ ] **ECON-06**: Diamonds are earned in smaller quantities through gameplay and world map promo challenges
- [ ] **ECON-07**: Store offers power packs (bundles of boosts)
- [ ] **ECON-08**: Store offers upgrades (input modes as unlockable purchases)
- [ ] **ECON-09**: Economy values (earn rates, prices, gate thresholds) are server-configurable without app updates
- [ ] **ECON-10**: Currency transactions are server-authoritative to prevent client-side manipulation

### World Map

- [ ] **WMAP-01**: World map displays 3 Nations, each containing multiple Lands
- [ ] **WMAP-02**: 25 Lands total are navigable across the 3 Nations
- [ ] **WMAP-03**: Each Land contains a path of level nodes the player progresses through
- [ ] **WMAP-04**: Ruut avatar walks between level nodes on the world map
- [ ] **WMAP-05**: Tapping a level node launches the puzzle for that level
- [ ] **WMAP-06**: Completed levels show star ratings on the map
- [ ] **WMAP-07**: Progression gates visually indicate star requirements to advance
- [ ] **WMAP-08**: Lives remaining are displayed on the world map screen

### Boss Levels

- [ ] **BOSS-01**: Boss level appears at the end of each Land
- [ ] **BOSS-02**: Boss levels contain more words than standard levels (up to 20)
- [ ] **BOSS-03**: Boss levels have randomized challenge conditions drawn from a constrained set
- [ ] **BOSS-04**: Boss levels feature more aggressive obstacle frequency
- [ ] **BOSS-05**: Completing a boss level grants special rewards (boosts, currency, or progression unlocks)
- [ ] **BOSS-06**: Boss NPC character is visible on screen during boss levels

### Authentication

- [ ] **AUTH-01**: Player can sign in with Sign in with Apple (iOS)
- [ ] **AUTH-02**: Player can sign in with Google Sign-In (Android and iOS)
- [ ] **AUTH-03**: Player can sign in with magic email link
- [ ] **AUTH-04**: Player can sign in with email and password
- [ ] **AUTH-05**: Player session persists across app restarts
- [ ] **AUTH-06**: Name generator assigns a display name from categories (silly, cool, heroic, whimsical, fun)
- [ ] **AUTH-07**: Generated names are unique across all players (no duplicates)
- [ ] **AUTH-08**: No user-typed names are permitted

### Backend

- [ ] **BACK-01**: Player progress syncs to cloud on key events (level completion, purchase, login)
- [ ] **BACK-02**: Cloud save loads on login and resolves conflicts (server-authoritative for currency, high-water-mark for progress)
- [ ] **BACK-03**: Content delivery serves word-pair data and level configurations from cloud storage
- [ ] **BACK-04**: Pre-fetching caches an entire Land of content on entry (offline-first)
- [ ] **BACK-05**: Single-player gameplay functions fully without network connectivity
- [ ] **BACK-06**: Server-side receipt validation for all IAP transactions
- [ ] **BACK-07**: Remote Config enables feature flags and economy value tuning without app updates

### Monetization

- [ ] **MNTZ-01**: Interstitial ads display between levels at configurable frequency
- [ ] **MNTZ-02**: Rewarded ads recover hearts, hints, or lives when player opts in
- [ ] **MNTZ-03**: Banner ads display in reserved bottom region during non-gameplay screens
- [ ] **MNTZ-04**: Banner region collapses and layout refluxes when ads are off (ad-free purchase or server toggle)
- [ ] **MNTZ-05**: Diamond packs are purchasable via platform IAP (Apple App Store / Google Play)
- [ ] **MNTZ-06**: Ad-free purchase option removes interstitial and banner ads permanently
- [ ] **MNTZ-07**: Ad frequency and placement are server-configurable

### Audio and Polish

- [ ] **AUDP-01**: Sound effects play for key actions: letter input, correct word, incorrect input, surge fill, surge bust, obstacle trigger, boost activation, level complete
- [ ] **AUDP-02**: Background music plays during gameplay and world map with distinct themes
- [ ] **AUDP-03**: Haptic feedback triggers on key touch interactions (letter tap, word complete, boost use)
- [ ] **AUDP-04**: Visual animations for letter placement, word completion, scroll advance, and surge bar movement
- [ ] **AUDP-05**: Player can toggle sound effects, music, and haptics independently in settings

### Tutorial

- [ ] **TUTR-01**: First 5 levels teach only core puzzle mechanics (no obstacles, no surge complexity)
- [ ] **TUTR-02**: New mechanics are introduced one at a time with contextual overlays when first encountered
- [ ] **TUTR-03**: Surge system is introduced after core puzzle is established (~level 6-10)
- [ ] **TUTR-04**: Each obstacle type is introduced with a dedicated tutorial moment in its Nation
- [ ] **TUTR-05**: Economy mechanics (stars, diamonds, store) are introduced progressively as they become relevant
- [ ] **TUTR-06**: Tutorials do not replay once completed (one-time triggers per mechanic)

### Retention

- [ ] **RETN-01**: Login streaks track consecutive days the player opens the app
- [ ] **RETN-02**: Login streak rewards increase with streak length (boosts, currency, lower-tier premium packs)
- [ ] **RETN-03**: Streak rewards are displayed on login with a claim interaction

### Inventory

- [ ] **INVT-01**: Player has an inventory of owned boosts and items
- [ ] **INVT-02**: Player selects a loadout of boosts before starting a level
- [ ] **INVT-03**: Loadout can be changed between levels without returning to store

## v2 Requirements

Deferred to post-launch. Tracked but not in current roadmap.

### Multiplayer

- **MULT-01**: Vs mode with turn-based gameplay on a shared word column
- **MULT-02**: Each player has an individual time clock during Vs mode
- **MULT-03**: Skip-turn power boost available in Vs mode
- **MULT-04**: Matchmaking pairs strangers by skill/level
- **MULT-05**: Friend invites via link or code
- **MULT-06**: Match ends when a player's clock runs out
- **MULT-07**: Async competition mode (same puzzle, leaderboard comparison) as stepping stone to real-time

### Alternative Input Modes

- **INPT-01**: Radial wheel input mode (unlockable upgrade)
- **INPT-02**: Scrambled tile input mode (unlockable upgrade)

### Cosmetics

- **COSM-01**: Character skins for Ruut avatar (purchasable with diamonds)
- **COSM-02**: Multiple skin categories/themes

### Narrative

- **NARR-01**: NPC dialogue at points on the world map
- **NARR-02**: Light story unfolding across Nations
- **NARR-03**: Themed word pools tied to story/land context (basic theming in v1, deeper narrative in v2)

### Social

- **SOCL-01**: Referral program (invitee reaches certain level, both players rewarded)
- **SOCL-02**: Daily challenges with unique puzzle configurations
- **SOCL-03**: Shareable player personality insights

### Accessibility

- **ACCS-01**: Colorblind mode for obstacle and surge visual cues
- **ACCS-02**: Adjustable font sizing
- **ACCS-03**: Screen reader compatibility for menus and navigation
- **ACCS-04**: Reduced motion option for animations

### Expanded Content

- **XCON-01**: Nations 4-9 with new obstacle types (Ice, Charcoal, Acid, Flood, Acorn, Magnet)
- **XCON-02**: Victory lap challenge levels (300 post-game levels)
- **XCON-03**: Custom ad network with geo-targeting (zip code level)

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Full cutscene system | Deferred to post-launch; v1 uses themed word pools and NPC dialogue placeholders for narrative |
| Mini-game penalty box | v1 uses cooldown timer only; mini-game adds complexity without validated retention benefit |
| Merch store fulfillment | v1 has placeholder/"coming soon"; fulfillment is a separate business operation |
| User-typed names | Moderation overhead; name generator prevents obscene/inappropriate names without content review |
| Real-time PvP (simultaneous play) | Only turn-based; real-time multiplayer requires dedicated game server infrastructure |
| Desktop/web platform | Mobile-first (iOS + Android); desktop adds export complexity without clear market |
| Loot boxes / gacha mechanics | Anti-pattern; regulatory risk (Belgium, Netherlands bans); player trust concern |
| Energy wall blocking all play | Anti-pattern; hearts/lives allow continued play via ads, not hard gates |
| Forced social sharing for progression | Anti-pattern; social should be opt-in and rewarding, not required |
| Subscription as primary monetization | Anti-pattern for casual puzzle games; IAP + ads is the proven model |
| Full 3,000-level content at launch | v1 ships 25 lands (~250+ levels); cloud backend enables seamless content expansion post-launch |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| FNDN-01 | -- | Pending |
| FNDN-02 | -- | Pending |
| FNDN-03 | -- | Pending |
| FNDN-04 | -- | Pending |
| FNDN-05 | -- | Pending |
| FNDN-06 | -- | Pending |
| FNDN-07 | -- | Pending |
| FNDN-08 | -- | Pending |
| PUZL-01 | -- | Pending |
| PUZL-02 | -- | Pending |
| PUZL-03 | -- | Pending |
| PUZL-04 | -- | Pending |
| PUZL-05 | -- | Pending |
| PUZL-06 | -- | Pending |
| PUZL-07 | -- | Pending |
| PUZL-08 | -- | Pending |
| PUZL-09 | -- | Pending |
| PUZL-10 | -- | Pending |
| SRGE-01 | -- | Pending |
| SRGE-02 | -- | Pending |
| SRGE-03 | -- | Pending |
| SRGE-04 | -- | Pending |
| SRGE-05 | -- | Pending |
| SRGE-06 | -- | Pending |
| SRGE-07 | -- | Pending |
| SRGE-08 | -- | Pending |
| OBST-01 | -- | Pending |
| OBST-02 | -- | Pending |
| OBST-03 | -- | Pending |
| OBST-04 | -- | Pending |
| OBST-05 | -- | Pending |
| OBST-06 | -- | Pending |
| OBST-07 | -- | Pending |
| BOST-01 | -- | Pending |
| BOST-02 | -- | Pending |
| BOST-03 | -- | Pending |
| BOST-04 | -- | Pending |
| BOST-05 | -- | Pending |
| BOST-06 | -- | Pending |
| CONT-01 | -- | Pending |
| CONT-02 | -- | Pending |
| CONT-03 | -- | Pending |
| CONT-04 | -- | Pending |
| CONT-05 | -- | Pending |
| CONT-06 | -- | Pending |
| CONT-07 | -- | Pending |
| PROG-01 | -- | Pending |
| PROG-02 | -- | Pending |
| PROG-03 | -- | Pending |
| PROG-04 | -- | Pending |
| PROG-05 | -- | Pending |
| PROG-06 | -- | Pending |
| PROG-07 | -- | Pending |
| PROG-08 | -- | Pending |
| ECON-01 | -- | Pending |
| ECON-02 | -- | Pending |
| ECON-03 | -- | Pending |
| ECON-04 | -- | Pending |
| ECON-05 | -- | Pending |
| ECON-06 | -- | Pending |
| ECON-07 | -- | Pending |
| ECON-08 | -- | Pending |
| ECON-09 | -- | Pending |
| ECON-10 | -- | Pending |
| WMAP-01 | -- | Pending |
| WMAP-02 | -- | Pending |
| WMAP-03 | -- | Pending |
| WMAP-04 | -- | Pending |
| WMAP-05 | -- | Pending |
| WMAP-06 | -- | Pending |
| WMAP-07 | -- | Pending |
| WMAP-08 | -- | Pending |
| BOSS-01 | -- | Pending |
| BOSS-02 | -- | Pending |
| BOSS-03 | -- | Pending |
| BOSS-04 | -- | Pending |
| BOSS-05 | -- | Pending |
| BOSS-06 | -- | Pending |
| AUTH-01 | -- | Pending |
| AUTH-02 | -- | Pending |
| AUTH-03 | -- | Pending |
| AUTH-04 | -- | Pending |
| AUTH-05 | -- | Pending |
| AUTH-06 | -- | Pending |
| AUTH-07 | -- | Pending |
| AUTH-08 | -- | Pending |
| BACK-01 | -- | Pending |
| BACK-02 | -- | Pending |
| BACK-03 | -- | Pending |
| BACK-04 | -- | Pending |
| BACK-05 | -- | Pending |
| BACK-06 | -- | Pending |
| BACK-07 | -- | Pending |
| MNTZ-01 | -- | Pending |
| MNTZ-02 | -- | Pending |
| MNTZ-03 | -- | Pending |
| MNTZ-04 | -- | Pending |
| MNTZ-05 | -- | Pending |
| MNTZ-06 | -- | Pending |
| MNTZ-07 | -- | Pending |
| AUDP-01 | -- | Pending |
| AUDP-02 | -- | Pending |
| AUDP-03 | -- | Pending |
| AUDP-04 | -- | Pending |
| AUDP-05 | -- | Pending |
| TUTR-01 | -- | Pending |
| TUTR-02 | -- | Pending |
| TUTR-03 | -- | Pending |
| TUTR-04 | -- | Pending |
| TUTR-05 | -- | Pending |
| TUTR-06 | -- | Pending |
| RETN-01 | -- | Pending |
| RETN-02 | -- | Pending |
| RETN-03 | -- | Pending |
| INVT-01 | -- | Pending |
| INVT-02 | -- | Pending |
| INVT-03 | -- | Pending |

**Coverage:**
- v1 requirements: 96 total
- Mapped to phases: 0
- Unmapped: 96 (traceability populated during roadmap creation)

---
*Requirements defined: 2026-01-29*
*Last updated: 2026-01-29 after research synthesis*
