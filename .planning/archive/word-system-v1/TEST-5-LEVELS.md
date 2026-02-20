# Pipeline Test: 5 Levels (Corinthia L1, Levels 1-5)

## Test Parameters

| Parameter | Value | Source |
|-----------|-------|--------|
| Nation | Corinthia | User request |
| Land | L1 (Levels 1-14) | MAPPING Section 1 |
| Test Levels | 1-5 | User request |
| Playthrough | 1 (Introduction) | MAPPING Section 3 |

---

## STEP 1: Query MAPPING for Constraints

**Source:** 01-MAPPING.md, Corinthia L1 row + Playthrough 1 modifiers

### Constraints Retrieved:

| Constraint | Value | Source Location |
|------------|-------|-----------------|
| LAS Floor | 85 | MAPPING: Corinthia table, L1 row |
| LAS Ceiling | 100 | MAPPING: Corinthia table, L1 row |
| Allowed Tones | neutral | MAPPING: Corinthia table, L1 row |
| Allowed Categories | food, household, objects | MAPPING: Corinthia table, L1 row |
| Forbidden | abstract, tension, theme | MAPPING: Corinthia table, L1 row |
| Playthrough Modifier | +0 (use base values) | MAPPING: Section 3, Playthrough 1 |
| Word Length Max | 6 chars preferred | MAPPING: Section 4 (0-10% = short words) |
| Commonality | very_common only | MAPPING: Section 4 |

### Decision Log:
- ✅ MAPPING provided clear constraints
- ⚠️ ISSUE: "objects" category not formally defined - what counts as objects?
- ⚠️ ISSUE: Word length guidance is in Section 4 but not in per-Land table

---

## STEP 2: Select Phrases (Simulating PHRASE-BANK Query)

Since PHRASE-BANK doesn't exist yet, I'll manually select phrases that WOULD match.

**Filter criteria applied:**
- LAS 85-100
- Tone: neutral only
- Category: food, household, objects
- No abstract, tension, or theme words
- Short, very common words

### Candidate Phrases Selected:

| Phrase | LAS | Category | Tone | word_a len | word_b len | Chain Potential |
|--------|-----|----------|------|------------|------------|-----------------|
| hot dog | 100 | food | neutral | 3 | 3 | park, show, food, house |
| dog park | 90 | objects | neutral | 3 | 4 | bench, ranger |
| park bench | 88 | objects | neutral | 4 | 5 | press, seat |
| bench press | 85 | objects | neutral | 5 | 5 | box |
| press box | 85 | objects | neutral | 5 | 3 | office, car, spring |
| box office | 92 | objects | neutral | 3 | 6 | chair, space, building |
| office chair | 88 | household | neutral | 6 | 5 | lift, back |
| chair lift | 85 | objects | neutral | 5 | 4 | ticket, pass |
| lift ticket | 85 | objects | neutral | 4 | 6 | price, booth |
| ticket price | 85 | objects | neutral | 6 | 5 | tag, cut, point |
| price tag | 92 | objects | neutral | 5 | 3 | team, line, sale |
| tag team | 85 | objects | neutral | 3 | 4 | player, work |
| team player | 88 | objects | neutral | 4 | 6 | card, piano |
| player card | 85 | objects | neutral | 6 | 4 | game, stock, trick |
| card game | 95 | objects | neutral | 4 | 4 | day, show, plan, face |
| ice cream | 100 | food | neutral | 3 | 5 | cheese, soda, cone |
| cream cheese | 90 | food | neutral | 5 | 6 | cake, pizza |
| cheese pizza | 88 | food | neutral | 6 | 5 | box, party |
| pizza box | 90 | food | neutral | 5 | 3 | car, office, spring |
| fire truck | 95 | objects | neutral | 4 | 5 | stop, driver |
| truck stop | 90 | objects | neutral | 5 | 4 | sign, light |
| stop sign | 95 | objects | neutral | 4 | 4 | language, post |
| school bus | 95 | objects | neutral | 6 | 3 | stop, pass, driver |
| bus stop | 95 | objects | neutral | 3 | 4 | sign, light |
| high school | 98 | objects | neutral | 4 | 6 | bus, day, year |
| front door | 95 | household | neutral | 5 | 4 | frame, step, prize |
| door frame | 88 | household | neutral | 4 | 5 | rate, work |
| frame rate | 85 | objects | neutral | 5 | 4 | card |
| rate card | 85 | objects | neutral | 4 | 4 | game, stock |
| ball game | 92 | objects | neutral | 4 | 4 | day, show, plan |
| game day | 90 | objects | neutral | 4 | 3 | trip, care, pack |
| game show | 88 | objects | neutral | 4 | 4 | room, time, down |
| show room | 85 | objects | neutral | 4 | 4 | key, service |
| room key | 88 | household | neutral | 4 | 3 | chain, ring |
| room service | 88 | household | neutral | 4 | 7 | ⚠️ "service" = 7 chars |

