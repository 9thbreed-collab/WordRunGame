# Lexical Association Strength (LAS) Analysis

## The Model: What Makes Word Pairs "Flow"

### Four Scoring Factors

| Factor | Weight | Description | Example High | Example Low |
|--------|--------|-------------|--------------|-------------|
| **Collocation Frequency** | 40% | How often heard in media (TV, ads, social) | "ice cream" (daily) | "bowl game" (niche) |
| **Associative Dominance** | 25% | Is this THE answer, or are there competitors? | "ice→cream" (99%) | "pet→?" (food/store/fish) |
| **Semantic Concreteness** | 20% | Can you picture/draw it? | "hot dog" (yes) | "time out" (abstract) |
| **Age of Acquisition** | 15% | When do kids learn this? | "birthday" (age 2) | "shelf life" (adult) |

### Tier 1 Threshold: Score ≥ 75

For early tutorial levels, every phrase should feel **automatic** - no pause, no hesitation.

---

## Level-by-Level Analysis

### LEVEL 1 ❌ NEEDS FIXES

| # | Phrase | Freq | Dom | Conc | Age | **Score** | Verdict |
|---|--------|------|-----|------|-----|-----------|---------|
| 1 | ice cream | 10 | 10 | 10 | 10 | **100** | ✓ |
| 2 | cream cheese | 8 | 8 | 10 | 8 | **85** | ✓ |
| 3 | cheese cake | 8 | 7 | 10 | 7 | **80** | ✓ |
| 4 | cake pop | 7 | 6 | 10 | 6 | **72** | ⚠️ |
| 5 | pop corn | 10 | 10 | 10 | 10 | **100** | ✓ |
| 6 | corn dog | 8 | 8 | 10 | 8 | **85** | ✓ |
| 7 | dog house | 9 | 9 | 10 | 9 | **93** | ✓ |
| 8 | house pet | 5 | 4 | 6 | 5 | **50** | ❌ FAIL |
| 9 | pet fish | 4 | 3 | 7 | 5 | **45** | ❌ FAIL |
| 10 | fish bowl | 6 | 6 | 10 | 7 | **70** | ⚠️ |
| 11 | bowl game | 2 | 2 | 5 | 3 | **28** | ❌ FAIL |
| 12 | game day | 7 | 7 | 5 | 6 | **65** | ⚠️ |
| 13 | day care | 8 | 8 | 8 | 7 | **78** | ✓ |
| 14 | care bear | 9 | 9 | 10 | 8 | **90** | ✓ |
| 15 | bear hug | 9 | 9 | 8 | 8 | **85** | ✓ |

**Problems:**
- `house pet` (50): "house cat" and "house party" are stronger associations
- `pet fish` (45): "pet food", "pet store", "pet shop" all dominate over "fish"
- `bowl game` (28): Niche sports reference (Rose Bowl, Super Bowl) - most people don't know this

---

### LEVEL 2 ⚠️ MINOR FIXES

| # | Phrase | Score | Verdict |
|---|--------|-------|---------|
| 1 | hot dog | 100 | ✓ |
| 2 | dog house | 93 | ✓ |
| 3 | house cat | 75 | ✓ |
| 4 | cat nap | 75 | ✓ |
| 5 | nap time | 85 | ✓ |
| 6 | time out | 88 | ✓ |
| 7 | out back | 60 | ⚠️ |
| 8 | back yard | 95 | ✓ |
| 9 | yard sale | 85 | ✓ |
| 10 | sale price | 75 | ✓ |
| 11 | price tag | 85 | ✓ |
| 12 | tag line | 50 | ❌ Marketing term |
| 13 | line dance | 65 | ⚠️ |
| 14 | dance floor | 75 | ✓ |
| 15 | floor plan | 45 | ❌ Real estate term |

**Problems:**
- `tag line` (50): Marketing jargon - kids don't know this
- `floor plan` (45): Real estate/architecture term - not kid vocabulary

---

### LEVEL 3 ⚠️ MODERATE FIXES

