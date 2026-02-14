# Word-Pair Difficulty Scoring System for WordRun! Game

*Research compiled via Gemini CLI*

---

## 1. Frequency Data Sources

The best sources for US English phrase frequency are large, balanced corpora. Here are the most reputable options:

### Corpus of Contemporary American English (COCA)
- **Description**: This is the largest and most balanced corpus of American English. It contains over one billion words from 1990-present and is updated regularly.
- **Content**: Comprises spoken, fiction, popular magazines, newspapers, and academic texts.
- **Usefulness**: Ideal for this project. It provides raw frequency counts for n-grams (sequences of words), allowing you to find the frequency of specific two-word phrases. You can directly query the database online for frequencies.

### Google Books Ngram Viewer Corpus
- **Description**: An enormous corpus based on Google's digitization of millions of books. It contains trillions of words.
- **Content**: Written English from books published between 1500 and 2019.
- **Usefulness**: Excellent for tracking historical usage and the frequency of phrases in written form. Its sheer size makes it statistically powerful, though it is not as balanced as COCA (it only contains book text). The data is freely downloadable.

### American National Corpus (ANC)
- **Description**: A corpus of American English containing over 22 million words of written and spoken data produced since 1990.
- **Content**: A wide range of genres, similar to COCA but smaller.
- **Usefulness**: A strong, well-regarded alternative or supplement to COCA.

### Kuperman Age of Acquisition (AoA) Norms
- **Description**: A database of "age of acquisition" ratings for nearly 52,000 English words. It provides an estimated age at which a person learns a word.
- **Content**: Ratings were collected from human participants.
- **Usefulness**: Directly addresses the "age of acquisition" scoring criterion. You can use the ratings for both words in a phrase to estimate its cognitive difficulty.

---

## 2. Difficulty Tiers

These tiers are defined by a combination of frequency, age of acquisition, and cultural penetration.

| Tier | Name | Score Range | Description |
|------|------|-------------|-------------|
| 1 | Trivial | 1-20 | Phrases known by preschool-age children. Typically concrete nouns and simple, high-frequency concepts. |
| 2 | Easy | 21-40 | Common everyday phrases known to the general population. Heard daily in conversation and media. |
| 3 | Medium | 41-60 | Familiar phrases that are common but not ubiquitous. May involve more abstract concepts or less frequent contexts. |
| 4 | Hard | 61-80 | Phrases requiring a broader vocabulary or more specific domain knowledge. Often found in literature, professional settings, or formal writing. |
| 5 | Expert | 81-100 | Obscure, archaic, highly specialized, or regional phrases. These are challenging even for well-read native speakers. |

---

## 3. Scoring Criteria

Here are the key metrics to build a robust scoring formula:

### Phrase Frequency (PF)
The raw frequency of the complete two-word phrase (e.g., "ice cream") in a corpus like COCA. Higher frequency means lower difficulty. **This is the most important metric.**

### Age of Acquisition (AoA)
The estimated age a person learns the words in the phrase. Use the Kuperman AoA database. The score for the phrase would be the *maximum* AoA of the two words. A higher AoA means higher difficulty.

### Completion Ambiguity (CA)
The number of common words that can complete the first word to form a new, valid phrase. For the clue "ice ____", possible completions include "cream", "water", "tea", "cube", "pick", "skates". Higher ambiguity increases difficulty. This can be estimated by searching the corpus for `[ice] [NOUN]` and counting the high-frequency results.

### Lexical Sophistication (LS)
A measure of the complexity of the words themselves. This can be approximated by the frequency of the *second word on its own*. A very low-frequency second word (e.g., "laic") makes a phrase harder than a high-frequency one (e.g., "cream").

---

## 4. Example Phrases by Tier

Here are over 25 phrases for each tier, formatted in chains where possible.

### Tier 1: Trivial (Scores 1-20)
*Phrases a 5-year-old knows*

| Phrase | Chain Link |
|--------|------------|
| ice cream | cream -> |
| cream cheese | cheese -> |
| cheese puff | |
| hot dog | dog -> |
| dog house | |
| teddy bear | bear -> |
| bear hug | |
| piggy bank | |
| peanut butter | butter -> |
| butter knife | |
| fire truck | truck -> |
| truck stop | stop -> |
| stop sign | |
| bed time | time -> |
| time out | |
| apple juice | juice -> |
| juice box | box -> |
| box car | car -> |
| car seat | |
| sea shore | |
| school bus | bus -> |
| bus stop | |
| play ground | ground -> |
| ground hog | |
| door bell | bell -> |
| bell pepper | |
| egg hunt | |

### Tier 2: Easy (Scores 21-40)
*Common everyday phrases*

| Phrase | Chain Link |
|--------|------------|
| phone call | call -> |
| call center | center -> |
| center field | field -> |
| field trip | trip -> |
| trip wire | |
| credit card | card -> |
| card shark | shark -> |
| shark tank | tank -> |
| tank top | top -> |
| top secret | secret -> |
| secret agent | agent -> |
| agent orange | orange -> |
| orange peel | |
| gas station | station -> |
| station wagon | |
| train station | |
| post office | office -> |
| office space | space -> |
| outer space | |
| space heater | |
| front door | door -> |
| door knob | knob -> |
| knob creek | |
| hard drive | drive -> |
| drive through | |
| junk food | food -> |
| food court | court -> |
| court house | |

