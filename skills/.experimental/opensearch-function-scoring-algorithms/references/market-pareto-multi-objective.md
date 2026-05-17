---
title: Optimize Multi-Objective Ranking with Pareto-Aware Weights
impact: HIGH
impactDescription: explicit Pareto frontier > implicit single objective
tags: market, multi-objective, pareto, optimization, ltr
---

## Optimize Multi-Objective Ranking with Pareto-Aware Weights

Marketplace ranking has at least three competing objectives: short-term revenue (conversion), long-term marketplace health (supply diversity, host fairness), and user satisfaction (relevance, repeat usage). A single-objective optimization (maximize conversion) silently sacrifices the others. The right framing is Pareto-aware: pick a point on the Pareto frontier where no objective can improve without harming another, and make the weights explicit and reviewable.

**Incorrect (single-objective with hidden costs):**

```python
# Train LTR on click+conversion alone — implicit objective is short-term revenue
def training_target(impression):
    if impression.converted: return 4
    if impression.clicked:   return 1
    return 0

# Result: model maximizes short-term conversion; supply diversity, fairness, and
# repeat usage drift silently without anyone noticing until it's a quarter too late.
```

**Correct (explicit multi-objective score with named, tracked weights):**

```python
def composite_target(impression, listing, marketplace_state):
    # Objective 1: short-term conversion
    o1_conversion = 4.0 if impression.converted else (1.0 if impression.clicked else 0.0)

    # Objective 2: supply fairness — reward exposing under-exposed listings
    listing_exposure_percentile = marketplace_state.exposure_percentile(listing.id)
    o2_fairness = 1.0 - listing_exposure_percentile  # 0..1, higher for under-exposed

    # Objective 3: long-term retention — favor host with strong repeat-guest rate
    o3_retention = listing.repeat_guest_rate_180d

    # Explicit weights — reviewable, tunable, deliberate
    w = {"conv": 0.60, "fair": 0.20, "retent": 0.20}
    return (
        w["conv"]   * o1_conversion
      + w["fair"]   * o2_fairness
      + w["retent"] * o3_retention
    )
```

**Apply in OpenSearch via `script_score` over rank_features:**

```json
{
  "query": {
    "script_score": {
      "query": { "match": { "city": "lisbon" } },
      "script": {
        "source": """
          double conv     = doc['market.conv_rate_30d_shrunk'].value;
          double fairness = 1.0 - doc['market.exposure_percentile'].value;
          double retent   = doc['market.repeat_guest_rate_180d'].value;

          return _score * (params.wConv * conv + params.wFair * fairness + params.wRetent * retent);
        """,
        "params": { "wConv": 0.60, "wFair": 0.20, "wRetent": 0.20 }
      }
    }
  }
}
```

**Pareto-frontier exploration via A/B testing:**

| Variant | wConv | wFair | wRetent | Hypothesis |
|---------|-------|-------|---------|-----------|
| Control | 0.80 | 0.10 | 0.10 | Current ranking |
| A | 0.60 | 0.20 | 0.20 | More balanced — fairness lift, small conv cost |
| B | 0.50 | 0.30 | 0.20 | Stronger fairness shift |
| C | 0.60 | 0.10 | 0.30 | Bias toward repeat-guest hosts |

Measure all three KPIs (conversion, exposure Gini, repeat-usage rate) across variants; pick the Pareto-efficient point that aligns with business goals.

**Why explicit weights beat learned multi-objective models for marketplaces:** Implicit objectives shift quietly with data distribution; explicit weights are documented, reviewable, and changeable in one place. When a stakeholder asks "why did the host fairness metric move?" the answer is "we changed `wFair` from 0.10 to 0.20 last Tuesday" — not "the model learned something we can't explain."

**DoorDash's framework (KDD 2025):** Combines affordability, familiarity, and novelty as three objectives. The framework reports incremental conversion lifts in the 2-5% range from each axis, validating the multi-objective approach over single-axis optimization.

Reference: [DoorDash — LLM-Assisted Personalization Framework (KDD 2025)](https://careersatdoordash.com/blog/doordash-kdd-llm-assisted-personalization-framework/) · [Etsy — Multi-Objective Ranking](https://www.etsy.com/codeascraft/multi-objective-ranking-at-etsy)