| # | Phrase | Score | Verdict |
|---|--------|-------|---------|
| 1 | peanut butter | 100 | ✓ |
| 2 | butter cup | 85 | ✓ |
| 3 | cup cake | 95 | ✓ |
| 4 | cake walk | 50 | ❌ Idiom - not literal |
| 5 | walk way | 65 | ⚠️ |
| 6 | way back | 60 | ⚠️ |
| 7 | back pack | 95 | ✓ |
| 8 | pack lunch | 45 | ❌ Awkward phrasing |
| 9 | lunch box | 95 | ✓ |
| 10 | box car | 40 | ❌ Train jargon |
| 11 | car seat | 85 | ✓ |
| 12 | seat belt | 95 | ✓ |
| 13 | belt loop | 60 | ⚠️ |
| 14 | loop hole | 45 | ❌ Abstract/legal |
| 15 | hole punch | 70 | ⚠️ |

**Problems:**
- `cake walk` (50): Idiom meaning "easy task" - kids think literally
- `pack lunch` (45): Awkward - should be "packed lunch" or skip
- `box car` (40): Train terminology - not everyday speech
- `loop hole` (45): Abstract/legal term - not kid-friendly

---

### LEVEL 4 ⚠️ MODERATE FIXES

| # | Phrase | Score | Verdict |
|---|--------|-------|---------|
| 1 | school bus | 100 | ✓ |
| 2 | bus stop | 95 | ✓ |
| 3 | stop sign | 95 | ✓ |
| 4 | sign post | 60 | ⚠️ |
| 5 | post card | 75 | ✓ |
| 6 | card board | 85 | ✓ |
| 7 | board game | 95 | ✓ |
| 8 | game show | 85 | ✓ |
| 9 | show case | 50 | ❌ Usually one word |
| 10 | case book | 30 | ❌ Legal term |
| 11 | book shelf | 85 | ✓ |
| 12 | shelf life | 45 | ❌ Grocery/science |
| 13 | life guard | 80 | ✓ |
| 14 | guard dog | 75 | ✓ |
| 15 | dog park | 85 | ✓ |

**Problems:**
- `show case` (50): "Showcase" is typically one word
- `case book` (30): Legal terminology - obscure
- `shelf life` (45): Grocery/expiration concept - not kid vocabulary

---

### LEVEL 5 ⚠️ MINOR FIXES

| # | Phrase | Score | Verdict |
|---|--------|-------|---------|
| 1 | apple sauce | 85 | ✓ |
| 2 | sauce pan | 70 | ⚠️ |
| 3 | pan cake | 95 | ✓ |
| 4 | cake mix | 75 | ✓ |
| 5 | mix up | 70 | ⚠️ |
| 6 | up town | 70 | ⚠️ |
| 7 | town house | 75 | ✓ |
| 8 | house cat | 75 | ✓ |
| 9 | cat nap | 75 | ✓ |
| 10 | nap time | 85 | ✓ |
| 11 | time table | 50 | ❌ British term |
| 12 | table top | 70 | ⚠️ |
| 13 | top hat | 85 | ✓ |
| 14 | hat box | 50 | ❌ Old-fashioned |
| 15 | box car | 40 | ❌ Train jargon |

**Problems:**
- `time table` (50): British English - US says "schedule"
- `hat box` (50): Dated term - kids don't know this
- `box car` (40): Train terminology (again)

---

### LEVEL 6 ✓ MOSTLY GOOD

| # | Phrase | Score | Verdict |
|---|--------|-------|---------|
| 1 | birth day | 100 | ✓ |
| 2 | day dream | 85 | ✓ |
| 3 | dream team | 75 | ✓ |
| 4 | team work | 85 | ✓ |
| 5 | work day | 75 | ✓ |
| 6 | day light | 85 | ✓ |
| 7 | light house | 85 | ✓ |
| 8 | house boat | 75 | ✓ |
| 9 | boat ride | 85 | ✓ |
| 10 | ride home | 70 | ⚠️ |
| 11 | home run | 85 | ✓ |
| 12 | run way | 65 | ⚠️ Usually one word |
| 13 | way back | 60 | ⚠️ |
| 14 | back yard | 95 | ✓ |
| 15 | yard sale | 85 | ✓ |

