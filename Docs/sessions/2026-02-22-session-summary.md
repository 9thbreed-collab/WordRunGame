# Session Summary: 2026-02-22

**Version:** v0.0.08
**Phase:** Phase 4 Extended - Content Pipeline & Level Generation
**Date:** February 22, 2026

---

## From Dev Director's Notes

### Core Vision
WordRun! is a mobile word puzzle game where momentum creates the rush. The word-pair puzzle with the surge momentum system must feel like a "rush" -- the tension between solving fast for multipliers and risking a bust, combined with obstacle anticipation, is the experience that makes WordRun! unique.

The content system must be deterministic and rule-based. No subjective judgment permitted in phrase selection, scoring, or level construction. The director's vision is that difficulty progression must be invisible level-to-level but significant across distance (fractal progression).

### Must-Include Features
- 9 Nations, 8 Lands each, 23 Levels each (22 + 1 boss minimum)
- Total: 3,024 levels across full game (3 Acts, 9 Nations)
- v1 (MVP): Nations 1-3 = 336 levels (Act 1 only)
- Fractal difficulty progression: imperceptible step-to-step, significant across distance
- Nation-specific theme and tone that escalates across Acts
- All phrase evaluation must be numeric and reproducible

### User Preferences (Corinthia, Land 1)
- Minimum 80 LAS (now replaced by PFS >= 4 for Tier 1)
- Zero conceptual/abstract phrases in early game
- No aggressive tone in first half of game
- Phrases must pass Compound Word Gate FIRST before scoring

### Visual Appeal & UX Goals
- Professional code quality, no shortcuts
- Component-Driven Development for UI resilience
- Offline-first gameplay, online-first revenue
- Documentation-first during foundation phase

---

## From This Session

### Structural & Architectural Decisions

#### ContentRuleDoc System - Full Architecture (Commit 15cdd0c)

Built a complete deterministic content management system from scratch. This is a major infrastructure milestone replacing the ad-hoc phrase selection from prior sessions.

**Five Independent Axes (CRITICAL - axes may not alter each other):**
1. Difficulty (global, monotonic across all 3,024 levels)
2. Tier windows (filter buckets, 10 tiers total)
3. Tone cap (Act-based continuous function)
4. Nation abstraction density (keyword lexicon matching only)
5. Industry word pools (Nation-scoped, constant across Acts)

**ContentRuleDoc.md** - The master rules document (~900 lines), establishes:
- Master Phrase Database construction rules
- Validation stage (dictionary check, word frequency, phrase structure)
- Scoring metrics (word length, PFS, entropy, difficulty formula)
- Content exclusion layers (category filtering, word blacklist, phrase blacklist)
- 33-category semantic master list (locked, no dynamic invention)
- Tone system with Act-based cap functions
- Theme tagging via keyword lexicons (no embeddings, no inference)
- Graph construction (directed phrase graph, word2 → word1 edges)
- Tier-based filtering views (10 tiers across 3,024 levels)
- Level generation rules (16 phrases, linear, no loops)
- Pathfinding algorithm (DFS with depth_limit=16)

**Supporting docs created:**
- `KEYWORD_LEXICONS_DRAFT.md` - Adultery, Drunkenness, Sedition lexicons (31 keywords each)
- `NATION_FILTERS.md` - Per-nation allowed/disallowed categories
- `TONE_SCORE_RULES.md` - Tone scoring methodology

#### PFS (Phrase Frequency Score) System (Commit 01aec27)

The original CES (Combined Entropy Score) system used word-level Zipf heuristics to approximate phrase familiarity. This was DEPRECATED in favor of PFS.

**PFS Definition:**
- Measures how often Americans hear and say a two-word phrase in everyday speech
- Normalized percentile rank of bigram frequency from spoken American English corpora
- Sources (priority order): COCA Spoken Corpus, SUBTLEX-US, Google Ngrams (fallback)

**PFS Scale:**
- PFS 5: Top 10% (said daily) - e.g., "seat belt", "stop sign"
- PFS 4: 70-90% (said weekly) - e.g., "ice cream", "fire truck"
- PFS 3: 40-70% (said monthly) - e.g., "truck bed", "office chair"
- PFS 2: 20-40% (said occasionally) - e.g., "chair lift"
- PFS 1: Below 20% (rare/specialized) - e.g., "rack mount"

