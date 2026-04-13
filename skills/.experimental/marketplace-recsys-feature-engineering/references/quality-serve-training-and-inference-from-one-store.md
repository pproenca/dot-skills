---
title: Serve Training and Inference Features from One Store
impact: MEDIUM-HIGH
impactDescription: eliminates the #1 cause of silent model regression
tags: quality, feature-store, training-serving-skew, online-offline
---

## Serve Training and Inference Features from One Store

Training-serving skew — the model learns from one feature distribution and serves on another — is the most common silent killer of marketplace models. The fix is structural: a feature store that offers a single computation with two reads, one for training (batch, historical, point-in-time correct) and one for inference (low-latency, latest value). Both paths must pull from the same transformation code and the same storage backend, so that any change to the feature is reflected in both simultaneously. Bespoke SQL at training time and bespoke caches at serving time are the anti-pattern.

**Incorrect (parallel pipelines for training and serving):**

```python
# training batch job (spark)
def training_features(window_start, window_end):
    return spark.sql(f"""
        SELECT sitter_id, AVG(rating) AS avg_rating_30d
        FROM reviews
        WHERE created_at BETWEEN '{window_start}' AND '{window_end}'
        GROUP BY sitter_id
    """)

# serving path (python service)
def serving_features(sitter_id):
    key = f"sitter:{sitter_id}:avg_rating"
    return redis.get(key) or 0.0  # redis is populated by a different ETL with different window semantics
```

**Correct (one feature store, two reads):**

```python
# definition (Feast feature view)
avg_rating_30d = FeatureView(
    name="sitter_stats_hourly",
    entities=[sitter_entity],
    ttl=timedelta(days=7),
    schema=[Field(name="avg_rating_30d", dtype=Float32)],
    source=PostgresSource(
        query="""
            SELECT sitter_id, AVG(rating) AS avg_rating_30d, NOW() AS event_timestamp
            FROM reviews WHERE created_at > NOW() - INTERVAL '30 days'
            GROUP BY sitter_id
        """,
    ),
    online=True,
)

# training read: point-in-time correct
training_df = store.get_historical_features(
    entity_df=labels_df,
    features=["sitter_stats_hourly:avg_rating_30d"],
).to_df()

# serving read: online latency
features = store.get_online_features(
    features=["sitter_stats_hourly:avg_rating_30d"],
    entity_rows=[{"sitter_id": sid}],
).to_dict()
```

Reference: [Feast — Solving the Training-Serving Skew Problem](https://medium.com/@scoopnisker/solving-the-training-serving-skew-problem-with-feast-feature-store-3719b47e23a2)
