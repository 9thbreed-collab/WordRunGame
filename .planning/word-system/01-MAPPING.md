# WordRun! Progression Mapping Document

## Purpose

This document defines WHERE the player is in the game and WHAT constraints apply to word pair selection at each stage. It serves as the first step in the word generation pipeline:

```
MAPPING (this doc) → PHRASE BANK → LAS VALIDATION → CHAIN BUILDER → OUTPUT
```

The Mapping outputs constraints; downstream systems filter and validate against them.

---

## MVP Scope

| Metric | Value |
|--------|-------|
| Nations | 3 (Corinthia, Carnea, Patmos) |
| Lands per Nation | 8 |
| Levels per Land | 14 |
| Total MVP Levels | 336 |
| Playthroughs | 3 (same levels, different difficulty/tone) |

### Travel Route (MVP)
```
Corinthia (Home) → Carnea (Ally) → Patmos (Neutral)
```

---

## Section 1: Progression Bands

### By Nation (MVP)

| Nation | Levels | Progression % | Tone Character |
|--------|--------|---------------|----------------|
| Corinthia | 1-112 | 0-33% | Temperate but secretive; dual nature |
| Carnea | 113-224 | 33-67% | Joyful but unsteady; liquid/dizzy |
| Patmos | 225-336 | 67-100% | Meek but subversive; spy/covert |

### By Land (Within Each Nation)

| Land | Levels | Nation % | Cumulative % | Notes |
|------|--------|----------|--------------|-------|
| L1 | 1-14 | 0-12.5% | Early | Tutorial zone, simplest phrases |
| L2 | 15-28 | 12.5-25% | | Gentle difficulty increase |
| L3 | 29-42 | 25-37.5% | | Light abstraction introduced (sparse) |
| L4 | 43-56 | 37.5-50% | Mid | Light tension allowed |
| L5 | 57-70 | 50-62.5% | | Theme signals introduced |
| L6 | 71-84 | 62.5-75% | | Full abstraction available |
| L7 | 85-98 | 75-87.5% | | Full tension, difficulty peaks |
| L8 | 99-112 | 87.5-100% | Late | Climax, all tones available |

---

## Section 2: Nation Profiles

### Corinthia (Temperance / Adultery)
**Player's Home Nation**

```json
{
  "nation_id": "corinthia",
  "fruit_of_spirit": "Temperance",
  "work_of_flesh": "Adultery",
  "tone_keywords": ["balanced", "controlled", "hidden", "divided"],
  "abstraction_signals": {
    "use": ["secret", "divided", "broken", "hidden", "double", "mask", "veil"],
    "avoid": ["sex", "affair", "lover", "cheat", "betray"]
  },
  "cultural_character": "Self-controlled on the surface but harboring secrets; duality between public virtue and private compromise",
  "environmental_themes": ["markets", "gardens", "domestic spaces", "mirrors", "veils"]
}
```

#### Progression Constraints (Corinthia)

| Land | LAS Floor | LAS Ceiling | Allowed Tones | Allowed Categories | Forbidden |
|------|-----------|-------------|---------------|--------------------| ----------|
| L1 | 85 | 100 | neutral | food, household, objects | abstract, tension, theme |
| L2 | 80 | 100 | neutral | food, household, objects, nature | abstract, tension, theme |
| L3 | 80 | 100 | neutral, warm | + commerce, light abstraction (sparse) | tension, theme |
| L4 | 75 | 100 | neutral, warm, light_tension | + daily activities | theme |
| L5 | 75 | 95 | neutral, warm, light_tension | + theme signals (secret, hidden) | explicit |
| L6 | 70 | 95 | all except aggressive | + full abstraction | explicit |
| L7 | 65 | 90 | all except aggressive | + full tension phrases | explicit |
| L8 | 65 | 90 | all | all available | explicit |

---

### Carnea (Joy / Drunkenness)
**First Nation Visited**

```json
{
  "nation_id": "carnea",
  "fruit_of_spirit": "Joy",
  "work_of_flesh": "Drunkenness",
  "tone_keywords": ["merry", "unstable", "indulgent", "fleeting"],
  "abstraction_signals": {
    "use": ["liquid", "pour", "spill", "dizzy", "sway", "merry", "stupor", "float", "blur"],
    "avoid": ["drunk", "wasted", "booze", "alcohol", "hangover", "addict"]
  },
  "cultural_character": "Pleasure-seeking and celebratory, but their joy is unstable and dependent on external stimulation; mood swings between ecstasy and emptiness",
  "environmental_themes": ["fountains", "festivals", "taverns", "flowing rivers", "colorful excess"]
}
```

