# Technology Stack

**Project:** WordRun!
**Researched:** 2026-01-29
**Research mode:** Ecosystem (Stack dimension)
**Tool limitations:** WebSearch and WebFetch were unavailable during this research session. All findings are based on training data (cutoff: mid-2025). Confidence levels reflect this constraint. Recommendations marked VERIFY should be validated against current official documentation before implementation.

---

## Recommended Stack

### 1. Game Engine: Godot 4.5 (GL Compatibility)

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Godot Engine | 4.5.x stable | Core game engine | Already initialized in project. Godot 4.x is the correct choice for a 2D-heavy mobile game. The GL Compatibility renderer is the right call for broad mobile device support. | HIGH |
| GDScript | 4.5 (bundled) | Primary scripting language | Native to Godot, best performance for scene-integrated logic, most community resources, fastest iteration cycle. C# adds build complexity and mobile export friction without meaningful benefit for a 2D word puzzle. | HIGH |
| GL Compatibility Renderer | (bundled) | Rendering backend | Already configured. This is correct -- it targets OpenGL ES 3.0 / WebGL 2.0 and has the broadest mobile device compatibility. Forward+ and Mobile renderers are for 3D-heavy projects. | HIGH |

**What NOT to use:**
- **C# / .NET:** Adds Mono/.NET runtime to the APK/IPA, increases binary size by ~30-50MB, complicates iOS export signing, and has historically lagged behind GDScript for mobile export stability in Godot 4.x. No benefit for a 2D word puzzle game. Confidence: HIGH.
- **Godot 3.x:** Legacy. Godot 4.x has superior 2D performance, better mobile export templates, and is the actively maintained branch. Confidence: HIGH.
- **Forward+ or Mobile renderer:** These are for 3D rendering pipelines. GL Compatibility is correct for 2D with broad device support. Confidence: HIGH.

#### Mobile Export Considerations

**Android Export:**
| Requirement | Detail | Confidence |
|-------------|--------|------------|
| Export templates | Download via Godot Editor > Export > Manage Export Templates | HIGH |
| Android SDK | Requires Android SDK with build-tools, platform-tools, and cmdline-tools | HIGH |
| JDK | OpenJDK 17 (Godot 4.x requirement) | MEDIUM -- VERIFY exact JDK version for 4.5 |
| Keystore | Required for release builds; generate via `keytool` | HIGH |
| Min API level | API 24 (Android 7.0) is the Godot 4.x default minimum | MEDIUM -- VERIFY for 4.5 |
| Target API level | Must meet Google Play's current requirement (API 34+ as of 2025) | MEDIUM -- VERIFY current Play Store requirement |
| AAB format | Google Play requires Android App Bundles (.aab), not APK, for new apps | HIGH |
| Gradle build | Godot 4.x uses Gradle for Android builds; custom Gradle plugins needed for AdMob/IAP | HIGH |

**iOS Export:**
| Requirement | Detail | Confidence |
|-------------|--------|------------|
| Export templates | Download via Godot Editor > Export > Manage Export Templates | HIGH |
| macOS required | iOS builds require a Mac with Xcode installed | HIGH |
| Xcode version | Xcode 15+ (latest stable recommended) | MEDIUM -- VERIFY for Godot 4.5 |
| Apple Developer account | $99/year, required for device testing and App Store submission | HIGH |
| Code signing | Requires provisioning profiles and certificates via Apple Developer portal | HIGH |
| Minimum iOS version | iOS 12+ is typical Godot 4.x minimum | MEDIUM -- VERIFY for 4.5 |
| One-shot export | Godot exports an Xcode project; final build/archive happens in Xcode | HIGH |

**Critical mobile performance notes:**
- Keep draw calls low: batch sprites, use texture atlases, minimize unique materials
- GL Compatibility renderer already handles most 2D batching automatically
- For the scrolling word window: use `CanvasItem` visibility culling -- only process/render words visible in the viewport
- Test on low-end devices early (Android: ~2GB RAM, older Mali/Adreno GPU; iOS: iPhone SE 2nd gen)
- Profile with Godot's built-in profiler and monitors regularly

---

### 2. Backend Services

This is the most consequential stack decision for WordRun!. The game needs: authentication, cloud database, real-time multiplayer/matchmaking, IAP receipt validation, and content delivery. I evaluated four options.

#### Backend Comparison Matrix

