# WordRun! Chain Builder Rules

## Purpose

This document defines how to assemble validated word phrases into playable chains. It takes validated phrases from the LAS filter and outputs complete level data.

---

## Level Structure

| Component | Count | Description |
|-----------|-------|-------------|
| Starter Word | 1 | Displayed first, player types word_b |
| Base Phrases | 12 | Core chain (13 words including starter) |
| Bonus Phrases | 3 | Extra challenge phrases |
| **Total Words** | **16** | 15 phrases total |

### Chain Mechanic

Word B of phrase N becomes Word A of phrase N+1:

```
(starter) → hot
hot → dog        [hot dog]
dog → park       [dog park]
park → bench     [park bench]
...
```

---

## Chain Assembly Rules

### Rule 1: No Word Repetition WITHIN A SINGLE LEVEL
No word may appear twice in the same chain (same level).

**Check before adding:** Is this word already in THIS chain?
- ✅ hot → dog → park → bench (all unique within level)
- ❌ hot → dog → park → dog (repeats "dog" in same level)

**HOWEVER:** Word repetition ACROSS levels is welcomed and encouraged.
- ✅ Level 1: "card game" ... Level 5: "credit card" (same word "card", different levels)
- This builds pattern recognition and inductive reasoning

### Rule 1B: Phrase Repetition ACROSS LEVELS (Allowed)
Same phrase CAN repeat in different levels, but should be spaced out.

- ✅ Level 1: "card game" ... Level 12: "card game" (same phrase, spaced out)
- ❌ Level 1: "card game" ... Level 2: "card game" (too close)
- When phrase repeats, player uses revealed letter hints to confirm

**Spacing guideline:** Same phrase should not repeat within 10 levels.

### Rule 2: No Immediate Reversals
A phrase and its reverse cannot both appear in the same chain.

- ❌ light → house ... then later ... house → light

### Rule 3: Verify Chain Continuations
Before committing to a word, verify it has valid forward continuations.

**Dead-end words to avoid:**
- "step" → mostly leads to compound words (stepstool, stepladder)
- "door" → limited safe options (doorbell, doorway are compound)
- "sun/day/moon/star" + "light" → all compound words

### Rule 4: Difficulty Ramp Within Level

| Level Segment | Phrases | LAS Target | Notes |
|---------------|---------|------------|-------|
| First 1/3 | 1-5 | +5 above floor | Entry ramp, easiest |
| Middle 1/3 | 6-10 | At floor | Target difficulty |
| Final 1/3 | 11-15 | -5 below floor | Exit challenge |

Variance should be ±5 LAS points, not dramatic swings.

### Rule 5: Bonus Words
The 3 bonus phrases should:
- Continue from the final base word
- Be slightly harder than base phrases (LAS -5)
- Provide satisfying completion

---

## Chain Building Process

### Step 1: Get Constraints
Query the Mapping Document for:
- Nation, Land, Playthrough
- LAS floor/ceiling
- Allowed categories and tones

### Step 2: Gather Candidates
Query the Phrase Bank for phrases matching constraints.
Filter to phrases with good chain potential.

### Step 3: Select Starter Word
Choose a high-LAS starter that has multiple valid continuations.

**Good starters:**
- "ice" (→ cream, pick, cold, age)
- "hot" (→ dog, tub, shot, air)
- "high" (→ school, five, way, chair)
- "fire" (→ truck, drill, place, arm)

### Step 4: Build Forward
For each position:
1. Get current word (word_b of previous phrase)
2. Find all valid phrases starting with that word
3. Filter to phrases matching LAS target for this segment
4. Choose phrase with best chain potential
5. Verify no repetition
6. Continue

### Step 5: Validate Complete Chain
Before finalizing:
- [ ] All 16 words are unique
- [ ] All 15 phrases pass Rule Zero (compound word check)
- [ ] LAS scores follow difficulty ramp
- [ ] No dead ends (final bonus word can terminate)
- [ ] Categories match Mapping constraints

---

## Chain Potential Ratings

Words rated by how many valid continuations they have:

### Excellent Chain Potential (5+ continuations)
| Word | Sample Continuations |
|------|---------------------|
| game | day, show, plan, face, time, room |
| card | game, stock, trick, table, shark |
| box | office, car, spring, score, cutter |
| time | out, zone, card, line, share |
| fire | truck, drill, alarm, place, sale |
| school | bus, day, year, board, book |

### Good Chain Potential (3-4 continuations)
| Word | Sample Continuations |
|------|---------------------|
| ball | game, park, room, point |
| door | frame, step, prize, man |
| night | shift, owl, club, fall |
| room | service, key, temperature |

### Limited Chain Potential (1-2 continuations)
| Word | Sample Continuations | Notes |
|------|---------------------|-------|
| belt | loop, buckle | Loop → loophole (compound) |
| step | ladder, child | Most are compound |
| key | chain, ring | Both borderline |

### Dead Ends and Dangerous Words

**Dead Ends (0-1 safe continuations):**
| Word | Problem | Avoid After |
|------|---------|-------------|
| loop | "loophole" is compound | belt loop |
| step | stepstool, stepladder, stepchild all compound | door step |
| light | lighthouse, daylight, sunlight compound | stop light |
| check | checkbook, checkmark, checkout compound | rain check |
| book | bookcase, bookshelf, bookmark compound | phone book |
| fire | fireplace, fireworks, firefly compound | camp fire |
| sun | sunlight, sunrise, sunset, sunflower compound | — |
| day | daylight, daytime, daybreak compound | game day |
| night | nighttime, nightmare, nightclub compound | date night |
| home | homework, homesick, homepage compound | group home |
| back | backyard, backpack, backbone compound | chair back |
| door | doorbell, doorway, doorstep, doormat compound | front door |
| news | newspaper, newsroom, newsletter compound | — |
| tooth | toothbrush, toothpaste, toothpick compound | — |
| bed | bedroom, bedtime, bedside compound | — |
| bath | bathroom, bathtub, bathrobe compound | — |
| cup | cupcake, cupboard compound | tea cup |
| pan | pancake, panhandle compound | sauce pan |
| pop | popcorn compound | soda pop |
| corn | corndog, cornfield compound | candy corn |
| cat | catfish, catnap, catwalk compound | — |
| gold | goldfish compound | — |
| star | starfish, starlight compound | — |

**Dangerous Transitions (limited options):**
| Word | Safe Continuations | Unsafe (Compound) |
|------|-------------------|-------------------|
| truck | stop, driver, load | — |
| stop | sign, gap, watch (borderline) | light (stoplight) |
| belt | loop (dead end), buckle, drive | — |
| trip | wire (tripwire), advisor | — |
| key | chain, ring, hole (keyhole) | board (keyboard) |
| rain | coat, drop, fall, check | bow (rainbow) |
| snow | ball, man, fall, storm | flake (snowflake) |

---

## Output Format

### JSON Structure (per level)

```json
{
  "level_id": "corinthia_01",
  "level_name": "Level 1",
  "time_limit_seconds": 180,
  "base_word_count": 12,
  "bonus_word_count": 3,
  "difficulty": 1,
  "word_pairs": [
    {"word_a": "", "word_b": "hot"},
    {"word_a": "hot", "word_b": "dog"},
    {"word_a": "dog", "word_b": "park"},
    ...
  ],
  "surge_config": { ... },
  "obstacle_configs": [ ... ]
}
```

### Chain Notation (Quick Reference)

For documentation, use arrow notation:
```
hot → dog → park → bench → press → box → office → chair → lift → ticket → price → tag → team → player → card → game
```

---

## Troubleshooting

### Problem: Chain hits dead end at position X
**Solution:** Backtrack to position X-1 and choose different word_b

### Problem: Can't find phrase matching LAS target
**Solution:** Widen LAS range by ±5, or backtrack to change approach

### Problem: Word repetition forced
**Solution:** Backtrack to find alternative path that avoids repeat

### Problem: All candidate phrases are compound words
**Solution:** This word is a dead end. Backtrack and choose different path.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-13 | Initial chain building rules |
