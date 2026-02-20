# WordRun! Word Generation System

## Overview

This folder contains a 4-part sequential pipeline for generating valid word pair chains for the WordRun! game. Each document serves a specific role in the pipeline.

```
┌─────────────────────────────────────────────────────────────────┐
│  01-MAPPING.md                                                  │
│  "Where are we and what do we need?"                            │
│                                                                 │
│  Input: Nation + Land + Playthrough                             │
│  Output: Constraints (LAS range, tone, categories, theme)       │
└─────────────────────────────┬───────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  02-PHRASE-BANK.json                                            │
│  "What phrases are available?"                                  │
│                                                                 │
│  Input: Constraints from Mapping                                │
│  Output: Candidate phrases matching constraints                 │
│  Contains: 2000+ pre-validated phrases with metadata            │
└─────────────────────────────┬───────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  03-LAS-VALIDATION.md                                           │
│  "Are these phrases truly valid?"                               │
│                                                                 │
│  Input: Candidate phrases from Phrase Bank                      │
│  Output: Validated phrases (Rule Zero + LAS scoring)            │
│  Contains: Compound word blacklist, validation rules            │
└─────────────────────────────┬───────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  04-CHAIN-BUILDER.md                                            │
│  "How do we assemble the chain?"                                │
│                                                                 │
│  Input: Validated phrases                                       │
│  Output: Complete word chains (16 words, 15 phrases per level)  │
│  Contains: Chaining rules, repetition checks, difficulty ramps  │
└─────────────────────────────┬───────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  OUTPUT: data/baseline/{nation}.json                            │
│  Final level data ready for game engine                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Document Purposes

### 01-MAPPING.md
**Role:** Context and Requirements

Defines WHERE the player is in the game (Nation, Land, Level, Playthrough) and WHAT constraints apply. This is the source of truth for:
- LAS score ranges
- Allowed tones (neutral, warm, tense, aggressive)
- Allowed phrase categories (food, household, theme, etc.)
- Theme signals (nation-specific abstraction words)
- Difficulty scaling

**When to consult:** Before generating any word pairs. This sets the parameters.

### 02-PHRASE-BANK.json
**Role:** Source Material

A database of 2000+ pre-validated two-word phrases, each tagged with:
- Category (food, household, nature, commerce, etc.)
- Tone compatibility (neutral, warm, tense, aggressive)
- LAS score estimate
- Word characteristics (length, commonality)
- Chain potential (can this word continue?)

**When to consult:** After getting constraints from Mapping. Query for matching phrases.

### 03-LAS-VALIDATION.md
**Role:** Quality Control

The filtering rules that ensure phrases are valid:
- **Rule Zero:** Compound Word Gate (if commonly one word → INVALID)
- LAS scoring (association strength)
- Chain viability (does this word have continuations?)

**When to consult:** Before finalizing any phrase selection. Double-check validity.

### 04-CHAIN-BUILDER.md
**Role:** Assembly

Rules for linking validated phrases into playable chains:
- Chain mechanics (word_b of phrase N = word_a of phrase N+1)
- No word repetition within a chain
- Difficulty ramp within level (first 1/3 easier, last 1/3 harder)
- Dead-end detection

**When to consult:** When assembling the final level data.

---

## Quick Reference

### MVP Scope
- 3 Nations: Corinthia → Carnea → Patmos
- 8 Lands per Nation
- 14 Levels per Land
- 336 Total Levels
- 3 Playthroughs (same levels, escalating difficulty)

### Abstraction Model (Theme Signals)

| Nation | Theme | SIGNAL WITH |
|--------|-------|-------------|
| Corinthia | Adultery | secret, divided, broken, hidden, double |
| Carnea | Drunkenness | liquid, pour, dizzy, merry, stupor, sway |
| Patmos | Seditions | spy, whisper, plot, rebel, covert, code |

### Key Rules
1. **Rule Zero:** Never split compound words (popcorn, doorbell, etc.)
2. **LAS 80+ minimum** for early game (0-25%)
3. **No explicit theme words** (use abstractions instead)
4. **16 words per level** (starter + 12 base + 3 bonus = 15 phrases)

---

## File Locations

| Document | Path |
|----------|------|
| System Overview | `.planning/word-system/00-OVERVIEW.md` |
| Mapping | `.planning/word-system/01-MAPPING.md` |
| Phrase Bank | `.planning/word-system/02-PHRASE-BANK.json` |
| LAS Validation | `.planning/word-system/03-LAS-VALIDATION.md` |
| Chain Builder | `.planning/word-system/04-CHAIN-BUILDER.md` |
| Level Output | `data/baseline/{nation}.json` |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-13 | Initial system architecture |