| Criterion | Firebase | Supabase | PlayFab | Custom (self-hosted) |
|-----------|----------|----------|---------|---------------------|
| Auth (email, OAuth, magic link) | Excellent -- native support for all 3 | Excellent -- native support for all 3 | Good -- supports email, OAuth; no native magic link | Full control but must build everything |
| Cloud database | Firestore (NoSQL) or Realtime DB | PostgreSQL (relational) | Entity system (NoSQL-like) | Any DB you want |
| Real-time multiplayer | Realtime Database works but is not a game server | No native game networking | Excellent -- built for games, has matchmaking | Must build matchmaking + relay |
| Matchmaking | Must build custom logic on Cloud Functions | Must build custom | Built-in -- skill-based, queue management | Must build |
| IAP receipt validation | Cloud Functions + Google/Apple server APIs | Edge Functions + Google/Apple server APIs | Built-in for major platforms | Must build |
| Godot SDK / plugin | Community plugins exist (GodotFirebase) | REST API (no official Godot SDK) | Community REST wrapper; no official Godot SDK | Whatever you build |
| Geo-targeting data | Analytics has location; no zip-code-level built-in | PostGIS extension for geo queries | Analytics has region-level | Full control |
| Free tier | Generous (Spark plan) | Generous (500MB DB, 1GB storage) | Free up to 100K users | Hosting costs from day 1 |
| Scalability | Excellent (Google infrastructure) | Good (managed Postgres) | Excellent (Microsoft infrastructure) | Depends on your ops |
| Cost at scale | Pay-per-use, can spike unpredictably | More predictable pricing | Tiered, predictable | Infra + dev time |
| Vendor lock-in | HIGH -- proprietary SDKs and data model | LOW -- standard Postgres, can self-host | MEDIUM -- proprietary APIs | NONE |

#### RECOMMENDATION: Firebase as Primary Backend + Custom Ad Server

**Confidence: MEDIUM** (I am confident in the technical fit, but Godot-Firebase plugin maturity should be verified against current plugin state)

**Why Firebase:**
1. **Auth:** Firebase Auth natively supports all three required methods (email/password, OAuth via Google/Apple/etc., and magic email links). This is a plug-and-play solution that handles token refresh, session management, and cross-device sync. No other option matches this breadth with less setup.

2. **Cloud Firestore:** NoSQL document model maps naturally to game data -- player profiles, inventory, progress per level, surge stats. Schema-less design accommodates the evolving data model of a game in active development. Offline persistence (built into Firestore client SDKs) means players can continue playing during connectivity gaps and sync when reconnected.

3. **Cloud Functions:** Server-side logic for IAP receipt validation, matchmaking queue processing, anti-cheat checks, and content delivery endpoints. Functions can validate purchases with Apple/Google servers before crediting diamonds.

4. **Realtime Database or Firestore listeners:** For Vs mode turn-based multiplayer. Since Vs mode is turn-based (not real-time physics), Firestore document listeners are sufficient -- each player writes their move to a shared match document, and the opponent receives it via listener. No need for a dedicated game server or WebSocket relay.

5. **Cloud Storage:** For downloadable word data packs, land content, and asset bundles. Enables the lightweight-app strategy where the APK/IPA ships minimal content and downloads land data on demand.

6. **Analytics + Crashlytics:** Built-in analytics for player behavior, funnel analysis, and crash reporting. Essential for a commercial mobile game.

**Why NOT Supabase (for this project):**
- Supabase is excellent for web apps but has no official Godot SDK. You would call REST endpoints via HTTPRequest nodes, which works but requires building your own auth token management, offline queue, and retry logic that Firebase clients provide out of the box.
- PostgreSQL is relational, which adds schema migration overhead as the game evolves. Firestore's schema-less documents are more forgiving during rapid game development.
- Supabase Realtime is built for database change subscriptions, not game session management. You would need to build matchmaking, turn management, and session lifecycle from scratch.
- PostGIS for geo-queries is powerful but overkill for zip-code ad targeting, which is better handled by a dedicated ad server.

**Why NOT PlayFab:**
- PlayFab (Microsoft Azure) is purpose-built for games and has excellent matchmaking, leaderboards, and player data. However, it has no official Godot SDK, and the community support for Godot + PlayFab is thin compared to Firebase.
- The Godot community gravitates toward Firebase, meaning more examples, more battle-tested plugins, and more Stack Overflow answers when things go wrong.
- PlayFab's strength is real-time multiplayer games (FPS, battle royale) -- overkill for a turn-based word puzzle.

