---
title: Diversify Categories Hierarchically in the Top Window
impact: MEDIUM-HIGH
impactDescription: 4-8% category-coverage lift in top-10
tags: div, category, hierarchical, taxonomy, rerank
---

## Diversify Categories Hierarchically in the Top Window

Marketplaces have a taxonomy (apartments / houses / rooms; restaurants / cafes / bars; clothing / shoes / accessories) — and search relevance often clusters within one branch even for broad queries. A user searching "lisbon stay" who only sees apartments misses the option to consider hotels or villas. Hierarchical category diversification ensures the top window spans the relevant subtree of the taxonomy, not a single leaf. Airbnb's "Learning to Rank Diversely" (2022) formalizes this as a constrained re-rank.

**Incorrect (no category diversification — top-10 is all apartments):**

```json
{
  "size": 10,
  "query": { "match": { "city": "lisbon" } }
}
```

**Correct (re-rank with per-category quota in top-K):**

```python
def hierarchical_diversify(ranked, taxonomy, top_k=10):
    """
    taxonomy: {category_id: parent_id} mapping
    Ensures top_k spans at least 3 distinct top-level categories if possible.
    """
    target_top_categories = 3
    top_seen = set()
    result = []
    overflow = []

    for item in ranked:
        top_cat = root_of(item.category_id, taxonomy)

        if len(result) < target_top_categories:
            # First N slots: enforce distinct top-level categories
            if top_cat not in top_seen:
                result.append(item)
                top_seen.add(top_cat)
            else:
                overflow.append(item)
        else:
            # After diversity quota met: fill by relevance from full pool
            if len(result) < top_k:
                result.append(item)

        if len(result) >= top_k:
            break

    # Fill remaining slots with overflow if needed
    for item in overflow:
        if len(result) >= top_k:
            break
        if item not in result:
            result.append(item)

    return result

def root_of(category_id, taxonomy):
    while taxonomy.get(category_id):
        category_id = taxonomy[category_id]
    return category_id
```

**Use a sliding-window quota for longer pages:**

```python
def windowed_diversity(ranked, window=10, max_per_top_cat_per_window=4):
    result = []
    for batch_start in range(0, len(ranked), window):
        window_items = ranked[batch_start : batch_start + window]
        per_cat_count = collections.Counter()
        diversified = []
        overflow = []
        for item in window_items:
            top_cat = root_of(item.category_id, taxonomy)
            if per_cat_count[top_cat] < max_per_top_cat_per_window:
                diversified.append(item)
                per_cat_count[top_cat] += 1
            else:
                overflow.append(item)
        result.extend(diversified + overflow)
    return result
```

**Why hierarchical, not flat?** A flat "max-per-category" treats `apartments_studio` and `apartments_1br` as different categories — but the user perceives both as "apartments." Hierarchical rolls up to top-level taxonomy nodes, matching user mental model.

**Calibration:**

| Top-window size | Distinct top-categories target |
|-----------------|--------------------------------|
| 5 | 2-3 |
| 10 | 3-4 |
| 20 | 4-5 |
| 50 | 5-7 |

**Don't over-diversify:** If a query is genuinely category-specific ("studio apartment lisbon"), forcing the top-10 to include 3 different categories surfaces irrelevant results. Detect category specificity from the query (NER on accommodation types) and reduce the diversity target proportionally.

**Coupling with MMR:** Use hierarchical category diversity as a *hard quota* on the top-3 slots, then apply MMR with `λ=0.7` on the remaining slots for soft within-category diversity.

Reference: [Airbnb — Learning to Rank Diversely (arXiv 2210.07774)](https://arxiv.org/pdf/2210.07774) · [Diversity in Recommender Systems Survey (Castells et al., 2022)](https://link.springer.com/chapter/10.1007/978-1-0716-2197-4_17)
