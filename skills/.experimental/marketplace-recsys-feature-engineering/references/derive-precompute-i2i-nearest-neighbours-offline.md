---
title: Precompute Item-to-Item Nearest Neighbours Offline
impact: MEDIUM-HIGH
impactDescription: turns i2i from 500ms per request to 5ms
tags: derive, i2i, ann, precompute, nearest-neighbours
---

## Precompute Item-to-Item Nearest Neighbours Offline

Computing cosine similarity across 500k listings at request time is a latency and compute disaster — the item shelf ("similar listings") is called on every listing page view, and recomputing neighbours on every request both burns money and bottlenecks the page. Build the i2i shelf offline as a batch job: compute pooled listing embeddings, build an ANN index (FAISS, HNSW, ScaNN, or a hosted service), and persist the top-K neighbours per listing into a key-value store keyed by listing ID. Serving then becomes a single-digit-millisecond key lookup instead of a kNN recompute.

**Incorrect (recomputes neighbours at request time):**

```python
def similar_listings(listing_id: str, k: int = 12) -> list[str]:
    query_vec = feature_store.get(listing_id, "cover_photo_embedding")
    all_vecs = feature_store.scan_all("cover_photo_embedding")  # 500k items loaded every request
    sims = [(other_id, cosine(query_vec, vec)) for other_id, vec in all_vecs.items()]
    return [id for id, _ in sorted(sims, key=lambda x: -x[1])[1 : k + 1]]
```

**Correct (precomputed offline, served from KV):**

```python
# Offline batch job (runs nightly)
def build_i2i_shelves():
    embeddings = feature_store.scan_all("listing_pooled_embedding")  # dict[id, np.ndarray]
    ids = list(embeddings.keys())
    matrix = np.stack([embeddings[i] for i in ids])

    index = faiss.IndexFlatIP(matrix.shape[1])
    index.add(matrix)

    _, neighbour_idx = index.search(matrix, k=25)  # self + 24 neighbours
    for i, listing_id in enumerate(ids):
        neighbours = [ids[j] for j in neighbour_idx[i] if ids[j] != listing_id][:24]
        i2i_store.put(listing_id, neighbours)

# Online serving
def similar_listings(listing_id: str, k: int = 12) -> list[str]:
    return i2i_store.get(listing_id)[:k]  # <5ms
```

Reference: [Eugene Yan — Real-time Machine Learning For Recommendations](https://eugeneyan.com/writing/real-time-recommendations/)
