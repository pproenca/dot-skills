---
title: Use Determinantal Point Processes for Joint Quality and Diversity
impact: MEDIUM
impactDescription: 1-3% engagement lift over MMR on high-stakes pages
tags: div, dpp, kernel, quality-diversity, top-window
---

## Use Determinantal Point Processes for Joint Quality and Diversity

MMR is a greedy heuristic; Determinantal Point Processes (DPPs — Kulesza & Taskar 2012) are the principled probabilistic framework for diverse subset selection. A DPP defines a probability distribution over subsets where the probability is proportional to the determinant of a kernel matrix that encodes both per-item quality and pairwise similarity. The result: subsets that simultaneously maximize quality AND minimize within-subset similarity, with a single tunable trade-off and clean theoretical properties (the only sampler distribution that's both repulsive and tractable).

**The DPP construction:**

```text
Kernel: L_ij = q_i × s_ij × q_j

  where:
    q_i  = quality of item i (e.g., relevance score, conversion rate)
    s_ij = similarity between items i and j (cosine over embeddings, ∈ [0,1])

Probability of subset Y ⊆ [N]:
    P(Y) ∝ det(L_Y)

  Maximizes when items are individually high-quality (large diagonal)
  AND pairwise diverse (small off-diagonal, making det large)
```

**Incorrect (MMR greedy — locally optimal, can miss good subsets):**

```python
# Greedy MMR picks one item at a time — may get stuck in local optima
selected = mmr_rerank(candidates, query_vec, lambda_=0.5, top_k=10)
```

**Correct (DPP MAP via greedy submodular approximation):**

```python
import numpy as np

def dpp_greedy(candidates, query_vec, top_k=10):
    """
    Greedy MAP inference for DPP — same time complexity as MMR but uses
    proper DPP kernel structure. Within 1-1/e of optimum (submodular guarantee).
    """
    # 1. Build feature vectors and quality scores
    feats = np.array([c.embedding for c in candidates])
    feats = feats / np.linalg.norm(feats, axis=1, keepdims=True)  # L2-normalize
    quality = np.array([(c.relevance + c.shrunken_conv_rate) / 2.0 for c in candidates])

    # 2. Construct DPP kernel: L_ij = q_i × s_ij × q_j
    sim = feats @ feats.T  # cosine similarity (since normalized)
    L = (quality[:, None] * sim) * quality[None, :]

    # 3. Greedy MAP — pick items maximizing log-det incrementally
    selected = []
    remaining = list(range(len(candidates)))
    while len(selected) < top_k and remaining:
        best_i = best_gain = None
        for i in remaining:
            sub_idx = selected + [i]
            try:
                gain = np.linalg.slogdet(L[np.ix_(sub_idx, sub_idx)])[1]
            except np.linalg.LinAlgError:
                continue
            if best_gain is None or gain > best_gain:
                best_gain, best_i = gain, i
        if best_i is None:
            break
        selected.append(best_i)
        remaining.remove(best_i)

    return [candidates[i] for i in selected]
```

**When DPP beats MMR (and when it doesn't):**

| Scenario | Winner | Why |
|----------|--------|-----|
| Small top-k (≤10), heterogeneous candidates | DPP (~1-3% gain) | Principled global trade-off |
| Large k (>50) | MMR | DPP cost grows as k³ |
| Sparse, high-stakes pages (e.g., homepage) | DPP | Engagement lift worth the cost |
| Generic listing page, time-budget tight | MMR | Negligible quality gap, much cheaper |
| Cold-start (items with noisy quality estimates) | MMR | DPP amplifies quality-estimate noise via determinant |

**Computational note:** DPP greedy is O(N × k²) for top-k from N candidates due to the determinant updates. For top-10 from top-500, that's ~50k ops — fast. For top-50 from top-5000, ~12.5M ops — getting expensive; switch to MMR or apply DPP only on the top-100 candidates.

**Implementation tip:** Use Cholesky updates rather than full determinant re-computation; reduces inner loop from O(k³) to O(k²).

**Library options:** `dppy` (Python), or implement directly — the kernel is just `quality⊙sim⊙quality`.

Reference: [Kulesza & Taskar — Determinantal Point Processes for Machine Learning (Foundations and Trends 2012)](https://arxiv.org/abs/1207.6083) · [Chen et al. — Fast Greedy MAP Inference for DPP (NIPS 2018)](https://papers.nips.cc/paper/2018/hash/dbbf603ff0e99629dda5d75b6f75f966-Abstract.html)
