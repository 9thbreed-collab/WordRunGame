# Phrase Bank Generation Instructions

## For: Gemini / Codex
## Task: Generate 2000 validated two-word phrases for WordRun! game

---

## CRITICAL RULE (RULE ZERO)

**Before including ANY phrase, it must pass this test:**

### The Compound Word Gate
1. Search the phrase written as ONE word (e.g., "popcorn")
2. If it commonly appears as one word → **INVALID, DO NOT INCLUDE**
3. Only if it's predominantly written as TWO words → include it

### NEVER SPLIT THESE (Examples of Invalid Phrases)
```
popcorn, corndog, cupcake, pancake, bedroom, bathroom,
cardboard, catfish, goldfish, starfish, backyard,
doorbell, doorway, doorstep, doormat, doorknob,
sunlight, daylight, moonlight, starlight, rainbow,
breakfast, keyboard, bookcase, fireplace, suitcase,
showtime, nightclub, clubhouse, ballpark, snowball,
toothbrush, toothpaste, butterfly, newspaper,
roommate, teammate, classmate, caretaker, caregiver,
downtown, uptown, upgrade, update, download
```

### VALID TWO-WORD PHRASES (Examples)
```
ice cream, hot dog, high school, credit card,
seat belt, fire truck, school bus, bus stop, stop sign,
pizza box, box office, office chair, chair lift,
ball game, game day, card game, game show,
front door, back door, dog park, park bench
```

---

## OUTPUT FORMAT

Generate a JSON array. Each phrase object must have:

```json
{
  "phrase": "ice cream",
  "word_a": "ice",
  "word_b": "cream",
  "las_score": 100,
  "category": "food",
  "tone": "neutral",
  "word_a_length": 3,
  "word_b_length": 5,
  "commonality": "very_common",
  "chain_potential": ["cheese", "soda", "puff", "pie"],
  "nation_fit": ["all"]
}
```

### Field Definitions

| Field | Type | Description |
|-------|------|-------------|
| phrase | string | The complete two-word phrase |
| word_a | string | First word (shown to player) |
| word_b | string | Second word (player types this) |
| las_score | int 1-100 | Lexical Association Strength (see scoring guide) |
| category | string | Primary category (see list below) |
| tone | string | Emotional register (see list below) |
| word_a_length | int | Character count of word_a |
| word_b_length | int | Character count of word_b |
| commonality | string | "very_common", "common", "moderate", "uncommon" |
| chain_potential | array | 2-5 valid words that can follow word_b |
| nation_fit | array | Which nations this phrase fits (see below) |

---

## CATEGORIES (Target Count)

Generate phrases across these categories:

| Category | Target | Examples |
|----------|--------|----------|
| food | 250 | ice cream, hot dog, apple pie, cheese pizza |
| household | 200 | front door, living room, door frame, window sill |
| nature | 200 | rain coat, tree branch, flower pot, bird nest |
| commerce | 150 | price tag, gift card, store front, cash register |
| transportation | 150 | bus stop, train track, car seat, truck driver |
| daily_activities | 150 | lunch break, phone call, day trip, night shift |
| objects | 150 | card game, ball game, box office, table top |
| body | 100 | hand shake, head start, eye drop, arm chair |
| clothing | 100 | belt buckle, shoe store, coat rack, hat trick |
| buildings | 100 | fire station, post office, church bell, school bus |
| tools_work | 100 | paint brush, tool box, work bench, drill press |
| entertainment | 100 | game show, stage fright, film star, music box |
| communication | 100 | code word, sign language, phone book, mail box |
| abstract_light | 100 | brain storm, day dream, ground work, break through |
| theme_corinthia | 50 | secret keeper, double cross, hidden path, mask ball |
| theme_carnea | 50 | pour spout, dizzy spell, merry go, float tank |
| theme_patmos | 50 | spy glass, code name, whisper campaign, plot twist |

**Total: 2000 phrases**

---

## TONES

