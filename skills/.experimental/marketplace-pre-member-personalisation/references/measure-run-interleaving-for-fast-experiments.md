---
title: Run Interleaving for Fast Pre-Member Experiments
impact: MEDIUM
impactDescription: reduces required sample size by 10-100x
tags: measure, interleaving, experimentation
---

## Run Interleaving for Fast Pre-Member Experiments

Radlinski and Craswell's research on interleaved evaluation (WSDM 2013) showed that interleaving — alternating items from two ranking variants within the same session — delivers statistically significant results with 10-100x less traffic than full A/B testing. For pre-member surfaces, where traffic is usually the bottleneck (high-intent visitors are the minority), interleaving is the right primitive for ranking-quality experiments because it lets the team iterate at the pace of a week instead of a quarter. The trade-off is that interleaving answers "which variant is preferred within a session" not "which variant produces better downstream outcomes", so the team runs interleaving for ranking and full A/B for conversion.

**Incorrect (full A/B test for every ranking change, slow iteration):**

```python
def evaluate_ranking_change(variant_a: Ranker, variant_b: Ranker) -> Report:
    experiment = ab_test.create(
        variants={"a": variant_a, "b": variant_b},
        allocation={"a": 0.5, "b": 0.5},
        primary_metric="click_through_rate",
    )
    return experiment.wait_for_significance(min_sample_size=50_000)
```

**Correct (interleaving for ranking iterations, full A/B for conversion gates):**

```python
def evaluate_ranking_change(variant_a: Ranker, variant_b: Ranker) -> Report:
    interleaved = interleaving.create(
        variants=[variant_a, variant_b],
        method="team_draft",
        primary_metric="clicks_by_variant",
    )
    quick_report = interleaved.wait_for_significance(min_sample_size=5_000)
    if quick_report.winner is None:
        return quick_report

    full = ab_test.create(
        variants={"control": variant_a, "treatment": quick_report.winner},
        allocation={"control": 0.5, "treatment": 0.5},
        primary_metric="anonymous_to_member_conversion",
    )
    return full.wait_for_significance(min_sample_size=40_000)
```

Reference: [Radlinski and Craswell — Optimized Interleaving for Online Retrieval Evaluation (WSDM 2013)](https://dl.acm.org/doi/10.1145/2433396.2433429)
