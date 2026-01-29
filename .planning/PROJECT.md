# WordRun!

## What This Is

WordRun! is a timed word puzzle mobile game where players solve chains of two-word phrases (compound words and common expressions) by filling in letters one at a time in a scrolling window. It combines word puzzle mechanics with RPG-style progression, obstacle/power-boost strategy, a momentum-based "surge" system that creates risk/reward tension, and a world map narrative that unfolds across nine Nations. Built in Godot for iOS and Android, targeting commercial release with in-app purchases and ad monetization.

## Core Value

The word-pair puzzle with the surge momentum system must feel like a "rush" — the tension between solving fast for multipliers and risking a bust, combined with obstacle anticipation, is the experience that makes WordRun! unique.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Core word-pair puzzle with scrolling window, letter-by-letter input, and auto-submit/advance
- [ ] Surge bar with threshold-based multipliers, imminent drain, and bust mechanic
- [ ] 3 obstacle types (Padlock, Random Blocks, Sand) with visual animations and mechanical effects
- [ ] 3 corresponding power boosts (Lock Key, Block Breaker, Bucket of Water)
- [ ] Power boosts usable for score bonus when no obstacle present
- [ ] On-screen keyboard input (default), with radial and scrambled tile modes as unlockable upgrades
- [ ] 25 lands across 3 Nations with level node paths on world map
- [ ] Boss levels with randomized challenge conditions, more words (up to 20), aggressive obstacles, and rewards
- [ ] Hearts, hints, and lives system with carry-over, recovery via rewarded ads, and cooldown penalty box
- [ ] Stars (non-premium currency): earned in gameplay, used as progression gates and spendable currency
- [ ] Diamonds (premium currency): earned through stellar gameplay, purchasable, used for premium items
- [ ] Store: power packs, upgrades, character skins, merch (coming soon placeholder)
- [ ] Inventory system: choose loadout before gameplay, switch between levels
- [ ] Required auth (magic email, OAuth, or email/password login)
- [ ] Name generator (silly, cool, heroic, whimsical, fun categories; no duplicates; no user-typed names)
- [ ] Ruut avatar introduction at onboarding; avatar walks world map and appears in gameplay
- [ ] Vs mode: turn-based with long word column, individual time clocks, skip-turn power boost
- [ ] Vs mode matchmaking (strangers by skill/level) and friend invites (link/code)
- [ ] Ads: interstitial and rewarded (AdMob integration + custom ad network with geo-targeting)
- [ ] Cloud/database storage for word data, level content, and player progress
- [ ] Login streaks with gifts (boosts and/or random lower-tier premium packs)
- [ ] In-game tutorials triggered when new mechanics are introduced
- [ ] Light narrative: themed word pools tied to story/land, NPC dialogue on world map
- [ ] 12 base words + 3 bonus words per standard level; bonus words gated by surge momentum

### Out of Scope

- Full cutscene system — deferred to post-launch; v1 uses themed word pools and NPC dialogue for narrative
- Nations 4-9 and their obstacle types (Ice, Charcoal, Acid, Flood, Acorn, Magnet) — future content updates
- Victory lap challenge levels (300 post-game levels) — post-main-game content
- Mini-game penalty box variant — v1 uses cooldown timer only
- Merch store fulfillment — v1 has placeholder/"coming soon"
- Shareable player personality insights — post-launch social feature
- Full 3,000-level content — v1 ships 25 lands worth; cloud backend enables seamless content expansion

## Context

### Game Design References
- Candy Crush (progression, obstacle economy)
- Wordscapes (radial input mode, word puzzles)
- Word Villas (world map structure, narrative)
- RPG elements (power boosts as abilities that grow, upgrades)

### Puzzle Content
- Word pairs are AI-generated from American English compound phrases and common two-word expressions
- Pool is validated to support 3,000+ levels with significant remaining capacity
- Words are curated per land to align with narrative themes and story context
- Content stored in cloud/database to keep app lightweight and enable OTA content updates

### Character Design
- Ruut (pronounced "root"): a rounded chibi-like onion-inspired character with a bulbous head, a sprout on top, and a glyph on its stomach
- Character already designed by the creator
- Boss NPCs are also Ruut-species characters that pantomime obstacle causation during boss levels

### Asset Pipeline
- AI-generated art pipeline: cartoon generation, 3D-style rendering, animation generation, sprite sheet extraction
- Goal: professional-quality visuals without traditional production costs
- Open to AI-assisted simplification for non-code elements (animations, stills, sprites)

