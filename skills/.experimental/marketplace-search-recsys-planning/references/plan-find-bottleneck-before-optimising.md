---
title: Find the Bottleneck Before Optimising
impact: HIGH
impactDescription: prevents work on non-bottleneck layers
tags: plan, bottleneck, theory-of-constraints
---

## Find the Bottleneck Before Optimising

Goldratt's Theory of Constraints observes that the throughput of a system is governed by a single bottleneck — work on anything else produces no end-to-end improvement. In retrieval systems, the bottleneck is rarely ranking sophistication; it is usually zero-result rate, stale index, missing intent classes, or broken telemetry. A one-day diagnostic that measures each layer (audit coverage, index freshness, query-log zero-result rate, retrieval recall on golden set, ranking NDCG gap to baseline) identifies the bottleneck and directs work to the layer that will actually move the needle.

**Incorrect (jumping straight to ranking tuning without diagnosis):**

```python
def next_sprint() -> list[Task]:
    return [
        Task("Tune BM25 k1 and b parameters"),
        Task("Deploy Learning to Rank model v2"),
        Task("Add cross-encoder re-ranker"),
    ]
```

**Correct (diagnostic-driven sprint planning):**

```python
def next_sprint() -> list[Task]:
    diagnosis = run_bottleneck_diagnostic()

    if diagnosis.zero_result_rate > 0.12:
        return [Task("Add relaxed-query fallback"), Task("Expand synonym dictionary")]
    if diagnosis.index_freshness_p99 > timedelta(hours=2):
        return [Task("Switch to PutItems stream for metadata")]
    if diagnosis.recall_at_100_on_golden_set < 0.85:
        return [Task("Retrieval recall improvement"), Task("Hybrid BM25 plus KNN")]
    if diagnosis.ndcg_gap_to_baseline < 0.03:
        return [Task("Ranking improvements worth justifying")]
    return [Task("Exploration: collect more labelled data")]
```

Reference: [Google — Rules of Machine Learning, Rule 16: Plan to Launch and Iterate](https://developers.google.com/machine-learning/guides/rules-of-ml)
