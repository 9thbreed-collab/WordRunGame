# Bigram Phrase Frequency Sources

Research compiled: 2026-02-21

## Purpose
Find pre-compiled datasets of common English two-word phrases (bigrams) with frequency data to populate the WordRun! phrase library and PFS (Phrase Frequency Score) cache.

---

## Recommended Sources

### 1. COCA N-grams (Best for American English)
- **URL**: https://www.ngrams.info/
- **Format**: Database/CSV (various options)
- **Size**: 8.2 million 2-grams (basic), up to 13.5 million with POS tagging
- **Frequency Data**: YES - from 1 billion word corpus
- **Cost**: PAID (pricing on site)
- **Notes**: Genre-balanced corpus including spoken, fiction, magazine, newspaper, academic. This is the gold standard for American English phrase frequencies.

### 2. SUBTLEX-UK Bigrams (Best Free Option)
- **URL**: https://www.ugent.be/pp/experimentele-psychologie/en/research/documents/subtlexus
- **Paper**: https://journals.sagepub.com/doi/10.1080/17470218.2013.850521
- **Format**: Excel/Text
- **Size**: ~2 million bigram entries
- **Frequency Data**: YES - from TV subtitles
- **Cost**: FREE
- **Notes**: Based on British TV subtitles. Includes word bigram frequencies, contextual diversity. Good proxy for spoken English.

### 3. Google Books Ngrams
- **URL**: https://storage.googleapis.com/books/ngrams/books/datasetsv3.html
- **Format**: TSV (tab-separated)
- **Size**: MASSIVE (100+ GB for English 2-grams)
- **Frequency Data**: YES - from Google Books corpus
- **Cost**: FREE
- **Notes**: Very large but includes written/formal English, not ideal for spoken frequency. Requires significant processing.

### 4. BiRD Dataset (Bigram Relatedness)
- **URL**: https://github.com/sasaadi/BiRD
- **Paper**: https://aclanthology.org/N19-1050/
- **Format**: TXT
- **Size**: 3,345 English term pairs
- **Frequency Data**: NO (relatedness scores, not frequency)
- **Cost**: FREE
- **Notes**: Useful for semantic relationships between word pairs, not frequency. Could supplement phrase selection.

### 5. Peter Norvig's N-gram Data
- **URL**: https://norvig.com/ngrams/
- **Format**: Text files
- **Size**: Various
- **Frequency Data**: YES
- **Cost**: FREE
- **Notes**: Processed Google data, easier to work with than raw Google Ngrams.

---

## Sources NOT Recommended

| Source | Reason |
|--------|--------|
| GitHub lydell/bigrams | Letter pairs only (th, he, in), NOT word pairs |
| SUBTLEX-US | Unigrams only, no bigram data |
| Most Kaggle datasets | Usually unigrams, not phrase-level |

---

## Priority Action Plan

### Immediate (Free)
1. **Download SUBTLEX-UK bigrams** - Best free option for spoken-like frequencies
2. **Process into JSON format** matching `spoken_pfs_manual.json` structure
3. **Filter to common phrases** (top 10k by frequency)

### If Budget Available
1. **Purchase COCA 2-grams** - Gold standard for American English
2. **Cross-reference with SUBTLEX-UK** for validation

### Processing Pipeline
```
Raw Data → Filter common phrases → Normalize to PFS 1-5 scale → JSON cache
```

---

## Current PFS Cache Status

| Metric | Value |
|--------|-------|
| Phrases in cache | 51 |
| Phrases needed (estimate) | 500-1000 |
| Missing from current levels | 18 |

---

## Next Steps

1. Download SUBTLEX-UK bigram file from official source
2. Write Python script to:
   - Parse the bigram frequency data
   - Filter to phrases matching WordRun! criteria (noun-noun, adj-noun, etc.)
   - Calculate PFS scores (percentile → 1-5 scale)
   - Export to JSON format
3. Merge with existing `spoken_pfs_manual.json`
4. Re-run level validation

---

## References

- [COCA N-grams](https://www.ngrams.info/)
- [SUBTLEX-UK Paper](https://journals.sagepub.com/doi/10.1080/17470218.2013.850521)
- [SUBTLEX-US Official](https://www.ugent.be/pp/experimentele-psychologie/en/research/documents/subtlexus)
- [Google Books Ngrams](https://storage.googleapis.com/books/ngrams/books/datasetsv3.html)
- [BiRD Dataset](https://github.com/sasaadi/BiRD)
- [Peter Norvig N-grams](https://norvig.com/ngrams/)
- [Lexical Computing](https://www.lexicalcomputing.com/english-ngram-databases-and-ngram-models-for-download/)
