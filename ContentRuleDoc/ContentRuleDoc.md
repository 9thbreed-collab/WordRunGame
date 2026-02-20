# WORDRUN CONTENT SYSTEM

## MASTER DATABASE + TIER FILTERING MODEL

### RULES DOCUMENT v2.0

---

## 0. SYSTEM OVERVIEW

This is a deterministic content rules document, not a philosophy document.

Everything below is written so a terminal AI or scripted pipeline can execute it without interpretation, guessing, or drift.

No subjective judgment is allowed unless explicitly defined.

This system:
- Builds one Master Phrase Database
- Scores all phrases deterministically
- Constructs a directed phrase graph
- Generates levels using tier-based filtering views
- Keeps per-level difficulty stable
- Uses stair-step progression across levels
- Separates narrative abstraction from difficulty

No component may use subjective guessing.

---

## 0.1 GLOBAL STRUCTURE

| Metric | Value |
|--------|-------|
| Total Levels | 3,024 |
| Acts | 3 |
| Levels per Act | 1,008 |
| Nations | 9 |
| Levels per Nation per Act | 112 |
| Difficulty Tiers | 10 (global) |

Nations (9 total):
1. Corinthia (includes North sub-region)
2. Carnea
3. Patmos
4. Gilead
5. Kanaan
6. Aethelgard
7. Niridia
8. Salomia
9. Tobin

Each Nation is visited once per Act (3 total visits per Nation).

Difficulty tiers are GLOBAL across all 3,024 levels.
- They do NOT reset per Act.
- They do NOT reset per Nation.

Tone increases smoothly within each Act via a continuous function.

Themes are Nation-scoped, not Act-unlocked.

Industries are Nation-scoped and constant across all Acts.

---

## 0.2 FIVE INDEPENDENT AXES

The system operates on 5 independent axes:

1. **Difficulty** (global, monotonic)
2. **Tier windows** (filter buckets)
3. **Tone cap** (act-based continuous function)
4. **Nation abstraction density**
5. **Industry word pools**

**CRITICAL**: No axis may alter another.

No subjective vibe decisions allowed.

All filtering must be rule-based.

---

## 1. MASTER PHRASE DATABASE CONSTRUCTION

### 1.1 Candidate Phrase Generation

AI generates raw candidate phrases under these strict constraints:

Each phrase must:
1. Contain exactly two words.
2. Words separated by exactly one space.
3. No hyphenated words.
4. No punctuation.
5. No numerals.
6. No slang.
7. No profanity.
8. No politics.
9. No religion.
10. No violence.
11. No sexual content.
12. No phrase that is primarily known as part of a 3+ word idiom.
13. Both words must appear in a standard English dictionary.
14. Phrase must exist in American English usage.

Output format:
```
phrase,word1,word2
```

Example:
```
cold cut,cold,cut
```

Raw phrases stored in:
```
phrases_raw.csv
```

---

## 2. VALIDATION STAGE

Each phrase must pass all checks below.

Reject phrase if any fail.

### 2.1 Dictionary Validation

```
dictionary_check(word1) == true
dictionary_check(word2) == true
```

Source: standardized English dictionary dataset.

### 2.2 Word Frequency Validation (Objective)

Use wordfreq (Zipf scale).

```python
wordfreq.zipf_frequency(word, 'en')
```

Version must be pinned.

For each word:
```
zipf(word) >= 4.0
```

If either word < 4.0 → reject phrase.

Zipf values must be precomputed and stored in Master Word DB.

No runtime recalculation.

### 2.3 Phrase Structure Validation

Reject if:
- Phrase commonly appears as truncated part of 3-word idiom.
- Phrase is typically written as a single compound word and rarely separated.
- Phrase contains plural possessive fragment that implies missing third word.

This must be validated via frequency search:

If:
```
frequency("phrase + third_word") > frequency("phrase")
```
Reject.

Validated phrases stored in:
```
phrases_validated.csv
```

---

## 3. SCORING METRICS

Each validated phrase receives deterministic metrics.

### 3.1 WORD LENGTH

```
word1_length = len(word1)
word2_length = len(word2)
avg_word_length = (word1_length + word2_length) / 2
```

No rounding.

### 3.2 FAMILIARITY SCORE (OBJECTIVE)

Familiarity is computed using Zipf frequency only.

```
zipf1 = zipf(word1)
zipf2 = zipf(word2)
avg_zipf = (zipf1 + zipf2) / 2
```

Convert avg_zipf to familiarity_score:

| avg_zipf | familiarity_score |
|----------|-------------------|
| >= 6.0 | 5 |
| 5.5–5.99 | 4 |
| 5.0–5.49 | 3 |
| 4.5–4.99 | 2 |
| < 4.5 | 1 |

For MVP:
```
Reject familiarity_score < 3.
```

### 3.3 ENTROPY (PRIMARY DIFFICULTY DRIVER)

Definition:

For phrase P:
```
starter = word1
first_letter = first letter of word2
```

Entropy calculation:
```
entropy_score = count of phrases Q in validated database
where:
    Q.word1 == starter
    AND Q.word2 starts with first_letter
```

This count includes the phrase itself.

Entropy must be computed from validated database only.

No external estimation.

### 3.4 DIFFICULTY SCORE (FINAL FORMULA)

The model is **additive**, not multiplicative.

Multiplication causes:
- Exponential scaling
- Instability across tiers
- Extreme sensitivity to outliers
- Difficulty spikes

We want subtle, stackable progression.

**Formula:**
```
difficulty_score =
    (w_entropy * entropy)
  + (w_length * avg_word_length)
  + (w_familiarity * familiarity_penalty)
```

Where:
```
familiarity_penalty = (zipf_max - avg_zipf)
```

Zipf must be inverted because:
- Higher Zipf = more common = easier
- We want: Lower familiarity → higher difficulty

**Constants (Locked):**
```
w_entropy = 5
w_length = 3
w_familiarity = 2
zipf_max = 7
```

**Final formula:**
```
difficulty_score =
    (5 * entropy)
  + (3 * avg_word_length)
  + (2 * (7 - avg_zipf))
```

Priority order:
```
Entropy > Word Length > Familiarity
```

Additive only. No multiplication allowed.

Stored as float. No rounding.

---

## 4. CONTENT EXCLUSION LAYER

"Vibe" must be encoded deterministically.

Use the following hierarchy:

### 4.1 Layer A — Word Category Filtering (Primary System)

Each word in Master Word DB must include:
- `semantic_categories` (multi-label, 1-3 max)
- `tone_score` (0–100)
- `zipf_score`

Each Nation defines:
- `allowed_categories`
- `disallowed_categories`

**Filtering Rule:**
```
If any word in phrase has a category disallowed by the active Nation → reject phrase.
```

No subjective judgment permitted.

### 4.2 Layer B — Word Blacklist (Hard Override)

Explicit banned token list.

Used only for edge cases not captured by categories.

### 4.3 Layer C — Phrase Blacklist (Minimal Use)

Explicit phrase-level override.

This replaces subjective vibe evaluation.

### 4.4 SEMANTIC CATEGORY MASTER LIST (LOCKED)

Do NOT allow AI to invent categories dynamically.

Use this fixed master category set:

```
nature
animal
pest
food
drink
alcohol
household
object_neutral
clothing
emotion
relationship
social
commerce
trade
transport
maritime
architecture
civic
religious
abstract
conflict
violence
medical
anatomy
grime
disease
political
communication
music
agriculture
craft
law
festival
```

Each word must have:
- 1–3 categories max
- Assigned manually or rule-based
- Version controlled

No category sprawl.

---

## 5. TONE SYSTEM

### 5.1 TONE CAP RANGES

Tone ranges are NOT equal thirds:

| Act | Tone Range |
|-----|------------|
| Act 1 | 0 → 33.33 |
| Act 2 | 33.33 → 80 |
| Act 3 | 80 → 100 |

This preserves narrative acceleration.

### 5.2 TONE CAP FUNCTIONS

**Act 1:**
```
tone_cap(level) = ((level - 1) / 1007) * 33.33
```

**Act 2:**
```
tone_cap(level) = 33.33 + ((level - 1009) / 1007) * (80 - 33.33)
```

**Act 3:**
```
tone_cap(level) = 80 + ((level - 2017) / 1007) * 20
```

Continuous. No jumps.

### 5.3 PHRASE TONE SCORE

```
phrase.tone_score = MAX(word1.tone_score, word2.tone_score)
```

Not average.

Reason: If either word carries heavy tone, the phrase inherits that intensity. Using average would dilute tone artificially.

**Validation rule:**
```
if phrase.tone_score > tone_cap(level):
    reject phrase
```

**CRITICAL:** Tone never affects difficulty_score.

---

## 6. THEME TAGGING

Theme tagging does NOT influence difficulty_score.

Tags are binary: 0 or 1.

### 6.1 NATION ABSTRACTIONS

Each Nation has:
- `primary_abstraction`
- `opposing_abstraction`