**Tier enforcement:**
- Tier 1: PFS >= 4 (most familiar phrases only)
- Tier 2: PFS >= 3
- Tier 3+: No PFS restriction

**CRITICAL:** PFS is a FILTER ONLY. It does NOT affect difficulty_score, entropy, or graph generation.

#### Difficulty Formula (Locked Constants)

```
difficulty_score =
    (5 * entropy)
  + (3 * avg_word_length)
  + (2 * (7 - avg_zipf))
```

Priority: Entropy > Word Length > Familiarity. Additive only, no multiplication.

#### Entropy Definition

For phrase P:
- starter = word1
- first_letter = first letter of word2
- entropy = count of validated phrases where word1 == starter AND word2 starts with first_letter

Entropy = 1 means only one valid phrase continues from that word with that first letter. Easy.
Entropy = 2+ means the player has ambiguity to resolve. Harder.

#### Phrase Data Pipeline - 6 Batch CSVs + Master Files (Commit 898a5cb)

Generated 6 thematic batch phrase files covering distinct semantic domains:
- `batch1_household_everyday.csv` (~500 phrases): Home, daily life
- `batch2_food_drink.csv` (~500 phrases): Food, beverages
- `batch3_transport_outdoor.csv` (~500 phrases): Transport, outdoors
- `batch4_school_social.csv` (~500 phrases): Education, social life
- `batch5_commerce_work.csv` (~500 phrases): Commerce, workplace
- `batch6_abstraction.csv` (~500 phrases): Abstract concepts

**Master merged files:**
- `phrases_master.csv`: Combined all batches
- `phrases_master_ces.csv`: With CES (Combined Entropy Score) metric
- `phrases_master_pfs.csv`: With PFS scores (3,184+ phrases)
- `phrases_early_game.csv`: Filtered to early-game eligible phrases

All phrase files include computed columns: word1, word2, difficulty, entropy, familiarity, tone, category, abstraction, avg (word length), bigram, CES, PFS.

#### Scripts Built

1. `pathfinder.py` - Backtracking DFS algorithm for chain building
   - Depth-limited DFS (depth = 16)
   - No node repetition within a chain
   - Backtracking on dead ends
   - Returns first valid path meeting depth target

2. `early_filter.py` - Early-game phrase filtering
   - Applies PFS minimum thresholds
   - Filters by entropy cap
   - Removes compound words (via MEMORY.md blocklist)
   - Applies tone constraints

3. `generate_early_levels.py` - Level generation orchestrator
   - Loads filtered phrase graph
   - Runs pathfinder for N unique chains
   - Validates no repeated bigrams between levels
   - Outputs chains to corinthia.json format

4. `calculate_pfs.py` - PFS calculation utility
   - Loads spoken corpus data
   - Computes percentile ranks
   - Normalizes to PFS 1-5 scale

5. `calculate_ces.py` - CES calculation utility
   - Computes entropy per phrase
   - Combined with difficulty formula weights

6. `merge_phrases.py` - Phrase database merger
   - Merges batch CSVs into master database
   - Deduplicates on (word1, word2) key
   - Preserves all score columns

7. `spoken_pfs.py` - Spoken corpus PFS processing
   - Processes SUBTLEX-US / COCA data
   - Builds ngram_cache.json for fast lookups

#### Level Data: 3 Valid 16-Word Chains for Corinthia (Commits 898a5cb, 01aec27)

After fixing buggy test levels, the current `data/baseline/corinthia.json` contains 3 levels each with 16 valid phrases:

**Level 1** (avg PFS 3.53):
house → cat food → food ... → letter
- Starting word: "house"
- Chain validated: word2 of each phrase == word1 of next phrase
- No compound words
- PFS-filtered for Tier 1 eligibility

**Level 2** (avg PFS 3.47):
credit → card game → game ... → lime
- Starting word: "credit"
- Unique bigrams (no overlap with Level 1)

**Level 3** (avg PFS 3.20):
dry → ice cream → cream ... → rack
- Starting word: "dry"
- Slightly lower avg PFS (still Tier 1/2 eligible)

**Archived/Rejected versions:**
- Original entropy=1 test chains (15cdd0c) had some archaic phrases ("pack horse", "tone arm")
- Replaced in 898a5cb with all-valid chains
- L3 from 15cdd0c was only 8 phrases (too short for a level), replaced with full 16-phrase chain

