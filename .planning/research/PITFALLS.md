# Domain Pitfalls: WordRun!

**Domain:** Commercial mobile word puzzle game (Godot, iOS/Android)
**Researched:** 2026-01-29
**Overall confidence:** MEDIUM (web research tools unavailable; findings based on deep domain knowledge through mid-2025 -- Godot mobile, F2P economy design, word game content, and mobile publishing are mature domains where core pitfalls are stable year-over-year; Godot-specific version details should be re-verified against current 4.5 docs before implementation)

---

## Critical Pitfalls

Mistakes that cause rewrites, failed launches, or app store rejection. Each of these can set the project back weeks or months.

---

### C1: Godot Mobile Export Pipeline Blindsides

**What goes wrong:** Developers build the entire game on desktop, then discover the mobile export pipeline has requirements they never accounted for. Godot's iOS export requires a Mac with Xcode, valid Apple Developer account with provisioning profiles and certificates, and specific project settings (bundle identifier, version strings, capability entitlements for IAP, push notifications, etc.). Android export requires a signed APK/AAB with a release keystore. These are not "plug and play" -- they require manual configuration that is poorly documented for first-timers and frequently breaks between Godot minor versions.

**Why it happens:** Godot's export templates are separate downloads. The mobile export docs assume familiarity with native mobile development toolchains (Xcode, Android SDK/NDK). Developers who have never shipped a native mobile app don't know what they don't know until the export step.

**Consequences:**
- App store rejection for missing entitlements, wrong icon sizes, missing privacy manifests (Apple now requires these)
- Weeks lost debugging signing, provisioning, and export template issues
- Discovery that certain GDExtensions or plugins don't compile for the target platform
- AAB (Android App Bundle) vs APK confusion -- Google Play now requires AAB

**Prevention:**
1. Export to both iOS and Android in the FIRST week of development, before any game code exists -- even if it's just the default Godot splash screen. Validate the full pipeline: export, sign, install on physical device, submit to TestFlight/Play Console internal track.
2. Set up the Apple Developer account, provisioning profiles, and Google Play Console EARLY. These have approval delays (Apple developer enrollment can take days).
3. Keep a "mobile export checklist" document and run through it monthly during development.
4. Store the Android release keystore securely with backups -- losing it means you cannot update the app on Google Play. Ever.
5. For Godot 4.5: verify that the GL Compatibility renderer (which is already configured in `project.godot`) is the correct choice for mobile. It is -- the Vulkan Forward+ and Mobile renderers have higher hardware requirements and more compatibility issues on low-end devices.

**Warning signs:** No physical device testing in the first month. "We'll deal with export later." Android keystore stored in a single location.

**Detection:** Ask "Can you show me a build running on a physical phone right now?" at any point during development.

**Phase mapping:** Phase 1 (Project Foundation). Must be validated before any gameplay code is written.

**Severity:** CRITICAL -- discovering export issues late can delay launch by weeks. Losing the keystore is unrecoverable.

**Confidence:** HIGH -- these are well-documented, stable issues.

---

### C2: Touch Input Feels Wrong and Nobody Noticed Until Late

**What goes wrong:** The game is developed and tested primarily with mouse/keyboard. Touch input on actual mobile devices has different characteristics: imprecise taps (finger size vs pixel precision), no hover state, different scroll/swipe physics, virtual keyboard interaction, multi-touch conflicts. A letter-by-letter word puzzle with an on-screen keyboard is an input-heavy experience. If touch responsiveness feels even slightly laggy or imprecise, the "rush" feeling of the surge mechanic is destroyed.

**Why it happens:** Desktop testing is comfortable and fast. Godot's `InputEvent` system abstracts mouse and touch, making developers think "it just works." But touch events have platform-specific quirks: iOS and Android handle touch differently, virtual keyboards behave differently, and the Godot `Control` node touch handling has known edge cases with overlapping clickable areas.

**Consequences:**
- The core "rush" experience (solving fast, maintaining surge) feels sluggish on mobile
- Players mis-tap letters constantly due to button sizing
- Virtual keyboard conflicts with game's custom keyboard UI (system keyboard pops up unexpectedly, or game keyboard gets covered by system elements)
- Scrolling the word window conflicts with letter input taps
- On-screen keyboard buttons too small for adult thumbs on smaller phones (iPhone SE, budget Android)

**Prevention:**
1. Design ALL input from a touch-first perspective. Minimum touch target: 44x44 points (Apple HIG) or 48x48dp (Material Design). For a fast-paced word game, go larger: 52-56dp per key.
2. Test on physical devices from Day 1 of input implementation. Absolute minimum: one iOS device, one Android device, one small-screen device, one large-screen device.
3. Disable the system virtual keyboard explicitly. Since WordRun uses a custom on-screen keyboard, the system keyboard should never appear. In Godot, this means not using `LineEdit` or `TextEdit` nodes for input -- use custom `Button`-based or `TouchScreenButton`-based input instead.
4. Implement touch feedback: visual press states, haptic feedback (short vibration), and audio taps. Missing feedback makes touch feel "dead."
5. Handle the scrolling word window with gesture detection that distinguishes between "tap to select" and "swipe to scroll." This is a common source of input conflicts.
6. Test with "sausage fingers" -- have someone with large hands test on a small phone.

**Warning signs:** "We test on desktop but it should work the same on mobile." No physical device in the developer's hands. Button sizes defined in pixels without density-independent units.

**Phase mapping:** Phase 2 (Core Puzzle Mechanics). Must be validated before surge and obstacle systems are built on top.

**Severity:** CRITICAL -- if touch input feels wrong, the entire gameplay loop fails. Fixing it late requires reworking the UI layer.

**Confidence:** HIGH -- touch input issues are the #1 complaint in mobile game post-mortems.

---

### C3: Word Pair Validation Gaps Ship Embarrassing or Broken Content

**What goes wrong:** AI-generated word pairs (compound phrases like "car door", "door stop") include entries that are: not real phrases ("moon table"), offensive combinations ("crack head" as a word pair could be problematic), culturally insensitive, or have ambiguous validity that makes players feel the game is wrong. Since content is cloud-stored and loaded dynamically, a bad batch can affect all players simultaneously.

**Why it happens:** English compound phrases have a massive gray area. "Is 'butter finger' one word, two words, or hyphenated?" AI generation casts a wide net and will include plausible-sounding but non-standard combinations. The "common American English" requirement is subjective -- regional, generational, and cultural differences mean no universal agreement on which two-word phrases are "valid."

**Consequences:**
- Players submit correct-seeming answers that are rejected, creating "the game is broken" perception
- Offensive word combinations go viral on social media (career-level risk for a small studio)
- Players in 1-star reviews cite specific invalid word pairs as evidence the game is broken
- Word pair chains can create unintended compound meanings across pairs (e.g., pairs that read as a sentence with offensive meaning)
- Content updates pushed to cloud accidentally break existing levels

