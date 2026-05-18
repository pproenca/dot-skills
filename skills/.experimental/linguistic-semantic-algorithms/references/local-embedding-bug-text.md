---
title: Embed Bug Reports and Source Code in the Same Space for Semantic Localization
impact: MEDIUM
impactDescription: enables semantic localization when bug and code share no vocabulary
tags: local, embeddings, codebert, semantic-localization, retrieval
---

## Embed Bug Reports and Source Code in the Same Space for Semantic Localization

The hardest bug-localization case is when the bug report describes user-visible symptoms in natural language and the source code uses entirely different technical vocabulary. "Users see a duplicated invoice line" matches `src/billing/line_item_dedup.py` — a file where neither "invoice" nor "duplicated" appears in the way the user thinks of them. TF-IDF and BM25 fail this case. CodeBERT / UniXcoder were trained on paired natural language and code, so they embed both into the same vector space. Cosine similarity in that space finds semantic matches no IR scheme can. Use it as the re-ranker on top of BM25 candidates.

**Incorrect (BM25 alone — fails when vocabulary doesn't overlap):**

```python
# Bug: "Users see a duplicated invoice line on monthly statements"
# Source: src/billing/line_item_dedup.py uses "dedup", "lineItem", "monthly_bill"
# No token overlap. BM25 returns irrelevant files.

from rank_bm25 import BM25Okapi
# ... vocabulary mismatch — top-10 misses the actual buggy file ...
```

**Correct (BM25 candidates → embedding re-rank → hybrid score):**

```python
import re, pathlib
import numpy as np
from rank_bm25 import BM25Okapi
from sentence_transformers import SentenceTransformer

# 1. Stage one — BM25 retrieves top-K candidates (fast, lexical)
WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]{2,}")
files = list(pathlib.Path("src").rglob("*.py"))
texts = [p.read_text(errors="ignore") for p in files]
corpus = [[w.lower() for w in WORD.findall(t)] for t in texts]
bm25 = BM25Okapi(corpus)

bug = "Users see a duplicated invoice line on monthly statements"
bm25_scores = bm25.get_scores([w.lower() for w in WORD.findall(bug)])
top_k_idx = np.argsort(-bm25_scores)[:100]                # K=100 candidates

# 2. Stage two — embedding model re-ranks the K candidates (precise, semantic)
encoder = SentenceTransformer("microsoft/unixcoder-base")
candidate_texts = [texts[i][:4000] for i in top_k_idx]    # truncate to model limit
cand_emb = encoder.encode(candidate_texts, normalize_embeddings=True)
bug_emb = encoder.encode(bug, normalize_embeddings=True)
sem_scores = cand_emb @ bug_emb

# 3. Fuse — normalized BM25 + semantic, weighted
def normalize(arr: np.ndarray) -> np.ndarray:
    rng = arr.max() - arr.min()
    return (arr - arr.min()) / max(rng, 1e-9)

bm25_n = normalize(bm25_scores[top_k_idx])
sem_n = normalize(sem_scores)
final = 0.4 * bm25_n + 0.6 * sem_n

ranked = sorted(zip(final, top_k_idx), reverse=True)[:10]
for s, i in ranked:
    print(f"  {s:.3f}  bm25={bm25_n[list(top_k_idx).index(i)]:.2f}  sem={sem_n[list(top_k_idx).index(i)]:.2f}  {files[i]}")
# 0.812  bm25=0.21  sem=1.00  src/billing/line_item_dedup.py    <- semantic win
# 0.640  bm25=0.62  sem=0.65  src/billing/monthly_statement.py
# 0.587  bm25=0.45  sem=0.68  src/billing/invoice_lines.py
```

**Two-stage retrieval is non-negotiable above ~10k files.** Encoding every file at every query is slow. BM25 (fast, broad recall) narrows the candidate set; the embedding model (slow, precise) re-ranks. Final precision exceeds either alone.

**Use a small fast model for re-ranking.** `microsoft/unixcoder-base` (110M params) is the sweet spot for code: cross-lingual, paired NL+code, and runs in <500ms per query on CPU. CodeBERT (125M) is similar. Larger models help marginally but pay 10× the latency.

**Combine with the history prior** from `local-history-prior-localization`. Three signals (BM25 + embedding + bug-history) fused with weights `[0.3, 0.5, 0.2]` outperforms any pair on published benchmarks.

**Cache file embeddings.** Re-encode only files that changed since last index build (use git for the diff). For monorepos, batch encode on a schedule and store in a vector store (faiss / Qdrant / PostgreSQL pgvector).

**Combine with `sim-doc-code-alignment`:** the same encoder used here can pre-compute doc-section embeddings; bug reports may match documented contracts that the code no longer honours, surfacing both the code location and the doc to update.

**When NOT to apply:**
- Bug reports that are pure stack traces — embedding a stack trace gives noisy results; jump straight to the top frame's file
- Languages outside the encoder's training set — multilingual coverage matters; use UniXcoder or CodeT5+ which support more languages than CodeBERT

Reference: [UniXcoder (Guo et al., 2022)](https://arxiv.org/abs/2203.03850), [Wang et al., CodeT5+ (2023)](https://arxiv.org/abs/2305.07922), [Zhou et al., Where Should the Bugs Be Fixed? (ICSE 2012)](https://web.cs.ucla.edu/~xtmu/wsbf.pdf)
