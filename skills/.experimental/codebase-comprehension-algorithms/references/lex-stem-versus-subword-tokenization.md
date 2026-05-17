---
title: Stem Or Subword-Tokenize To Collapse Morphological Variants
impact: MEDIUM-HIGH
impactDescription: collapses 20-40% vocabulary inflation from singular/plural/tense variation
tags: lex, stemming, porter, subword, bpe, lemmatization
---

## Stem Or Subword-Tokenize To Collapse Morphological Variants

After splitting and expansion, your vocabulary contains `user`, `users`, `userId`, `usering`, `usered`, `paymentService`, `paymentServices`, `paymentServiced` — all referring to the same concept. The matrix doesn't know they're related; cosine similarity treats them as fully distinct dimensions. **Stemming** (Porter 1980) or **lemmatization** collapses morphological variants to a canonical form (`user`, `users`, `usering` → `user`). For modern pipelines, **subword tokenization** (BPE — Sennrich-Haddow-Birch ACL 2016; WordPiece — Wu et al. 2016) handles this *and* handles rare-identifier OOV problems by decomposing into shared sub-pieces.

The non-obvious trade-off: **stem aggressively for topic models and clustering** (you want fewer, denser dimensions); **subword-tokenize for embeddings and neural methods** (the model can compose meaning from pieces). Conflate the two and you get poor results from both — over-stem and BPE has nothing to learn from; under-stem and LDA inflates the topic count.

**Incorrect (no morphological collapse — separate dimensions for user/users/userId):**

```python
# Each plural / suffix / variant is its own vocabulary slot.
# A codebase with `user`, `users`, `userId`, `userName` contributes 4
# uncorrelated dimensions to the file × term matrix.
vocab = sorted(set(t for doc in corpus for t in doc))
# After preprocessing on a real codebase: vocab size ~25,000.
# After stemming: ~10,000-15,000. 40% reduction, denser signal.
```

**Correct (Porter stemming for topic models / clustering):**

```python
from nltk.stem import PorterStemmer, SnowballStemmer

stemmer = PorterStemmer()  # SnowballStemmer("english") is more aggressive

def stem_tokens(tokens: list[str]) -> list[str]:
    out = []
    for t in tokens:
        s = stemmer.stem(t)
        if len(s) >= 2:  # Porter can produce 1-char stems; drop them
            out.append(s)
    return out

# Examples:
#   stemmer.stem("payments")     → "payment"
#   stemmer.stem("paymentService") → "paymentservic"   # ← naive: doesn't split first
#   stem_tokens(["payment", "payments", "userId"]) → ["payment", "payment", "userid"]
#
# CRITICAL: stem AFTER identifier splitting, not the raw identifier.
# Apply Samurai → expand → lowercase → stem. Order matters.
```

**Correct (lemmatization when you need real words, not stems):**

```python
import spacy
nlp = spacy.load("en_core_web_sm", disable=["parser", "ner", "tagger"])

def lemmatize_tokens(tokens: list[str]) -> list[str]:
    """Lemmatization preserves word identity ("payment", "payments" → "payment")
    where stemming may not ("paid" stems to "pai"). Slower (~10x); use for
    cluster *labels*, not for similarity computation."""
    doc = nlp(" ".join(tokens))
    return [t.lemma_.lower() for t in doc if not t.is_punct and len(t.lemma_) > 1]
```

**Alternative (subword/BPE — for embedding-based methods):**

```python
# BPE (Byte-Pair Encoding) starts with single characters and iteratively
# merges the most-frequent adjacent pair. Result: a fixed vocabulary that
# covers any input via composition.
#
# Example BPE merges on a Python corpus might produce:
#   "payment" → ["payment"]            (whole word — frequent enough)
#   "userId"  → ["user", "id"]         (split at concept boundary)
#   "paymentService" → ["payment", "service"]
#   "xqz_handler" → ["x", "q", "z", "_handler"]  (rare → fragmented)
#
# Use case: feeding tokens into an embedding model (code2vec, CodeBERT,
# nomic-embed-code). Subword tokenization handles never-seen identifiers
# gracefully; pure-word tokenization either OOVs or treats them as new.

from tokenizers import Tokenizer
from tokenizers.models import BPE
from tokenizers.trainers import BpeTrainer
from tokenizers.pre_tokenizers import Whitespace

tokenizer = Tokenizer(BPE(unk_token="[UNK]"))
tokenizer.pre_tokenizer = Whitespace()
trainer = BpeTrainer(vocab_size=10000, special_tokens=["[UNK]", "[PAD]"])
tokenizer.train_from_iterator(iter_token_strings(corpus), trainer)
# tokenizer.encode("paymentService").tokens → ['payment', 'service']
```

**Comparison: pick the right tool for the downstream method:**

| Downstream | Best preprocessor | Why |
|------------|-------------------|-----|
| LDA / NMF topic modelling | Porter or Snowball stemmer | Compress vocabulary; sampler converges faster |
| LSI / SVD | Porter stemmer or lemmatizer | Less sparse term-doc matrix |
| TF-IDF + k-means / hierarchical clust | Porter stemmer | Higher cosine similarity within clusters |
| Cluster *labelling* (human-readable) | Lemmatizer | Real words instead of "paymen" |
| Neural code embeddings (code2vec, CodeBERT) | BPE / WordPiece | Inductive over OOV |
| Code search (Lucene/Elasticsearch) | Stemmer + edge n-grams | Recall over partial matches |

**Empirical baseline:** Maletic-Marcus (ICSE 2001) reports a 5–10% topic-coherence improvement from Porter stemming versus no stemming on their LSI software experiments. Bavota et al. (TSE 2014) report that subword tokenization (then called "compound identifier decomposition") improves traceability link recovery by 8–15% over stemming-only.

**Don't over-stem:**

- Porter is "aggressive" — `general`, `generic`, `generation`, `generated` all stem to `gener`. Sometimes you want them separate. Snowball is even more aggressive.
- Lemmatization is conservative but slow (~10× Porter). Worth it for labels only.
- BPE depends on training corpus size; a 10k-vocab BPE trained on a 200-file repo is degenerate.

**When NOT to use either:**

- Languages with poor stemming support (you'd need a Spanish/Japanese/etc. stemmer instead of Porter).
- Project where exact-name distinction matters (compiler-level analysis, type-system work, where `User` ≠ `Users`).
- Already very small vocabulary — collapsing it further makes everything similar to everything.

**Production:** Lucene/Elasticsearch's default analyzer chain is `tokenize → lowercase → stemming filter (Porter/Snowball)`. CodeBERT's tokenizer is byte-level BPE. Eclipse Mylyn's task-context indexing uses Porter on Java identifiers.

Reference: [An Algorithm for Suffix Stripping (Porter, Program 1980)](https://tartarus.org/martin/PorterStemmer/def.txt)