**Prevention:**
1. Build a multi-layer validation pipeline BEFORE generating level content:
   - Layer 1: Automated dictionary check (both words exist, compound phrase appears in a reference corpus like Google Ngrams or a curated compound word list)
   - Layer 2: Profanity/sensitivity filter -- not just slurs but compound combinations that create offensive meanings. Use an explicit blocklist AND check the combined pair, not just individual words.
   - Layer 3: Human review of every level's word chain in sequence. Read the full chain aloud. Check for unintended meanings when pairs are read together.
   - Layer 4: Beta tester review -- real players flag "this doesn't seem right" pairs.
2. Implement a player reporting system for word pairs. "Report this word" button during gameplay. Track reports per pair. Auto-flag pairs with >N reports for human review.
3. Version your word content database. Every content push should be tagged with a version. Ability to roll back to previous version instantly if bad content is discovered.
4. Never include a word pair you can't defend. When in doubt, cut it. There are enough valid compound phrases in English to fill 3,000+ levels without borderline entries.
5. Consider the word chain in context: pairs like "head case" and "case load" are individually fine, but the chain "crack > head > case" reads problematically. Validate chains, not just pairs.

**Warning signs:** "The AI generated 10,000 pairs, we'll use them all." No human review step in the content pipeline. No profanity filter that checks compound combinations. No player reporting mechanism.

**Phase mapping:** Phase 2-3 (Content Generation and Validation). Must be solved before any content goes live. The validation pipeline is as important as the game code.

**Severity:** CRITICAL -- bad word content can cause PR disasters, app store removal (content policy violations), and permanent brand damage.

**Confidence:** HIGH -- content validation issues are the most common post-launch emergency for word games.

---

### C4: Godot Plugin Ecosystem Gaps for Mobile Monetization

**What goes wrong:** Godot's plugin ecosystem for mobile monetization (AdMob, IAP, analytics) is maintained by the community, not by Godot Engine officially. These plugins break between Godot versions, have incomplete feature coverage, and may not support the latest ad SDK requirements (which Google and Apple update frequently). Developers discover mid-project that a critical plugin doesn't work with their Godot version, or doesn't support a required feature (e.g., SKAdNetwork for iOS ad attribution, Google Play Billing Library v6+).

**Why it happens:** Google and Apple update their ad/billing SDKs at least annually with breaking changes and new requirements. Community-maintained Godot plugins lag behind these updates. Unlike Unity, which has official first-party support for AdMob and IAP, Godot relies on third-party GDExtension plugins or GDNative/GDExtension wrappers.

**Consequences:**
- App store rejection because the IAP implementation doesn't comply with current billing requirements
- Ad revenue loss because the ad SDK version is outdated and doesn't support the latest mediation features
- Apple App Store rejection for missing ATT (App Tracking Transparency) prompt, which must be shown before any ad tracking
- Google Play policy violation for not using the latest Play Billing Library version
- Plugin compatibility issues force downgrading Godot version or forking the plugin

**Prevention:**
1. Identify and test the specific Godot 4.5 AdMob and IAP plugins BEFORE committing to the architecture. As of mid-2025, the primary options are:
   - `godot-admob-plugin` (Poing Studios) -- most popular, but verify Godot 4.5 compatibility
   - `godot-google-play-billing` -- for Android IAP
   - For iOS IAP: may need a custom GDExtension wrapping StoreKit2
2. Build a "monetization spike" early: implement one interstitial ad and one test IAP in a throwaway scene, export to both platforms, and verify the full flow works on physical devices with sandbox/test accounts.
3. Budget time for plugin maintenance. When Godot updates or ad SDK requirements change, these plugins need updating. If the community plugin is abandoned, you need a plan (fork it, write your own wrapper, or use a different approach).
4. For the custom ad network (geo-targeted ads): this is a significant backend feature. Treat it as a separate system that serves ad creatives via HTTP, not as a Godot plugin. The Godot client just needs to fetch and display an image/video from your server.
5. Apple's ATT (App Tracking Transparency): you MUST show the ATT prompt before initializing ad tracking on iOS. Missing this is an automatic rejection. Godot doesn't handle this natively -- it must be implemented via plugin or native iOS code in the export.
6. Google Play Billing: Google requires the latest billing library version within a grace period. If your plugin uses an old version, your app update will be rejected.

**Warning signs:** "We'll add ads and IAP at the end." No monetization testing until beta. Using a plugin that hasn't been updated in 6+ months. No ATT implementation plan.

**Phase mapping:** Phase 3-4 (Monetization Integration). But the spike/feasibility test should happen in Phase 1 or 2.

**Severity:** CRITICAL -- monetization is the revenue model. If it doesn't work or gets rejected, the commercial product has no business model.

**Confidence:** MEDIUM -- the specific plugin landscape for Godot 4.5 should be re-verified; the underlying platform requirements (ATT, Play Billing) are HIGH confidence.

---

### C5: Required Authentication Creates a Churn Wall at First Launch

**What goes wrong:** The game requires authentication (magic email link, OAuth, or email/password) before the player can do anything. This is a significant friction point. Mobile games lose 50-80% of potential players at any mandatory registration screen. The player hasn't experienced ANY gameplay yet and is being asked to create an account. Combined with a tutorial that introduces many mechanics, the onboarding funnel becomes: open app -> forced auth -> long tutorial -> maybe play. Most users bounce.

**Why it happens:** The design requires auth for legitimate reasons (progress sync, multiplayer, IAP, name generation). But the business requirement to have auth conflicts with the UX requirement to get players into gameplay as fast as possible.

**Consequences:**
- Massive Day 1 churn -- most downloaded users never complete registration
- App store ratings suffer ("I just want to play, stop asking me to sign up")
- Marketing cost per acquired player skyrockets because most downloads don't convert to players
- Multiplayer matchmaking pool is smaller because fewer people ever get through auth

**Prevention:**
1. STRONGLY RECOMMEND reconsidering "required auth before gameplay." The industry-standard approach is:
   - Let players play immediately with a local/anonymous profile
   - Trigger auth when they need it: first cloud save, first multiplayer match, first IAP
   - Migrate the anonymous profile to an authenticated account seamlessly
2. If required auth is a firm decision, minimize friction:
   - OAuth (Sign in with Apple + Sign in with Google) is the lowest-friction option -- one tap, no typing
   - Magic email link requires the user to switch to their email app and back -- this is higher friction than it sounds, especially on mobile
   - Email/password is the highest-friction option -- don't make it the primary path
   - "Sign in with Apple" is REQUIRED by Apple if you offer any other third-party sign-in (Apple App Store Review Guideline 4.8)