| Nation | Primary (Fruit) | Opposing (Work) |
|--------|-----------------|-----------------|
| Corinthia | Temperance | Adultery |
| Carnea | Joy | Drunkenness |
| Patmos | Meekness | Seditions |
| Gilead | Longsuffering | Wrath |
| Kanaan | Faith | Idolatry |
| Aethelgard | Love | Hatred |
| Niridia | Gentleness | Murders |
| Salomia | Peace | Sedition |
| Tobin | Goodness | Envyings |

### 6.2 NATION ABSTRACTION RULES

- **Visit 1 (Act 1):** Nation uses primary abstraction identity (opposing dominant).
- **Visit 2 (Act 2):** Nation maintains same abstraction identity.
- **Visit 3 (Act 3):** Nation transitions toward inverse abstraction (restoration).

Example:
- Carnea: Act 1–2 → Drunkenness dominant. Act 3 → Joy restoration.
- Salomia: Act 1–2 → Sedition dominant. Act 3 → Peace restoration.

Abstraction identity does NOT change difficulty.

It only influences theme density and tone scoring.

### 6.3 THEME TAGGING METHOD (NO GUESSING)

Use keyword lexicon lists.

Theme density is computed via literal keyword matching only.

- No embeddings.
- No inference.
- No semantic similarity.

Each abstraction must define:
- `keyword_list`
- `keyword_weight`
- `max_density_per_tier`

If either word in phrase matches lexicon → tag = 1.

Max 2 tags per phrase.

### 6.4 KEYWORD LEXICONS (APPROVED)

**Match Method:** Case-insensitive exact match
**Match Location:** Either word1 OR word2
**Tag Assignment:** If match found → tag = 1
**Multiple Matches:** Max 2 tags per phrase
**No Partial Match:** "hidden" does not match "hide"

#### ADULTERY LEXICON (Corinthia)

Symbolic Theme: Concealment, division, duality, betrayal of trust

```
hidden, secret, double, split, side, blind, cover, shadow, mask, false,
second, half, dual, two, apart, private, closed, behind, under, sneak,
slip, other, veil, cloak, fold, turn, away, break, crack, torn
```

Keyword Count: 31

#### DRUNKENNESS LEXICON (Carnea)

Symbolic Theme: Instability, liquid, sway, excess, blur

```
liquid, pour, spill, dizzy, sway, blur, float, tip, tilt, spin,
rock, wave, flood, flow, drown, deep, cup, glass, full, empty,
stagger, stumble, heavy, haze, fog, thick, warm, rush, wild, loose
```

Keyword Count: 31

#### SEDITION LEXICON (Patmos, Salomia)

Symbolic Theme: Rebellion, faction, covert action, whisper networks

```
whisper, plot, rebel, covert, code, spy, secret, shadow, under, ground,
cell, group, band, gather, meet, plan, signal, sign, mark, hidden,
silent, quiet, still, wait, watch, rise, stand, fall, break, change
```

Keyword Count: 31

#### LEXICON OVERLAP

Keywords appearing in multiple lexicons create thematic bridges:

| Keyword | Adultery | Drunkenness | Sedition |
|---------|----------|-------------|----------|
| hidden | X | | X |
| secret | X | | X |
| shadow | X | | X |
| under | X | | X |
| break | X | | X |

Overlap is allowed. Phrases matching multiple lexicons receive up to 2 tags.

---

## 7. INDUSTRY WORD POOLS

Industries are Nation-scoped.

They are constant across all 3 Acts.

They add word pools (single words only).

They do NOT add phrase pools.

### 7.1 INDUSTRY WORD REQUIREMENTS

Industry words must:
- Pass familiarity threshold (zipf >= 4.0)
- Avoid niche jargon
- Avoid deep technical terminology
- Pass entropy constraints

Industry words are symbolic reinforcement, not literal profession simulation.

### 7.2 INDUSTRY ASSIGNMENTS (LOCKED)

| Nation | Industry | Word Pool Examples |
|--------|----------|-------------------|
| Corinthia | Maritime Trade / Governance | port, dock, ledger, seal, decree, harbor, ferry, court |
| Carnea | Festivals / Brewing / Music | barrel, cider, drum, lantern, feast, toast, grape, tavern |
| Patmos | Printing / Proclamation | press, ink, scroll, banner, bell, square, torch |
| Gilead | Stonework / Fortification | stone, wall, iron, gate, forge, shield |
| Kanaan | Temple Craft | altar, pillar, veil, flame, chant, idol |
| Aethelgard | Textiles / Letters / Gardens | rose, silk, ribbon, letter, ring, ivy |
| Niridia | Medicine / Care (non-gory) | balm, herb, cup, linen, candle |
| Salomia | Civic Architecture | hall, arch, oath, banner, bell, square |
| Tobin | Trade Guilds | market, coin, scale, crate, stall, wagon |

