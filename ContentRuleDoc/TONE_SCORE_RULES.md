# TONE SCORE RULES

## Rule-Based Tone Assignment

Tone scores (0-100) are assigned based on semantic categories.

No subjective judgment. Pure category lookup.

---

## CATEGORY → TONE MAPPING

| Category | Base Tone | Notes |
|----------|-----------|-------|
| nature | 10 | Calm, neutral |
| animal | 15 | Neutral |
| pest | 45 | Slightly negative connotation |
| food | 5 | Pleasant, neutral |
| drink | 10 | Neutral |
| alcohol | 40 | Elevated due to theme relevance |
| household | 5 | Domestic, calm |
| object_neutral | 5 | Baseline neutral |
| clothing | 10 | Neutral |
| emotion | 50 | Variable intensity |
| relationship | 35 | Can carry weight |
| social | 25 | Interaction-based |
| commerce | 15 | Neutral transaction |
| trade | 15 | Neutral |
| transport | 10 | Neutral |
| maritime | 20 | Slight adventure tone |
| architecture | 15 | Structural, neutral |
| civic | 25 | Formal |
| religious | 35 | Elevated formality |
| abstract | 45 | Requires thought |
| conflict | 70 | High intensity |
| violence | 90 | Maximum tension |
| medical | 40 | Clinical concern |
| anatomy | 30 | Body-related |
| grime | 55 | Negative connotation |
| disease | 60 | Negative |
| political | 50 | Charged |
| communication | 20 | Neutral exchange |
| music | 15 | Pleasant |
| agriculture | 10 | Pastoral, calm |
| craft | 15 | Creative, neutral |
| law | 45 | Formal, weighty |
| festival | 20 | Celebratory |

---

## MULTI-CATEGORY WORDS

If a word has multiple categories:

```
tone_score = MAX(category_tones)
```

Reason: The highest-intensity category dominates perception.

---

## PHRASE TONE SCORE

```
phrase.tone_score = MAX(word1.tone_score, word2.tone_score)
```

As defined in ContentRuleDoc Section 5.3.

---

## TONE CAP VALIDATION

For level L in Act 1:
```
tone_cap = ((L - 1) / 1007) * 33.33
```

A phrase is rejected if:
```
phrase.tone_score > tone_cap(level)
```

---

## EXAMPLES

| Word | Categories | Tone Score |
|------|------------|------------|
| table | household, object_neutral | MAX(5, 5) = 5 |
| blood | anatomy, medical | MAX(30, 40) = 40 |
| war | conflict, violence | MAX(70, 90) = 90 |
| feast | food, festival | MAX(5, 20) = 20 |
| shadow | abstract | 45 |
| court | civic, law | MAX(25, 45) = 45 |

---

## VERSION

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-19 | Initial rule-based tone mapping |