### Surge Mechanic Detail
- Progressive drain: always draining to zero when not at zero
- Threshold segments change the point multiplier
- Past the final threshold: enters "imminent drain" (faster drain rate)
- If surge crosses back below the imminent threshold: unrecoverable bust — drains fully regardless of consecutive correct answers
- Strategic tension: go fast for high multipliers but risk busting (blackjack analogy)
- Bonus words (3 after the 12 base words) are gated by active momentum at word 12 and sustained momentum through the bonus round

### Obstacle Behavior (V1)
- **Padlock** (Nation 1): locks each letter of target word; word unavailable unless the word after it is solved. Counter: solve next word, or Lock Key power boost.
- **Random Blocks** (Nation 2): without warning, letterless wood grain blocks fill spaces; if whole word fills, it self-solves for zero points. Counter: each correct letter in place breaks the block, or Block Breaker power boost.
- **Sand** (Nation 3): fills 1 random space in 1-5 random words slowly; can make words unsolvable if spaces fully filled; trickles down on scroll. Counter: solve affected words quickly, or Bucket of Water power boost (max 3 words per use).

### Hearts / Hints / Lives System
- **Hearts**: in-level resource, count carries across levels until boss level or time-based recovery; rewarded ad recovers one heart; then cooldown penalty box
- **Hints**: replenish each level; when depleted, rewarded ad for one extra; then cooldown penalty box
- **Lives**: lost when all hearts lost; displayed on world map; rewarded ad recovery; then cooldown penalty box
- Penalty box: cooldown timer (no mini-game in v1)

### Monetization Model
- Stars: non-premium currency earned through gameplay challenges (time-based, boost-usage-based); used for progression gates and store purchases
- Diamonds: premium currency; discovered through stellar gameplay (tutorial triggered on first discovery); purchasable in large quantities; earned in smaller quantities through gameplay, world map promo challenges, and referral program (invitee reaches certain level)
- Store: power packs, upgrades (input modes), character skins, merch (coming soon)
- Ads: interstitial (between levels), rewarded (heart/hint/life recovery)
- Custom ad network: creator's own ads with geo-targeting (zip code level) capability

### Vs Mode Detail
- Turn-based: endless (or very long) word column in scrolling window
- Players alternate solving, each with their own time clock
- Power boost: ability to skip turn (gains time advantage)
- Match ends when a player's clock runs out
- Matchmaking: skill/level-based for strangers; invite codes/links for friends

### World Structure
- 9 Nations (each mapped to one obstacle type)
- Nations contain Lands
- Lands contain Levels (path of nodes on world map)
- Full game: 3,000 main levels + 300 victory lap levels
- Story traverses all 9 Nations to midpoint (1,500 levels), then returns through all 9 Nations
- V1: 25 lands spanning 3 Nations
- Obstacle template architecture: each obstacle shares a base system with configuration-driven behavior; new Nations primarily add new visuals/animations on top of repeatable mechanics

## Constraints

- **Engine**: Godot — already chosen, project initialized
- **Platform**: iOS and Android mobile — primary targets
- **Backend**: TBD (research will determine) — must support auth, cloud data, multiplayer, IAP
- **Content Delivery**: Cloud/database storage for word data and level content — keep app lightweight, enable OTA updates
- **Asset Production**: AI-generated pipeline for art, animation, sprites — professional quality, low production cost
- **Code Quality**: Professional, production-grade code — no shortcuts on the code itself despite AI-assisted assets
- **Obstacle Architecture**: Template-based system where new obstacles are primarily configuration + visuals, not new code paths

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Godot engine | Already initialized, suitable for 2D mobile games | -- Pending |
| V1 ships 25 lands / 3 Nations | Enough content to retain players while updates are prepared; prevents stalling | -- Pending |
| Padlock, Random Blocks, Sand as first 3 obstacles | Creator's chosen Nation order for the opening experience | -- Pending |
| Required auth (no guest mode) | Need accounts for progress sync, multiplayer, IAP, name generator integration | -- Pending |
| Name generator instead of typed names | Prevents obscene/inappropriate names without moderation overhead | -- Pending |
| Cloud-stored content | Lightweight app, OTA content updates, seamless expansion | -- Pending |
| AI-generated asset pipeline | Professional visuals without traditional production costs | -- Pending |
| Backend TBD | Research phase will evaluate Firebase, Supabase, custom, or other options | -- Pending |

---
*Last updated: 2026-01-29 after initialization*
