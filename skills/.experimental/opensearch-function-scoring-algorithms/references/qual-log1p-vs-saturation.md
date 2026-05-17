---
title: Choose log1p over Saturation for Long-Tail Signal Preservation
impact: MEDIUM-HIGH
impactDescription: preserves head-vs-super-head differentiation
tags: qual, log1p, saturation, distribution, normalization
---

## Choose log1p over Saturation for Long-Tail Signal Preservation

`saturation` asymptotes — once a count is many multiples of `pivot`, all such items score nearly the same (~0.98). For some domains that's correct ("popular enough is just popular enough"). For others, the long tail matters: when ranking restaurants by review count, you want a place with 50,000 reviews to clearly beat one with 5,000, even if both are "saturated." `log1p` (= `log(1+x)`) grows unboundedly but slowly — `log1p(5000) ≈ 8.5`, `log1p(50000) ≈ 10.8` — preserving order at the top end.

**Incorrect (using `saturation` when long-tail signal matters):**

```json
{
  "query": {
    "bool": {
      "must": [{ "match": { "name": "ramen" } }],
      "should": [
        {
          "rank_feature": {
            "field": "review_count",
            "saturation": { "pivot": 100 }
          }
        }
      ]
    }
  }
}
```

At review_count=100 → 0.5; review_count=10,000 → 0.99; review_count=100,000 → 0.999. The 10× and 100× more reviewed places are indistinguishable.

**Correct (`script_score` with `log1p` — head items remain distinguishable):**

```json
{
  "query": {
    "script_score": {
      "query": {
        "bool": {
          "must": [{ "match": { "name": "ramen" } }]
        }
      },
      "script": {
        "source": "_score * (1.0 + params.w * Math.log1p(doc['review_count'].value))",
        "params": { "w": 0.15 }
      }
    }
  }
}
```

**Distribution → modifier decision table:**

| Signal shape | Best modifier | Why |
|--------------|---------------|-----|
| Power-law count, head & long-tail both matter | `log1p` | Unbounded, slow growth |
| Power-law count, only "popular vs not" matters | `saturation` | Bounded, asymptotic |
| Bounded ratio with cliff (rate, fraction) | `sigmoid` | S-curve around pivot |
| Bounded ratio, monotone | `linear` or `field_value_factor` | Identity |
| Latency-like signal (lower = better) | `reciprocal` | 1/(x+ε), tunable shift |

**Combining with `boost_mode: multiply`:** When using log1p in `script_score`, the typical pattern is `_score * (1 + w * log1p(x))` so that an item with zero count still gets the base relevance score (1 + 0 = 1), not zeroed out.

**When unbounded growth is dangerous:** If a single field can have 100M values (e.g., view count on a viral video), `log1p` returns ~18.4 — fine. If it's `log(x)` without `1+`, then x=0 returns -Inf and x<1 goes negative. Always `log1p`, never `log`.

Reference: [OpenSearch script_score with log1p](https://opensearch.org/docs/latest/query-dsl/specialized/script-score/) · [Elastic relevance — log modifier](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-function-score-query.html#function-field-value-factor)