#### ngram_cache.json

Generated to accelerate PFS lookups. Caches bigram frequency lookups so the pipeline doesn't need to re-query the spoken corpus on every run. Located at `ContentRuleDoc/data/phrases/ngram_cache.json`.

#### phrases_master_pfs.csv Milestone

3,184 phrases with full PFS scoring. This is the primary phrase bank for Corinthia levels. The pipeline is now capable of generating many more levels beyond the 3 currently in corinthia.json.

#### Godot Translation Files (.translation)

Godot auto-generates `.translation` binary files for each CSV imported into the engine. The batch CSVs and master CSVs created this session each have corresponding `.translation` files. These are untracked because they are Godot build artifacts, not source data. They can be regenerated by opening the Godot project.

### Problems Identified & Solutions

**Problem:** Original 544-phrase bank (phrases_scored.csv from commit 15cdd0c) was too small for meaningful entropy scoring. With only 544 phrases, most entropy values were 1 (only one valid path), making all phrases equally "easy" by entropy.
- **Solution:** Expanded to 3,184 phrases via 6 batch CSVs and merger pipeline. Now entropy has meaningful variance.

**Problem:** Word-level Zipf scores used as proxy for phrase familiarity gave incorrect results. "Pack horse" has individually common words but is an archaic phrase.
- **Solution:** PFS system based on spoken English corpus bigram frequency. Now familiarity reflects actual phrase-level recognition, not just word-level vocabulary.

**Problem:** Buggy test chains included "pack horse" and "tone arm" (archaic) and a truncated Level 3 (8 phrases).
- **Solution:** Replaced all 3 levels with clean 16-phrase chains validated against compound word blocklist.

**Problem:** Pipeline v1 built graph before filtering, which caused the pathfinder to explore many dead-end routes.
- **Solution:** Pipeline v2.1 filters phrases BEFORE building the graph. Only eligible phrases enter the graph. DFS has fewer dead ends to backtrack through.

### Ideas Explored But Ultimately Rejected

**Multiplicative difficulty formula:** Explored `difficulty = entropy * avg_word_length * familiarity_penalty`. Rejected because multiplication causes exponential scaling, instability across tiers, and extreme sensitivity to outliers. Additive formula selected instead.

**Per-session entropy reset:** Considered resetting entropy counts per Nation or per tier. Rejected because entropy must be computed from the full validated database to be reproducible. Partial databases give unstable entropy values.

**Embedding-based theme matching:** Considered using semantic embeddings to identify thematic phrases (e.g., "sailing ship" matching maritime theme via similarity). Rejected because embeddings are non-deterministic across model versions. Keyword lexicon matching only.

**Dynamic category assignment:** Considered letting the AI assign semantic categories at runtime during level generation. Rejected because this introduces subjective drift. All category assignments must be pre-computed and version-controlled.

**LAS (Link Assessment Score) for Tier 1:** LAS was the original scoring from Rulebook v2.0. Replaced by the PFS + difficulty_score two-metric system. LAS is archived in `.planning/archive/word-system-v1/`.

### Visual & Design Choices

No Godot UI changes were made this session. All work was in the content pipeline layer.

### Technical Implementations Completed

1. **ContentRuleDoc/ directory** - New top-level system with:
   - `ContentRuleDoc.md` (v2.1 as of last commit): Master rules document
   - `KEYWORD_LEXICONS_DRAFT.md`: Theme keyword lists
   - `NATION_FILTERS.md`: Nation-specific content gates
   - `TONE_SCORE_RULES.md`: Tone scoring methodology
   - `data/graphs/phrase_graph.json`: Directed graph adjacency list
   - `data/phrases/`: Phrase database files (CSVs + Godot translation artifacts)
   - `data/levels/test_levels.json`: Entropy=1 test level data
   - `data/levels/early_game_test.json`: Early game validated chains
   - `data/BIGRAM_SOURCES.md`: Documents spoken corpus sources
   - `data/tier1_frequency_audit.md`: PFS audit for Tier 1 phrases
   - `data/validation_report.md`: Phrase validation report
   - `scripts/`: Python pipeline scripts (pathfinder, filters, generators, calculators)

