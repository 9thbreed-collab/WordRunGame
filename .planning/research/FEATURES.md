# Feature Landscape: Mobile Word Puzzle Games

**Domain:** Commercial mobile word puzzle game with progression mechanics
**Researched:** 2026-01-29
**Research mode:** Ecosystem (feature landscape survey)
**Source limitations:** WebSearch and WebFetch were unavailable during this research session. All findings are based on training data (through mid-2025). Confidence levels reflect this constraint. Competitive feature claims should be validated against current App Store/Play Store listings before finalizing requirements.

---

## Competitive Landscape Overview

WordRun! sits at the intersection of three established mobile game categories: word puzzles (Wordscapes, Word Cookies, CodyCross), map-based progression games (Candy Crush Saga, Word Villas, Homescapes), and obstacle/power-up economy games (Candy Crush, Toon Blast). The market is mature, well-monetized, and dominated by a handful of publishers (PeopleFun/IsCool, King, Playrix). Standing out requires either a genuinely novel core mechanic or a compelling combination of proven elements. WordRun!'s surge momentum system and word-pair chain mechanic are genuinely novel in this space.

### Key Competitors Analyzed

| Game | Publisher | Core Mechanic | Monthly Revenue (est.) | Key Differentiator |
|------|-----------|--------------|----------------------|-------------------|
| Wordscapes | PeopleFun | Crossword fill from radial letter wheel | $10M+ | Clean, addictive core loop |
| Word Cookies | BitMango | Swipe letters to form words | $3-5M | Simple, satisfying input |
| CodyCross | Fanatee | Themed crossword puzzles | $2-4M | Educational themes, group puzzles |
| Word Villas | Betta Games | Word puzzles + home decoration | $1-3M | Narrative + decoration meta |
| Word Connect | Zentertain | Connect letters to form words | $2-4M | Simplicity, casual appeal |
| Candy Crush Saga | King | Match-3 with obstacles | $100M+ | Best-in-class progression/monetization |

**Confidence:** MEDIUM -- revenue estimates are directional from training data, not verified current figures.

---

## Table Stakes Features

Features users expect in any commercial mobile word puzzle game released in 2025/2026. Missing any of these will result in user churn, poor reviews, or store rejection.

### TS-1: Core Puzzle Loop with Satisfying Input

| Aspect | Requirement | Complexity | WordRun! Status |
|--------|-------------|------------|-----------------|
| Responsive input | < 50ms tap-to-visual response | Medium | Planned (keyboard input) |
| Visual feedback | Letter placement animation, correct/incorrect states | Medium | Planned |
| Auto-advance | Move to next input target on correct answer | Low | Planned (auto-submit/advance) |
| Sound design | Tap sounds, success chimes, failure tones, combo sounds | Medium | Not explicitly mentioned |
| Haptic feedback | Vibration on correct/incorrect (iOS Taptic Engine, Android) | Low | Not explicitly mentioned |

**Notes:** Sound and haptics are often overlooked in planning but are critical for "game feel." The "rush" that WordRun! targets requires excellent audio-visual-haptic feedback. Wordscapes owes a significant portion of its addictiveness to its satisfying letter-snap sounds and subtle haptics.

**Dependency:** None -- this is the foundation everything else builds on.

### TS-2: Progressive Difficulty with Level Structure

| Aspect | Requirement | Complexity | WordRun! Status |
|--------|-------------|------------|-----------------|
| Numbered levels | Clear sense of progress (Level 1, 2, 3...) | Low | Planned (node paths on world map) |
| Difficulty curve | Gradual increase over hundreds of levels | High (content design) | Planned (3,000+ levels) |
| Level completion screen | Stars, score breakdown, share option | Medium | Partially planned |
| Replay option | Let players replay completed levels | Low | Not explicitly mentioned |
| Level count | 500+ levels minimum at launch for retention | High (content) | Planned (25 lands, likely 250-500+ levels) |

**Notes:** The planned 25 lands across 3 Nations for v1 is solid if each land has 15-20+ levels (375-500 total). Below 300 levels at launch, you risk players churning before monetization hooks engage. Candy Crush launched with ~65 levels but had rapid content updates. Wordscapes shipped with 6,000+. For a word-pair mechanic, content generation at scale is the bottleneck.

**Dependency:** Requires word-pair content pipeline (already planned via AI generation).

### TS-3: World Map / Progression Visualization

| Aspect | Requirement | Complexity | WordRun! Status |
|--------|-------------|------------|-----------------|
| Visual map | Scrollable path of level nodes | Medium | Planned (world map with nations/lands) |
| Current position indicator | Clear "you are here" on map | Low | Planned (Ruut avatar walks map) |
| Locked/unlocked states | Future levels visually locked | Low | Implied |
| Area theming | Visual variety across regions | High (art) | Planned (9 Nations with themes) |
| Progress gates | Currency or achievement gates between areas | Medium | Planned (stars as gates) |

**Notes:** WordRun!'s world map with Ruut walking between nodes is well above the minimum bar. Most word puzzle games use a simple scrolling path (Wordscapes). Word Villas adds a decoration meta-game on top. The planned Nations/Lands/Levels hierarchy is more ambitious than most competitors. The risk is that the map itself becomes a development bottleneck.