Tag each phrase with ONE tone:

| Tone | Description | Examples |
|------|-------------|----------|
| neutral | No emotional charge | door frame, bus stop, price tag |
| warm | Positive, comfortable | home town, gift card, sun rise |
| merry | Celebratory, joyful | party time, game day, dance floor |
| quiet | Subdued, peaceful | night fall, soft touch, calm down |
| covert | Secretive, hidden | code word, spy glass, back door |
| light_tension | Mild conflict/challenge | stand off, break down, show down |
| tension | Stronger conflict | fight back, clash point, split second |
| aggressive | Confrontational | (rare, only for late game) |

---

## LAS SCORING GUIDE

**LAS = Lexical Association Strength**
Given word_a, how quickly would most people think of word_b?

| Score | Meaning | Example |
|-------|---------|---------|
| 95-100 | Instant, automatic | ice → cream, hot → dog |
| 85-94 | Very quick, confident | front → door, school → bus |
| 75-84 | Quick, familiar | road → trip, phone → call |
| 65-74 | Familiar, brief pause | brain → storm, price → cut |
| 55-64 | Known, requires thought | code → word, plot → twist |
| 45-54 | Less common, thinking | spy → glass, cipher → text |
| 35-44 | Uncommon, domain knowledge | (avoid for this bank) |

**Target distribution:**
- 40% at 85-100 (easy phrases)
- 35% at 70-84 (moderate phrases)
- 20% at 55-69 (challenging phrases)
- 5% at 45-54 (hard phrases)

---

## NATION FIT

Tag phrases that specifically fit a nation's theme:

### Corinthia (Temperance/Adultery)
**Abstraction signals:** secret, divided, broken, hidden, double, mask, veil
**DO NOT USE:** sex, affair, lover, cheat, betray
**Tag as:** "corinthia" or "all"

### Carnea (Joy/Drunkenness)
**Abstraction signals:** liquid, pour, spill, dizzy, sway, merry, stupor, float, blur
**DO NOT USE:** drunk, wasted, booze, alcohol, hangover, addict
**Tag as:** "carnea" or "all"

### Patmos (Meekness/Seditions)
**Abstraction signals:** spy, whisper, plot, rebel, covert, undermine, shadow, code, cipher
**DO NOT USE:** traitor, terrorist, assassin, overthrow
**Tag as:** "patmos" or "all"

Most phrases should be tagged "all" (nation-neutral). Only tag specific nations for theme phrases.

---

## CHAIN POTENTIAL

For each phrase, list 2-5 words that could validly follow word_b.

Example:
```json
{
  "phrase": "card game",
  "word_b": "game",
  "chain_potential": ["day", "show", "plan", "face", "room"]
}
```

This means: game day, game show, game plan, game face, game room are all valid.

**Verify each chain word:**
- Forms a real two-word phrase
- NOT a compound word
- Has reasonable LAS (50+)

---

## VALIDATION CHECKLIST

Before including each phrase:

- [ ] Is it written as TWO words (not a compound)?
- [ ] Is it used in American English?
- [ ] Given word_a, would most people say word_b?
- [ ] No brand names, trademarks, or copyrighted terms?
- [ ] No profanity, slurs, or explicit content?
- [ ] No graphic violence references (kill, stab, blood, death)?
- [ ] Does word_b have valid chain continuations?
- [ ] Correctly categorized and tagged?

---

## EXAMPLE OUTPUT (First 10 Phrases)