### Decision Log:
- ✅ Found sufficient phrases matching constraints
- ⚠️ ISSUE: "objects" is overloaded - most things fall into it
- ⚠️ ISSUE: Some word_b exceed 6 chars ("office", "ticket", "player", "cheese") - is this OK at L1?
- ⚠️ ISSUE: "room service" has 7-char word - constraint says 6 preferred

---

## STEP 3: Apply LAS-VALIDATION

**Source:** 03-LAS-VALIDATION.md

### Rule Zero Check (Compound Word Gate):

| Phrase | One-Word Form? | Valid? |
|--------|----------------|--------|
| hot dog | hotdog exists but two-word dominant | ✅ Valid |
| dog park | dogpark? No | ✅ Valid |
| park bench | parkbench? No | ✅ Valid |
| bench press | benchpress? No | ✅ Valid |
| press box | pressbox? No | ✅ Valid |
| box office | boxoffice? No | ✅ Valid |
| office chair | officechair? No | ✅ Valid |
| chair lift | chairlift exists | ⚠️ BORDERLINE |
| lift ticket | liftticket? No | ✅ Valid |
| ticket price | ticketprice? No | ✅ Valid |
| price tag | pricetag? No | ✅ Valid |
| tag team | tagteam? No | ✅ Valid |
| team player | teamplayer? No | ✅ Valid |
| player card | playercard? No | ✅ Valid |
| card game | cardgame? No | ✅ Valid |
| ice cream | icecream? No, always two | ✅ Valid |
| cream cheese | creamcheese? No | ✅ Valid |
| cheese pizza | cheesepizza? No | ✅ Valid |
| pizza box | pizzabox? No | ✅ Valid |
| fire truck | firetruck exists | ⚠️ BORDERLINE |
| truck stop | truckstop exists | ⚠️ BORDERLINE |
| stop sign | stopsign? No | ✅ Valid |
| school bus | schoolbus? No | ✅ Valid |
| bus stop | busstop? No | ✅ Valid |
| high school | highschool? No | ✅ Valid |
| front door | frontdoor? No | ✅ Valid |
| door frame | doorframe exists | ⚠️ BORDERLINE |
| frame rate | framerate exists in tech | ⚠️ BORDERLINE |
| rate card | ratecard? No | ✅ Valid |
| ball game | ballgame exists | ⚠️ BORDERLINE |
| game day | gameday exists | ⚠️ BORDERLINE |
| game show | gameshow? No | ✅ Valid |
| show room | showroom exists | ⚠️ BORDERLINE |
| room key | roomkey? No | ✅ Valid |

### Decision Log:
- ⚠️ ISSUE: Several phrases are BORDERLINE (both spellings exist in common use)
- Borderline phrases: chairlift, firetruck, truckstop, doorframe, framerate, ballgame, gameday, showroom
- ❓ QUESTION: Should borderline phrases be allowed or excluded?
- ⚠️ ISSUE: 03-LAS-VALIDATION says "if >50% usage as one word → INVALID" but doesn't define how to measure this

---

## STEP 4: Apply CHAIN-BUILDER to Assemble Levels

**Source:** 04-CHAIN-BUILDER.md

### Level 1 Chain (16 words, 15 phrases):

```
hot → dog → park → bench → press → box → office → chair → lift → ticket → price → tag → team → player → card → game
```

**Verification:**
| Rule | Check | Result |
|------|-------|--------|
| No word repetition within level | All 16 words unique | ✅ PASS |
| All phrases valid | 15 phrases checked | ✅ PASS (excluding borderlines) |
| Difficulty ramp | First 5 at LAS 85-100, last 5 at LAS 85 | ✅ PASS |
| Chain potential | "game" can continue (day, show, plan) | ✅ PASS |

### Level 2 Chain:

```
ice → cream → cheese → pizza → box → car → seat → belt → loop → hole...
```

**STOP - ISSUE DETECTED**

| Phrase | Check | Result |
|--------|-------|--------|
| belt loop | Valid? | ✅ Valid |
| loop hole | Compound? | ❌ "loophole" is one word - INVALID |

**Backtrack:** Need different path from "loop"

```
ice → cream → cheese → pizza → box → car → seat → belt → buckle → shoe → store → front → door → frame → rate → card
```

**Verification:**
| Phrase | Valid? | LAS | Notes |
|--------|--------|-----|-------|
| ice cream | ✅ | 100 | |
| cream cheese | ✅ | 90 | |
| cheese pizza | ✅ | 88 | |
| pizza box | ✅ | 90 | |
| box car | ✅ | 88 | |
| car seat | ✅ | 90 | |
| seat belt | ✅ | 95 | |
| belt buckle | ✅ | 88 | |
| buckle shoe | ✅ | 75 | ⚠️ Below LAS floor of 85! |
| shoe store | ✅ | 85 | |
| store front | ✅ | 85 | ⚠️ "storefront" is often one word |
| front door | ✅ | 95 | |
| door frame | ⚠️ | 88 | Borderline compound |
| frame rate | ⚠️ | 85 | Borderline compound |
| rate card | ✅ | 85 | |