**Dependency:** Requires art assets per Nation/Land. Gated by asset pipeline.

### TS-4: Hint System

| Aspect | Requirement | Complexity | WordRun! Status |
|--------|-------------|------------|-----------------|
| Reveal a letter | Show one correct letter | Low | Planned (hints system) |
| Limited hints | Finite per level, replenish each level | Low | Planned |
| Earn more hints | Via rewarded ads or currency | Medium | Planned (rewarded ads + penalty box) |
| Purchase hints | IAP for hint packs | Low | Planned (store) |

**Notes:** Every major word puzzle game has hints. Wordscapes gives free hints through "bonus words" (words that fit the crossword but aren't required). This is a clever monetization-friendly mechanic. WordRun!'s hint system is standard and well-planned. The penalty box cooldown after rewarded ad recovery is a smart monetization pressure valve -- it forces players to either wait or pay.

**Dependency:** Requires IAP infrastructure and ad SDK integration.

### TS-5: Daily / Login Rewards

| Aspect | Requirement | Complexity | WordRun! Status |
|--------|-------------|------------|-----------------|
| Daily login bonus | Escalating rewards for consecutive days | Low-Medium | Planned (login streaks with gifts) |
| Daily challenge | Special puzzle each day | Medium | Not explicitly mentioned |
| Calendar display | Visual progress through reward cycle | Low | Not explicitly mentioned |
| Streak protection | Grace period or streak-save item | Low | Not explicitly mentioned |

**Notes:** Login streaks are planned. Daily challenges are a gap -- nearly all top word puzzle games have them (Wordscapes "Daily Puzzle," CodyCross daily themed puzzles). Daily challenges drive DAU (daily active users) and are a strong retention mechanic. Consider adding a daily puzzle variant.

**Dependency:** Requires server-side daily content or procedural generation.

### TS-6: Dual Currency System

| Aspect | Requirement | Complexity | WordRun! Status |
|--------|-------------|------------|-----------------|
| Soft currency (earned) | Earned through gameplay, spent on common items | Medium | Planned (Stars) |
| Hard currency (premium) | Purchasable, earned slowly, spent on premium items | Medium | Planned (Diamonds) |
| Currency display | Always visible, clear balance | Low | Implied |
| Currency earn rates | Balanced to encourage but not require purchase | High (balance design) | Needs tuning |
| Store with both currencies | Clear pricing in both currencies | Medium | Planned |

**Notes:** The Stars/Diamonds dual currency is industry standard and well-designed. The discovery mechanic for Diamonds (player finds them through stellar gameplay, triggering a tutorial) is a nice touch -- it contextualizes the premium currency within gameplay rather than pushing it as a store-first concept.

**Dependency:** Requires IAP infrastructure (App Store / Play Store billing), balance tuning, analytics.

### TS-7: Tutorial / Onboarding

| Aspect | Requirement | Complexity | WordRun! Status |
|--------|-------------|------------|-----------------|
| Interactive tutorial | Guided first few levels | Medium | Planned (in-game tutorials for new mechanics) |
| Progressive reveal | New mechanics introduced gradually | Low (design) | Planned (obstacles introduced per Nation) |
| Skip option | Let experienced players skip | Low | Not explicitly mentioned |
| Contextual help | Tooltips on first encounter | Low-Medium | Planned (tutorials trigger on new things) |

**Notes:** WordRun! has a more complex core mechanic than Wordscapes (word-pair chains vs simple crossword fill). The onboarding needs to teach: (1) word-pair concept, (2) scrolling window, (3) letter input, (4) surge bar, and (5) obstacles -- in that order, spread across many levels. Overloading the tutorial is a common pitfall. Candy Crush is the gold standard here: each mechanic introduced one at a time over 15-20 levels.

**Dependency:** Must be designed alongside level 1-20 content.

### TS-8: Settings and Quality-of-Life

| Aspect | Requirement | Complexity | WordRun! Status |
|--------|-------------|------------|-----------------|
| Sound/music toggle | On/off and volume | Low | Not explicitly mentioned |
| Notifications toggle | Push notification preferences | Low | Not explicitly mentioned |
| Account management | Link accounts, sign out | Medium | Planned (auth required) |
| Language/region | At minimum, language setting | Low | Not explicitly mentioned |
| Accessibility | Font size, colorblind mode, reduced motion | Medium | Not explicitly mentioned |

**Notes:** Accessibility is increasingly important for App Store featuring. Apple and Google both prioritize apps with accessibility features. Colorblind mode is particularly relevant for any game using color-coded feedback. At minimum, plan for Dynamic Type support (iOS) and adjustable text sizes.

**Dependency:** Independent, but should be architected early (not bolted on).

### TS-9: Cloud Save / Progress Sync

| Aspect | Requirement | Complexity | WordRun! Status |
|--------|-------------|------------|-----------------|
| Server-side progress | Player progress stored in cloud | High | Planned (cloud/database storage) |
| Cross-device sync | Play on phone, continue on tablet | Medium | Implied by required auth |
| Offline capability | Play without internet (sync when reconnected) | High | Not explicitly mentioned |
| Data recovery | Account recovery if device lost | Medium | Covered by required auth |

**Notes:** WordRun! requires auth (no guest mode), which automatically enables cloud save. The risk here is offline play -- many mobile word game sessions happen on commutes, flights, and areas with poor connectivity. If the game requires constant connectivity for word data (stored in cloud), this is a significant friction point. Consider caching a buffer of upcoming levels locally.

**Critical dependency:** Backend infrastructure. This blocks almost everything else.

### TS-10: Ads Integration (Interstitial + Rewarded)

| Aspect | Requirement | Complexity | WordRun! Status |
|--------|-------------|------------|-----------------|
| Interstitial ads | Between levels, not mid-gameplay | Medium | Planned (between levels) |
| Rewarded ads | Opt-in for hearts/hints/lives recovery | Medium | Planned |
| Ad frequency cap | Not too many interstitials (user backlash) | Low (config) | Not explicitly mentioned |
| Ad-free purchase option | One-time IAP to remove interstitials | Low | Not explicitly mentioned |
| Mediation | Multiple ad networks for fill rate | Medium | Planned (AdMob + custom network) |

**Notes:** The custom ad network with geo-targeting (zip code level) is ambitious. This is a differentiator, not table stakes. For v1, AdMob mediation alone is sufficient. The custom ad network is a significant engineering and sales effort that should be deferred. Rewarded ads tied to the penalty box cooldown system is a well-designed monetization loop.

**Dependency:** Requires AdMob SDK integration. Custom ad network is a separate project.

---

## Differentiators

Features that set WordRun! apart from competitors. Not expected by users, but create competitive advantage and can drive organic growth/retention.

### D-1: Surge Momentum System (CORE DIFFERENTIATOR)

| Aspect | Description | Complexity | Competitive Uniqueness |
|--------|-------------|------------|----------------------|
| Progressive drain | Surge bar always draining when not at zero | High | No direct competitor equivalent |
| Threshold multipliers | Higher surge = higher score multiplier | Medium | Unique to WordRun! |
| Imminent drain | Faster drain past final threshold | Medium | Unique -- creates blackjack tension |
| Bust mechanic | Cross back below imminent = unrecoverable bust | Medium | Unique risk/reward |
| Bonus word gating | Must maintain momentum to access bonus words | Medium | Novel content-access mechanic |

**Why this differentiates:** No major word puzzle game has a real-time momentum/risk system. Wordscapes is untimed and stress-free. Word Cookies is relaxed. CodyCross is leisurely. WordRun!'s surge system adds an adrenaline/tension layer that is completely absent from the word puzzle genre. This is the game's identity. The "rush" feeling comes from this system.

**Risk:** The casual word puzzle audience (40+ year old women, per industry data) may find time pressure stressful rather than thrilling. WordRun! may attract a different demographic than traditional word games -- younger, more competitive, action-oriented players. This is not necessarily bad, but it shapes marketing and retention strategy.

**Complexity:** HIGH. The surge system is the most mechanically complex feature and the hardest to tune. Too aggressive = frustrating. Too lenient = no tension. Requires extensive playtesting.

**Dependency:** Core mechanic. Must be in v1. Everything else (obstacles, scoring, boss levels) builds on this.

### D-2: Word-Pair Chain Puzzle Mechanic

| Aspect | Description | Complexity | Competitive Uniqueness |
|--------|-------------|------------|----------------------|
| Compound phrase chains | Each word pairs with the previous (car>door, door>stop) | Low (mechanic), High (content) | Unique puzzle format |
| Scrolling window | 4-5 words visible at once, scrolling up | Medium | Distinctive visual presentation |
| First-letter visible | Only first letter shown, spaces for rest | Low | Similar to some games |
| Bonus words | 3 extra words gated by momentum | Medium | Unique gating mechanism |

**Why this differentiates:** The word-pair chain is a genuinely novel puzzle format. Most word games use crosswords (Wordscapes), word search (Word Connect), or themed clue-based puzzles (CodyCross). The chaining mechanic adds a lateral-thinking element that is fresh. Players must think about two-word phrases, not just individual words.

**Risk:** The content pipeline is the constraint. You need thousands of valid word-pair chains that are solvable, fun, and appropriately difficult. The AI generation pipeline for this content is critical infrastructure.

**Dependency:** Content pipeline. Must validate at scale before committing to launch-level quantities.

### D-3: Obstacle/Power-Boost Economy

| Aspect | Description | Complexity | Competitive Uniqueness |
|--------|-------------|------------|----------------------|
| 9 obstacle types | Each with unique visual + mechanical effect | Very High | More variety than most competitors |
| Corresponding counter boosts | 1:1 mapping of obstacle to power boost | High | Clear strategic choice |
| Score bonus on unused boost | Boosts have value even without obstacles | Medium | Adds strategic depth |
| Obstacle anticipation | Not knowing when obstacles drop | Medium | Tension mechanic |

**Why this differentiates:** Candy Crush has a mature obstacle economy (blockers, bombs, locked pieces). Word puzzle games have much simpler obstruction -- Wordscapes has none; CodyCross has none. WordRun! imports the Candy Crush obstruction/power-up meta-game into a word puzzle context, which is genuinely novel for the genre.

**Risk:** 9 obstacle types is massive scope. V1 wisely limits to 3 (Padlock, Random Blocks, Sand). The template architecture (configuration-driven behavior) is essential for scaling this without code explosion.

**Complexity:** HIGH for full 9, MEDIUM for v1's 3. The visual animations per obstacle are the bottleneck.

**Dependency:** Requires template architecture, animation system, visual assets per obstacle type.

### D-4: Vs Mode (Turn-Based Multiplayer)

| Aspect | Description | Complexity | Competitive Uniqueness |
|--------|-------------|------------|----------------------|
| Turn-based word solving | Alternate solving from shared word column | Very High | Rare in word puzzle games |
| Individual time clocks | Chess-clock style pressure | High | Novel for genre |
| Matchmaking | Skill/level-based stranger matching | Very High | Requires backend infrastructure |
| Friend invites | Link/code-based friend challenges | High | Common but expected for multiplayer |
| Skip-turn power boost | Strategic time advantage play | Medium | Unique tactical element |

**Why this differentiates:** Multiplayer in word games is rare. Scrabble GO and Words With Friends are the only major players with real-time/turn-based PvP, and they are fundamentally different games (board-based). A competitive speed-based word puzzle PvP mode would be unique in the scrolling puzzle genre.

**Risk:** Multiplayer is the single highest-complexity feature on this list. Matchmaking alone requires significant backend infrastructure, anti-cheat considerations, and a minimum viable player base to function. If the player base is small at launch, matchmaking queues will be empty, creating a dead-feature perception.

**Recommendation:** Defer Vs Mode to post-launch update. Focus v1 on single-player excellence. Add Vs Mode when you have a proven player base. This is the pattern Wordscapes and Word Cookies followed -- they added competitive/social features after establishing single-player retention.

**Complexity:** VERY HIGH. This is effectively a separate game mode requiring its own backend, matchmaking, anti-cheat, and UI.

**Dependency:** Backend infrastructure, authentication system, minimum player base.

### D-5: Character/Avatar System (Ruut)

| Aspect | Description | Complexity | Competitive Uniqueness |
|--------|-------------|------------|----------------------|
| Named character | Ruut as guide/companion | Medium (art) | Uncommon in word games |
| Map walking | Ruut walks between level nodes | Medium (animation) | Adds personality to progression |
| Character skins | Purchasable/earnable cosmetics | Medium | Monetization + self-expression |
| Boss NPC characters | Ruut-species antagonists during boss levels | High (art + design) | Novel for genre |

**Why this differentiates:** Word puzzle games rarely have characters. Wordscapes has nature themes. CodyCross has a small alien avatar. Word Villas has a narrative protagonist. Having Ruut as a consistent companion character with purchasable skins adds emotional investment and cosmetic monetization potential that most word games lack.

**Complexity:** MEDIUM for base implementation, HIGH for skin variety and boss NPCs.

**Dependency:** Art pipeline (AI-generated), animation system.

### D-6: Inventory/Loadout System

| Aspect | Description | Complexity | Competitive Uniqueness |
|--------|-------------|------------|----------------------|
| Pre-level loadout | Choose which boosts to bring | Medium | Not seen in word puzzle games |
| Between-level switching | Swap loadout between levels | Low | Adds strategic layer |
| Inventory management | View all owned boosts/items | Medium | RPG-like depth |

**Why this differentiates:** No major word puzzle game has a pre-level inventory/loadout screen. This is borrowed from RPG/strategy games and adds a preparatory strategic layer. Players must decide which obstacles they expect and equip accordingly.

**Risk:** Casual players may find loadout management confusing or tedious. Consider auto-equip defaults with manual override for players who want depth.

**Complexity:** MEDIUM. UI-heavy but mechanically straightforward.

**Dependency:** Obstacle system, store/purchase system.

### D-7: Input Mode Upgrades

| Aspect | Description | Complexity | Competitive Uniqueness |
|--------|-------------|------------|----------------------|
| Default keyboard | Standard on-screen keyboard | Medium | Baseline input |
| Radial mode | Wordscapes-style radial letter selection | High | Familiar to word game players |
| Scrambled tiles | Scrabble-like tile arrangement | High | Alternative input feel |
| Unlockable/purchasable | Modes are upgrades in the store | Low | Monetization of input preference |

**Why this differentiates:** Making input mode itself an upgrade is novel. No competitor monetizes input method. This is clever because it gives players a reason to spend currency on something that genuinely changes gameplay feel, not just cosmetics.

**Risk:** If the default keyboard input feels bad, players will churn before unlocking alternatives. The default input MUST feel excellent on its own.

**Complexity:** HIGH. Each input mode is essentially a separate input system with its own UX design, animations, and edge cases.

**Dependency:** Core puzzle system must support swappable input methods architecturally.

### D-8: Boss Levels

| Aspect | Description | Complexity | Competitive Uniqueness |
|--------|-------------|------------|----------------------|
| Randomized conditions | Different challenge each attempt | High | Uncommon in puzzle games |
| More words (up to 20) | Extended challenge | Medium (content) | Longer engagement per level |
| Aggressive obstacles | Higher frequency/intensity | Medium | Difficulty spike at milestones |
| Special rewards | Premium rewards for boss completion | Low | Expected for boss content |
| NPC antagonist | Ruut-species boss character | High (art) | Character-driven challenge |

**Why this differentiates:** Candy Crush has "hard levels" but no explicit boss encounters. Adding named boss characters with randomized challenge conditions brings RPG flavor into word puzzles. This is genuinely novel for the genre.

**Complexity:** HIGH. Randomized conditions require extensive testing for fairness/solvability.

**Dependency:** Obstacle system, Ruut character system, word content pipeline (longer word chains).

### D-9: Light Narrative / Themed Content

| Aspect | Description | Complexity | Competitive Uniqueness |
|--------|-------------|------------|----------------------|
| Themed word pools | Words tied to story/land context | Medium (content curation) | CodyCross does this; uncommon otherwise |
| NPC dialogue | Characters on world map with dialogue | Medium | Word Villas has narrative; rare for word puzzles |
| Environmental storytelling | Land visual design tells story | High (art) | Ambitious for genre |

**Why this differentiates:** Most word puzzle games are theme-free (Wordscapes) or lightly themed (CodyCross categories). A progressive narrative revealed through word choices, environment design, and NPC dialogue is ambitious and distinctive. Word Villas proved that narrative can work in word games (decoration as narrative reward).

**Risk:** Narrative is expensive to produce and easy to do poorly. If the narrative feels tacked on, it hurts rather than helps. V1 wisely defers full cutscenes and focuses on themed word pools + NPC dialogue, which is the right scope.

**Complexity:** MEDIUM for v1 scope (themed words + NPC text), HIGH for full vision.

**Dependency:** Content pipeline, art pipeline, writing/narrative design.

### D-10: Custom Ad Network with Geo-Targeting

| Aspect | Description | Complexity | Competitive Uniqueness |
|--------|-------------|------------|----------------------|
| Own ad placements | Sell ad slots directly | Very High | Very few indie games do this |
| Zip-code targeting | Hyperlocal ad targeting | Very High | Typically requires ad tech platform |
| Revenue bypass | Skip ad network revenue share | Medium (business) | Higher margins if executed |

**Why this differentiates:** This is a business model differentiator, not a player-facing feature. If successful, it provides higher ad revenue margins than AdMob alone.

**Recommendation:** Defer entirely to post-launch. This is a business development and ad tech project, not a game feature. Ship with AdMob only. Revisit when you have user numbers that make direct ad sales viable (typically 100K+ DAU).

**Complexity:** VERY HIGH. This is essentially building a mini ad tech platform.

**Dependency:** Significant user base, sales team or self-serve ad platform.

---

## Anti-Features

Features to deliberately NOT build. Common in the genre but harmful to WordRun!'s positioning, user experience, or development timeline.

### AF-1: Energy/Lives System That Blocks All Play

**What it is:** Many F2P games (Candy Crush, Homescapes) completely block gameplay when lives/energy run out. Player must wait, watch an ad, or pay.

**Why to avoid for WordRun!:** WordRun!'s planned hearts/hints/lives system with the rewarded ad + penalty box cooldown is already walking a fine line. The key is that some gameplay avenue should remain available even when the primary resource is depleted. If a player opens your game and literally cannot play, they are one tap away from uninstalling.

**What to do instead:** WordRun!'s penalty box with cooldown is the right approach -- it creates friction without a hard block. Consider also: let players replay completed levels for reduced/no rewards while waiting for recovery. This keeps them in the game.

**Confidence:** HIGH -- this is a well-documented retention principle in mobile game design.

### AF-2: Forced Social Mechanics / Facebook Login Required

**What it is:** Some games require Facebook login for features, spam friend requests, or gate progression behind "ask a friend for help."

**Why to avoid:** Facebook login is declining in relevance (especially among younger demographics). Forced social sharing annoys users and generates negative reviews. WordRun!'s referral system (share to earn diamonds when invitee reaches a level) is the RIGHT approach -- it rewards sharing without requiring it.

**What to do instead:** Keep social features opt-in. Referral rewards, shareable scores/achievements, friend invites for Vs mode -- all good because they are voluntary. Never gate single-player progression behind social actions.

**Confidence:** HIGH -- this is a known anti-pattern with extensive negative review data.

### AF-3: Pay-to-Win Power Boosts

**What it is:** Selling power boosts so powerful that paying players trivialize all content while free players hit frustration walls.

**Why to avoid:** Pay-to-win destroys the core game feel. If the "rush" of WordRun! can be bypassed by buying your way through every obstacle, the game's core value proposition dies. Paying should provide convenience, not victory.

**What to do instead:** WordRun!'s design where boosts counter obstacles is good. The balance point: obstacles should be solvable without boosts (just harder), and boosts should help but not guarantee success. The score-bonus-for-unused-boost mechanic is well-designed -- it rewards skill (not needing the boost) while giving a use case for purchased items.

**Confidence:** HIGH -- fundamental F2P design principle.

### AF-4: Excessive Interstitial Ad Frequency

**What it is:** Showing interstitial ads after every single level, or worse, mid-level.

**Why to avoid:** Ad fatigue is the #1 driver of negative reviews in F2P mobile games. "Too many ads" appears in reviews of virtually every word puzzle game with aggressive ad placement. It also decreases eCPM (effective cost per mille) over time as users develop "ad blindness."

**What to do instead:** Cap interstitials at every 3-5 levels. Never show ads mid-gameplay (this would destroy the surge momentum flow). Offer an ad-free IAP option ($4.99-$9.99 one-time purchase to remove interstitials). Players who pay to remove ads have proven to have higher LTV (lifetime value) overall.

**Confidence:** HIGH -- consistent across mobile game industry data.

### AF-5: Typed User Names / User-Generated Content

**What it is:** Letting users type their own names, messages, or any free-text content.

**Why to avoid:** Moderation at scale is expensive and error-prone. Inappropriate names, hate speech, and predatory behavior are guaranteed in any system with typed input. WordRun!'s name generator (silly, cool, heroic, whimsical, fun categories; no duplicates; no user-typed names) is the exactly correct approach.

**What to do instead:** Already planned correctly. Name generator with curated categories. No free-text chat in Vs mode -- use preset emojis/phrases if any communication is needed (Clash Royale model).

**Confidence:** HIGH -- established best practice for games targeting broad audiences including minors.

### AF-6: Loot Boxes / Randomized Premium Purchases

**What it is:** Selling randomized packs where the player doesn't know what they'll get before purchasing.

**Why to avoid:** Loot boxes face increasing regulatory scrutiny (Belgium banned them, UK/EU considering regulations, Apple requires probability disclosure). They also generate significant negative press. For a word puzzle game, the optics are especially bad -- the audience expects a relaxing/fun experience, not gambling mechanics.

**What to do instead:** Sell specific, known items. Power packs with listed contents. Character skins that are shown before purchase. The login streak gifts with "random lower-tier premium packs" should show pack contents before claiming, or frame them as "mystery gifts" (free) rather than purchasable random packs.

**Confidence:** HIGH -- regulatory trend is clear and ongoing.

### AF-7: Overly Complex Onboarding

**What it is:** Front-loading the tutorial with all mechanics at once. Teaching surge, obstacles, boosts, inventory, currencies, and world map in the first 5 minutes.

**Why to avoid:** Cognitive overload causes immediate churn. Mobile game players expect to be playing within 30 seconds of first launch. WordRun! has more mechanics than a typical word puzzle game (surge, obstacles, boosts, inventory, two currencies, world map, boss levels). Teaching all of these early would be overwhelming.

**What to do instead:** Phased introduction over 30-50 levels:
- Levels 1-3: Core word-pair mechanic only (no surge, no obstacles, no timer pressure)
- Levels 4-8: Introduce surge bar (show it, explain thresholds)
- Levels 9-15: First obstacle type (Padlock) with tutorial
- Levels 16-20: Introduce power boosts and inventory
- Levels 21-25: Stars, hints system
- Level 26+: Boss level introduction, more complexity

**Confidence:** HIGH -- phased onboarding is the gold standard (Candy Crush, Clash Royale).

### AF-8: Real-Money PvP / Competitive Wagering

**What it is:** Allowing players to bet real money or premium currency on Vs mode matches.

**Why to avoid:** Gambling regulations, age-rating issues, predatory design concerns. Even betting premium currency creates problematic incentive structures. This turns a word puzzle game into a gambling platform in the eyes of regulators.

**What to do instead:** Vs mode rewards should be fixed (win = X stars/diamonds, lose = consolation reward). Leaderboards and rankings provide competitive motivation without financial stakes.

**Confidence:** HIGH -- regulatory and ethical best practice.

### AF-9: Subscription Model as Primary Monetization

**What it is:** Requiring a monthly subscription to access core features or removing ads.

**Why to avoid:** Subscription fatigue is real. Word puzzle game audiences resist subscriptions more than other categories. Wordscapes tried "Wordscapes Pro" with limited success. The dual currency + IAP + ads model is more appropriate for this genre.

**What to do instead:** IAP for currencies and specific items. One-time ad-removal purchase. If subscription is offered, make it a "VIP pass" with daily diamonds + ad-free + bonus daily rewards, NOT a gate on core gameplay.

**Confidence:** MEDIUM -- subscription models are evolving, but word puzzle genre data supports IAP > subscription.

---

## Feature Dependencies

```
FOUNDATION LAYER (must build first)
  Core Puzzle Engine (word pairs, scrolling window, letter input)
    |
    +-- Surge Momentum System
    |     |
    |     +-- Bonus Word Gating
    |     +-- Boss Level Conditions
    |
    +-- Obstacle System (template architecture)
    |     |
    |     +-- Power Boost System
    |     |     |
    |     |     +-- Inventory/Loadout System
    |     |     +-- Store (boost purchasing)
    |     |
    |     +-- Boss Levels (aggressive obstacles)
    |
    +-- Input System (keyboard default)
          |
          +-- Radial Mode (upgrade)
          +-- Scrambled Tiles (upgrade)

PROGRESSION LAYER (builds on foundation)
  World Map
    |
    +-- Level Node Paths
    |     |
    |     +-- Ruut Avatar Walking
    |     +-- NPC Dialogue Points
    |
    +-- Nation/Land Theming
    |     |
    |     +-- Themed Word Pools
    |
    +-- Progress Gates (stars)

ECONOMY LAYER (builds on progression)
  Dual Currency System (Stars + Diamonds)
    |
    +-- Store
    |     |
    |     +-- Power Packs
    |     +-- Upgrades (input modes)
    |     +-- Character Skins
    |
    +-- IAP Integration (App Store / Play Store billing)
    |
    +-- Ad Integration (AdMob)
          |
          +-- Interstitial (between levels)
          +-- Rewarded (hearts/hints/lives recovery)

RETENTION LAYER (builds on economy)
  Hearts/Hints/Lives System
    |
    +-- Rewarded Ad Recovery
    +-- Penalty Box Cooldown

  Login Streaks
  Daily Rewards
  Tutorial System (progressive)

SOCIAL LAYER (builds on everything above)
  Authentication (required)
    |
    +-- Name Generator
    +-- Cloud Save / Progress Sync
    +-- Referral System
    +-- Vs Mode (deferred recommendation)
          |
          +-- Matchmaking
          +-- Friend Invites
          +-- Turn-Based Engine
```

---

## MVP Feature Recommendation

For a commercially viable v1 launch, prioritize in this order:

### Must Have for Launch (Blocks release if missing)

1. **Core word-pair puzzle** with scrolling window, letter-by-letter keyboard input, auto-advance
2. **Surge momentum system** with thresholds, imminent drain, bust mechanic
3. **3 obstacle types** (Padlock, Random Blocks, Sand) with counter power boosts
4. **World map** with level node paths (at least Nation 1 fully themed, Nations 2-3 can be simpler)
5. **Dual currency** (Stars + Diamonds) with basic store
6. **Hints system** with rewarded ad recovery
7. **Hearts/lives system** with rewarded ad recovery and penalty box
8. **AdMob integration** (interstitial + rewarded)
9. **IAP integration** (diamond packs, power packs)
10. **Cloud save** via authentication (magic link or OAuth -- skip email/password for v1)
11. **Sound design** (tap sounds, success/failure audio, surge tension audio)
12. **Tutorial** (phased over first 20+ levels)
13. **250+ levels** of word-pair content (minimum viable content depth)
14. **Name generator** (for safe profiles)

### Should Have for Launch (Strong improvement but not blocking)

15. **Boss levels** (at least at end of each Land)
16. **Inventory/loadout system** (pre-level boost selection)
17. **Login streaks** with daily rewards
18. **Ruut avatar** walking world map + onboarding introduction
19. **Level completion screen** with score breakdown and share button
20. **Settings** (sound toggle, account management)

### Defer to Post-Launch (High complexity, lower launch priority)

21. **Vs Mode** -- Defer until player base is established (matchmaking needs players)
22. **Radial and Scrambled Tile input modes** -- Ship with keyboard only, add modes as updates
23. **Character skins** -- Ship Ruut base skin, add cosmetics as monetization update
24. **Custom ad network** -- Ship with AdMob only, build custom network when DAU justifies it
25. **NPC dialogue / narrative** -- Ship with themed word pools only, add dialogue in updates
26. **Referral system** -- Add when you have enough players for viral mechanics to work
27. **Daily challenges** -- Add as a retention update after analyzing D1/D7/D30 retention data
28. **Accessibility features** -- Important but can follow initial launch

---

## Monetization Feature Analysis

### Revenue Stream Comparison (Genre Benchmarks)

| Revenue Stream | % of Revenue (genre avg) | WordRun! Implementation | Notes |
|---------------|------------------------|------------------------|-------|
| IAP (currencies) | 50-65% | Diamonds (premium) | Primary revenue driver |
| IAP (specific items) | 10-15% | Power packs, upgrades | Secondary driver |
| Interstitial ads | 10-20% | AdMob between levels | Steady baseline revenue |
| Rewarded ads | 5-15% | Hearts/hints/lives recovery | High engagement, lower CPM |
| Subscription | 0-10% | Not planned (correct) | Low fit for genre |
| Cosmetics | 5-10% | Character skins | Growing segment |

**Confidence:** MEDIUM -- percentages are directional from training data on F2P word game monetization.

### Monetization Pressure Points (Where Players Feel Compelled to Spend)

| Pressure Point | Mechanism | Ethical Rating | WordRun! Feature |
|---------------|-----------|---------------|-----------------|
| Stuck on level | Difficulty spike | Acceptable | Hints, power boosts |
| Out of lives | Can't play | Borderline | Hearts/lives with penalty box |
| Want to skip wait | Time gate | Acceptable | Penalty box bypass with diamonds |
| Want better score | Competitive drive | Good | Power boosts for score bonus |
| Want cosmetics | Self-expression | Good | Ruut skins |
| Want competitive edge | PvP advantage | Caution | Vs mode boosts (keep fair) |

### Key Monetization Recommendations

1. **First purchase trigger:** Make the first diamond purchase extremely affordable ($0.99 for a starter pack with outsized value). Converting a free player to a paying player is the hardest step; once they've paid once, they're 10x more likely to pay again.

2. **Battle pass consideration:** Many mobile games have shifted to season/battle pass models (free tier + premium tier with daily/weekly challenges and rewards). This could replace or supplement login streaks and provide predictable recurring revenue. Consider for a post-launch update.

3. **No-ads IAP:** Offer a one-time $4.99-$6.99 purchase to remove interstitial ads permanently. This is expected by players and generates meaningful revenue from players who hate ads but don't mind spending a little.

4. **Spending ceiling awareness:** Design currency packages so the maximum reasonable spend is clear. Word puzzle game players are not whales in the same way gacha game players are. Median spend in word puzzle games is $5-15 over lifetime. Top spenders might reach $50-100. Design IAP tiers accordingly.

---

## WordRun! Feature Alignment Score

How well do WordRun!'s planned features align with market expectations?

| Category | Alignment | Notes |
|----------|-----------|-------|
| Core puzzle mechanic | STRONG | Novel and differentiated. No direct competitor. |
| Progression system | STRONG | World map with nations/lands exceeds genre standard. |
| Monetization model | STRONG | Dual currency + IAP + ads is genre-appropriate. |
| Obstacle/boost economy | STRONG | Borrows Candy Crush model, novel for word games. |
| Tutorial/onboarding | NEEDS ATTENTION | More complex than genre average; phasing plan needed. |
| Sound/haptics | GAP | Not mentioned in planning docs; critical for "rush" feel. |
| Social features | AMBITIOUS | Vs mode is high-risk, high-reward. Defer to post-launch. |
| Accessibility | GAP | Not mentioned; increasingly important for store featuring. |
| Offline play | GAP | Cloud-dependent content delivery may block offline play. |
| Daily content | GAP | No daily challenge/puzzle mentioned; strong retention driver. |
| Content depth | NEEDS ATTENTION | 25 lands needs to translate to 250+ levels minimum. |
| Custom ad network | OVER-SCOPED for v1 | Defer entirely to post-launch. Ship with AdMob only. |

---

## Competitor Feature Matrix

| Feature | Wordscapes | Word Cookies | CodyCross | Word Villas | Candy Crush | WordRun! (planned) |
|---------|-----------|--------------|-----------|-------------|-------------|-------------------|
| Core puzzle type | Crossword fill | Swipe to form | Themed crossword | Word puzzle | Match-3 | Word-pair chains |
| Input method | Radial wheel | Swipe pan | Keyboard | Keyboard | Tap/swipe | Keyboard (+ upgrades) |
| Timer/pressure | No | No | No | No | Move limit | Yes (surge system) |
| Obstacles | None | None | None | None | Yes (many) | Yes (9 types, 3 for v1) |
| Power-ups | Hint, shuffle | Hint | Hint, reveal | Hint, tools | Many (hammer, etc.) | 9 counter-boosts + score bonus |
| World map | Simple path | Simple path | Themed worlds | Yes (decoration) | Scrolling path | Nations > Lands > Levels |
| Character | None | None | Alien mascot | Protagonist | None (candy) | Ruut avatar + skins |
| Narrative | None | None | Theme descriptions | Decoration story | None | Light (themed words + NPC) |
| PvP/Multiplayer | Tournament | None | None | None | Limited | Vs mode (turn-based) |
| Dual currency | Yes | Yes | Yes | Yes | Yes | Yes (Stars + Diamonds) |
| Lives system | No | No | No | Yes | Yes (5 lives) | Yes (hearts + lives) |
| Daily challenge | Yes | Yes | Yes | Yes | Yes | Not planned (recommended) |
| Login streaks | Yes | Yes | Yes | Yes | Yes | Yes |
| Ads (rewarded) | Yes | Yes | Yes | Yes | No | Yes |
| Ads (interstitial) | Yes | Yes | Yes | Yes | No | Yes |
| IAP | Yes | Yes | Yes | Yes | Yes | Yes |
| Boss levels | No | No | No | No | No (hard levels) | Yes |
| Inventory/loadout | No | No | No | No | No | Yes |

---

## Open Questions for Validation

These items could not be verified with current tools and should be validated before finalizing requirements:

1. **Current market size and trends for word puzzle games (2025-2026):** Is the category growing, stable, or declining? My training data suggests stable with slight growth, but recent trends may differ.

2. **Wordscapes/Word Cookies current feature sets:** These games update frequently. Verify current features against what is described above.

3. **Apple/Google current policies on loot boxes and gacha mechanics:** Regulatory landscape is evolving. Verify current requirements before designing any randomized purchase mechanics.

4. **AdMob current eCPM rates for word puzzle games by geo:** Revenue projections depend on current ad rates, which fluctuate.

5. **Godot mobile game performance benchmarks:** Verify that Godot can deliver the < 50ms input response time needed for the "rush" feel, especially on lower-end Android devices.

6. **Competitor daily challenge implementations:** Verify current state of daily puzzles across competitors to ensure WordRun!'s approach (if added) is differentiated.

---

## Sources

All findings in this document are based on training data (through mid-2025) covering:
- Mobile game design best practices (GDC talks, Gamasutra/Game Developer articles, Deconstructor of Fun analyses)
- App Store / Play Store feature analysis of top word puzzle games
- F2P monetization literature (including works by Will Luton, Ethan Levy)
- Candy Crush, Wordscapes, CodyCross, Word Villas gameplay analysis
- Mobile game industry reports (Sensor Tower, data.ai/App Annie, Newzoo)
- Apple and Google developer guidelines for IAP and ad integration

**Overall confidence:** MEDIUM -- findings are well-grounded in training data but could not be verified against current (2026) sources due to tool limitations. Core principles (table stakes, anti-features, monetization patterns) are stable and unlikely to have changed significantly. Specific competitor features may have evolved.
