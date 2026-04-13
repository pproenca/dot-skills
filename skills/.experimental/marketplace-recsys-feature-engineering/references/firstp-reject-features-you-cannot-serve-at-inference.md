---
title: Reject Features You Cannot Compute at Inference Time
impact: CRITICAL
impactDescription: prevents the #1 cause of training-serving skew
tags: firstp, inference, parity, training-serving-skew
---

## Reject Features You Cannot Compute at Inference Time

A feature that is trivial to compute at training time over a warehouse batch job — "average rating over all reviews received in the last 30 days" — can be impossible to compute at inference time within a 50ms budget without a feature store, a stream processor, or a precomputation pipeline. If the serving path cannot produce the feature value for a live request, the model silently receives a zero or a stale value, and the distribution it saw at training diverges from what it sees in production. Reject any feature at the design stage whose serving story is not already wired up, or invest in the infrastructure before registering the feature.

**Incorrect (training feature with no serving plan):**

```python
# training-time feature — heavy SQL join
def training_feature_avg_rating_30d(sitter_id: str) -> float:
    return db.query(
        "SELECT AVG(rating) FROM reviews "
        "WHERE sitter_id = :id AND created_at > NOW() - INTERVAL '30 days'",
        id=sitter_id,
    ).scalar()

# inference-time — the same SQL is too slow for a 50ms homefeed request
# someone patches in a cached value that is 24h stale; model now sees a different distribution online
```

**Correct (serving-first design or hard rejection):**

```python
# Option A: feature is precomputed hourly by a batch job and served from the feature store
feature_store.put_batch(
    feature_group="sitter_stats_hourly",
    computed_at=now(),
    values=compute_avg_rating_30d_for_all_sitters(),
)

def online_serving_feature(sitter_id: str) -> float:
    return feature_store.get(entity_key=sitter_id, name="avg_rating_30d")

# Option B: the feature is rejected at registration time because serving is not wired up
feature_registry.register(
    name="avg_rating_30d",
    serving_source="feature_store.sitter_stats_hourly",  # required field, validated on registration
    serving_latency_p99_ms=8,
)
```

Reference: [Feast — Training-Serving Skew](https://medium.com/@scoopnisker/solving-the-training-serving-skew-problem-with-feast-feature-store-3719b47e23a2)