**Why NOT fully custom:**
- Building auth, database, matchmaking, IAP validation, analytics, and crash reporting from scratch would consume months of backend engineering time. For a solo/small team shipping a mobile game, managed services dramatically reduce time-to-market.
- Custom backends make sense when you outgrow managed services or have unique requirements they cannot serve. WordRun! does not have such requirements at launch.

#### Firebase Components to Use

| Firebase Service | Purpose in WordRun! | Confidence |
|------------------|---------------------|------------|
| Firebase Auth | Email/password, Google/Apple OAuth, magic email link login | HIGH |
| Cloud Firestore | Player profiles, progress, inventory, match history, leaderboards | HIGH |
| Cloud Functions (Node.js) | IAP receipt validation, matchmaking logic, content manifest generation, anti-cheat | HIGH |
| Cloud Storage | Word data packs per land, downloadable content, asset delivery | HIGH |
| Firebase Analytics | Player behavior, funnel analysis, retention metrics | HIGH |
| Crashlytics | Crash reporting and stability monitoring | HIGH |
| Remote Config | Feature flags, A/B testing, difficulty tuning without app updates | MEDIUM |
| Cloud Messaging (FCM) | Push notifications for login streaks, match invites, content updates | MEDIUM |

#### Custom Ad Server (for geo-targeted custom ads)

AdMob handles standard interstitial and rewarded ads. But the requirement for a **custom ad network with zip-code-level geo-targeting** for the creator's own ads requires a separate lightweight service.

**Recommended approach:**
| Component | Technology | Purpose | Confidence |
|-----------|------------|---------|------------|
| Ad decision server | Cloud Functions or Cloud Run | Receives player location, returns appropriate ad creative | MEDIUM |
| Ad creative storage | Cloud Storage | Hosts ad images/videos organized by campaign | HIGH |
| Geo database | Firestore collection or BigQuery | Maps zip codes to ad campaigns | MEDIUM |
| Location source | Device GPS (with permission) or IP-based geolocation | Determines player's approximate location | HIGH |
| Impression/click tracking | Firestore or BigQuery | Logs ad views and clicks for reporting | MEDIUM |

**Architecture:** The game client requests an ad from the custom ad server (Cloud Function), passing the player's zip code or lat/long. The function queries the campaign database for matching geo-targeted ads, returns a creative URL, and logs the impression. The client downloads and displays the creative. Click-through opens the system browser.

This is a lightweight "ad server" -- not a full programmatic ad exchange. It handles the creator's own campaigns only.

---

### 3. Ads: AdMob Integration

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| Poing GodotAdMob | Latest (check GitHub) | AdMob ads in Godot | Most maintained Godot 4.x AdMob plugin. Supports banner, interstitial, rewarded, and rewarded interstitial ad formats. Uses Godot's Android plugin system and iOS plugin system. | MEDIUM -- VERIFY current maintenance status |
| Google AdMob SDK | Bundled with plugin | Underlying ad SDK | Industry standard for mobile ad monetization | HIGH |

**Alternative plugins (if Poing is unmaintained):**
- **godot-admob-plugin** by Shin-NiL: Another community AdMob plugin for Godot. Check GitHub stars and last commit date to determine which is more active.
- **Custom AdMob integration:** Write a thin GDScript wrapper over platform-native AdMob calls using Godot's Android plugin API (Java/Kotlin) and iOS plugin API (Swift/Obj-C). More work but full control.

**VERIFY:** The Godot AdMob plugin ecosystem has historically been fragmented with multiple forks. Before committing, check which plugin is actively maintained for Godot 4.5. Key signals: last commit date, open issues responsiveness, Godot 4.x compatibility explicitly stated.

**Ad placement strategy for WordRun!:**
| Ad Type | Placement | Frequency | Notes |
|---------|-----------|-----------|-------|
| Interstitial | Between levels (after level complete screen) | Every 3-5 levels | Not after losses -- bad UX. Only after wins or map returns. |
| Rewarded | Heart recovery, hint recovery, life recovery | On demand (player-initiated) | Player chooses to watch. Must deliver reward reliably. |
| Rewarded | Bonus diamonds/stars offer | After level complete | Optional "watch to double rewards" -- high engagement format |
| Custom (geo-targeted) | In-game billboard or loading screen | Variable per campaign | Creator's own ads, served by custom ad server |