### Tier 3: Medium (Scores 41-60)
*Familiar but requires thought*

| Phrase | Chain Link |
|--------|------------|
| interest rate | rate -> |
| rate of return | return -> |
| return policy | |
| press conference | conference -> |
| conference call | call -> |
| call sign | sign -> |
| sign language | language -> |
| language barrier | |
| common sense | sense -> |
| sense of humor | |
| moral compass | compass -> |
| compass rose | |
| direct deposit | deposit -> |
| deposit slip | |
| supply chain | chain -> |
| chain reaction | reaction -> |
| reaction time | time -> |
| time capsule | |
| search engine | engine -> |
| engine block | |
| civil rights | rights -> |
| rights issue | |
| social security | security -> |
| security deposit | |
| carbon footprint | footprint -> |
| foot print | print -> |
| print media | |

### Tier 4: Hard (Scores 61-80)
*Less common, educated vocabulary*

| Phrase | Chain Link |
|--------|------------|
| cognitive dissonance | dissonance -> |
| dissonance theory | |
| capital gains | gains -> |
| gains tax | tax -> |
| tax bracket | bracket -> |
| bracket creep | |
| due process | process -> |
| process server | server -> |
| server farm | |
| body politic | |
| litmus test | test -> |
| test case | case -> |
| case law | |
| double jeopardy | jeopardy -> |
| jeopardy clause | |
| amicus brief | brief -> |
| brief encounter | |
| Occam's razor | |
| separation anxiety | anxiety -> |
| anxiety disorder | |
| confirmation bias | bias -> |
| bias ply | |
| proxy war | war -> |
| war hawk | |
| fait accompli | |
| geopolitical hotspot | hotspot -> |
| hotspot shield | |

### Tier 5: Expert (Scores 81-100)
*Obscure or specialized phrases*

| Phrase | Chain Link |
|--------|------------|
| Pyrrhic victory | victory -> |
| victory lap | |
| Deus ex machina | |
| ad hominem | hominem -> |
| hominem attack | |
| non sequitur | |
| prima facie | facie -> |
| facie evidence | |
| force majeure | |
| habeas corpus | corpus -> |
| corpus luteum | luteum -> |
| luteum cyst | |
| ex post facto | facto -> |
| facto law | |
| casus belli | belli -> |
| belli gerent | |
| pro bono | bono -> |
| bono fide | fide -> |
| fide purchaser | |
| in situ | situ -> |
| situ conservation | |
| sine qua non | |
| ab initio | |
| nolo contendere | contendere -> |
| contendere plea | |
| caveat emptor | |
| modus operandi | |

---

## 5. Scoring Formula

A practical formula requires normalizing each metric to a common scale (0 to 1) and then applying weights.

### Step 1: Normalize Metrics (0-1 Scale)

**Normalized Frequency (NF)**: Use the logarithm of the frequency to handle the long-tail distribution.
```
NF = 1 - (log(PhraseFrequency) / log(MaxFrequencyInCorpus))
```
*A higher frequency results in a value closer to 0.*

**Normalized AoA (NA)**:
```
NA = (Max(Word1_AoA, Word2_AoA) - MinAoA) / (MaxAoA - MinAoA)
```
*A higher age of acquisition results in a value closer to 1.*

**Normalized Ambiguity (NC)**:
```
NC = (log(NumberOfCompletions) / log(MaxPossibleCompletions))
```
*More ambiguity results in a value closer to 1.*

**Normalized Sophistication (NS)**: Use the frequency of the second word.
```
NS = 1 - (log(Word2_Frequency) / log(MaxFrequencyInCorpus))
```
*A rarer second word results in a value closer to 1.*

### Step 2: Weighted Formula

Assign weights to each component based on its importance in determining difficulty. Frequency is the most powerful predictor.

```
DifficultyScore = (NF * 50) + (NA * 25) + (NC * 15) + (NS * 10)
```

This formula produces a score where:
- **50%** of the score is from the overall phrase frequency
- **25%** is from the age of acquisition
- **15%** is from the ambiguity of the first word
- **10%** is from the rarity of the second word

### Step 3: Scale to 1-100

The result of the weighted formula will be a score between 0 and 100. Clamp it to a 1-100 range:

```
Final Score = max(1, min(100, round(DifficultyScore)))
```

---

## Quick Reference: Weight Distribution

| Metric | Weight | Description |
|--------|--------|-------------|
| Phrase Frequency | 50% | How often the phrase appears in corpus |
| Age of Acquisition | 25% | When people learn the harder word |
| Completion Ambiguity | 15% | How many valid completions exist |
| Lexical Sophistication | 10% | Rarity of the answer word |

---

## Implementation Notes

1. **Data Sources**: Start with COCA for phrase frequencies and Kuperman AoA norms for word difficulty
2. **Ambiguity Calculation**: Query corpus for `[word1] [*]` patterns and count high-frequency matches
3. **Fallback Scoring**: If corpus data unavailable, use manual tier assignment based on subjective familiarity
4. **Chain Bonus**: Phrases that chain well (word_b becomes word_a of next) could receive slight difficulty reduction for gameplay flow

This system provides a robust, data-driven method for scoring phrase difficulty that can be automated once you have access to the underlying corpora data.
