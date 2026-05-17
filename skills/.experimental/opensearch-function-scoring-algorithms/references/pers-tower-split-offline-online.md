---
title: Split Item Tower Offline, Query Tower Online
impact: HIGH
impactDescription: enables sub-100ms query latency at billion-item scale
tags: pers, two-tower, offline, online, batch, latency
---

## Split Item Tower Offline, Query Tower Online

The two-tower architecture's payoff is asymmetric compute: item features change slowly (a listing's amenities, location, capacity, photo set are stable), so the item tower can be a daily batch job; query features change every request (user state, search location, dates, party size), so the query tower must run online. Computing both online is needlessly expensive; computing both offline freezes personalization. Airbnb (Abdool et al. 2025) explicitly chose features to make this split clean — anything user-state-dependent stays in the query tower; anything listing-intrinsic moves to the item tower.

**Incorrect (both towers online — high per-request cost):**

```python
def search_handler(query, user, dates):
    candidates = retrieve_all_listings(query)  # 100k listings

    # Both towers run per-request, per-listing — N * 2 forward passes
    query_vec = query_tower(query, user, dates)
    item_vecs = [item_tower(c) for c in candidates]
    scores = [cosine(query_vec, iv) for iv in item_vecs]
    return rank_by(scores)
```

100k listings × item-tower forward pass = unacceptable latency.

**Correct (offline daily item embedding + online query embedding):**

```python
# OFFLINE — runs daily as a Spark/batch job, writes to OpenSearch
def daily_item_embedding_job():
    for listing in all_listings:
        vec = item_tower(listing.intrinsic_features)
        opensearch.update(
            index="listings",
            id=listing.id,
            body={"doc": {"item_embedding": vec.tolist()}}
        )

# ONLINE — runs per request, single forward pass + ANN lookup
def search_handler(query, user, dates):
    query_vec = query_tower(
        query_text=query,
        user_features=user_state(user),
        search_context={"dates": dates, "guests": user.party_size}
    )
    return opensearch.search(index="listings", body={
        "size": 200,
        "query": {"knn": {"item_embedding": {"vector": query_vec.tolist(), "k": 200}}}
    })
```

**Feature partition discipline:**

| Goes in Item Tower (offline) | Goes in Query Tower (online) |
|------------------------------|-------------------------------|
| Listing amenities, photos, capacity | Search query text |
| Listing geographic coordinates | Search location / map bounds |
| Historical engagement rates | Selected dates, party size |
| Host attributes | User device, time of day |
| Cluster IDs, type embeddings | User long-term embedding |
| Pricing structure (base) | Real-time session vector |

**The discipline:** If a feature requires online evaluation, it must move to the query tower — but features in the query tower can't be shared with the kNN index, so you pay for them every request. Optimize the split to keep the query tower lean (~10-50 features) and rich features (photos, descriptions, capacity) on the item side.

**Why retraining the item tower more often than daily isn't worth it:** Item attributes change on the order of days-weeks (amenity edits, pricing changes), not minutes. Daily batch hits the sweet spot of freshness vs cost. Use the query tower for anything that changes faster (session-level personalization, today's date, real-time inventory).

**Validation pattern:** When you change the item-tower architecture, you must reindex *all* item embeddings before deploying the new query tower. They live in the same vector space; mismatched towers produce garbage scores. Use blue-green deployment for tower updates.

Reference: [Abdool et al. — Embedding-Based Retrieval for Airbnb Search (arXiv 2601.06873, 2025)](https://arxiv.org/pdf/2601.06873) · [Airbnb Engineering: EBR Architecture](https://airbnb.tech/uncategorized/embedding-based-retrieval-for-airbnb-search/)
