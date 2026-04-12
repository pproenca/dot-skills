---
title: Run Interleaving as a Cheap A/B Proxy
impact: MEDIUM
impactDescription: reduces experiment sample-size cost
tags: measure, interleaving, experimentation
---

## Run Interleaving as a Cheap A/B Proxy

A traditional A/B test needs thousands of sessions to reach statistical significance on small ranking changes. Interleaving — showing a single list where alternating slots come from variant A and variant B — lets each seeker effectively vote on both variants simultaneously, reducing the sample size needed by 10-100x for the same statistical power. The trade-off is that interleaving answers "which variant is preferred within a single session" rather than "which variant produces better long-term outcomes", but for ranking-quality measurement that is usually enough.

**Incorrect (full A/B split required for every ranking change, multi-week experiment runs):**

```python
def evaluate_ranking_change(variant_a: Ranker, variant_b: Ranker) -> Report:
    experiment = ab_test.create(
        name="ranker-v2-vs-v1",
        allocation={"a": 0.5, "b": 0.5},
        primary_metric="click_through_rate",
    )
    return experiment.wait_for_significance(min_sample_size=50_000)
```

**Correct (team draft interleaving, 10x less sample needed):**

```python
def evaluate_ranking_change(variant_a: Ranker, variant_b: Ranker) -> Report:
    experiment = interleaving.create(
        name="ranker-v2-vs-v1",
        variants=[variant_a, variant_b],
        interleave_method="team_draft",
        primary_metric="clicks_by_variant",
    )
    return experiment.wait_for_significance(min_sample_size=5_000)
```

Reference: [Pinecone — Evaluation Measures in Information Retrieval](https://www.pinecone.io/learn/offline-evaluation/)
