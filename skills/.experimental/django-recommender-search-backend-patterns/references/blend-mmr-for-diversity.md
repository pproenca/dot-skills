---
title: Apply MMR Diversity to Avoid Recommendation Monocultures
impact: HIGH
impactDescription: prevents top-K from showing 10 near-duplicate items
tags: blend, mmr, diversity, recommender, ranking
---

## Apply MMR Diversity to Avoid Recommendation Monocultures

A pure relevance ranker often returns 10 nearly-identical items at the top (10 different sizes of the same headphones, 10 articles about the same news event). The user sees no real variety, click-through tanks. **Maximal Marginal Relevance (MMR)** re-ranks the top candidates to balance relevance with diversity: each subsequent item is penalized by similarity to already-selected items, so the ranking spreads across the space.

The diversity dimension is domain-specific: in retail it might be category/brand; in news it's topic clusters; in entertainment it's genre. Whatever it is, MMR is a 20-line algorithm that runs on candidates after blending, before pagination.

**Incorrect (pure relevance ranking — top-K is monoculture):**

```python
def rank(candidates: list[dict]) -> list[dict]:
    return sorted(candidates, key=lambda c: c["blended_score"], reverse=True)
# Top 10 might all be variants of one product
```

**Correct (MMR re-rank — balance relevance with diversity):**

```python
def mmr_rerank(
    candidates: list[dict],
    *,
    k: int,
    lambda_: float = 0.7,             # 0..1: weight toward relevance (1=pure relevance, 0=pure diversity)
    feature_key: str = "category",    # field used to compute similarity
) -> list[dict]:
    """Maximal Marginal Relevance.
    Picks the item that maximizes: λ × relevance - (1-λ) × max_similarity_to_selected.
    """
    if not candidates:
        return []
    # Sort by relevance to start with a strong candidate
    pool = sorted(candidates, key=lambda c: c["blended_score"], reverse=True)
    selected = [pool[0]]
    pool = pool[1:]

    while len(selected) < k and pool:
        best = None
        best_mmr = -float("inf")
        for cand in pool:
            sim = max(
                _similarity(cand[feature_key], sel[feature_key])
                for sel in selected
            )
            mmr_score = lambda_ * cand["blended_score"] - (1 - lambda_) * sim
            if mmr_score > best_mmr:
                best_mmr = mmr_score
                best = cand
        selected.append(best)
        pool.remove(best)
    return selected

def _similarity(a, b) -> float:
    """Categorical similarity — 1.0 if same, 0.0 if different.
    Adapt to your domain: for tags use Jaccard; for embeddings use cosine."""
    if isinstance(a, str) and isinstance(b, str):
        return 1.0 if a == b else 0.0
    if isinstance(a, (list, set)) and isinstance(b, (list, set)):
        sa, sb = set(a), set(b)
        if not sa or not sb:
            return 0.0
        return len(sa & sb) / len(sa | sb)  # Jaccard
    return 0.0
```

**Usage in the recommendation pipeline:**

```python
async def recommendations_view(request):
    user_id = request.user.id
    candidates = await fetch_and_blend(user_id, size=100)  # fetch wider candidate set
    diverse = mmr_rerank(candidates, k=20, lambda_=0.7, feature_key="category")
    return JsonResponse({"items": diverse})
```

**Tuning `lambda_`:**

| Value | Behavior |
|-------|----------|
| 1.0 | Pure relevance — no diversity (the default ranking) |
| 0.7-0.8 | Strong relevance with mild diversity (common in retail) |
| 0.5 | Balanced |
| 0.3 | Diversity-heavy (good for discovery feeds) |
| 0.0 | Pure diversity, no relevance — almost never useful |

Measure click-through with A/B tests to pick the right value for your domain.

**Multi-dimensional diversity:**

When one diversity feature isn't enough (you want variety in category AND brand AND price tier), use weighted multi-feature similarity:

```python
def _similarity_multi(a: dict, b: dict, weights: dict) -> float:
    score = 0.0
    for field, weight in weights.items():
        score += weight * _similarity(a[field], b[field])
    return score / sum(weights.values())

# Usage:
diverse = mmr_rerank(
    candidates, k=20, lambda_=0.7,
    similarity_fn=lambda a, b: _similarity_multi(
        a, b, weights={"category": 0.5, "brand": 0.3, "price_tier": 0.2}
    ),
)
```

**For embedding-based diversity (uses ML features):**

```python
import numpy as np

def cosine(a: np.ndarray, b: np.ndarray) -> float:
    return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b) + 1e-9))

# Each candidate has a precomputed embedding from a content model
diverse = mmr_rerank(
    candidates, k=20, lambda_=0.7,
    feature_key="embedding",
    similarity_fn=lambda a, b: cosine(np.asarray(a), np.asarray(b)),
)
```

**Performance considerations:**

MMR is O(K × N) where K is items to select and N is the candidate pool. For K=20, N=100, that's 2000 similarity computations — fast (<5ms). For K=100, N=1000 it's 100k — measure. The Python loop above is fine for typical sizes; for larger sets, use numpy vectorization.

**Don't over-diversify the top of the list:**

Some users will still expect "the best results first." Apply MMR only after position N (e.g., top 3 = pure relevance, positions 4-20 = MMR-diversified). This pattern is common for retail listings.

**Symptom of missing diversity:**
- Top 10 results all look similar
- Click-through declines with position deeper than expected
- A/B tests show users scrolling past the top results

Reference: [Carbonell & Goldstein — MMR original paper](https://www.cs.cmu.edu/~jgc/publication/The_Use_MMR_Diversity_Based_LTMIR_1998.pdf) | [Recsys diversity](https://en.wikipedia.org/wiki/Diversity_(ranking))
