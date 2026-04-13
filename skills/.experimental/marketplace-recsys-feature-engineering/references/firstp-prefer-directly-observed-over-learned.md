---
title: Prefer Directly Observed Features over Learned Features at Launch
impact: CRITICAL
impactDescription: delivers 80% of the lift at 10% of the system complexity
tags: firstp, observed, learned, launch, simplicity
---

## Prefer Directly Observed Features over Learned Features at Launch

The first version of any marketplace recommender should use features that the data already contains as typed columns — amenity lists, pet species, review counts, booking counts, wizard answers — before investing in embeddings, GNNs, or learned representations. Directly observed features are easy to explain, easy to validate, easy to debug, and easy to serve consistently offline and online. Learned features require training infrastructure, inference infrastructure, drift monitoring, and an ownership story. Start observed; add learned only when the observed feature portfolio has been exhausted and a specific gap is proven.

**Incorrect (ships with a GNN over the booking graph as the first feature):**

```python
def build_sitter_features(sitter: Sitter) -> dict:
    return {
        "sitter_id": sitter.id,
        "graph_embedding": gnn_service.embed_node(sitter.id).tolist(),  # 256 floats, unexplainable
    }
```

**Correct (ships with observed features; learned features deferred to v2):**

```python
def build_sitter_features(sitter: Sitter) -> dict:
    return {
        "sitter_id": sitter.id,
        "completed_stays_count": sitter.stats.completed_stays,
        "average_rating_received": sitter.stats.avg_rating,
        "review_count": sitter.stats.review_count,
        "verified_id": sitter.verification.id_verified,
        "has_senior_pet_experience": sitter.wizard.senior_pet_experience,
        "response_time_median_hours": sitter.stats.response_time_median_hours,
    }
    # v2 will add a graph embedding only after this v1 has shipped an A/B with a baseline.
```

Reference: [Google — Rules of Machine Learning, Rule #17](https://developers.google.com/machine-learning/guides/rules-of-ml)
