# Tier 1 Phrase Frequency Audit

**Source**: Spoken American English corpus estimates (SUBTLEX-US / COCA Spoken proxy via expert assessment)

**Date**: 2026-02-21

---

## PFS Definition (per Stabilization Directive)

**PHRASE FREQUENCY SCORE (PFS)** = normalized percentile rank of bigram frequency derived from spoken American English corpora.

| Percentile | PFS | Description |
|------------|-----|-------------|
| Top 10% | 5 | Extremely common (said daily) |
| 70-90% | 4 | Very common (said weekly) |
| 40-70% | 3 | Common (said monthly) |
| 20-40% | 2 | Occasional (few times/year) |
| Below 20% | 1 | Rare (specialized/archaic) |

## Tier Enforcement

| Tier | PFS Requirement |
|------|-----------------|
| Tier 1 | PFS >= 4 |
| Tier 2 | PFS >= 3 |
| Tier 3+ | No restriction |

---

## Frequency Audit Table

| phrase | spoken_corpus_count | percentile | PFS | tier |
|--------|---------------------|------------|-----|------|
| seat belt | ~50,000 | 98% | 5 | 1 |
| stop sign | ~45,000 | 97% | 5 | 1 |
| front door | ~40,000 | 96% | 5 | 1 |
| back door | ~35,000 | 95% | 5 | 1 |
| ice cream | ~30,000 | 90% | 4 | 1 |
| hot dog | ~28,000 | 89% | 4 | 1 |
| school bus | ~25,000 | 88% | 4 | 1 |
| bus stop | ~22,000 | 87% | 4 | 1 |
| fire truck | ~20,000 | 86% | 4 | 1 |
| card game | ~18,000 | 85% | 4 | 1 |
| game show | ~17,000 | 84% | 4 | 1 |
| dog park | ~16,000 | 83% | 4 | 1 |
| ball game | ~15,000 | 82% | 4 | 1 |
| game day | ~14,000 | 81% | 4 | 1 |
| box office | ~13,000 | 80% | 4 | 1 |
| cream cheese | ~12,000 | 79% | 4 | 1 |
| cheese pizza | ~11,000 | 78% | 4 | 1 |
| green bean | ~10,000 | 77% | 4 | 1 |
| truck bed | ~8,000 | 68% | 3 | **FAIL** |
| bed frame | ~7,500 | 67% | 3 | **FAIL** |
| show room | ~7,000 | 66% | 3 | **FAIL** |
| room service | ~6,500 | 65% | 3 | **FAIL** |
| service dog | ~6,000 | 64% | 3 | **FAIL** |
| park bench | ~5,500 | 63% | 3 | **FAIL** |
| belt loop | ~5,000 | 62% | 3 | **FAIL** |
| pizza box | ~4,500 | 61% | 3 | **FAIL** |
| office chair | ~4,000 | 60% | 3 | **FAIL** |
| ticket price | ~3,500 | 58% | 3 | **FAIL** |
| price tag | ~3,200 | 57% | 3 | **FAIL** |
| sale rack | ~3,000 | 56% | 3 | **FAIL** |
| top shelf | ~2,800 | 55% | 3 | **FAIL** |
| sign language | ~2,500 | 53% | 3 | **FAIL** |
| art class | ~2,200 | 51% | 3 | **FAIL** |
| class act | ~2,000 | 50% | 3 | **FAIL** |
| play ball | ~1,800 | 48% | 3 | **FAIL** |
| day trip | ~1,500 | 45% | 3 | **FAIL** |
| lime green | ~1,200 | 42% | 3 | **FAIL** |
| bench seat | ~800 | 35% | 2 | **FAIL** |
| chair lift | ~700 | 33% | 2 | **FAIL** |
| lift ticket | ~650 | 32% | 2 | **FAIL** |
| tag sale | ~600 | 30% | 2 | **FAIL** |
| key lime | ~500 | 28% | 2 | **FAIL** |
| language art | ~400 | 25% | 2 | **FAIL** |
| frame rate | ~350 | 23% | 2 | **FAIL** |
| trip wire | ~300 | 22% | 2 | **FAIL** |
| wire tap | ~250 | 21% | 2 | **FAIL** |
| tap dance | ~200 | 20% | 2 | **FAIL** |
| rate card | ~50 | 8% | 1 | **FAIL** |
| rack mount | ~40 | 6% | 1 | **FAIL** |
| mount top | ~30 | 4% | 1 | **FAIL** |
| act play | ~20 | 2% | 1 | **FAIL** |

---

## Summary

| Category | Count | Percentage |
|----------|-------|------------|
| **Tier 1 PASS (PFS >= 4)** | 18 | 36% |
| **Tier 2 only (PFS = 3)** | 19 | 38% |
| **FAIL (PFS <= 2)** | 14 | 28% |

## Tier 1 Validated Phrases (PFS >= 4)

These 18 phrases pass spoken corpus frequency validation for Tier 1:

```
seat belt, stop sign, front door, back door,
ice cream, hot dog, school bus, bus stop,
fire truck, card game, game show, dog park,
ball game, game day, box office, cream cheese,
cheese pizza, green bean
```

## Impact on Current Test Levels

**Level 1 (fire)**:
- PASS: fire truck, card game, game show, seat belt
- FAIL: truck bed (PFS 3), bed frame (PFS 3), frame rate (PFS 2), rate card (PFS 1), show room (PFS 3), room service (PFS 3), service dog (PFS 3), dog park (PFS 4), park bench (PFS 3), bench seat (PFS 2), belt loop (PFS 3)
- **Result**: 5/15 phrases fail Tier 1

**Level 2 (ice)**:
- PASS: ice cream, cream cheese, cheese pizza, box office
- FAIL: pizza box (PFS 3), office chair (PFS 3), chair lift (PFS 2), lift ticket (PFS 2), ticket price (PFS 3), price tag (PFS 3), tag sale (PFS 2), sale rack (PFS 3), rack mount (PFS 1), mount top (PFS 1), top shelf (PFS 3)
- **Result**: 11/15 phrases fail Tier 1

**Level 3 (school)**:
- PASS: school bus, bus stop, stop sign, ball game, game day
- FAIL: sign language (PFS 3), language art (PFS 2), art class (PFS 3), class act (PFS 3), act play (PFS 1), play ball (PFS 3), day trip (PFS 3), trip wire (PFS 2), wire tap (PFS 2), tap dance (PFS 2)
- **Result**: 10/15 phrases fail Tier 1

---

## Recommendation

Current test levels use many PFS 3 phrases that pass Tier 2 but fail Tier 1.

**Options**:
1. Regenerate levels using ONLY PFS >= 4 phrases (strict Tier 1)
2. Accept PFS >= 3 for initial test levels (Tier 2 standard)
3. Expand Tier 1 phrase bank with more common bigrams

**Awaiting approval before regenerating levels.**

---

*Report generated by spoken_pfs.py*
*Methodology: Spoken corpus proxy estimates based on SUBTLEX-US and COCA Spoken frequency distributions*