All industry pools must be reviewed against abstraction drift.

---

## 8. GRAPH CONSTRUCTION

Build directed graph:

- Node = phrase.
- Edge from A → B if: `A.word2 == B.word1`

Rules:
- No self-loop.
- No duplicate edges.
- Graph stored as adjacency list JSON.

---

## 9. TIER-BASED FILTERING VIEWS

Master DB never changes.

Tier view applies constraints dynamically.

### 9.1 TIER BOUNDARIES (GLOBAL)

There are 10 difficulty tiers across 3,024 levels.

| Tier | Level Range |
|------|-------------|
| 1 | 1–302 |
| 2 | 303–604 |
| 3 | 605–906 |
| 4 | 907–1,208 |
| 5 | 1,209–1,512 |
| 6 | 1,513–1,814 |
| 7 | 1,815–2,116 |
| 8 | 2,117–2,418 |
| 9 | 2,419–2,720 |
| 10 | 2,721–3,024 |

Difficulty_target changes only when tier changes.

Within a tier block: No parameter drift allowed.

### 9.2 TIER CONFIG STRUCTURE

Example (Tier 1):
```
difficulty_target = 20
window_percent = 8
entropy_cap = 2
min_familiarity = 4
theme_density_target = 0.45
theme_density_range = 0.40–0.55
```

---

## 10. LEVEL GENERATION RULES

Each level:
- 16 phrases
- Strictly linear
- No repetition
- No loops
- Dead-end allowed only at final phrase

### 10.1 DIFFICULTY BAND RULE

Let:
```
window = difficulty_target * window_percent
```

All phrases must satisfy:
```
difficulty_score ∈ [difficulty_target - window, difficulty_target + window]
```

### 10.2 ENTROPY CAP RULE

All phrases must satisfy:
```
entropy_score <= entropy_cap
```

### 10.3 FAMILIARITY RULE

```
familiarity_score >= min_familiarity
```

### 10.4 THEME DENSITY RULE

Let:
```
tagged_phrases = count of phrases with any theme tag = 1
density = tagged_phrases / 16
```

Must satisfy:
```
density ∈ theme_density_range
```

Additional constraints:
- No more than 2 tagged phrases consecutively.
- Tagged phrases cannot occupy positions 1–2 both.
- Tagged phrases cannot occupy positions 15–16 both.

This prevents theme front-loading or heavy endings.

---

## 11. LEVEL-TO-TIER MAPPING (MVP)

**Act 1 = Levels 1–1,008**

**MVP = Levels 1–336**

Nations visible in MVP (first visit order):
1. Corinthia
2. Carnea
3. Patmos

Difficulty tiers remain global.

Tone cap uses Act 1 tone function:
```
tone_cap(level) = ((level - 1) / 1007) * 33.33
```

No special casing for MVP.

The system must behave as though all 3,024 levels exist.

---

## 12. PATHFINDING ALGORITHM

Input: Tier configuration.

Process:
1. Filter nodes by:
   - difficulty band
   - entropy cap
   - familiarity minimum
   - tone cap
   - Nation category constraints
2. Construct filtered graph.
3. Perform DFS with:
   - depth_limit = 16
   - no node repetition
   - stop at dead-end only if depth == 16
4. After candidate path found: Validate theme density rules.
5. If fail: Continue search.
6. Return first valid path.

---

## 13. OUTPUT FORMAT

Each level output:
```
level_number
tier_name
difficulty_target
phrase_sequence:
1. cold cut
2. cut down
3. down town
...
16. final phrase
```

---

## 14. ABSOLUTE NON-NEGOTIABLES

The system must NEVER:
- Guess familiarity.
- Guess entropy.
- Use subjective "common sense."
- Use semantic similarity for tagging.
- Modify difficulty formula dynamically.
- Adjust window inside level.
- Allow any axis to alter another.

All evaluation must be numeric and reproducible.

---

## 15. SYSTEM SUMMARY

You now have:
- Master database
- Deterministic scoring
- Objective familiarity
- Computed entropy
- Stable per-level difficulty
- Stair-step global progression
- Theme separated from difficulty
- Tone cap system
- Content exclusion layers
- Industry word pools
- No drift architecture

---

## VERSION HISTORY

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-19 | Initial deterministic system |
| 2.0 | 2026-02-19 | Added: 5-axis architecture, tone cap functions, content exclusion layers, industry pools, nation abstractions, difficulty formula constants, semantic category list |
