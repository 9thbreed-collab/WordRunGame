# Cloud Database Design: WordRun! Content Pipeline

**Decision:** Firebase (Firestore + Cloud Storage) per STACK.md research recommendation
**Goal:** Zero gameplay latency, 100% offline capability after initial download

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      CLOUD STORAGE                          │
│  (Bulk Content - Downloaded Once Per Land)                  │
│                                                              │
│  /lands/{land_id}/content.json   <- All levels + word data  │
│  /lands/{land_id}/manifest.json  <- Version, checksum       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ Download on land entry
┌─────────────────────────────────────────────────────────────┐
│                     FIRESTORE                                │
│  (Metadata, Versioning, Player State)                       │
│                                                              │
│  /content_versions     <- Current version per land          │
│  /word_metadata        <- Difficulty, rarity, lore tags     │
│  /profanity_filter     <- Blocked words + safe exceptions   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ Cached locally (user://)
┌─────────────────────────────────────────────────────────────┐
│                    LOCAL CACHE                               │
│  (ContentCache autoload - already exists)                   │
│                                                              │
│  user://content_cache/{land_id}.json                        │
│  user://content_cache/versions.json                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Firestore Collections

### 1. `/content_versions` (Single Document)

Tracks current version of all content. Client checks this on app launch.

```json
{
  "document_id": "current",
  "lands": {
    "corinthia": { "version": "1.2.0", "checksum": "sha256:abc123...", "size_kb": 45 },
    "forest": { "version": "1.0.0", "checksum": "sha256:def456...", "size_kb": 52 },
    "desert": { "version": "1.1.0", "checksum": "sha256:ghi789...", "size_kb": 48 }
  },
  "profanity_filter_version": "2.1.0",
  "metadata_version": "1.0.0",
  "updated_at": "2026-02-07T12:00:00Z"
}
```

**Read pattern:** Single document read on app launch (~1 read/session)

---

### 2. `/word_metadata/{word}` (Build-Time Reference)

Master word database with validation attributes. Used at **content authoring time**, NOT runtime.

```json
{
  "document_id": "sunflower",
  "word": "sunflower",
  "length": 9,
  "difficulty": {
    "score": 2,           // 1=easy (3-4 chars), 2=medium (5-7), 3=hard (8+)
    "ambiguity": 1,       // 1=unique solution, 2=some alternatives, 3=many alternatives
    "typing_complexity": 1 // 1=common keys, 2=some rare keys, 3=awkward patterns
  },
  "rarity": {
    "frequency_rank": 8500,      // 1=most common, higher=rarer
    "corpus": "english_compound", // which word list
    "commonness_tier": 2          // 1=everyday, 2=familiar, 3=uncommon, 4=rare
  },
  "lore_tags": ["nature", "plants", "corinthia", "growth", "garden"],
  "profanity": {
    "is_profane": false,
    "is_safe_exception": false,  // true for words like "class" that contain profane substrings
    "notes": ""
  },
  "compounds": {
    "as_first": ["sunflower_seed", "sunflower_oil"],  // valid compound phrases
    "as_second": ["wild_sunflower"]
  },
  "validated": true,
  "validated_at": "2026-01-15T10:00:00Z"
}
```

**Read pattern:** NOT read at runtime. Used by content authoring pipeline only.

---

### 3. `/word_pairs/{pair_id}` (Build-Time Reference)

Validated two-word combinations with compound scoring.

```json
{
  "document_id": "sun_flower",
  "word_a": "sun",
  "word_b": "flower",
  "compound_type": "compound_word",  // compound_word, phrase, expression
  "difficulty": {
    "combined_score": 2,
    "ambiguity_score": 1,  // could "sun" + ? have other answers? (sunlight, sunshine)
    "hint_letters_needed": 3  // minimum letters before solution is obvious
  },
  "rarity": {
    "phrase_frequency": 7200,
    "commonness_tier": 1  // 1=very common phrase
  },
  "lore_tags": ["nature", "corinthia", "plants"],
  "nations": ["corinthia", "forest"],  // which nations can use this pair
  "mood": "cheerful",  // cheerful, neutral, tense, mysterious, dark
  "profanity_check": {
    "word_a_safe": true,
    "word_b_safe": true,
    "compound_safe": true  // "sunflower" checked as combined word
  },
  "validated": true
}
```

**Read pattern:** NOT read at runtime. Used by content authoring pipeline.

---

### 4. `/profanity_filter` (Single Document)

Runtime-loadable profanity filter for edge cases.

```json
{
  "document_id": "v2",
  "version": "2.1.0",
  "blocked_words": ["<redacted list>"],
  "blocked_patterns": ["<regex patterns>"],
  "safe_exceptions": [
    "class", "assassin", "basement", "therapist", "assume",
    "grape", "scrap", "cocktail", "classic", "arsenal"
  ],
  "compound_blocks": ["<combinations that become profane when joined>"],
  "updated_at": "2026-02-01T00:00:00Z"
}
```

**Read pattern:** Downloaded once, cached indefinitely. ~1 read per app install.

---

### 5. `/nations/{nation_id}` (Metadata)

Nation/land structure and lore configuration.

```json
{
  "document_id": "corinthia_nation",
  "nation_id": "corinthia_nation",
  "display_name": "The Grasslands",
  "order": 1,
  "theme": {
    "primary_color": "#4a7c23",
    "mood": "cheerful",
    "tone": "welcoming",
    "culture_reference": "pastoral, agrarian"
  },
  "lore": {
    "description": "Rolling meadows where Ruut begins the journey",
    "word_pool_tags": ["nature", "plants", "animals", "weather", "farm"],
    "excluded_tags": ["dark", "industrial", "urban"],
    "mood_progression": ["cheerful", "curious", "determined"]
  },
  "lands": [
    { "land_id": "corinthia", "order": 1, "level_count": 10 },
    { "land_id": "meadow_path", "order": 2, "level_count": 10 },
    { "land_id": "flower_fields", "order": 3, "level_count": 10 }
  ],
  "obstacle_type": "padlock",
  "boss_config": {
    "npc_name": "Thornwick",
    "personality": "grumpy gardener"
  }
}
```

**Read pattern:** Once per nation entry, cached.

---

## Cloud Storage Structure

All level content is stored in Cloud Storage as JSON files for bulk download.

```
gs://wordrun-content/
├── lands/
│   ├── corinthia/
│   │   ├── content.json      # Full land content (all 10 levels)
│   │   └── manifest.json     # Version, checksum, metadata
│   ├── meadow_path/
│   │   ├── content.json
│   │   └── manifest.json
│   └── ... (25 lands total)
├── filters/
│   └── profanity_v2.json     # Profanity filter data
└── metadata/
    └── word_database.json    # Full word metadata (build-time only)
```

### Land Content File: `content.json`

```json
{
  "land_id": "corinthia",
  "display_name": "Grasslands",
  "nation_id": "corinthia_nation",
  "theme": {
    "mood": "cheerful",
    "lore_tags": ["nature", "plants", "growth"]
  },
  "version": "1.2.0",
  "levels": [
    {
      "level_id": "corinthia_01",
      "level_name": "Level 1",
      "difficulty": 1,
      "time_limit_seconds": 180,
      "base_word_count": 12,
      "bonus_word_count": 3,
      "word_pairs": [
        {
          "word_a": "",
          "word_b": "sun",
          "difficulty": 1,
          "rarity": 1,
          "lore_fit": 5
        },
        {
          "word_a": "sun",
          "word_b": "flower",
          "difficulty": 1,
          "rarity": 1,
          "lore_fit": 5
        }
      ],
      "surge_config": { ... },
      "obstacle_configs": [ ... ]
    }
  ]
}
```

---

## Validation Filter Integration

### Filter 1: Difficulty

**Attributes:**
- `length`: Character count (short: 3-4, medium: 5-7, long: 8+)
- `ambiguity`: How many valid answers exist for word_a + ? (1=unique, 3=many)
- `typing_complexity`: Keyboard difficulty (common keys vs awkward patterns)

**Level Progression:**
| Level Range | Max Difficulty | Max Ambiguity | Notes |
|-------------|---------------|---------------|-------|
| 1-3 | 1 (easy) | 1 (unique) | Tutorial levels |
| 4-6 | 2 (medium) | 2 (some) | Learning curve |
| 7-9 | 2-3 | 2-3 | Challenge building |
| 10 (boss) | 3 (hard) | 3 | Full difficulty |

### Filter 2: Rarity

**Attributes:**
- `frequency_rank`: Position in word frequency corpus (1=most common)
- `commonness_tier`: 1=everyday, 2=familiar, 3=uncommon, 4=rare

**Level Progression:**
| Level Range | Max Rarity Tier | Notes |
|-------------|----------------|-------|
| 1-5 | 1-2 | Common phrases only |
| 6-8 | 2-3 | Mix in some uncommon |
| 9-10 | 2-4 | Rare words allowed |

### Filter 3: Lore (Nation/Land Theming)

**Attributes:**
- `lore_tags`: Array of theme tags (nature, dark, industrial, etc.)
- `mood`: Emotional tone (cheerful, tense, mysterious, dark)
- `nations`: Which nations can use this word pair

**Application:**
- Each nation defines `word_pool_tags` and `excluded_tags`
- Word pairs must have at least 1 matching lore tag
- Word pairs must not have any excluded tags
- Mood should match nation's mood progression

**Example - Grasslands Nation:**
```
Required tags (any): nature, plants, animals, weather, farm, growth
Excluded tags: dark, industrial, urban, violence
Mood range: cheerful, curious, determined
```

### Filter 4: Profanity

**Layers:**
1. **Direct block**: Word is in blocked list
2. **Pattern block**: Word matches blocked regex
3. **Safe exception**: Word contains profane substring but is safe (e.g., "class")
4. **Compound check**: word_a + word_b checked as single string

**Pipeline:**
```
Input: "sun" + "flower"
  ├── Check "sun" → not in blocked list → PASS
  ├── Check "flower" → not in blocked list → PASS
  ├── Check "sunflower" → not in blocked list → PASS
  └── Result: VALID
```

---

## Content Authoring Pipeline

### Build-Time Validation Flow

```
1. Author creates word pairs in spreadsheet/database
                    │
                    ▼
2. WordValidator checks dictionary membership
   - Is word_a in dictionary? (skip if empty)
   - Is word_b in dictionary?
                    │
                    ▼
3. DifficultyScorer assigns difficulty attributes
   - Length score
   - Ambiguity score (query word_metadata for alternatives)
   - Typing complexity score
                    │
                    ▼
4. RarityScorer assigns rarity attributes
   - Look up frequency_rank in corpus
   - Assign commonness_tier
                    │
                    ▼
5. LoreFilter checks theme compatibility
   - Does pair have required lore tags for target nation?
   - Does pair have any excluded tags?
   - Does mood match nation progression?
                    │
                    ▼
6. ProfanityFilter checks safety
   - Direct word checks
   - Pattern matching
   - Safe exception lookup
   - Compound combination check
                    │
                    ▼
7. Valid pairs written to Cloud Storage
   - lands/{land_id}/content.json
   - Update content_versions in Firestore
```

### Updated WordValidator Interface

```gdscript
## scripts/tools/word_validator.gd (expanded)
class_name WordValidator
extends RefCounted

var _dictionary: Dictionary = {}
var _word_metadata: Dictionary = {}  # word -> metadata
var _profanity_filter: ProfanityFilter

## Validate a word pair with all filters
func validate_pair_full(word_a: String, word_b: String, nation_config: Dictionary) -> Dictionary:
    var result := {
        "valid": true,
        "errors": [],
        "warnings": [],
        "scores": {
            "difficulty": 0,
            "rarity": 0,
            "lore_fit": 0
        }
    }

    # Dictionary check
    if word_a != "" and not is_valid_word(word_a):
        result.valid = false
        result.errors.append("Not in dictionary: " + word_a)
    if not is_valid_word(word_b):
        result.valid = false
        result.errors.append("Not in dictionary: " + word_b)

    # Difficulty scoring
    result.scores.difficulty = _calculate_difficulty(word_a, word_b)

    # Rarity scoring
    result.scores.rarity = _calculate_rarity(word_a, word_b)

    # Lore fit
    var lore_result := _check_lore_fit(word_a, word_b, nation_config)
    result.scores.lore_fit = lore_result.score
    if not lore_result.fits:
        result.warnings.append("Poor lore fit: " + lore_result.reason)

    # Profanity check
    if _profanity_filter.check_compound(word_a, word_b):
        result.valid = false
        result.errors.append("Profanity detected")

    return result
```

---

## Runtime Flow (Zero Latency)

### App Launch
```
1. Check local cache versions (user://content_cache/versions.json)
2. Fetch /content_versions from Firestore (single doc read)
3. Compare versions
4. If updates available:
   - Queue background download for updated lands
   - Continue with cached content
```

### Entering a Land
```
1. Check local cache for land content
2. If cached and version matches:
   - Load from user://content_cache/{land_id}.json → INSTANT
3. If not cached or outdated:
   - Show download progress bar
   - Download from Cloud Storage
   - Save to local cache
   - Load content
```

### During Gameplay
```
- ALL content loaded from local cache
- ZERO network calls during gameplay
- Firestore offline persistence as backup
```

---

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Content versions - read only
    match /content_versions/{doc} {
      allow read: if true;
      allow write: if false;  // Admin SDK only
    }

    // Word metadata - no client access (build-time only)
    match /word_metadata/{word} {
      allow read, write: if false;
    }

    // Word pairs - no client access (build-time only)
    match /word_pairs/{pair} {
      allow read, write: if false;
    }

    // Profanity filter - read only
    match /profanity_filter/{doc} {
      allow read: if true;
      allow write: if false;
    }

    // Nations - read only
    match /nations/{nation} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

---

## Cloud Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Lands content - read only
    match /lands/{land}/{file} {
      allow read: if true;
      allow write: if false;  // Admin SDK only
    }

    // Filters - read only
    match /filters/{file} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

---

## Cost Optimization

| Operation | Frequency | Firestore Reads | Cloud Storage |
|-----------|-----------|-----------------|---------------|
| App launch version check | 1/session | 1 read | 0 |
| Land download | 1/land/ever | 0 | ~50KB download |
| Gameplay | 0 | 0 | 0 |
| Content update check | 1/day | 1 read | 0 |

**Estimated monthly costs at 10,000 DAU:**
- Firestore: ~$1-2 (version checks only)
- Cloud Storage: ~$5-10 (initial land downloads, updates)
- Cloud Functions: ~$0 (not needed for content delivery)

---

## Implementation Checklist

### Phase 4 (Current)
- [ ] Design Cloud Storage bucket structure
- [ ] Create Firestore collections for content_versions
- [ ] Update ContentCache to check versions
- [ ] Add Cloud Storage download capability to ContentCache
- [ ] Implement background download queue

### Phase 7 (Backend Integration)
- [ ] Set up Firebase project
- [ ] Deploy Firestore security rules
- [ ] Deploy Cloud Storage security rules
- [ ] Create admin scripts for content upload
- [ ] Build content authoring pipeline with full validation

---

*Schema designed: 2026-02-07*
*Based on: STACK.md Firebase recommendation*