---

### 4. In-App Purchases (IAP)

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| godot-google-play-billing | Latest | Google Play IAP | Official-adjacent plugin for Google Play Billing Library integration in Godot | MEDIUM -- VERIFY exists and is maintained for Godot 4.5 |
| Godot iOS IAP plugin | Latest | Apple StoreKit IAP | Plugin for StoreKit integration on iOS | MEDIUM -- VERIFY exists and is maintained for Godot 4.5 |
| Firebase Cloud Functions | Latest | Receipt validation | Server-side validation of purchase receipts with Google Play / App Store servers | HIGH (approach is standard) |

**Critical IAP architecture:**
1. **Client initiates purchase** via platform-native billing API (Google Play Billing / StoreKit)
2. **Client receives receipt/token** from platform
3. **Client sends receipt to server** (Cloud Function)
4. **Server validates receipt** with Google Play Developer API / Apple App Store Server API
5. **Server credits player account** in Firestore only after validation succeeds
6. **Client receives confirmation** and updates local state

**Never trust the client for purchase validation.** This is the number one IAP anti-pattern. A player with a jailbroken/rooted device can fake purchase receipts if validation happens client-side.

**IAP products for WordRun!:**
| Product Type | IAP Type | Examples |
|--------------|----------|---------|
| Diamond packs | Consumable | 100, 500, 2000 diamonds |
| Power packs | Consumable | Bundle of specific power boosts |
| Character skins | Non-consumable | Cosmetic unlocks (persist forever) |
| Premium upgrades | Non-consumable | Input mode unlocks |
| Subscription (future) | Subscription | Ad-free, daily diamonds, etc. |

**VERIFY:** Godot 4.x IAP plugin landscape. The situation as of mid-2025 was that IAP integration required platform-specific plugins (separate for Android and iOS). Check the Godot Asset Library and GitHub for current maintained options. If no reliable plugin exists, building thin native wrappers is the fallback.

---

### 5. Multiplayer / Matchmaking (Vs Mode)

WordRun! Vs mode is **turn-based**, not real-time. This dramatically simplifies the networking requirements.

| Technology | Purpose | Why | Confidence |
|------------|---------|-----|------------|
| Cloud Firestore (listeners) | Match state synchronization | Players write moves to a shared match document. Firestore's real-time listeners push updates to the opponent. Sub-second latency is achievable and sufficient for turn-based play. | HIGH (approach) |
| Cloud Functions | Matchmaking queue processor | Function triggered on queue write: finds compatible opponent by skill/level, creates match document, notifies both players. | HIGH (approach) |
| Cloud Functions | Match lifecycle | Handle timeouts, disconnections, match completion, rating updates. | HIGH (approach) |
| FCM (push notifications) | Match found / opponent's turn notification | Alert players when matched or when it's their turn (if app is backgrounded). | MEDIUM |

**Matchmaking design:**
1. Player requests match > writes to `matchmaking_queue` collection with skill rating, level, timestamp
2. Cloud Function (triggered or scheduled) scans queue for compatible pairs (skill range window, expanding over time)
3. Function creates `matches/{matchId}` document with both player IDs, initial state
4. Both clients listen to the match document for state changes
5. On each turn: player writes their word solution + timestamp to the match document
6. Opponent's listener fires, updating their view
7. Match ends when a player's clock runs out or a player forfeits

**Friend invites:**
- Player generates invite code (short alphanumeric, stored in Firestore with TTL)
- Or shares a deep link (Firebase Dynamic Links or custom URL scheme)
- Invited player enters code or opens link > Cloud Function creates match document for both players

**Why NOT a dedicated game server:**
- Turn-based gameplay does not require authoritative real-time simulation
- Firestore listeners provide sufficient latency (~100-500ms) for turn delivery
- No physics, no interpolation, no tick rate concerns
- Saves significant infrastructure cost and complexity

---

### 6. Cloud Content Delivery

The lightweight app strategy: ship a small APK/IPA with the core game engine and Nation 1 content, then download additional content on demand.