#### Progression Constraints (Carnea)

| Land | LAS Floor | LAS Ceiling | Allowed Tones | Allowed Categories | Forbidden |
|------|-----------|-------------|---------------|--------------------| ----------|
| L1 | 80 | 100 | neutral, warm | food, drink, celebration, objects | abstract, tension, theme |
| L2 | 75 | 100 | neutral, warm, merry | food, drink, celebration, nature | abstract, tension, theme |
| L3 | 75 | 95 | neutral, warm, merry | + commerce, light abstraction (sparse) | tension, theme |
| L4 | 70 | 95 | neutral, warm, merry, light_tension | + daily activities | theme |
| L5 | 70 | 95 | all positive + unstable | + theme signals (pour, sway) | explicit |
| L6 | 65 | 90 | all except aggressive | + full abstraction, mood phrases | explicit |
| L7 | 65 | 90 | all except aggressive | + full tension phrases | explicit |
| L8 | 60 | 85 | all | all available | explicit |

---

### Patmos (Meekness / Seditions)
**Second Nation Visited**

```json
{
  "nation_id": "patmos",
  "fruit_of_spirit": "Meekness",
  "work_of_flesh": "Seditions",
  "tone_keywords": ["humble", "quiet", "subversive", "covert"],
  "abstraction_signals": {
    "use": ["spy", "whisper", "plot", "rebel", "covert", "undermine", "shadow", "code", "cipher"],
    "avoid": ["traitor", "terrorist", "assassin", "overthrow"]
  },
  "cultural_character": "Outwardly humble and deferential, but harboring underground resistance movements; secrets passed in whispers, loyalty tested constantly",
  "environmental_themes": ["monasteries", "hidden passages", "quiet villages", "coded messages", "underground networks"]
}
```

#### Progression Constraints (Patmos)

| Land | LAS Floor | LAS Ceiling | Allowed Tones | Allowed Categories | Forbidden |
|------|-----------|-------------|---------------|--------------------| ----------|
| L1 | 75 | 100 | neutral, quiet | household, nature, objects | abstract, tension, theme |
| L2 | 70 | 95 | neutral, quiet | + daily activities | abstract, tension, theme |
| L3 | 70 | 95 | neutral, quiet, subdued | + commerce, light abstraction (sparse) | tension, theme |
| L4 | 65 | 95 | neutral, quiet, subdued, light_tension | + communication | theme |
| L5 | 65 | 90 | + covert | + theme signals (whisper, code) | explicit |
| L6 | 60 | 90 | + tension | + full abstraction, spy/covert phrases | explicit |
| L7 | 55 | 85 | all except aggressive | + full tension, rebellion phrases | explicit |
| L8 | 50 | 85 | all | all available including rebel | explicit |

---

## Section 3: Playthrough Variations

The player traverses the same levels 3 times with escalating difficulty and shifting tone.

### Playthrough 1: Introduction
**World State:** Normal (pre-antagonist influence)
**Mode:** Base (Mode B) - Works active but not amplified

| Adjustment | Value |
|------------|-------|
| LAS Floor Modifier | +0 (use base values) |
| Tone Allowance | Neutral to Warm only |
| Abstract Phrases | Minimal (L6+ only) |
| Theme Signals | Light (L5+ only) |
| Player Familiarity | Building muscle memory |

### Playthrough 2: Return Journey
**World State:** Aggressive (antagonist influence spreading)
**Mode:** Mix of Base (B) and Rebellion (C)

| Adjustment | Value |
|------------|-------|
| LAS Floor Modifier | -10 (harder phrases) |
| Tone Allowance | Tension phrases from L3+ |
| Abstract Phrases | Moderate (L4+ only) |
| Theme Signals | Full (L3+ only) |
| Scenery | Unrest visible, darker palette |
| Player Familiarity | Recognizes patterns, ready for challenge |

### Playthrough 3: Galvanization
**World State:** Crisis (full antagonist control)
**Mode:** Rebellion (C) with Transformation (A) emerging

| Adjustment | Value |
|------------|-------|
| LAS Floor Modifier | -15 (hardest phrases) |
| Tone Allowance | All tones available from L2+ |
| Abstract Phrases | Full (L2+ only) |
| Theme Signals | Full, including aggressive abstraction |
| Scenery | Dramatic transformation, hope emerging |
| Player Familiarity | Mastery expected |

