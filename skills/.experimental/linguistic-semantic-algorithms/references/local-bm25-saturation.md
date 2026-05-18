---
title: Use BM25 over TF-IDF when Source Files Vary Greatly in Length
impact: MEDIUM
impactDescription: prevents long-file bias in IR ranking via TF saturation and length normalization
tags: local, bm25, ir, ranking, length-normalization
---

## Use BM25 over TF-IDF when Source Files Vary Greatly in Length

TF-IDF treats a 100-LoC file and a 5000-LoC file with the same vocabulary as equally relevant — long files have inflated TF and dominate the ranking. BM25 (Robertson & Spärck Jones, 1994) fixes both problems: a length-normalization factor adjusts for file size, and a TF-saturation function (`k1` parameter) prevents repeated occurrences from gaining more than logarithmic weight. The result: BM25 reliably picks the *most relevant* file rather than the *longest* file. It's the ranking function in Elasticsearch / Lucene, in Sourcegraph, and in every serious code-search system built in the last decade. Default it for any bug-localization or feature-localization task in a repo with diverse file sizes.

**Incorrect (raw TF-IDF — long files dominate, repeated terms inflate scores linearly):**

```python
import math, collections

# Toy TF-IDF without saturation or length normalization
class NaiveTFIDF:
    def __init__(self, docs):
        self.n = len(docs)
        self.df = collections.Counter()
        self.docs = []
        for d in docs:
            toks = d.split()
            self.docs.append(toks)
            for t in set(toks): self.df[t] += 1

    def score(self, query: list[str], doc_id: int) -> float:
        d = self.docs[doc_id]
        tf = collections.Counter(d)
        return sum(tf[q] * math.log(self.n / (1 + self.df[q])) for q in query)

# A long file with "checkout" repeated 50 times beats a focused
# 100-LoC file where "checkout" is the entire topic with TF=8.
```

**Correct (BM25 — TF saturates, document length is normalized):**

```python
# pip install rank-bm25
import re, pathlib
from rank_bm25 import BM25Okapi

WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]{2,}")
files = list(pathlib.Path("src").rglob("*.py"))

def tokens(text: str) -> list[str]:
    return [w.lower() for w in WORD.findall(text)]

corpus = [tokens(p.read_text(errors="ignore")) for p in files]
bm25 = BM25Okapi(corpus, k1=1.5, b=0.75)        # default Lucene params

# Query the index
query = tokens("checkout fails after retry with card declined")
scores = bm25.get_scores(query)

ranked = sorted(zip(scores, files), reverse=True)[:10]
for s, p in ranked:
    print(f"  {s:.2f}  {p}")
# 24.31  src/api/v2/checkout_retry.py    <- focused 80 LoC, all relevant
# 19.78  src/billing/decline_handler.py
# 14.22  src/payments/stripe/retry.py
#  8.61  src/integrations/legacy_sync.py  <- long file, lower despite many "checkout" mentions
```

**Tune k1 and b per corpus.**
- `k1` (default 1.5): how quickly TF saturates. Lower (1.0) for code with extreme repetition (logs); higher (2.0) for prose-like documents.
- `b` (default 0.75): how aggressive length normalization is. b=1 fully normalizes; b=0 disables it.

For source code with mixed file sizes, the defaults are good. For markdown-heavy mono-repos, try `k1=1.2, b=0.85`.

**Compare against alternative scoring functions:** BM25F handles fielded documents (when you want to weight `filename` more than `body`); BM25+ corrects an edge-case where long highly-relevant documents still under-score. Both available in `rank_bm25.BM25Plus` and via dedicated libraries.

**Combine with `local-tfidf-bug-reports`** as the underlying ranker — same query/document model, better scoring function. Most "TF-IDF" pipelines published since 2010 are actually BM25 under the hood.

**Combine with `local-embedding-bug-text`** in a re-ranking pipeline: BM25 retrieves the top-100 candidates fast; an embedding model re-ranks the top-100 with semantic similarity. Final precision exceeds either alone.

**When NOT to apply:**
- Tiny indexes (<200 files) — overhead exceeds value; raw cosine TF-IDF is enough
- Code in a single language with extremely uniform file sizes — length normalization gains are marginal

Reference: [Robertson & Spärck Jones, Relevance weighting of search terms (JASIS 1976)](https://onlinelibrary.wiley.com/doi/10.1002/asi.4630270302), [Robertson, The probabilistic relevance framework: BM25 and beyond](https://www.staff.city.ac.uk/~sb317/papers/foundations_bm25_review.pdf)