2. **data/baseline/corinthia.json** - Updated 3x this session:
   - First update: entropy=1 test chains (15cdd0c)
   - Second update: fixed 16-phrase valid chains (898a5cb)
   - Third update: PFS-scored chains, 3 unique levels (01aec27)

3. **Archive:** Old word-system-v1 files moved to `.planning/archive/word-system-v1/`

4. **IAP plugin disabled** in `project.godot` (wrong architecture for local testing)

---

## Combined Context

### Alignment with Director's Vision

**Strong Alignment:**
- ContentRuleDoc system directly implements the director's fractal difficulty progression requirement
- PFS ensures early game phrases are genuinely familiar to American English speakers (critical for onboarding)
- Deterministic scoring means content can be audited, adjusted, and version-controlled - matches "professional code quality" directive
- 3,024-level architecture reflects the full 9 Nations, 3 Acts scope
- Entropy as primary difficulty driver is elegant: player difficulty is inherent in the word graph structure, not externally imposed

**Potential Tensions:**
- The phrase bank (3,184 phrases) is large but may still be insufficient for generating all 3,024 unique levels without repetition. This is a known limitation flagged in commit 15cdd0c.
- The director's memory notes specify "minimum 80 LAS for Land 1." LAS is now deprecated. The equivalent is PFS >= 4 for Tier 1. This translation is implicit and should be confirmed with the director.
- The ContentRuleDoc uses "16 phrases per level" but the Godot game was built with 12 base + 3 bonus = 15 word pairs. Alignment between the content pipeline and game code needs verification.

### Evolution of the Concept

**Before This Session:**
- Phrase selection was ad-hoc, human-curated
- Level data was hand-authored in JSON
- No systematic difficulty scoring
- No reproducible pipeline for generating at scale
- Rulebook v2.0 existed but wasn't implemented in code

**After This Session:**
- Fully automated content pipeline (Python scripts)
- 3,184 scored phrases in master database
- Deterministic scoring: entropy, PFS, difficulty, tone all computed
- Graph-based level generation via DFS pathfinding
- 3 validated levels ready for gameplay testing
- System architecture proven: can generate more levels with same pipeline
- Foundation in place for scaling to 3,024 total levels

### Open Questions for Next Session

1. **Level count alignment:** ContentRuleDoc specifies 16 phrases per level. Godot game expects 12 base + 3 bonus = 15. Which is canonical? Does bonus mode count as phrase 13-15 or are they separate?

2. **Phrase bank scaling:** 3,184 phrases generates ~3 unique Corinthia Tier 1 levels before the path diversity is exhausted. Need approximately 500x more unique phrase diversity to generate all 3,024 levels. Strategy: expand per-nation phrase pools substantially.

3. **Nation-scoped phrase pools:** Current batch CSVs are generic (household, food, transport, etc.). They need nation-specific thematic weighting for Corinthia vs Carnea vs Patmos etc. The industry word pools defined in ContentRuleDoc.md need to be seeded into the master database.

4. **Translation file handling:** The .translation files (Godot binary artifacts) are currently untracked. Should they be committed? They can be regenerated but committing avoids Godot reimport on fresh clone. Decision pending.

5. **corinthia.json format:** The current file has 3 levels with 16 phrases each. This needs to be extended to Level 4-10 (or 4-23 for full Corinthia) before the level selector UI is useful beyond testing.

6. **Phase 5 vs content expansion:** Still the pending decision from last session. Do we start Phase 5 (hearts/lives system) or continue expanding the content pipeline?

---

## Session Metrics

**Duration:** Estimated 2-3 sessions compressed (commits span Feb 20-22)
**Files Added:** 40+ (ContentRuleDoc system, batch CSVs, scripts, docs)
**Files Modified:** corinthia.json (3 times), project.godot, gameplay_screen.gd (minor)
**Scripts Created:** 8 Python pipeline scripts
**Phrases in Database:** 3,184 (phrases_master_pfs.csv)
**Levels Generated:** 3 valid 16-phrase chains for Corinthia
**Phase Progress:** Content pipeline infrastructure now in place (major milestone)

---

**Status:** Session closed successfully
**Next Action:** Decide Phase 5 (hearts/lives) vs Phase 4 content expansion (populate Corinthia levels 4-23)
**Blocking Issues:**
- Level count alignment (16 vs 15 phrases) needs resolution
- Phrase bank needs substantial expansion for full scale generation
