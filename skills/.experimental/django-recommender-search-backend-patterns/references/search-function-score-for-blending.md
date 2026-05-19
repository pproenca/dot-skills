---
title: Blend Personalization Signals with function_score
impact: HIGH
impactDescription: eliminates client-side re-rank of large candidate sets
tags: search, opensearch, function-score, personalization, ranking
---

## Blend Personalization Signals with function_score

When a search needs to combine BM25 relevance with personalization (user-item affinity, popularity, recency, business boosts), the wrong approach is to fetch a large top-K from OpenSearch and re-rank in Python. That wastes bytes and CPU. `function_score` lets OpenSearch apply boost functions to the relevance score in-engine, returning a final blended ranking — no client-side re-rank needed.

The trade-off: function_score evaluates per-hit, so it's not free. Use it for hot signals; fetch larger candidate sets and re-rank with Databricks/Personalize only when the function_score primitives aren't expressive enough.

**Incorrect (re-rank in Python — fetch 200 to rank 20):**

```python
def search_with_personalization(query: str, user_id: str, size: int = 20):
    # Fetch top 200 by relevance, then re-rank in Python
    body = {
        "query": {"match": {"title": query}},
        "size": 200,                              # ❌ 10× more docs than we need
        "_source": ["id", "title", "price", "popularity"],
    }
    hits = opensearch.search(index="products", body=body)["hits"]["hits"]

    # Re-rank with affinity and popularity boosts in Python
    affinities = get_user_affinities(user_id, [h["_source"]["id"] for h in hits])
    ranked = sorted(
        hits,
        key=lambda h: h["_score"] * (1 + affinities.get(h["_source"]["id"], 0)) * h["_source"]["popularity"],
        reverse=True,
    )
    return ranked[:size]
# Wastes bytes (200 vs 20), wastes Python CPU on sorting
```

**Correct (blend signals server-side with function_score):**

```python
def search_with_personalization(query: str, user_id: str, size: int = 20):
    affinity_categories = get_user_affinity_categories(user_id)  # ['electronics', 'audio']

    body = {
        "query": {
            "function_score": {
                # Base relevance query
                "query": {
                    "bool": {
                        "must": [{"match": {"title": query}}],
                        "filter": [{"term": {"in_stock": True}}],
                    }
                },
                # Multiplicative score modifiers
                "functions": [
                    # Boost items in user's affinity categories
                    {
                        "filter": {"terms": {"category": affinity_categories}},
                        "weight": 1.5,
                    },
                    # Boost by popularity, decaying influence with log
                    {
                        "field_value_factor": {
                            "field": "popularity",
                            "modifier": "log1p",
                            "factor": 0.5,
                            "missing": 0,
                        }
                    },
                    # Decay recent items higher (Gaussian decay)
                    {
                        "gauss": {
                            "created_at": {
                                "origin": "now",
                                "scale": "30d",
                                "decay": 0.5,
                            }
                        }
                    },
                ],
                "score_mode": "multiply",       # combine function scores
                "boost_mode": "multiply",       # combine with relevance score
            }
        },
        "size": size,                            # ✅ fetch exactly what we render
        "_source": ["id", "title", "price"],
    }
    return opensearch.search(index="products", body=body)["hits"]["hits"]
```

**`score_mode` (how function scores combine with each other):**

| Mode | Combination |
|------|-------------|
| `multiply` | product of all matching function scores (default) |
| `sum` | sum of scores |
| `avg` | average |
| `first` | first matching function's score only |
| `max` / `min` | max or min |

**`boost_mode` (how function score combines with the relevance score):**

| Mode | Combination |
|------|-------------|
| `multiply` | `relevance × functions` (default — function acts as a multiplier) |
| `sum` | `relevance + functions` (function adds to relevance) |
| `replace` | use only the function score, ignore relevance |
| `avg` | average of relevance and function |

**Common boost functions:**

```python
# 1. Field value factor — boost by a numeric field
{
    "field_value_factor": {
        "field": "popularity",
        "modifier": "log1p",     # log1p, sqrt, log, square, none
        "factor": 0.5,
        "missing": 0,             # value when field is missing
    }
}

# 2. Decay functions — boost recent/nearby items
{
    "gauss": {                    # gauss, exp, linear
        "created_at": {
            "origin": "now",
            "scale": "30d",       # 50% decay at 30 days
            "offset": "7d",       # no decay within last 7 days
            "decay": 0.5,
        }
    }
}

# 3. Random — for A/B testing or shuffle
{
    "random_score": {
        "seed": user_id,          # stable shuffle per user
        "field": "_seq_no",
    }
}

# 4. Script score — full flexibility
{
    "script_score": {
        "script": {
            "source": "Math.log(2 + doc['popularity'].value) * params.weight",
            "params": {"weight": 1.5},
        }
    }
}
```

**When to re-rank in Python anyway:**

- ML scores from external services (Databricks model that takes the full feature vector, not just OpenSearch fields) — fetch top 200, re-rank with ML on the candidate set
- Personalization that needs per-user features OpenSearch doesn't have indexed
- A/B testing different blending strategies — Python is easier to deploy/revert than index settings

In those cases, fetch a reasonable candidate set (50-200), re-rank in Python, return the top size.

**Don't combine `function_score` with `must` overrides:** if you wrap with `bool.must` that already excludes results, `function_score` boosts can't bring them back. Keep filters in `bool.filter`, scoring in `function_score.query`.

Reference: [OpenSearch — Function score](https://opensearch.org/docs/latest/query-dsl/compound/function-score/) | [Elasticsearch — function_score query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-function-score-query.html)