```json
[
  {
    "phrase": "ice cream",
    "word_a": "ice",
    "word_b": "cream",
    "las_score": 100,
    "category": "food",
    "tone": "neutral",
    "word_a_length": 3,
    "word_b_length": 5,
    "commonality": "very_common",
    "chain_potential": ["cheese", "soda", "puff", "pie"],
    "nation_fit": ["all"]
  },
  {
    "phrase": "hot dog",
    "word_a": "hot",
    "word_b": "dog",
    "las_score": 100,
    "category": "food",
    "tone": "neutral",
    "word_a_length": 3,
    "word_b_length": 3,
    "commonality": "very_common",
    "chain_potential": ["park", "show", "house", "food"],
    "nation_fit": ["all"]
  },
  {
    "phrase": "high school",
    "word_a": "high",
    "word_b": "school",
    "las_score": 98,
    "category": "buildings",
    "tone": "neutral",
    "word_a_length": 4,
    "word_b_length": 6,
    "commonality": "very_common",
    "chain_potential": ["bus", "day", "year", "board"],
    "nation_fit": ["all"]
  },
  {
    "phrase": "secret keeper",
    "word_a": "secret",
    "word_b": "keeper",
    "las_score": 72,
    "category": "theme_corinthia",
    "tone": "covert",
    "word_a_length": 6,
    "word_b_length": 6,
    "commonality": "common",
    "chain_potential": ["goal", "bee"],
    "nation_fit": ["corinthia"]
  },
  {
    "phrase": "code word",
    "word_a": "code",
    "word_b": "word",
    "las_score": 78,
    "category": "communication",
    "tone": "covert",
    "word_a_length": 4,
    "word_b_length": 4,
    "commonality": "common",
    "chain_potential": ["search", "play", "game"],
    "nation_fit": ["patmos", "all"]
  },
  {
    "phrase": "pour spout",
    "word_a": "pour",
    "word_b": "spout",
    "las_score": 65,
    "category": "theme_carnea",
    "tone": "merry",
    "word_a_length": 4,
    "word_b_length": 5,
    "commonality": "moderate",
    "chain_potential": ["off"],
    "nation_fit": ["carnea"]
  },
  {
    "phrase": "front door",
    "word_a": "front",
    "word_b": "door",
    "las_score": 95,
    "category": "household",
    "tone": "neutral",
    "word_a_length": 5,
    "word_b_length": 4,
    "commonality": "very_common",
    "chain_potential": ["frame", "step", "prize", "man"],
    "nation_fit": ["all"]
  },
  {
    "phrase": "bus stop",
    "word_a": "bus",
    "word_b": "stop",
    "las_score": 95,
    "category": "transportation",
    "tone": "neutral",
    "word_a_length": 3,
    "word_b_length": 4,
    "commonality": "very_common",
    "chain_potential": ["sign", "watch", "gap", "light"],
    "nation_fit": ["all"]
  },
  {
    "phrase": "brain storm",
    "word_a": "brain",
    "word_b": "storm",
    "las_score": 70,
    "category": "abstract_light",
    "tone": "neutral",
    "word_a_length": 5,
    "word_b_length": 5,
    "commonality": "common",
    "chain_potential": ["cloud", "drain", "surge"],
    "nation_fit": ["all"]
  },
  {
    "phrase": "game show",
    "word_a": "game",
    "word_b": "show",
    "las_score": 88,
    "category": "entertainment",
    "tone": "merry",
    "word_a_length": 4,
    "word_b_length": 4,
    "commonality": "very_common",
    "chain_potential": ["room", "time", "down", "case"],
    "nation_fit": ["all"]
  }
]
```

---

## DELIVERY FORMAT

Return the complete JSON array with all 2000 phrases. If generating in batches:
- Batch 1: Categories food, household, nature (650 phrases)
- Batch 2: Categories commerce, transportation, daily_activities, objects (600 phrases)
- Batch 3: Categories body, clothing, buildings, tools_work (400 phrases)
- Batch 4: Categories entertainment, communication, abstract_light, themes (350 phrases)

---

## FINAL REMINDERS

1. **RULE ZERO IS ABSOLUTE** - If in doubt about compound words, exclude the phrase
2. **American English only** - No British spellings or regional phrases
3. **Chain potential is critical** - Phrases with dead-end words are less valuable
4. **Balance the distribution** - Don't over-index on any single category
5. **Verify LAS scores** - Be honest about association strength