**Problems:** Minor - no critical failures

---

### LEVEL 7 ❌ NEEDS FIXES

| # | Phrase | Score | Verdict |
|---|--------|-------|---------|
| 1 | teddy bear | 100 | ✓ |
| 2 | bear trap | 60 | ⚠️ |
| 3 | trap door | 70 | ⚠️ |
| 4 | door step | 75 | ✓ |
| 5 | step ladder | 75 | ✓ |
| 6 | ladder back | 25 | ❌ Furniture term |
| 7 | back pack | 95 | ✓ |
| 8 | pack lunch | 45 | ❌ Awkward |
| 9 | lunch time | 85 | ✓ |
| 10 | time out | 88 | ✓ |
| 11 | out door | 65 | ⚠️ Usually one word |
| 12 | door bell | 95 | ✓ |
| 13 | bell boy | 45 | ❌ Dated hotel term |
| 14 | boy band | 75 | ✓ |
| 15 | band stand | 50 | ❌ Park/music term |

**Problems:**
- `ladder back` (25): Furniture style (ladderback chair) - extremely obscure
- `pack lunch` (45): Awkward phrasing (again)
- `bell boy` (45): Dated hotel terminology
- `band stand` (50): Old-fashioned park structure

---

### LEVEL 8 ❌ NEEDS FIXES (same issues as L1)

| # | Phrase | Score | Verdict |
|---|--------|-------|---------|
| 1 | fire truck | 100 | ✓ |
| 2 | truck stop | 70 | ⚠️ |
| 3 | stop light | 85 | ✓ |
| 4 | light house | 85 | ✓ |
| 5 | house pet | 50 | ❌ |
| 6 | pet fish | 45 | ❌ |
| 7 | fish bowl | 70 | ⚠️ |
| 8 | bowl game | 28 | ❌ |
| 9 | game face | 65 | ⚠️ |
| 10 | face time | 75 | ✓ |
| 11 | time table | 50 | ❌ British |
| 12 | table cloth | 75 | ✓ |
| 13 | cloth pin | 45 | ❌ Usually "clothespin" |
| 14 | pin ball | 75 | ✓ |
| 15 | ball park | 85 | ✓ |

**Problems:** Same as Level 1 + `cloth pin` and `time table`

---

### LEVEL 9 ⚠️ MODERATE FIXES

| # | Phrase | Score | Verdict |
|---|--------|-------|---------|
| 1 | rain coat | 85 | ✓ |
| 2 | coat check | 60 | ⚠️ Restaurant term |
| 3 | check book | 50 | ❌ Dated (no one writes checks) |
| 4 | book bag | 75 | ✓ |
| 5 | bag lunch | 45 | ❌ Awkward phrasing |
| 6 | lunch box | 95 | ✓ |
| 7 | box car | 40 | ❌ Train jargon |
| 8 | car seat | 85 | ✓ |
| 9 | seat back | 50 | ❌ Airplane/furniture |
| 10 | back yard | 95 | ✓ |
| 11 | yard sale | 85 | ✓ |
| 12 | sale price | 75 | ✓ |
| 13 | price tag | 85 | ✓ |
| 14 | tag team | 65 | ⚠️ Wrestling |
| 15 | team work | 85 | ✓ |

**Problems:**
- `check book` (50): Dated - kids don't know what checks are
- `bag lunch` (45): Awkward phrasing
- `box car` (40): Train jargon (third time!)
- `seat back` (50): Airplane/furniture term

---

### LEVEL 10 ⚠️ MINOR FIXES

