# NATION CATEGORY FILTERS

## Purpose

Each Nation defines allowed and disallowed semantic categories.

If ANY word in a phrase has a disallowed category → reject phrase for that Nation.

---

## GLOBAL DISALLOWED (ALL NATIONS)

These categories are never allowed in any Nation:

```
violence
disease
grime
political
```

---

## CORINTHIA

**Industry:** Maritime Trade / Governance
**Abstraction:** Temperance / Adultery
**Tone Character:** Temperate but secretive; dual nature

### Allowed Categories
```
nature
animal
food
drink
household
object_neutral
clothing
social
commerce
trade
transport
maritime
architecture
civic
communication
agriculture
craft
law
festival
```

### Disallowed Categories
```
violence
disease
grime
political
pest
alcohol
conflict
religious
```

---

## CARNEA

**Industry:** Festivals / Brewing / Music
**Abstraction:** Joy / Drunkenness
**Tone Character:** Joyful but unsteady; liquid/dizzy

### Allowed Categories
```
nature
animal
food
drink
alcohol
household
object_neutral
clothing
emotion
social
commerce
trade
transport
architecture
communication
music
agriculture
craft
festival
```

### Disallowed Categories
```
violence
disease
grime
political
pest
conflict
law
religious
```

---

## PATMOS

**Industry:** Printing / Proclamation
**Abstraction:** Meekness / Seditions
**Tone Character:** Meek but subversive; spy/covert

### Allowed Categories
```
nature
animal
food
drink
household
object_neutral
clothing
social
commerce
trade
transport
architecture
civic
communication
craft
```

### Disallowed Categories
```
violence
disease
grime
political
pest
alcohol
conflict
religious
festival
music
```

---

## FILTERING LOGIC

```python
def is_phrase_allowed(phrase, nation):
    for word in [phrase.word1, phrase.word2]:
        for category in word.categories:
            if category in GLOBAL_DISALLOWED:
                return False
            if category in nation.disallowed_categories:
                return False
    return True
```

---

## VERSION

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-19 | Initial nation filters for MVP (3 nations) |