3. If auth is required, make it the ONLY thing before gameplay. Don't stack auth + tutorial + name generation before the player touches a puzzle.
4. Track the auth funnel obsessively: app open -> auth screen shown -> auth started -> auth completed -> first puzzle played. If completion rate drops below 60%, the auth flow needs reworking.
5. The name generator (no user-typed names) is a good anti-moderation decision, but showing it before gameplay adds another step. Consider deferring name selection to after the first play session.

**Warning signs:** No analytics on auth completion rate. Auth + name generation + tutorial all before first puzzle. No "Sign in with Apple" implementation despite having OAuth.

**Phase mapping:** Phase 2 (Authentication and Onboarding). This is an architectural decision that affects the entire user flow.

**Severity:** CRITICAL -- this directly impacts whether the game has any players. A 70% auth-screen bounce rate means 70% of your marketing spend is wasted.

**Confidence:** HIGH -- auth wall churn rates are one of the most studied metrics in mobile gaming.

---

### C6: Cloud Content Delivery Introduces Latency Into Core Gameplay

**What goes wrong:** Word pairs and level content are stored in the cloud. The game must fetch this data before a level can start. On poor mobile connections (which are common globally), this introduces visible loading delays between levels. If the game requires a network call to START a level, players on subway, airplane, or rural connections simply cannot play. This is especially destructive for the "rush" feeling -- waiting 2-5 seconds for content to load between levels kills momentum.

**Why it happens:** Cloud-stored content is the right long-term architecture (OTA updates, lightweight app). But the implementation fails to account for the reality of mobile network conditions: high latency, intermittent connectivity, slow speeds on 3G/2G (still common in many markets).

**Consequences:**
- Loading screens between every level destroy game flow
- Players in low-connectivity situations cannot play at all
- "Requires internet connection" becomes a 1-star review trigger
- Backend outages make the entire game unplayable (single point of failure)

**Prevention:**
1. Implement aggressive content caching. On first launch (and periodically), download ALL content for the next several lands (100+ levels worth). Store it in local device storage. The game should NEVER need a network call to start a level during normal play.
2. Design for offline-first gameplay. The game should be fully playable with cached content and no internet connection. Sync happens in the background when connectivity is available.
3. Content should be fetched/updated in the background during non-gameplay moments (world map, store, between sessions). Never block gameplay on a network call.
4. Size the content payloads carefully. Word pairs and level definitions are tiny (a few KB per level). Pre-caching 500 levels worth of content is maybe 1-2 MB. There is no reason not to cache aggressively.
5. Implement a content version system: local cache stores a version number, game checks for updates on launch in background, downloads delta updates silently.
6. Have a "minimum viable offline mode" -- even if progress can't sync, the player can play cached levels and sync when back online.

**Warning signs:** Level start requires a synchronous API call. No local content cache. No offline mode. "Players will always have internet."

**Phase mapping:** Phase 3 (Backend Integration). But the caching architecture must be designed from the start, not bolted on later.

**Severity:** CRITICAL -- if the game doesn't work offline or has loading delays, it fails as a mobile game. Mobile gamers play in elevators, subways, and waiting rooms.

**Confidence:** HIGH -- offline-first is a foundational mobile game architecture principle.

---

## Moderate Pitfalls

Mistakes that cause significant delays, bad player experience, or technical debt that compounds over time.

---

### M1: Surge Momentum Bar Feels Unfair -- Bust Mechanic Creates Rage Quits

**What goes wrong:** The surge bar drains constantly, and crossing below the imminent threshold triggers an unrecoverable bust (bar drains fully regardless of correct answers). Players who are "almost there" on a hard word experience a bust and lose all momentum through no fault of their own -- the word was simply hard. This creates a perception that the game punished them unfairly. The bust mechanic works like a blackjack bust, but unlike blackjack, the player doesn't choose to "hit" -- the drain is automatic.

**Why it happens:** The tension between "challenging" and "unfair" is extremely narrow for momentum mechanics. In Candy Crush, when you lose, it's clearly because you ran out of moves. In a time-pressure + drain system, the loss feels systemic ("the game drained my bar") rather than player-driven ("I played poorly").

