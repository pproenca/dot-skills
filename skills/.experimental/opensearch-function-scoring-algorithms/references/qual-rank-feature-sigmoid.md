---
title: Apply Sigmoid Modifier for Bounded Ratio Signals
impact: MEDIUM-HIGH
impactDescription: prevents flat-line at high ratios
tags: qual, rank-feature, sigmoid, ratio, ctr
---

## Apply Sigmoid Modifier for Bounded Ratio Signals

`saturation` is right for unbounded counts (bookings, clicks); `sigmoid` is right for bounded ratios (host response rate, acceptance rate, CTR — all natively in [0,1]). The sigmoid modifier centers the curve around a configurable `pivot` and shapes its steepness via `exponent`. This lets you express domain-specific cliff effects: "a host with 90% response rate is meaningfully different from 80%, but 50% and 60% are both roughly bad."

**Incorrect (linear scoring on response rate — penalty is flat across the bottom):**

```json
{
  "query": {
    "function_score": {
      "query": { "match_all": {} },
      "functions": [
        { "field_value_factor": { "field": "host_response_rate", "factor": 2.0 } }
      ]
    }
  }
}
```

A 50% response-rate host scores 1.0; a 90% scores 1.8. The boost is proportional to the rate, but you care about response rate non-linearly — there's a steep quality cliff around 80-90%.

**Correct (`sigmoid` modifier with pivot at the cliff):**

```json
PUT /listings/_mapping
{
  "properties": {
    "host": {
      "properties": {
        "response_rate": { "type": "rank_feature", "positive_score_impact": true }
      }
    }
  }
}
```

```json
{
  "query": {
    "bool": {
      "must": [{ "match": { "title": "loft" } }],
      "should": [
        {
          "rank_feature": {
            "field": "host.response_rate",
            "sigmoid": { "pivot": 0.85, "exponent": 4.0 }
          }
        }
      ]
    }
  }
}
```

**The sigmoid shape:**

```text
Formula:  s(x) = x^exp / (x^exp + pivot^exp)

  exponent controls steepness:
    exp = 1   → gentle S-curve
    exp = 4   → distinct cliff around pivot
    exp = 10  → near step-function

  pivot = 0.85, exp = 4:
    x = 0.50 → s ≈ 0.11
    x = 0.80 → s ≈ 0.44
    x = 0.85 → s = 0.50
    x = 0.90 → s ≈ 0.56
    x = 0.95 → s ≈ 0.62
```

**When to choose `sigmoid` over `saturation`:** Whenever the feature is intrinsically bounded (rate, fraction, normalized score) AND you have a domain-meaningful threshold (acceptance threshold, "good enough" line). Use `saturation` for unbounded counts that grow forever.

**Don't sigmoid-modify raw counts:** A 0-100,000 booking count has no meaningful "midpoint" — picking pivot=50,000 makes 100,000 score 0.94 and 200,000 also score 0.94 (saturated), losing the long-tail signal. Use `saturation` for counts.

Reference: [OpenSearch rank_feature sigmoid](https://opensearch.org/docs/latest/query-dsl/specialized/rank-feature/#sigmoid-function) · [Elastic — Sigmoid function modifier](https://www.elastic.co/guide/en/elasticsearch/reference/current/rank-feature-query.html#sigmoid)