| # | Phrase | Score | Verdict |
|---|--------|-------|---------|
| 1 | star fish | 85 | ✓ |
| 2 | fish tank | 85 | ✓ |
| 3 | tank top | 75 | ✓ |
| 4 | top dog | 70 | ⚠️ Idiom |
| 5 | dog food | 95 | ✓ |
| 6 | food court | 75 | ✓ |
| 7 | court yard | 70 | ⚠️ |
| 8 | yard work | 75 | ✓ |
| 9 | work day | 75 | ✓ |
| 10 | day dream | 85 | ✓ |
| 11 | dream boat | 50 | ❌ Dated 50s slang |
| 12 | boat house | 70 | ⚠️ |
| 13 | house hold | 70 | ⚠️ Usually one word |
| 14 | hold back | 70 | ⚠️ |
| 15 | back bone | 75 | ✓ |

**Problems:**
- `dream boat` (50): 1950s slang for attractive person - outdated

---

## Pattern Analysis: What Makes Phrases FAIL

### 1. Niche Domain Knowledge
Phrases that require specific expertise:
- `bowl game` → Sports (football bowl games)
- `ladder back` → Furniture design
- `case book` → Legal terminology
- `shelf life` → Grocery/food science
- `band stand` → Parks/music history

### 2. Dated Expressions
Phrases that were common 20+ years ago but kids today don't encounter:
- `check book` → Who writes checks anymore?
- `bell boy` → Hotels have changed
- `dream boat` → 1950s slang
- `hat box` → Old-fashioned accessory

### 3. Awkward Phrasing
Phrases that sound unnatural in casual speech:
- `pack lunch` → Natural: "pack a lunch" or "packed lunch"
- `bag lunch` → Natural: "brown bag lunch" or "sack lunch"
- `seat back` → Natural: "back of the seat"

### 4. Competing Strong Associations
First word triggers a different, stronger completion:
- `pet ___` → "food" (90%), "store" (80%), "fish" (20%)
- `house ___` → "cat" (85%), "party" (80%), "pet" (40%)

### 5. Train/Transport Jargon
`box car` appears THREE times - this is not everyday vocabulary for kids.

### 6. British vs American English
- `time table` → British. Americans say "schedule"

---

## The Golden Standard: What Makes Phrases SUCCEED

### 1. Food Items (Universal, Concrete)
- ice cream, hot dog, peanut butter, popcorn, cupcake, pancake, corn dog
- **Why they work:** Daily exposure, visual, sensory (taste/smell)

### 2. Kid's World (Age-appropriate context)
- teddy bear, lunch box, school bus, fire truck, birthday party
- **Why they work:** Direct daily experience, learned before age 5

### 3. Character/Brand Associations
- Care Bear, cupcake (Cupcake Wars), birthday cake
- **Why they work:** Media exposure reinforces the pairing

### 4. Universal Actions/Idioms
- bear hug, time out, back yard, high five
- **Why they work:** Used in conversation constantly, heard in media

### 5. Concrete Visual Objects
- dog house, fish bowl, stop sign, door bell
- **Why they work:** Can be pictured instantly, no abstraction

---

## Replicability Rules for Generating New Phrases

When creating word pairs, verify:

1. **The "Commercial Test"**: Could this phrase appear in a McDonald's, Target, or Nickelodeon ad?
2. **The "5-Year-Old Test"**: Would a kindergartner recognize this from their daily life?
3. **The "One Answer Test"**: Given word A, is there only ONE obvious word B?
4. **The "Picture Test"**: Can you draw this phrase as a single image?
5. **The "2020s Test"**: Is this phrase still relevant in modern American English?

---

## Summary: Phrases Needing Replacement

| Level | Failing Phrases | Count |
|-------|-----------------|-------|
| 1 | house pet, pet fish, bowl game | 3 |
| 2 | tag line, floor plan | 2 |
| 3 | cake walk, pack lunch, box car, loop hole | 4 |
| 4 | show case, case book, shelf life | 3 |
| 5 | time table, hat box, box car | 3 |
| 6 | (minor issues only) | 0 |
| 7 | ladder back, pack lunch, bell boy, band stand | 4 |
| 8 | house pet, pet fish, bowl game, time table, cloth pin | 5 |
| 9 | check book, bag lunch, box car, seat back | 4 |
| 10 | dream boat | 1 |

**Total failing phrases: 29 across 10 levels**

The "box car" phrase alone accounts for 3 failures - remove it from the vocabulary entirely.