**Issues Found:**
- ❌ "buckle shoe" LAS is 75, below floor of 85
- ⚠️ "store front" / "storefront" - borderline
- ⚠️ "door frame" / "doorframe" - borderline
- ⚠️ "frame rate" / "framerate" - borderline

### Level 3 Chain:

```
high → school → bus → stop → sign → post → card → game → day → trip → wire...
```

**STOP - ISSUE DETECTED**
- "trip wire" / "tripwire" - compound word, INVALID

**Backtrack:**
```
high → school → bus → stop → sign → post → card → game → show → room → key → chain → link → fence → post...
```

**STOP - ISSUE DETECTED**
- "post" appears twice (sign post, fence post) - repetition within level!

**Backtrack again:**
```
high → school → bus → stop → sign → language → arts → center → stage → left → turn → signal → fire → truck → driver → seat
```

**Verification:**
| Phrase | Valid? | LAS | Category | Notes |
|--------|--------|-----|----------|-------|
| high school | ✅ | 98 | objects | |
| school bus | ✅ | 95 | objects | |
| bus stop | ✅ | 95 | objects | |
| stop sign | ✅ | 95 | objects | |
| sign language | ✅ | 88 | objects | ⚠️ Is this "objects" category? |
| language arts | ✅ | 85 | objects | ⚠️ Category unclear |
| arts center | ✅ | 80 | objects | ❌ Below LAS floor 85! |
| center stage | ✅ | 88 | objects | |
| stage left | ✅ | 82 | objects | ❌ Below LAS floor 85! |
| left turn | ✅ | 92 | objects | |
| turn signal | ✅ | 90 | objects | |
| signal fire | ✅ | 75 | objects | ❌ Below LAS floor 85! |
| fire truck | ⚠️ | 95 | objects | Borderline compound |
| truck driver | ✅ | 90 | objects | |
| driver seat | ✅ | 85 | objects | |

**Issues Found:**
- ❌ "arts center" LAS 80, below floor
- ❌ "stage left" LAS 82, below floor
- ❌ "signal fire" LAS 75, below floor
- ⚠️ Multiple category ambiguities

---

## STEP 5: Summary of Issues Found

### Document-Specific Issues:

| Issue | Responsible Document | Severity | Fix Needed |
|-------|---------------------|----------|------------|
| "objects" category too broad/undefined | 01-MAPPING | Medium | Define categories formally |
| Word length guidance not in per-Land tables | 01-MAPPING | Low | Add column or note |
| Borderline compounds not addressed | 03-LAS-VALIDATION | High | Define borderline policy |
| "50% usage" test not measurable | 03-LAS-VALIDATION | High | Provide clearer guidance |
| LAS floor violations in chains | 02-PHRASE-BANK (missing) | High | Need pre-validated bank |
| Category assignment unclear | 02-PHRASE-BANK (missing) | Medium | Need formal categories |
| Chain dead-ends not pre-mapped | 04-CHAIN-BUILDER | Medium | Add dead-end word list |

### Pipeline Friction Points:

1. **MAPPING → PHRASE-BANK gap:** Without the phrase bank, manually finding phrases that meet ALL constraints (LAS + tone + category + word length) is very difficult.

2. **LAS-VALIDATION borderlines:** Many common phrases exist in both one-word and two-word forms. Need policy.

3. **CHAIN-BUILDER dead-ends:** Easy to build chains that hit dead-ends or force LAS violations.

---

## Levels Successfully Built:

### Level 1: ✅ COMPLETE
```
hot → dog → park → bench → press → box → office → chair → lift → ticket → price → tag → team → player → card → game
```

### Level 2: ⚠️ HAS ISSUES
```
ice → cream → cheese → pizza → box → car → seat → belt → buckle → shoe → store → front → door → frame → rate → card
```
Issues: "buckle shoe" below LAS floor, borderline compounds

### Level 3: ⚠️ HAS ISSUES
```
high → school → bus → stop → sign → language → arts → center → stage → left → turn → signal → fire → truck → driver → seat
```
Issues: Multiple phrases below LAS floor

### Level 4: NOT ATTEMPTED
### Level 5: NOT ATTEMPTED

---

## Recommendations Before Continuing:

1. **Define borderline compound policy** in 03-LAS-VALIDATION
2. **Formalize category list** in 01-MAPPING
3. **Generate PHRASE-BANK** with pre-validated, pre-scored phrases
4. **Add "safe chain starters"** list to 04-CHAIN-BUILDER
5. **Add "known dead-ends"** list to 04-CHAIN-BUILDER
