---
title: Pool Embeddings Across a Listing's Photo Set
impact: HIGH
impactDescription: reduces i2i variance by 2-4x versus single-photo features
tags: vision, pooling, aggregation, multi-image
---

## Pool Embeddings Across a Listing's Photo Set

A listing has 6-30 photos, each capturing a different room and angle. Using only the cover photo's embedding throws away 90% of the visual information and makes i2i similarity sensitive to whichever room the owner chose as the cover. Pool the embeddings across the full photo set with either mean pooling (simple, good default) or attention pooling (weighted by photo importance), and store both the per-photo embeddings and the pooled listing-level embedding. The pooled vector is what feeds i2i ANN; the per-photo embeddings enable explanation ("this listing is similar because of the kitchen").

**Incorrect (cover photo only):**

```python
def listing_embedding(listing: Listing) -> np.ndarray:
    return clip_model.encode_image(fetch(listing.cover_photo_url))
    # i2i similarity between two villas with different cover angles says they are dissimilar
```

**Correct (pooled over the full photo set):**

```python
def listing_embedding(listing: Listing) -> tuple[np.ndarray, list[np.ndarray]]:
    per_photo = []
    for url in listing.photo_urls:
        photo = fetch(url)
        per_photo.append(clip_model.encode_image(photo))

    if not per_photo:
        return np.zeros(512), []

    photo_stack = np.stack(per_photo)
    pooled = photo_stack.mean(axis=0)  # mean pooling; attention pooling also valid
    pooled_normed = pooled / np.linalg.norm(pooled)

    return pooled_normed, per_photo

# store pooled in the listing feature group; store per_photo alongside with photo IDs
# so i2i shelves can say "similar because of your kitchen photo".
```

Reference: [Airbnb — Embedding-Based Retrieval for Airbnb Search](https://medium.com/airbnb-engineering/embedding-based-retrieval-for-airbnb-search-aabebfc85839)
