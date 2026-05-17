---
title: Use NDCG@k as the Primary Offline Ranking Metric
impact: HIGH
impactDescription: prevents metric-mismatch with multi-grade relevance
tags: eval, ndcg, metric, graded, primary
---

## Use NDCG@k as the Primary Offline Ranking Metric

NDCG (Normalized Discounted Cumulative Gain) is the right offline metric for marketplace ranking because it satisfies the two properties that matter: it uses *graded* relevance (a 4-star match is worth more than a 2-star match — not just "relevant vs not") and it *discounts position* (rank 1 matters more than rank 10). MAP and MRR fail on the first property (they treat relevance as binary); Precision@k fails on the second (it counts hits but ignores their position within k). Pick `k` to match your top window (5 for mobile, 10 for desktop result page, 20 for "above the fold + scroll").

**Incorrect (using MAP — collapses grade-4 and grade-2 into "relevant"):**

```python
def average_precision(query, ranker, judgments):
    ranked = ranker.search(query)
    relevant = [j.item_id for j in judgments if j.grade >= 2]  # binary collapse
    hits, ap = 0, 0.0
    for i, item in enumerate(ranked, 1):
        if item.id in relevant:
            hits += 1
            ap += hits / i
    return ap / len(relevant) if relevant else 0.0
```

A ranker that puts perfect matches (grade 4) at rank 3 and weak matches (grade 2) at rank 1 gets the same MAP as one that puts perfect matches at rank 1. MAP can't distinguish them.

**Correct (NDCG@k — graded gain × position discount):**

```python
import numpy as np

def dcg_at_k(grades, k):
    """Discounted Cumulative Gain at k.
       DCG = Σ_{i=1..k} (2^grade_i - 1) / log2(i + 1)
    """
    grades = np.asarray(grades[:k], dtype=float)
    if grades.size == 0:
        return 0.0
    discounts = np.log2(np.arange(2, grades.size + 2))
    return float(np.sum((2.0 ** grades - 1) / discounts))

def ndcg_at_k(query, ranker, judgments, k=10):
    """NDCG@k = DCG@k / IDCG@k  (normalize against the best possible ordering)"""
    judged = {j.item_id: j.grade for j in judgments}
    ranked = ranker.search(query, k=k)
    actual_grades = [judged.get(item.id, 0) for item in ranked]
    ideal_grades = sorted(judged.values(), reverse=True)
    idcg = dcg_at_k(ideal_grades, k)
    if idcg == 0:
        return 0.0
    return dcg_at_k(actual_grades, k) / idcg
```

**Picking `k`:**

| Surface | Recommended k | Why |
|---------|---------------|-----|
| Mobile result page | 5 | First-screen visibility on phone |
| Desktop result page | 10 | First-screen visibility on laptop |
| Long scroll / infinite feed | 20 | "Above the fold + first scroll" |
| Carousel / quick-pick | 3-5 | Limited visible slots |
| Map view | 20-30 | Visual grid, more items visible at once |

**Track NDCG@5, @10, @20 simultaneously:** A change might improve top-3 but degrade rank 11-20. Report all three — if they diverge, the ranker has a non-uniform effect across the page.

**Per-stratum NDCG is more diagnostic than average NDCG:**

```python
def stratified_ndcg(ranker, judgment_set, k=10):
    """Break NDCG down by query stratum so head/tail effects don't average out."""
    results = {}
    for stratum in ["head", "torso", "tail"]:
        queries = [j for j in judgment_set if j.query_stratum == stratum]
        scores = [ndcg_at_k(q.query, ranker, q.judgments, k=k) for q in queries]
        results[stratum] = float(np.mean(scores))
    return results
```

A ranker that improves head NDCG@10 from 0.65 → 0.68 while dropping tail NDCG@10 from 0.40 → 0.32 *averages* to a tiny lift — but the tail regression will surface as user-visible search failures the moment you ship.

**When to use other metrics anyway:**

- **MRR**: Navigational queries where exactly one result is correct ("the user is looking for THIS specific listing")
- **Precision@k**: Ad-style ranking with binary "ad shown vs not shown" outcomes
- **Recall@k**: Pure retrieval evaluation (am I even surfacing the right items in the candidate set?)
- **Mean Reciprocal Rank at first conversion**: Marketplace-specific metric when you have booking labels — measures "how quickly did the user find what they booked"

Reference: [Järvelin & Kekäläinen — Cumulated Gain-Based Evaluation of IR Techniques (TOIS 2002)](https://dl.acm.org/doi/10.1145/582415.582418) · [Towards Data Science — Why MAP and MRR Fail for Search Ranking](https://towardsdatascience.com/why-map-and-mrr-fail-for-search-ranking-and-what-to-use-instead/) · [Evidently AI — NDCG explained](https://www.evidentlyai.com/ranking-metrics/ndcg-metric)
