---
title: Use TF-IDF Or BM25 To Weight Identifier Tokens, Not Raw Counts
impact: HIGH
impactDescription: 2-3x improvement in topic coherence and clustering quality over raw token frequency
tags: lex, tf-idf, bm25, weighting, term-frequency, salton
---

## Use TF-IDF Or BM25 To Weight Identifier Tokens, Not Raw Counts

A file mentioning `payment` 10 times and `value` 50 times is *about* payment, not about value — but a raw bag-of-tokens treats value as five times more important. **TF-IDF** (Salton & Buckley, 1988) and **BM25** (Robertson & Walker, 1994) discount terms that appear in many files, recover terms that are rare but specific, and turn the file × term matrix into a meaningful similarity surface. Every IR system you've ever used (Google, Lucene, Elasticsearch) uses one or the other. Yet most software-clustering code in the wild uses raw counts because "we're just feeding it to LDA, which has its own weighting" — which is half-true and 100% suboptimal.

The non-obvious result: **TF-IDF features beat raw-count features as LDA input** by 10–25% on topic coherence (Hindle ICSM 2009, Maletic-Marcus ICSE 2001), because TF-IDF gives the Gibbs sampler a saner starting distribution. For non-probabilistic methods (LSI, NMF, k-means on file vectors, cosine similarity between files), TF-IDF is mandatory — without it, every file is "similar" via shared common tokens.

**Incorrect (raw counts — common tokens dominate every similarity):**

```python
from collections import Counter
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

def file_to_count_vector(file_tokens: list[str], vocab: list[str]) -> np.ndarray:
    counts = Counter(file_tokens)
    return np.array([counts.get(t, 0) for t in vocab])

# Files unrelated in domain but both heavy users of `data`, `value`, `result`
# (which survived stop-word filtering because they weren't in the list) get
# high cosine similarity. The agent reports false relationships.
vectors = [file_to_count_vector(toks, vocab) for toks in all_files]
sim = cosine_similarity(vectors)
```

**Correct (TF-IDF — standard IR weighting, ~5 lines with scikit-learn):**

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

# `sublinear_tf=True` applies 1 + log(tf) — robust to extreme term repetition
# (e.g. generated code) which would otherwise dominate.
# `min_df=2` drops terms appearing in only 1 file (hapaxes); `max_df=0.5` drops
# terms appearing in over half the files (residual stop-words you missed).
vectorizer = TfidfVectorizer(
    tokenizer=lambda x: x.split(),
    preprocessor=lambda x: x,
    sublinear_tf=True,
    min_df=2,
    max_df=0.5,
    norm="l2",
)
file_token_strings = [" ".join(toks) for toks in all_files]  # toks already preprocessed
X = vectorizer.fit_transform(file_token_strings)              # sparse F × T matrix
sim = cosine_similarity(X)
```

**Correct (Step 2 — BM25 when document lengths vary widely):**

```python
import numpy as np
from collections import Counter

class BM25:
    """
    BM25 (Robertson-Walker 1994) — TF-IDF with two improvements:
    (1) TF saturation: a term appearing 100 times isn't 100x as relevant.
        Controlled by k1 (≈1.2-2.0).
    (2) Document-length normalization: long files don't get artificially high
        scores. Controlled by b (≈0.75).
    Use BM25 when file sizes vary by an order of magnitude (small components
    vs large legacy classes); TF-IDF suffices when sizes are within ~5×.
    """
    def __init__(self, docs: list[list[str]], k1: float = 1.5, b: float = 0.75):
        self.k1, self.b = k1, b
        self.docs = docs
        self.doc_lens = [len(d) for d in docs]
        self.avg_len = sum(self.doc_lens) / len(docs)
        self.N = len(docs)
        self.df = Counter()
        for d in docs:
            for t in set(d):
                self.df[t] += 1
        self.tf = [Counter(d) for d in docs]

    def idf(self, term: str) -> float:
        # +0.5/-0.5/+1 corrections (Robertson) avoid negative IDF for common terms
        return np.log((self.N - self.df[term] + 0.5) / (self.df[term] + 0.5) + 1)

    def score(self, doc_idx: int, query_terms: list[str]) -> float:
        s = 0.0
        for term in query_terms:
            tf = self.tf[doc_idx].get(term, 0)
            if tf == 0: continue
            length_norm = 1 - self.b + self.b * self.doc_lens[doc_idx] / self.avg_len
            s += self.idf(term) * (tf * (self.k1 + 1)) / (tf + self.k1 * length_norm)
        return s
```

**Alternative (LMJM / Dirichlet smoothing — better for short queries):**

```python
# Language-Model Jelinek-Mercer (Zhai-Lafferty, SIGIR 2001) smooths each doc's
# term distribution toward the global distribution. Better than TF-IDF for
# very short queries (1-2 terms — code search). For "compute pairwise file
# similarity" — the codebase comprehension task — TF-IDF/BM25 dominates.
```

**Important parameter notes:**

| Parameter | Default | Tune toward... | When |
|-----------|---------|----------------|------|
| `min_df` | 2 | higher (5-10) | Larger corpus, noisier identifiers |
| `max_df` | 0.5 | lower (0.3) | If stop-word list is incomplete |
| `sublinear_tf` | True | always True | Generated code, copy-paste-heavy projects |
| `norm="l2"` | yes | yes for cosine sim | Always for similarity work |
| BM25 `k1` | 1.5 | 2.0 if heavy repetition | Logs, generated tests |
| BM25 `b` | 0.75 | 0.5 if file sizes uniform | Library code |

**When NOT to use:**

- Very small vocabulary (< ~200 distinct tokens after preprocessing) — IDF degenerates because almost every term is in almost every doc. Use raw counts and rely on LDA's smoothing instead.
- The clustering algorithm has its own term-weighting (e.g. some LDA implementations) — using TF-IDF can hurt. Try both and pick by coherence.
- You actively *want* the common terms (e.g. studying API conventions) — don't down-weight them.

**Production:** Lucene / Elasticsearch use BM25 as the default scoring since v5.0; Sourcegraph's symbol search uses BM25 over identifier tokens; nearly every modern code-search system has a BM25 stage somewhere.

Reference: [The Probabilistic Relevance Framework: BM25 and Beyond (Robertson & Zaragoza, FnT IR 2009)](https://www.staff.city.ac.uk/~sbrp622/papers/foundations_bm25_review.pdf)
