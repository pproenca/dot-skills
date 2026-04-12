---
title: Build a Golden Query Set as the First Artefact
impact: HIGH
impactDescription: enables offline regression detection
tags: plan, golden-set, evaluation
---

## Build a Golden Query Set as the First Artefact

A golden query set is a curated collection of representative queries with expected top results, graded by human judges — it is the reference point against which every ranking change is offline-evaluated before any online A/B test. Without a golden set, regressions are invisible until they show up in production metrics, and every ranking experiment is a high-variance bet. The golden set is built once at the start of a retrieval project, frozen per evaluation cycle, and versioned as a living artefact that grows with the domain. Building it is a one-week exercise; not building it adds months of debugging time.

**Incorrect (no golden set — ranking changes merged based on intuition):**

```python
def deploy_ranking_change(change: RankingChange) -> None:
    run_unit_tests()
    if all_tests_pass():
        deploy_to_production()
```

**Correct (golden set regression test as a mandatory gate):**

```python
def deploy_ranking_change(change: RankingChange) -> None:
    run_unit_tests()
    offline_metrics = evaluate_against_golden_set(
        change=change,
        golden_set=golden_set.load_version("v3.2-frozen-2026-03"),
        metrics=["ndcg@10", "mrr", "zero_result_rate"],
    )
    if offline_metrics.ndcg_at_10 < 0.98 * production.ndcg_at_10:
        raise RegressionError(
            f"NDCG@10 dropped from {production.ndcg_at_10} to {offline_metrics.ndcg_at_10}"
        )
    deploy_to_shadow_traffic(change)
```

Reference: [Pinecone — Evaluation Measures in Information Retrieval](https://www.pinecone.io/learn/offline-evaluation/)
