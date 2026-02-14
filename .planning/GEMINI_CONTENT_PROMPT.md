# Gemini Content Generation Prompt

Use this prompt when Gemini quota resets to populate word pairs for all lands.

---

## Master Prompt

```
You are generating word pair content for WordRun!, a mobile word puzzle game.

TASK: Replace all "PLACEHOLDER" word pairs in the JSON files located at data/baseline/*.json with valid English compound words or two-word phrases.

CRITICAL RULES:
1. Each level needs 16 word pairs (or 23 for boss levels)
2. word_a of pair N must equal word_b of pair N-1 (chain structure)
3. First pair always has empty word_a: {"word_a": "", "word_b": "START_WORD"}
4. All words must be real English words
5. Never use profanity or inappropriate content

DIFFICULTY PROGRESSION (check "difficulty" field in each level):
- Difficulty 1-2: Short words (3-5 chars), common phrases (sunflower, bedroom, football)
- Difficulty 3: Medium words (5-7 chars), familiar phrases (clipboard, warehouse)
- Difficulty 4-5: Longer words allowed, less common phrases

EXAMPLE CHAIN (difficulty 1):
{"word_a": "", "word_b": "sun"},
{"word_a": "sun", "word_b": "flower"},
{"word_a": "flower", "word_b": "bed"},
{"word_a": "bed", "word_b": "room"},
{"word_a": "room", "word_b": "mate"}
...continues for 16 pairs

FILES TO PROCESS (in order):
1. data/baseline/corinthia.json - ADD 13 more levels (currently has 10, needs 23)
2. data/baseline/land_1_02.json through land_1_08.json (Nation 1)
3. data/baseline/land_2_01.json through land_2_08.json (Nation 2)
4. data/baseline/land_3_01.json through land_3_08.json (Nation 3)

CONSTRAINTS:
- Avoid repeating the same word pair within the same land
- High-frequency connector words (ball, room, house, man, out) can repeat across lands but not excessively
- Boss levels (level 23 in each land) have 23 pairs instead of 16
- Each word pair should form a valid compound or common phrase

OUTPUT: Edit each JSON file in place, replacing PLACEHOLDER with actual words.

Start with corinthia.json - add levels 11-23, then proceed to land_1_02.json.
```

---

## Chunked Approach (If Full Prompt Too Large)

Run these in sequence:

### Chunk 1: Complete Corinthia
```
gemini -p "Read data/baseline/corinthia.json. It has 10 levels but needs 23. Add levels 11-23 following the same word chain format. Each level needs 16 word pairs (23 for boss level 23). word_a of each pair equals word_b of previous pair. Use difficulty 1-2 words (short, common). Write the updated file back."
```

### Chunk 2: Nation 1 Remaining Lands
```
gemini -p "Read data/baseline/land_1_02.json. Replace all PLACEHOLDER word pairs with real English compound words. 16 pairs per level, chain format (word_a = previous word_b). Difficulty shown in each level (1-2 = short common words). Write updated file. Then do the same for land_1_03.json through land_1_08.json."
```

### Chunk 3: Nation 2
```
gemini -p "Read data/baseline/land_2_01.json through land_2_08.json. Replace all PLACEHOLDER word pairs with real English compound words. 16 pairs per level, chain format. Difficulty 2-3 (medium words). Write updated files."
```

### Chunk 4: Nation 3
```
gemini -p "Read data/baseline/land_3_01.json through land_3_08.json. Replace all PLACEHOLDER word pairs with real English compound words. 16 pairs per level, chain format. Difficulty 3-4 (medium to harder words). Write updated files."
```

---

## Validation Check (Run After Content Generation)

```
gemini -p "Read all JSON files in data/baseline/. Verify: 1) No PLACEHOLDER remains, 2) All word chains are valid (word_a matches previous word_b), 3) All words are real English. Report any issues to fix."
```

---

*Prompt created: 2026-02-09*