---

## Section 4: Difficulty Scaling

Difficulty is expressed through multiple dimensions that loosen gradually:

### LAS Floor Progression (Playthrough 1)

| Game % | LAS Floor | LAS Ceiling | Notes |
|--------|-----------|-------------|-------|
| 0-10% | 85 | 100 | Automatic recognition |
| 10-25% | 80 | 100 | Very quick recall |
| 25-40% | 75 | 95 | Familiar, brief pause |
| 40-55% | 70 | 95 | Requires thought |
| 55-70% | 65 | 90 | Challenge begins |
| 70-85% | 60 | 90 | Domain knowledge helps |
| 85-100% | 55 | 85 | Expert territory |

### Constraint Relaxation

| Constraint | Unlocks At | Notes |
|------------|------------|-------|
| Light abstraction | 25% (L3) | "brain storm", "ground work" - sparse, not dense |
| Light tension | 35% (L4) | "stand off", "break down" |
| Theme signals | 45% (L5) | Nation-specific abstraction words |
| Full abstraction | 55% (L6) | Abstract phrases more frequent |
| Full tension | 65% (L7) | "fight back", "clash" |
| Aggressive tone | 75% (L8) | Reserved for climactic moments |
| Longer words (7+ chars) | 25% (L3) | "station", "question" |
| Less common words | 45% (L5) | "pellet", "cipher" |

---

## Section 4B: Repetition Rules

Repetition serves gameplay purpose: inductive reasoning. Players see familiar words and must discern context.

### Word Repetition (WELCOMED)
- Same word CAN appear in multiple levels
- Same word CAN appear in multiple chains
- Encourages pattern recognition
- Example: "card" appears in L1 ("card game") and L5 ("credit card")

### Phrase Repetition (ALLOWED, LESS FREQUENT)
- Same phrase CAN repeat across levels
- Should be spaced out (not consecutive levels)
- When repeated, player uses revealed letter hints to confirm or differentiate
- Creates inductive reasoning moments: "Is this the same 'card game' or different?"

### Repetition Guidelines by Scope

| Scope | Words | Phrases |
|-------|-------|---------|
| Within single level | No repeats | No repeats |
| Within single Land (14 levels) | Encouraged | Sparse (max 2-3 repeats) |
| Within single Nation (112 levels) | Frequent | Moderate (same phrase every 10-15 levels OK) |
| Across Nations | Very common | Common (reinforces learning) |

---

## Section 5: Theme Integration

### Land Scenery Themes (Unnamed Lands)

Since only "Bones Valley" is named, Lands use generic environmental themes that can be customized per Nation:

| Land | Environment Type | Phrase Category Boost |
|------|------------------|----------------------|
| L1 | Starting Village | household, daily life |
| L2 | Countryside/Farms | nature, food, animals |
| L3 | Market District | commerce, objects, trade |
| L4 | Urban Center | buildings, transportation |
| L5 | Industrial Zone | tools, work, machines |
| L6 | Cultural District | arts, entertainment |
| L7 | Government/Temple | formal, official |
| L8 | Border/Frontier | travel, transition |

### Nation-Specific Environmental Overlays

| Nation | L1-L2 | L3-L4 | L5-L6 | L7-L8 |
|--------|-------|-------|-------|-------|
| Corinthia | Gardens, homes | Markets, mirrors | Hidden chambers | Temples of virtue |
| Carnea | Vineyards, fountains | Festivals, taverns | Pleasure halls | Grand ballrooms |
| Patmos | Quiet villages | Monasteries | Hidden passages | Underground networks |

---

## Section 6: Query Interface

To query this document, provide:
- **Nation**: corinthia, carnea, or patmos
- **Land**: 1-8
- **Playthrough**: 1, 2, or 3

### Example Query

```
Nation: corinthia
Land: 5
Playthrough: 1
```

### Example Output

```json
{
  "progression_band": "50-62.5% of nation (16.7-20.8% of MVP)",
  "las_floor": 75,
  "las_ceiling": 95,
  "allowed_tones": ["neutral", "warm", "light_tension"],
  "allowed_categories": ["food", "household", "objects", "nature", "commerce", "daily_activities", "light_abstraction"],
  "theme_signals_allowed": true,
  "theme_signals": ["secret", "hidden", "double"],
  "forbidden_categories": ["explicit", "aggressive"],
  "word_length_max": 7,
  "commonality_requirement": "common"
}
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-13 | Initial MVP mapping (3 nations, 336 levels) |
