---
title: Track Ranking Stability as a Churn Metric
impact: MEDIUM
impactDescription: enables leading-indicator detection
tags: monitor, stability, churn
---

## Track Ranking Stability as a Churn Metric

Ranking churn — how much the top-10 for a fixed query set changes from one release to the next — is a leading indicator of model instability. A small, deliberate change typically moves the top-10 by 5-15% of positions. A sudden 40% churn without a matching deliberate change suggests a data pipeline drift, an index refresh anomaly, or a silent feature regression, and it shows up in this metric days before the business metrics move. The churn metric is computed by running the golden query set before and after each release and comparing the result lists with a rank-correlation measure like Kendall's tau or rank-biased overlap (RBO).

**Incorrect (ranking stability never measured, silent drift invisible):**

```python
def post_release_checks() -> None:
    run_smoke_tests()
    check_error_rates()
```

**Correct (RBO churn measured on every release against the golden set):**

```python
def post_release_checks() -> None:
    run_smoke_tests()
    check_error_rates()

    golden = golden_set.load_current()
    pre_ranking = cache.get("pre_release_ranking")
    post_ranking = {q.text: current_ranker(q) for q in golden.queries}

    rbo_scores = [
        rank_biased_overlap(pre_ranking[q], post_ranking[q], p=0.9)
        for q in pre_ranking
    ]
    avg_rbo = mean(rbo_scores)
    dashboard.emit("search.release_churn_rbo", value=avg_rbo)
    if avg_rbo < 0.75:
        pager.alert(
            f"Ranking churn suspicious: avg RBO {avg_rbo:.3f}",
            runbook="references/playbooks/improving.md#ranking-churn",
        )
```

Reference: [Pinecone — Evaluation Measures in Information Retrieval](https://www.pinecone.io/learn/offline-evaluation/)