**Consequences:**
- Players who bust repeatedly on the same level feel helpless, not challenged
- "This game is rigged to make you buy stuff" reviews (even if it's not)
- Core audience (word puzzle fans) skews older and has less tolerance for punishing mechanics
- Bust mechanic colliding with obstacle effects (e.g., a Padlock locks a word WHILE surge is draining) creates genuinely impossible situations

**Prevention:**
1. Extensive playtesting of the bust mechanic with REAL players, not developers. Developers are too skilled and too familiar with the mechanic.
2. Tunable drain rates per difficulty tier. Early levels should have very slow drain to let players learn the system before it punishes them.
3. Consider a "grace period" after the bust threshold -- instead of instant unrecoverable drain, give players 2-3 seconds or 1 more word attempt to recover. This keeps the tension without the "instant death" feeling.
4. Bust should NEVER happen during an obstacle encounter that wasn't the player's fault. If a Padlock locks the current word and the player can't progress while surge drains, that's broken design. Obstacle timing must account for surge state.
5. Track bust rates per level in analytics. If a level has >30% bust rate, the drain tuning or word difficulty on that level is wrong.
6. The bonus words (3 after the 12 base words) gated by surge are a natural "reward for skill" design -- this is good. But make sure the GATING is clear: "You earned bonus words!" not just the bar quietly dropping and bonus words not appearing.

**Warning signs:** No external playtest data. Bust rates not tracked. Developers say "it's challenging" while playtesters say "it's unfair." Obstacles and surge interacting in untested ways.

**Phase mapping:** Phase 2-3 (Core Mechanics). Requires iterative tuning that continues through soft launch.

**Severity:** MODERATE (but borders on CRITICAL if not addressed -- this is the core experience differentiator)

**Confidence:** HIGH -- momentum/drain mechanics have extensive industry data from rhythm games, endless runners, and combo systems.

---

### M2: Nine Obstacle Types Is Too Many Mechanics

**What goes wrong:** The design calls for 9 obstacle types (Padlock, Random Blocks, Sand for V1, plus Ice, Charcoal, Acid, Flood, Acorn, Magnet for future). Each obstacle has unique visual behavior, mechanical effects, counter-strategies, and corresponding power boosts. This means 9 obstacles + 9 power boosts = 18 distinct mechanics the player must learn and remember. Combined with the surge bar, word puzzle core, hearts/hints/lives, dual currency, and store, the total cognitive load is enormous.

**Why it happens:** Each obstacle sounds interesting in isolation. "The Magnet pulls words up!" "Acid dissolves down!" But the cumulative complexity is what matters to players. The design is feature-rich, which is a design asset AND a design risk.

**Consequences:**
- Tutorial fatigue: introducing each new mechanic requires explanation, practice level, and demonstration
- Players forget mechanics for obstacles they haven't seen in 50 levels
- Balance nightmare: each new obstacle interacts with surge, other obstacles, power boosts, boss levels, and Vs mode
- Development cost: each obstacle needs animation, sound, particle effects, edge-case handling, and testing with every other system
- The template architecture helps with code, but doesn't solve the design/balance/content complexity

**Prevention:**
1. V1 ships with 3 obstacles (already the plan) -- this is correct. But treat 3 as the ONLY obstacles until they are thoroughly balanced and playtested. Don't commit to all 9 until 3 prove the system works.
2. Follow the Candy Crush model: introduce ONE new mechanic at a time, with many levels of that mechanic before adding the next. Players need 20-30 levels with just Padlock before Random Blocks appear.
3. The template-based architecture is the right technical approach. But also create a "Obstacle Design Document" that defines the interaction matrix: how each obstacle behaves when combined with each other obstacle, when surge is high/low, when boss conditions apply.
4. Consider whether all 9 obstacles are truly needed. Could some be combined? (Acid and Charcoal have similar "spreading damage" mechanics.) Could some be variants of others? Fewer, deeper mechanics often beat many shallow ones.
5. Power boosts need to feel meaningfully different, not just "remove obstacle type X." If every power boost is "tap to remove the thing," the strategic depth is shallow despite the variety.

**Warning signs:** Design document doesn't have an interaction matrix. New obstacles designed without testing how they interact with existing ones. Players in testing can't remember what each obstacle does.

**Phase mapping:** Phase 2-3 (Obstacle System Design). The template architecture should be built for extensibility, but content should be conservative.

**Severity:** MODERATE -- the 3-obstacle V1 scope is correct. Risk increases with each additional obstacle type added post-launch without sufficient testing.

**Confidence:** HIGH -- complexity creep is the #1 killer of puzzle game designs.

---

### M3: Dual Currency Economy Collapses Into Either No Revenue or No Fun

**What goes wrong:** Stars (non-premium, earned) and Diamonds (premium, earned rarely + purchasable) create a dual economy that must be carefully balanced. If Stars are too easy to earn, players never need Diamonds. If Stars are too scarce, the game feels stingy and players churn before ever considering spending. If Diamonds are too powerful, players who spend have a completely different experience than free players (pay-to-win perception). If Diamond pricing is wrong ($0.99 for too many or too few), revenue per user is poor.

**Why it happens:** Economy design requires actual player behavior data to tune. Pre-launch estimates are almost always wrong. Developers either model off their own behavior (too generous, because they know the game) or model off predatory games (too stingy, because they want revenue). The correct balance point is only discoverable through live data.

**Consequences:**
- "We're getting downloads but no revenue" -- economy too generous
- "Great game but too pay-to-win" reviews -- economy too aggressive
- Players who spend feel no advantage (why spend?), or free players feel punished (why play?)
- Diamond earn rate too high through gameplay makes IAP unnecessary
- Diamond earn rate too low makes the currency feel inaccessible and players ignore it
- Star-gated progression feels like an artificial wall if not tied to real skill/content

**Prevention:**
1. Design the economy to be tunable from the server side. Prices, earn rates, drop rates, and reward values should be cloud-configured, not hardcoded. This allows rapid balancing without app updates.
2. Follow the "2% whale" model: 98% of players will never spend money. Design the free experience to be complete and fun. The spending experience adds convenience and cosmetics, not power.
3. Stars as progression gates: tie star requirements to skill-based achievements (time challenges, no-bust runs), not just "play X levels." This makes stars feel earned, not grinded.
4. Diamonds for premium content (skins, premium power packs) not for bypassing gameplay. If Diamonds can buy "skip this level" or "auto-solve," it devalues the core experience.
5. Conduct economy modeling before launch: simulate 100 days of play for a free player, a minnow ($5 total spend), a dolphin ($20 total spend), and a whale ($100+ total spend). Each should have a fun, distinct experience trajectory.
6. Soft launch in a small market first to gather real economy data before global launch. This is standard industry practice for F2P games and is how you discover that your economy assumptions are wrong.

**Warning signs:** Economy values hardcoded in game code. No simulation/modeling of player progression curves. Developer says "we'll figure out pricing later." No plan for soft launch.

**Phase mapping:** Phase 3-4 (Economy Design). Initial design early, but expect significant iteration during soft launch.

**Severity:** MODERATE -- fixable post-launch with server-side tuning, but a badly tuned launch economy is hard to recover from (players form first impressions fast).

**Confidence:** HIGH -- F2P economy design principles are extremely well-documented.

---

### M4: Hearts/Lives System Punishes Engagement Instead of Rewarding It

**What goes wrong:** The hearts -> lives -> penalty box (cooldown timer) system is designed to create monetization opportunities (rewarded ads to recover, IAP to skip timers). But poorly tuned, it punishes the most engaged players: those who play a lot and are most likely to become paying customers. A player on a hot streak hits a hard level, loses all hearts, loses a life, watches ad for recovery, loses again, and is now in penalty box. They were your most engaged user and you just told them "stop playing."

**Why it happens:** The Candy Crush lives model works for Candy Crush because: (1) levels are short (1-3 min), (2) failing a level is clearly the player's fault (no external drain mechanics), (3) lives refill on a timer that maps to session length. WordRun adds surge bust mechanics and obstacles on top of hearts/lives, creating more ways to lose that feel less player-driven.

**Consequences:**
- Most engaged players hit the penalty box most often
- Rewarded ads as "recovery" feel like punishment ("pay attention to this ad or you can't play")
- Cooldown timers are especially toxic for new players who are still learning -- they fail more, get blocked more, and churn
- Stacking heart loss from obstacle-induced failures + surge busts + time pressure makes heart consumption unpredictable

**Prevention:**
1. New players (first 2-3 Nations) should have either: more hearts, slower heart consumption, or no penalty box. Let them learn the game before introducing the consequence system.
2. Hearts should only be lost for clear, player-understandable failures. "I ran out of time" is clear. "The surge bar drained while a Padlock locked my word" is not clear.
3. The penalty box cooldown should be SHORT (5-10 minutes, not 30+ minutes). Long cooldowns don't create revenue -- they create uninstalls.
4. Provide an alternative to the penalty box that doesn't require spending: "Come back in 5 minutes" or "complete this mini-challenge to earn a life back." The V1 decision to not include a mini-game penalty box variant should be reconsidered if the cooldown timer proves too punishing.
5. Track "penalty box -> uninstall" rate in analytics. If more than 15% of players who enter the penalty box never return, the system is too harsh.
6. Consider making the first penalty box entry per day instant-recovery (free). This creates a daily "save" that feels generous while still limiting infinite play.

**Warning signs:** Penalty box duration longer than 15 minutes. No new-player protection from the lives system. Heart consumption rate not tracked in analytics.

**Phase mapping:** Phase 3 (Lives System). Needs iteration during soft launch.

**Severity:** MODERATE -- fixable with tuning, but the interaction between hearts and surge/obstacles creates unique tuning challenges.

**Confidence:** HIGH -- lives/energy systems are the most studied monetization mechanic in mobile gaming.

---

### M5: Multiplayer Matchmaking With a Small Launch Player Base

**What goes wrong:** Vs mode requires matchmaking between strangers by skill/level. At launch, the player base is small (hundreds to low thousands). Matchmaking pools are further fragmented by skill level, geographic region (for latency), and online-at-same-time windows. Result: players wait 30+ seconds for a match, get matched against wildly different skill levels, or simply never find an opponent. The Vs mode becomes a ghost town, and players who came for multiplayer leave.

**Why it happens:** Matchmaking requires a critical mass of concurrent online players segmented by skill. Even "successful" indie mobile games struggle with this. The math is brutal: if you have 1,000 DAU, and 5% open Vs mode, and matches take 5 minutes with 1-minute search windows, you have maybe 5-10 concurrent players in the matchmaking pool at any given time.

**Consequences:**
- Long wait times frustrate players and make the feature feel broken
- Wide skill mismatches make matches unfun for both players
- The feature exists but nobody uses it, wasting development effort
- Server costs for real-time matchmaking infrastructure with minimal usage

**Prevention:**
1. Do NOT launch Vs mode at global launch. Ship it as a post-launch update once you have proven DAU numbers. This is how most successful puzzle games handle multiplayer.
2. If Vs mode must be at launch, implement asynchronous competitive play instead of real-time matchmaking. Player A plays a word chain, their score/time is recorded. Player B plays the same chain later. Scores are compared. This eliminates the concurrency requirement entirely.
3. "Friend invite" multiplayer (link/code) can launch early because it doesn't require matchmaking. The player brings their own opponent.
4. If real-time matchmaking is implemented: use wide skill brackets at low player counts, narrowing as the player base grows. A bad-skill match is better than no match.
5. Implement bot opponents that fill in when no human match is found. Don't tell the player it's a bot (or make it transparent -- "playing against AI while we find you a match"). The bot should play at the player's approximate skill level.
6. Consider a "daily challenge" multiplayer format: all players play the same set of words during a 24-hour window, and a leaderboard ranks them. This is multiplayer without matchmaking.

**Warning signs:** Vs mode planned for launch with no bot fallback. No estimation of required DAU for matchmaking viability. Real-time matchmaking architecture without concurrent player analysis.

**Phase mapping:** Phase 5+ (Post-launch feature or late development). Should be deferred unless async or friend-only multiplayer is used.

**Severity:** MODERATE -- the feature is wasted effort if launched too early, but doesn't break the rest of the game.

**Confidence:** HIGH -- matchmaking math for small player bases is well-understood.

---

### M6: Tutorial and Onboarding Overwhelms New Players

**What goes wrong:** WordRun has an exceptional number of systems to teach: (1) word-pair puzzle mechanics, (2) scrolling window and auto-submit, (3) surge bar and multiplier thresholds, (4) imminent drain and bust, (5) obstacles (3 types in V1), (6) power boosts (3 types + score bonus usage), (7) hearts, hints, and lives, (8) penalty box, (9) stars and diamonds, (10) store, (11) inventory/loadout, (12) world map, (13) boss levels. That's 13+ distinct systems. If the tutorial tries to explain everything upfront, players will either skip it all (and be lost) or sit through 10+ minutes of instructions (and quit from boredom).

**Why it happens:** Designers know every system is important. They want players to understand everything. But players want to PLAY, not be lectured. The paradox: the more systems you have, the more tutorial you need, and the more tutorial you have, the more players you lose.

**Consequences:**
- Tutorial completion rate below 50% (industry average for long tutorials)
- Players who skip tutorials fail immediately and leave
- Players who complete tutorials feel lectured and exhausted before "real" gameplay
- Tutorial maintenance burden: every system change requires tutorial updates

**Prevention:**
1. Teach ONE system per tutorial moment. The first 5 levels should teach ONLY the core word-pair puzzle. No surge bar, no obstacles, no currency. Just "fill in the letters, solve the chain."
2. Introduce systems through progressive disclosure across 30-50 levels:
   - Levels 1-5: Core puzzle only
   - Levels 6-10: Introduce surge bar (just the concept, no bust risk yet)
   - Levels 11-15: Introduce multipliers and bust risk
   - Level 16+: First obstacle (Padlock)
   - Level 25+: First power boost
   - Continue for each system
3. Never explain a mechanic before the player encounters it. "Just-in-time" teaching: show the tutorial popup the moment the obstacle first appears, not 10 levels earlier.
4. Make tutorials skippable but repeatable. A "How to play" section in settings for players who need a refresher.
5. Design the first 5 levels to be unlosable. No time pressure, very common word pairs, generous scoring. First impressions matter more than first challenge.
6. Test with a "zero knowledge player" -- someone who has never heard of the game. Watch them play silently. Where do they get confused? That's your tutorial priority.

**Warning signs:** Tutorial explains more than 2 systems at once. First level has surge bar, obstacles, AND currency. No "zero knowledge player" testing.

**Phase mapping:** Phase 4 (Onboarding). But the progressive disclosure plan must be designed in Phase 2 alongside the mechanics, because it affects level design for the first 50 levels.

**Severity:** MODERATE -- fixable post-launch through redesign, but a bad first impression is hard to overcome in a market with infinite alternatives.

**Confidence:** HIGH -- onboarding is the most A/B-tested aspect of mobile gaming.

---

### M7: Boss Level Randomized Conditions Create Impossible Combinations

**What goes wrong:** Boss levels use randomized challenge conditions with more words (up to 20), aggressive obstacles, and special rewards. If conditions are fully random, some combinations are mathematically impossible or so difficult that no human could complete them. Example: "20 words + all-Padlock obstacles + aggressive surge drain + time limit" creates a level where locked words drain the surge while the player can't progress. Boss NPCs that "pantomime obstacle causation" imply obstacles increase during boss fights, compounding the problem.

**Why it happens:** Randomization feels like it creates infinite content. But unconstrained randomization creates a Gaussian distribution of difficulty where the extremes are either trivially easy or impossibly hard. Without constraint rules, random is the enemy of fair.

**Consequences:**
- Players hit an impossible boss level and get permanently stuck (no amount of skill solves it)
- Boss levels become a hard gate that kills progression for a percentage of players
- "The boss is impossible" becomes a common review/complaint
- If bosses are tied to hearts/lives, an impossible boss rapidly depletes lives and sends players to penalty box

**Prevention:**
1. Never fully randomize boss conditions. Use a "difficulty budget" system: each condition has a difficulty cost, and the total budget is capped per boss level. "20 words" costs X, "aggressive obstacles" costs Y, "fast surge drain" costs Z. Total cannot exceed the budget.
2. Create a compatibility matrix: certain condition combinations are flagged as forbidden. "All Padlock obstacles + aggressive surge drain" is forbidden because Padlock prevents progression while surge drains.
3. Playtest every possible boss condition combination (or at least simulate them). If a combination can't be completed by a skilled player in testing, exclude it.
4. Boss levels should have a "difficulty ceiling" that scales with player skill level, not just Nation number. A player who has been busting frequently should face easier boss conditions than a player who has been maintaining high surge.
5. Provide a "boss retry" mechanic that is more generous than normal level retries. Boss frustration is amplified because players invest more effort to reach them.
6. Track boss completion rates in analytics. Any boss level with <40% first-attempt completion rate probably has balance issues. Any boss level with <80% completion rate after 3 attempts definitely has balance issues.

**Warning signs:** No constraint rules on random condition generation. No compatibility matrix. Boss conditions not playtested as combinations. No analytics tracking for boss completion rates.

**Phase mapping:** Phase 3 (Boss Levels). Must be designed alongside the obstacle template system.

**Severity:** MODERATE -- blocking boss levels cause churn, but they're fixable with server-side condition adjustments if content is cloud-stored.

**Confidence:** HIGH -- constrained randomization is a well-studied game design pattern.

---

### M8: Performance Degradation on Low-End Android Devices

**What goes wrong:** The game runs smoothly on development machines and modern phones but performs poorly on budget Android devices (which represent a LARGE share of the global Android market). The word puzzle itself may be lightweight, but combined with: particle effects for obstacles (sand trickling, blocks appearing, acid dissolving), scroll animations, surge bar animations, power boost visual effects, and ad SDK overhead, frame drops and lag appear on devices with 2-3GB RAM and older GPUs.

**Why it happens:** Godot's GL Compatibility renderer is the right choice for mobile, but it still requires attention to draw calls, texture sizes, shader complexity, and memory usage. Developers test on their own (typically flagship or mid-range) phones and never see the problem.

**Consequences:**
- Poor reviews from budget Android users (a significant market in global launch)
- Stuttering during obstacle animations makes the game feel broken
- Ad SDK initialization causes frame drops (ads are notoriously heavy on resources)
- Memory-related crashes on 2GB RAM devices
- The "rush" feeling requires smooth, responsive animation -- any stutter destroys it

**Prevention:**
1. Get a budget Android test device (under $150, 3GB RAM, 2-3 year old chipset). Test on it regularly. If it runs well there, it'll run well everywhere.
2. Profile GPU performance in Godot using the built-in performance monitors: draw calls, vertices, and frame time. On mobile, target <100 draw calls per frame and consistent 60fps (or at minimum stable 30fps on low-end).
3. Use Godot's CanvasGroup for batching draw calls when rendering the word grid, obstacle effects, and UI together.
4. Obstacle particle effects should be configurable in quality: full effects on capable devices, reduced effects on low-end. Detect device capability at startup and set quality accordingly.
5. Pre-load and cache textures for the current level. Don't load obstacle sprites dynamically during gameplay.
6. Ads (especially interstitial video ads) cause frame drops because the ad SDK is doing heavy work in the background. Never show ads during gameplay. Only show ads on transition screens (world map, level complete, store) where a frame drop is invisible.
7. Minimize GDScript allocations during gameplay loops. GDScript has garbage collection that can cause hitches. Pool objects (letters, blocks, obstacles) instead of creating/destroying them.

**Warning signs:** No budget Android test device. No frame rate monitoring during development. Particle effects not performance-tested on mobile. Ad SDK initialized during gameplay scenes.

**Phase mapping:** Phase 2-3 (ongoing). Must be a continuous concern, not a late optimization pass.

**Severity:** MODERATE -- performance is fixable incrementally, but if the architecture doesn't account for low-end devices from the start, optimization becomes a major refactor.

**Confidence:** MEDIUM -- specific Godot 4.5 performance characteristics should be verified against current docs. General mobile performance principles are HIGH confidence.

---

### M9: Data Sync Conflicts Lose Player Progress

**What goes wrong:** The game stores progress in the cloud (required for the auth-based account system). When a player plays on two devices, or plays offline and then reconnects, their progress data may conflict. Common scenario: player plays 5 levels on Device A offline, then opens the game on Device B (which has older progress), plays 3 levels, and Device B's progress syncs to the cloud, overwriting Device A's progress. Player loses 5 levels of work and is furious.

**Why it happens:** Client-server data sync is a fundamentally hard problem. Mobile games make it harder because: (1) devices are frequently offline, (2) players expect to switch between devices, (3) game state is complex (level progress, currency balances, inventory, streak data). Naive "last write wins" sync strategies cause data loss. But proper conflict resolution (CRDTs, vector clocks, operational transforms) adds significant backend complexity.

**Consequences:**
- Players lose progress -- this is the single most rage-inducing bug in mobile gaming
- Currency balances go negative or duplicate (exploit risk)
- Inventory items disappear or duplicate
- Streak data corrupts (breaks login streak rewards)
- "I lost my progress" support tickets are the most common for mobile games

**Prevention:**
1. Define a clear sync strategy before writing any backend code. Recommended for a puzzle game: server-authoritative for currency and purchases, client-authoritative with server merge for level progress.
2. For level completion data: use a "high-water mark" strategy. Track the highest completed level number and highest star count per level. On sync conflict, take the MAX of both. Players can never lose progress, only gain it.
3. For currency: ALL currency changes should go through the server. Never award Stars or Diamonds from the client alone. If offline, queue currency changes and replay them on the server when online. Server validates each change.
4. For IAP: ALWAYS verify purchases server-side against Apple/Google receipt validation APIs. Never trust the client's claim that a purchase was made. This prevents both sync issues and purchase fraud.
5. Implement a "sync status" indicator in the UI. Players should know whether their progress is synced. A small cloud icon (green=synced, yellow=syncing, red=offline) prevents anxiety.
6. Log all sync operations for debugging. When a "lost progress" support ticket comes in, you need to reconstruct what happened.
7. Never auto-delete or overwrite data. Keep historical snapshots. If something goes wrong, you can restore.

**Warning signs:** No sync strategy document. "Last write wins" approach. Currency changes handled on client side. No server-side receipt validation. No sync status UI.

**Phase mapping:** Phase 3 (Backend Integration). The sync strategy affects every system that stores data.

**Severity:** MODERATE (can become CRITICAL if currency/IAP data is lost or exploited).

**Confidence:** HIGH -- data sync conflicts are a well-documented problem with well-documented solutions.

---

## Minor Pitfalls

Mistakes that cause annoyance, rework, or missed opportunities but are recoverable.

---

### N1: Custom Ad Network Scope Creep

**What goes wrong:** The vision includes a custom ad network with geo-targeting at the zip code level. This is not a small feature -- it's a separate product. Building an ad network requires: an ad server (serving creative assets with targeting rules), a campaign management dashboard (creating/editing campaigns, setting geo-targets), impression/click tracking with fraud prevention, reporting and analytics, and integration with the game client. This scope rivals the game itself.

**Prevention:**
1. For V1, use ONLY third-party ad networks (AdMob). Ship the game first, validate the audience.
2. The custom ad network should be a V2 or V3 feature, built only after the game has proven its ad inventory is valuable.
3. If geo-targeted ads are needed pre-launch (e.g., local business partnerships), use AdMob's own geo-targeting features, which already support city-level targeting.
4. If building the custom network later: treat it as a separate project with its own backend, not bolted onto the game's backend.

**Warning signs:** Custom ad network architecture being designed alongside game architecture. Geo-targeting at zip code level discussed in Phase 1.

**Phase mapping:** Phase 5+ (Post-launch). Not a V1 feature.

**Severity:** MINOR for V1 (just don't build it). Could become MODERATE if scope creep pulls it into V1.

**Confidence:** HIGH.

---

### N2: Name Generator Creates Inappropriate Combinations

**What goes wrong:** The name generator (silly, cool, heroic, whimsical, fun categories; no duplicates; no user-typed names) randomly combines words to create player names. Random word combinations can create unintended meanings. "Big Pickle," "Master Bait," or "Moist Nugget" are the kinds of outputs random generators produce.

**Prevention:**
1. Curate name components carefully. Every adjective-noun combination should be reviewed by a human.
2. Test the full combinatorial space (or a large sample of it) for offensive or unfortunate combinations.
3. Use a compound-phrase profanity filter (same tool that validates word pairs).
4. Consider using pre-generated complete names (not random combinations) from a curated list. This eliminates combinatorial risk entirely.
5. The name list should be large enough (10,000+ names) to ensure uniqueness without player frustration.

**Warning signs:** Name components combined without combinatorial review. No profanity filter on generated names.

**Phase mapping:** Phase 2 (Auth/Onboarding).

**Severity:** MINOR -- embarrassing but fixable quickly by updating the name list.

**Confidence:** HIGH.

---

### N3: Apple and Google Policy Compliance Is a Moving Target

**What goes wrong:** App store policies change frequently. Requirements that didn't exist when development started are enforced by the time you submit. Common surprises: Apple's privacy manifest requirements (documenting all APIs and SDKs that access user data), Apple's mandatory "Sign in with Apple" when other social logins exist, Google's data safety declarations, new requirements for targeting SDK versions, and child safety regulations (COPPA compliance if any under-13 users could play).

**Prevention:**
1. Review Apple App Store Review Guidelines and Google Play Developer Policy monthly during development. Subscribe to developer newsletter/blog for both platforms.
2. Apple Privacy Manifest: generate one early. Every third-party SDK (AdMob, analytics, any backend SDK) must be declared.
3. "Sign in with Apple" is REQUIRED if you offer Google sign-in or any other third-party authentication. Plan for it from the start.
4. Age gate or COPPA compliance: if the game could attract under-13 players (word games often do), COPPA applies in the US. This restricts data collection, ad targeting, and requires parental consent. Decide early: is this a 13+ game or an all-ages game? This affects ad networks, analytics, and authentication options.
5. Google requires apps to target a recent Android API level (currently API level 34+). Verify Godot's export template targets the required level.

**Warning signs:** No one on the team has read the App Store Review Guidelines end-to-end. No privacy manifest. No age rating decision. No "Sign in with Apple" despite having OAuth.

**Phase mapping:** Phase 1 (Foundation) and ongoing.

**Severity:** MINOR per individual policy, but collectively they cause rejected submissions and launch delays.

**Confidence:** HIGH for the principles; specific current requirements should be verified against current Apple/Google docs.

---

### N4: Scrolling Word Window + Obstacle Animations Creates Visual Chaos

**What goes wrong:** The scrolling word window displays 4-5 words at a time, with the current word second from bottom. Obstacles have animated effects (sand trickling, blocks appearing, padlocks falling, acid dissolving). Power boosts have visual effects. The surge bar is animating. Score popups appear. The cursor pulses. On a 5-6 inch phone screen, this becomes an illegible mess of competing animations.

**Prevention:**
1. Establish a visual hierarchy: gameplay text (words and letters) must ALWAYS be the most readable element. No animation should obscure the current word.
2. Use animation priority levels: at most 2 animations active simultaneously. If a third would start, queue it.
3. Obstacle effects on non-current words should be subtle (color change, icon indicator) not fully animated unless the player scrolls to them.
4. Test on the smallest supported screen size (iPhone SE at 375x667 points). If the UI is cramped there, it's too complex.
5. Give the surge bar its own dedicated space outside the word window, not overlapping or competing with word content.

**Warning signs:** UI design done only for large screens. No maximum concurrent animation rule. Obstacle animations fully rendered for all affected words simultaneously.

**Phase mapping:** Phase 2-3 (UI/UX design for puzzle and obstacles).

**Severity:** MINOR -- visual polish that can be iteratively improved.

**Confidence:** HIGH.

---

### N5: Godot 4.x Version Churn During Development

**What goes wrong:** Godot 4.x has been releasing frequent minor and patch versions (4.0, 4.1, 4.2, 4.3, 4.4, 4.5). Each version can introduce breaking changes to APIs, scene format changes, or plugin compatibility issues. Upgrading mid-development can cause unexpected breakage. Staying on an older version means missing bug fixes and performance improvements.

**Prevention:**
1. Pin to a specific Godot version (currently 4.5) and do not upgrade unless there is a compelling reason (critical bug fix, required feature, plugin compatibility).
2. Before upgrading: make a full backup (git tag), read the changelog line by line, and test export to both platforms.
3. Use Godot's version control-friendly `.tscn` text format (already the default) so scene changes from version upgrades are visible in diffs.
4. If using GDExtension plugins, verify plugin compatibility with the target Godot version BEFORE upgrading.

**Warning signs:** Upgrading Godot "to get the latest features" without checking changelog for breaking changes. Multiple developers on different Godot versions.

**Phase mapping:** Ongoing throughout development.

**Severity:** MINOR -- version pinning mostly prevents this.

**Confidence:** HIGH.

---

### N6: AI-Generated Art Pipeline Produces Inconsistent Visual Style

**What goes wrong:** The project uses AI-generated art (cartoon generation, 3D-style rendering, animation generation, sprite sheet extraction). Different AI generation sessions produce subtly different art styles, color palettes, and character proportions. Over hundreds of assets, the game looks like it was made by different artists with different styles.

**Prevention:**
1. Create a visual style guide BEFORE generating any final assets: specific color palette (hex codes), line weight, shading style, character proportions for Ruut and NPCs.
2. Use consistent prompts with style reference images. Save the exact prompts and settings that produce the desired style.
3. Do a visual consistency pass after generating a batch of assets. View them all together, not individually.
4. Consider using image-to-image with a style reference for consistency rather than pure text-to-image generation.
5. Budget time for asset cleanup -- AI-generated assets almost always need manual touchup for consistency.

**Warning signs:** Each asset generated independently with different prompts. No style guide document. No side-by-side comparison of generated assets.

**Phase mapping:** Phase 2-3 (Asset Production). Style guide should be created in Phase 1.

**Severity:** MINOR -- visual inconsistency looks unprofessional but doesn't break gameplay.

**Confidence:** HIGH.

---

## Phase-Specific Warnings

Summary table mapping pitfalls to development phases for quick reference during roadmap planning.

| Phase Topic | Likely Pitfall | Severity | Mitigation |
|-------------|---------------|----------|------------|
| Phase 1: Foundation/Setup | C1 (Export pipeline), N3 (Policy compliance), N5 (Version pinning) | CRITICAL, MINOR, MINOR | Validate export pipeline in Week 1. Pin Godot version. Read store guidelines. |
| Phase 1: Spike/Feasibility | C4 (Monetization plugins) | CRITICAL | Build and test a monetization spike before committing architecture. |
| Phase 2: Core Puzzle | C2 (Touch input), M1 (Surge unfairness), M6 (Tutorial overload) | CRITICAL, MODERATE, MODERATE | Touch-first design. Playtest bust mechanic with non-developers. Progressive disclosure plan. |
| Phase 2: Auth/Onboarding | C5 (Auth churn wall), N2 (Name generator) | CRITICAL, MINOR | Consider deferred auth. Curate name components. |
| Phase 2-3: Content Pipeline | C3 (Word pair validation) | CRITICAL | Multi-layer validation pipeline before any content goes live. |
| Phase 3: Obstacles/Boosts | M2 (Too many mechanics), M7 (Impossible boss combos), N4 (Visual chaos) | MODERATE, MODERATE, MINOR | Start with 3 obstacles only. Constrained randomization for bosses. Visual hierarchy rules. |
| Phase 3: Backend Integration | C6 (Cloud latency), M9 (Data sync) | CRITICAL, MODERATE | Offline-first caching architecture. Server-authoritative currency. High-water-mark progress sync. |
| Phase 3-4: Economy/Monetization | M3 (Economy balance), M4 (Lives/hearts punishing), C4 (Plugin compatibility) | MODERATE, MODERATE, CRITICAL | Server-side tunable values. New player protection. Early plugin testing. |
| Phase 4: Performance | M8 (Low-end Android) | MODERATE | Budget test device. Draw call monitoring. Configurable effect quality. |
| Phase 5+: Multiplayer | M5 (Matchmaking cold start) | MODERATE | Defer real-time matchmaking. Async competition or friend-only for V1. |
| Phase 5+: Custom Ads | N1 (Scope creep) | MINOR | Do not build for V1. Use AdMob targeting. |

---

## Interaction Risks: Where Pitfalls Compound

Several pitfalls interact with each other to create worse-than-sum outcomes:

**Surge + Obstacles + Hearts (M1 + M2 + M4):** The surge bar drains while obstacles prevent progress, causing a bust, which costs hearts, which leads to penalty box. Each system is moderate risk alone; together they create "unfair" moments where the player loses through system interaction rather than their own mistakes. These three systems must be tested TOGETHER, not individually.

**Auth + Tutorial + Economy Introduction (C5 + M6 + M3):** Required auth, followed by a tutorial explaining multiple systems, followed by introducing two currencies -- all before the player has solved a single word puzzle. This is a triple-stacked onboarding wall that each individually reduces completion rates. Together, they could result in <20% of downloads becoming active players.

**Cloud Content + Performance + Ads (C6 + M8 + C4):** Cloud content loading, ad SDK background processing, and obstacle particle effects all competing for resources on a low-end Android device. If all three are active (loading next level content while ad SDK prefetches, while obstacle effects animate), the "rush" feeling evaporates into stuttering.

**Word Validation + Cloud Delivery + Boss Levels (C3 + C6 + M7):** Bad word pairs delivered from the cloud into a boss level with aggressive randomized conditions could create a scenario where the boss level is literally unsolvable (invalid word pair + impossible condition combination). This requires validation at multiple layers.

---

## Sources and Confidence Notes

This pitfalls analysis is based on training data through mid-2025 covering:

- **Godot mobile development:** Godot Engine documentation, community forums, post-mortems from Godot mobile game developers. Godot's mobile export pipeline has been a known pain point since 3.x and remains so in 4.x, though it has improved significantly. Specific Godot 4.5 issues should be verified against current official documentation. **Confidence: MEDIUM** (principles stable, version-specific details should be reverified).

- **Mobile game economy design:** GDC talks, Deconstructor of Fun blog, GameAnalytics industry reports, Candy Crush/King post-mortems. F2P economy design principles are extremely stable. **Confidence: HIGH.**

- **Word game content validation:** Post-mortems from Zynga (Words With Friends), Wordscapes (PeopleFun), and indie word game developers. Content validation pitfalls are the same as they were a decade ago. **Confidence: HIGH.**

- **Mobile app store policies:** Apple App Store Review Guidelines, Google Play Developer Policy Center. These change frequently -- the SPECIFIC requirements listed should be verified against current versions. ATT, Privacy Manifests, and COPPA principles are stable. **Confidence: MEDIUM** (verify specifics).

- **Data sync and backend:** Standard mobile backend architecture patterns from Firebase documentation, AWS game backend whitepapers. These patterns are mature and stable. **Confidence: HIGH.**

- **Multiplayer matchmaking:** GDC talks on indie multiplayer matchmaking, Supercell's and King's approaches to competitive mobile play. **Confidence: HIGH.**

**Items that should be reverified with current sources before implementation:**
- Godot 4.5 specific export pipeline changes and known issues
- Current state of `godot-admob-plugin` and IAP plugin compatibility with Godot 4.5
- Apple's current Privacy Manifest requirements (these have evolved since mid-2024)
- Google Play's current minimum target API level requirement
- Current state of StoreKit2 integration options for Godot

---

*Last updated: 2026-01-29*