| Technology | Purpose | Why | Confidence |
|------------|---------|-----|------------|
| Cloud Storage (Firebase) | Host content bundles (word data, level configs, land themes) | Integrated with Firebase, supports CDN caching, resumable downloads | HIGH |
| Cloud Functions | Content manifest API | Returns list of available content packs with versions, sizes, checksums | HIGH |
| Firestore | Content metadata & player download state | Track which packs a player has downloaded, content versions | HIGH |
| HTTPRequest (Godot) | Download manager in client | Godot's built-in HTTP client for downloading content packs | HIGH |

**Content pack structure:**
```
content/
  nation_1/
    land_01/
      words.json          # Word pairs for this land's levels
      level_config.json   # Level parameters (word count, obstacles, difficulty)
      theme.json          # Visual theme data (colors, sprite references)
    land_02/
      ...
  nation_2/
    ...
```

**Download flow:**
1. App launch > check content manifest (Cloud Function returns latest versions)
2. Compare local content versions with server versions
3. Download new/updated packs in background or on land entry
4. Store locally in `user://` directory (Godot's persistent user storage)
5. Verify checksums before using downloaded content
6. Show download progress bar when entering a new land for the first time

**Important:** Word data as JSON is tiny (thousands of word pairs = kilobytes, not megabytes). The bigger downloads will be themed assets (sprites, backgrounds, sounds) if those are also cloud-delivered. Consider shipping all word data in the initial app and only cloud-delivering visual themes and future content updates.

---

### 7. Essential Godot Plugins / Addons

| Plugin | Purpose | Where to Get | Confidence |
|--------|---------|-------------|------------|
| GodotAdMob (Poing or equivalent) | Ad integration | GitHub / Godot Asset Library | MEDIUM -- VERIFY |
| Google Play Billing plugin | Android IAP | GitHub / Godot Asset Library | MEDIUM -- VERIFY |
| iOS StoreKit plugin | iOS IAP | GitHub / Godot Asset Library | MEDIUM -- VERIFY |
| Firebase REST or GodotFirebase plugin | Backend communication | GitHub (GodotFirebase by GodotNuts or equivalent) | MEDIUM -- VERIFY |
| Gut (Godot Unit Testing) | Unit testing framework | Godot Asset Library | HIGH |
| Phantom Camera (optional) | Smooth camera transitions for map navigation | Godot Asset Library | LOW -- nice to have |
| LimboAI (optional) | Behavior trees for NPC logic on world map | Godot Asset Library | LOW -- only if NPC behavior becomes complex |

**GodotFirebase plugin detail:**
- The GodotFirebase plugin (by GodotNuts/Codelyok) has historically provided Auth, Firestore, Storage, and Analytics integration for Godot.
- **VERIFY:** Check if this plugin supports Godot 4.5. The Godot plugin ecosystem has been catching up to Godot 4.x; some plugins may still target 4.2 or 4.3.
- **Fallback:** If no maintained Firebase plugin exists for Godot 4.5, use Firebase REST APIs directly via Godot's `HTTPRequest` node. Firebase REST API is well-documented and works with any HTTP client. This is more boilerplate but fully reliable.

**Plugins to explicitly AVOID:**
| Plugin | Why Avoid |
|--------|-----------|
| Nakama (for this project) | Open-source game server -- excellent for real-time multiplayer but overkill for turn-based. Adds server hosting/ops burden. Firebase covers the same needs with zero ops. |
| Colyseus (for this project) | Same reasoning as Nakama -- real-time game server for real-time games. |
| ENet/WebRTC multiplayer | Low-level networking for real-time games. Wrong abstraction level for turn-based word puzzle. |

---

### 8. Development & Build Tools

| Tool | Purpose | Why | Confidence |
|------|---------|-----|------------|
| Godot Editor 4.5 | Development IDE | Primary development environment | HIGH |
| Git + GitHub | Version control + remote | Already configured in project | HIGH |
| GitHub Actions | CI/CD pipeline | Automate Android/iOS builds, run tests, deploy Cloud Functions | HIGH |
| Node.js 20 LTS | Cloud Functions runtime | Firebase Cloud Functions runs on Node.js; LTS version for stability | HIGH |
| Firebase CLI | Backend deployment | Deploy Cloud Functions, Firestore rules, Storage rules | HIGH |
| Android Studio | Android SDK management + debugging | Required for SDK tools; also useful for on-device debugging | HIGH |
| Xcode | iOS builds + debugging | Required for iOS export and App Store submission | HIGH |
| Gut (GDScript) | Unit tests for game logic | Test word validation, surge calculations, obstacle mechanics in isolation | HIGH |

**CI/CD pipeline (GitHub Actions):**
- Use `abarichello/godot-ci` Docker image or equivalent for headless Godot builds
- Separate workflows for Android (.aab) and iOS (.xcodeproj export, then Xcode build via Fastlane)
- Run Gut tests before builds
- Deploy Cloud Functions via Firebase CLI in a separate workflow

---

### 9. Data Architecture (Firestore Collections)

High-level Firestore data model for WordRun!:

```
users/{userId}
  - displayName (from name generator)
  - authProvider
  - createdAt
  - lastLogin
  - loginStreak
  - stars (non-premium currency)
  - diamonds (premium currency)
  - currentNation
  - currentLand
  - currentLevel
  - skillRating (for matchmaking)

users/{userId}/inventory/{itemId}
  - itemType (power_boost, skin, upgrade)
  - itemName
  - quantity (for consumables)
  - equipped (boolean)

users/{userId}/progress/{landId}
  - levels: { levelNum: { stars, bestScore, completed, bonusWordsEarned } }
  - unlocked (boolean)

matches/{matchId}
  - player1, player2
  - status (waiting, active, completed)
  - turns: [ { playerId, word, correct, timestamp } ]
  - player1TimeRemaining, player2TimeRemaining
  - winner
  - createdAt

matchmaking_queue/{queueEntryId}
  - userId
  - skillRating
  - timestamp
  - status (waiting, matched)

content_manifest/
  - nations/{nationId}: { lands, version, downloadUrl, checksum }

ad_campaigns/{campaignId}
  - creativePath (Cloud Storage URL)
  - targetZipCodes: [array]
  - active (boolean)
  - impressions, clicks
  - startDate, endDate
```

---

## Installation / Setup Summary

### Godot Project (already initialized)
```bash
# Already done -- project.godot exists with Godot 4.5, GL Compatibility
# Plugins: install via Godot Asset Library or git submodule into addons/
```

### Firebase Backend
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase project
firebase login
firebase init  # Select: Functions, Firestore, Storage, Hosting (optional)

# Install Cloud Functions dependencies
cd functions/
npm install firebase-admin firebase-functions

# Deploy
firebase deploy
```

### Android Export Prerequisites
```bash
# Install Android Studio (for SDK)
# In Android Studio SDK Manager, install:
#   - Android SDK Platform (API 34+)
#   - Android SDK Build-Tools
#   - Android SDK Command-line Tools
#   - NDK (if using native plugins)

# Set paths in Godot Editor Settings:
#   Editor > Editor Settings > Export > Android
#   - Android SDK Path
#   - Debug Keystore (auto-generated or custom)

# Generate release keystore:
keytool -genkey -v -keystore wordrun-release.keystore \
  -alias wordrun -keyalg RSA -keysize 2048 -validity 10000
```

### iOS Export Prerequisites
```bash
# Install Xcode from Mac App Store (latest version)
# Enroll in Apple Developer Program ($99/year)
# Create App ID, provisioning profiles, and certificates in Apple Developer portal
# Configure in Godot Export settings:
#   - Team ID
#   - Bundle Identifier (com.yourcompany.wordrun)
#   - Provisioning Profile path
```

---

## Alternatives Considered (Summary)

| Category | Recommended | Alternative | Why Not Alternative |
|----------|-------------|-------------|---------------------|
| Engine | Godot 4.5 | Unity, Unreal | Already chosen; Godot is excellent for 2D mobile, open source, no revenue share |
| Language | GDScript | C#, C++ (GDExtension) | C# adds mobile export complexity; C++ is overkill for 2D puzzle game logic |
| Renderer | GL Compatibility | Forward+, Mobile | GL Compat has broadest device support for 2D |
| Backend | Firebase | Supabase | No Godot SDK, relational DB schema overhead, no game-oriented features |
| Backend | Firebase | PlayFab | Thin Godot community support, overkill for turn-based game |
| Backend | Firebase | Custom/self-hosted | Massive dev time investment for commodity services |
| Multiplayer | Firestore listeners | Nakama, Colyseus | Real-time game servers are overkill for turn-based; add hosting burden |
| Ads | AdMob plugin | Unity Ads, ironSource | AdMob has best Godot plugin support; others have no maintained Godot plugins |
| IAP | Platform-native plugins | RevenueCat | RevenueCat has no Godot SDK; would need REST API wrapper |
| Testing | Gut | GdUnit4 | Both viable; Gut has longer history and more documentation |

---

## Risk Register

| Risk | Severity | Mitigation | Confidence |
|------|----------|------------|------------|
| Firebase plugin not maintained for Godot 4.5 | HIGH | Fallback to Firebase REST API via HTTPRequest; more boilerplate but works | MEDIUM |
| AdMob plugin not maintained for Godot 4.5 | HIGH | Build thin native wrappers (Java/Kotlin for Android, Swift for iOS) using Godot plugin API | MEDIUM |
| IAP plugins fragmented/unmaintained | HIGH | Same as AdMob -- build thin native wrappers | MEDIUM |
| Firestore costs spike with growth | MEDIUM | Implement aggressive client-side caching, batch reads, use Firestore bundles for static content | HIGH |
| App Store/Play Store rejection | MEDIUM | Follow platform guidelines strictly; test IAP flows in sandbox environments; comply with COPPA/GDPR if applicable | HIGH |
| GL Compatibility renderer limitations | LOW | This renderer is well-suited for 2D; unlikely to hit limitations for a word puzzle game | HIGH |
| Offline play broken by cloud dependency | MEDIUM | Design content download system with offline-first mindset; cache word data locally after first download; Firestore has offline persistence built in | HIGH |

---

## Key Decisions Summary

| Decision | Recommendation | Rationale | Status |
|----------|---------------|-----------|--------|
| Backend platform | Firebase | Best auth breadth, Firestore fits game data model, Cloud Functions for IAP/matchmaking, largest Godot community adoption | RECOMMENDED -- verify plugin state |
| Multiplayer approach | Firestore listeners (not game server) | Turn-based gameplay needs document sync, not real-time networking | RECOMMENDED |
| Ad integration | AdMob plugin + custom ad server on Cloud Functions | AdMob for standard ads; custom server for geo-targeted creator ads | RECOMMENDED |
| IAP approach | Platform-native plugins + server-side validation | Industry standard; never trust client for purchase verification | RECOMMENDED |
| Content delivery | Cloud Storage + content manifest | Lightweight app, OTA updates, progressive download per land | RECOMMENDED |
| Custom ad geo-targeting | Cloud Functions + Firestore geo data | Simple ad server for creator's campaigns; not a full ad exchange | RECOMMENDED |

---

## Sources and Confidence Notes

This research was conducted without access to live web resources (WebSearch and WebFetch were unavailable). All findings are based on training data with a cutoff of mid-2025.

**HIGH confidence items:** Core Godot architecture, mobile export pipeline structure, Firebase service capabilities, general IAP architecture, CI/CD patterns. These are well-established patterns unlikely to have fundamentally changed.

**MEDIUM confidence items:** Specific plugin names and maintenance status, exact version requirements (JDK, API levels, Xcode), Firebase pricing details. These should be verified before implementation begins.

**LOW confidence items:** Whether specific community plugins have been updated for Godot 4.5 specifically. The Godot plugin ecosystem moves fast, and new plugins may have emerged or old ones may have been abandoned since mid-2025.

### Verification Checklist (Do Before Implementation)

- [ ] Verify GodotFirebase plugin compatibility with Godot 4.5 (check GitHub: GodotNuts/GodotFirebase or search Godot Asset Library)
- [ ] Verify AdMob plugin compatibility with Godot 4.5 (check GitHub: Poing-Studios/godot-admob-plugin or alternatives)
- [ ] Verify IAP plugin landscape for Godot 4.5 (search Godot Asset Library for "billing" and "storekit")
- [ ] Verify Android min/target API level requirements for Godot 4.5 export templates
- [ ] Verify iOS minimum version and Xcode requirement for Godot 4.5
- [ ] Verify JDK version required by Godot 4.5 Android export
- [ ] Check if Firebase REST API approach has been documented for Godot 4.x (community tutorials)
- [ ] Verify Google Play Store current target API level requirement (was API 34 in 2024)
- [ ] Check if RevenueCat has released a Godot SDK (would simplify cross-platform IAP significantly)
- [ ] Check if Godot 4.5 has any new built-in mobile-specific features (e.g., notification support, deep link handling)

---

*This document informs roadmap creation. Technology decisions should be finalized after the verification checklist is completed during the first development phase.*
