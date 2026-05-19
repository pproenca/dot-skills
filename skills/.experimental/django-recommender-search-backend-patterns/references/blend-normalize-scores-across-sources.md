---
title: Normalize Scores Before Blending Across Sources
impact: HIGH
impactDescription: prevents one source from dominating the ranking
tags: blend, scoring, normalization, recommender, mixing
---

## Normalize Scores Before Blending Across Sources

Personalize returns scores in [0, 1]. Databricks logits are unbounded floats. OpenSearch BM25 ranges from ~0 to ~30 depending on corpus statistics. A naive blend (`final = personalize + databricks + opensearch`) is dominated by whichever source has the largest raw values — usually BM25. The blend looks reasonable in tests with one source, then breaks when you mix.

Normalize to a common range before combining. Min-max scaling per source (within the current candidate set) is the simplest robust approach.

**Incorrect (raw scores from heterogeneous sources):**

```python
def blend(personalize, databricks, opensearch):
    by_id = {}
    for item in personalize:
        by_id[item["id"]] = by_id.get(item["id"], 0) + item["score"]  # [0, 1]
    for item in databricks:
        by_id[item["id"]] = by_id.get(item["id"], 0) + item["score"]  # unbounded
    for item in opensearch:
        by_id[item["id"]] = by_id.get(item["id"], 0) + item["_score"] # 0-30
    # OpenSearch BM25 dominates; personalize and databricks barely contribute
    return sorted(by_id.items(), key=lambda kv: kv[1], reverse=True)
```

**Correct (min-max normalize per source, then weighted sum):**

```python
def min_max_normalize(items: list[dict], score_field: str) -> dict[str, float]:
    scores = [item[score_field] for item in items]
    if not scores:
        return {}
    lo, hi = min(scores), max(scores)
    span = hi - lo
    if span == 0:
        return {item["id"]: 1.0 for item in items}  # all tied
    return {item["id"]: (item[score_field] - lo) / span for item in items}

def blend(personalize, affinity, databricks, opensearch, *, weights):
    """Weighted sum of normalized scores. Items only in some sources still get scored."""
    normalized = {
        "personalize": min_max_normalize(personalize, "score"),
        "affinity":    min_max_normalize(affinity, "score"),
        "databricks":  min_max_normalize(databricks, "score"),
        "opensearch":  min_max_normalize(opensearch, "_score"),
    }
    # weights = {"personalize": 0.4, "affinity": 0.2, "databricks": 0.3, "opensearch": 0.1}

    all_ids = set().union(*(d.keys() for d in normalized.values()))
    blended = {}
    for item_id in all_ids:
        # Items missing from a source get 0 from it
        blended[item_id] = sum(
            normalized[source].get(item_id, 0) * weights[source]
            for source in normalized
        )
    return sorted(blended.items(), key=lambda kv: kv[1], reverse=True)
```

**Track which sources contributed to each item (for explainability + debug):**

```python
def blend_with_provenance(sources: dict[str, list], weights: dict[str, float]):
    normalized = {name: min_max_normalize(items, _score_field(name))
                  for name, items in sources.items()}

    all_ids = set().union(*(d.keys() for d in normalized.values()))
    result = []
    for item_id in all_ids:
        contributions = {
            name: normalized[name].get(item_id, 0) * weights[name]
            for name in normalized
            if item_id in normalized[name]
        }
        result.append({
            "id": item_id,
            "score": sum(contributions.values()),
            "contributions": contributions,    # { "personalize": 0.34, "opensearch": 0.18 }
            "sources": list(contributions.keys()),
        })
    return sorted(result, key=lambda r: r["score"], reverse=True)
```

**Alternative normalizations:**

| Method | Use when |
|--------|----------|
| Min-max | Default — bounded [0,1] per source, simple |
| Z-score | Sources have outliers that distort min-max |
| Rank-based (1/rank) | Scores aren't comparable in magnitude; only order matters |
| Sigmoid | Need bounded output from unbounded inputs (Databricks logits) |

**Rank-based blend (when scores are too different to normalize meaningfully):**

```python
def rrf_blend(sources: dict[str, list], k: int = 60):
    """Reciprocal Rank Fusion — combine ranked lists without using raw scores.
    Robust when scores from different models aren't on the same scale.
    """
    by_id = {}
    for source_name, ranked_items in sources.items():
        for rank, item in enumerate(ranked_items, start=1):
            by_id.setdefault(item["id"], 0)
            by_id[item["id"]] += 1.0 / (k + rank)
    return sorted(by_id.items(), key=lambda kv: kv[1], reverse=True)
# RRF is the default for Elastic's hybrid search and many production recommenders.
```

**Tune weights with offline evals:**

Don't hand-pick weights. Run an offline evaluation with held-out user interactions, measure NDCG/MAP@K with different weight settings, pick the best. Re-tune when models change.

**Pair with [[blend-dedup-across-sources]]:** before blending, dedupe — otherwise the same item from Personalize and Databricks gets double-counted at higher scores.

Reference: [Microsoft — Reciprocal Rank Fusion](https://learn.microsoft.com/en-us/azure/search/hybrid-search-ranking) | [Elastic — Hybrid search](https://www.elastic.co/search-labs/blog/hybrid-search-elasticsearch)
