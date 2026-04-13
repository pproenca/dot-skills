---
title: Version Feature Definitions in a Single Registry
impact: MEDIUM-HIGH
impactDescription: prevents two models silently computing the same feature differently
tags: quality, registry, versioning, governance
---

## Version Feature Definitions in a Single Registry

If `avg_rating_30d` is computed by Python in one training pipeline and by SQL in another, the two models see different distributions and every debugging session starts with "which version of the feature is this?" A single feature registry is the only contract that prevents drift — it owns the name, the computation code, the owner, the schema version, the serving path, and the history of changes. Every consumer looks up the registry entry and gets the same implementation. Without this, feature engineering is a distributed graveyard of one-off SQL scripts.

**Incorrect (two pipelines, two definitions):**

```python
# training pipeline (notebook)
def avg_rating_30d(sitter_id):
    return db.query(
        "SELECT AVG(rating) FROM reviews WHERE sitter_id = :id AND age_days < 30", id=sitter_id,
    ).scalar()

# serving pipeline (different repo)
def avg_rating_30d_serving(sitter_id):
    reviews = cache.get(f"reviews:{sitter_id}")  # cache has 7-day TTL, not 30
    return sum(r.rating for r in reviews) / max(len(reviews), 1)  # guards against empty differently
# training and serving silently disagree on zero-review sitters
```

**Correct (single registry, single implementation, versioned):**

```python
@feature_registry.define(
    name="sitter_avg_rating_30d",
    version="v2",
    dtype="float32",
    owner="ml-marketplace@trustedhousesitters.com",
    serving_source="feature_store.sitter_stats_hourly",
    offline_query="sql/sitter_avg_rating_30d_v2.sql",
    default_value=0.0,
)
def sitter_avg_rating_30d(context: FeatureContext) -> float:
    return context.feature_store.get(
        entity_key=context.sitter_id,
        feature_group="sitter_stats_hourly",
        feature_name="avg_rating_30d",
    )

# training and serving both call `feature_registry.compute("sitter_avg_rating_30d", ...)` —
# no second implementation exists.
```

Reference: [Uber — Meet Michelangelo: Uber's Machine Learning Platform](https://www.uber.com/blog/michelangelo-machine-learning-platform/)
