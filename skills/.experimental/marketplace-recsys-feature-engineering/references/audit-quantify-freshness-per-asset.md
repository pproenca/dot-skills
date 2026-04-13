---
title: Quantify Freshness Per Asset Type
impact: CRITICAL
impactDescription: prevents stale assets from poisoning similarity and affinity scores
tags: audit, freshness, decay, staleness
---

## Quantify Freshness Per Asset Type

A cover photo uploaded in 2019 does not reflect the listing in 2026 — the pet has changed, the kitchen is renovated, the garden is overgrown. A sitter wizard response from two years ago describes someone with fewer stays and different preferences. Before features based on these assets feed i2i or u2i scoring, measure the age distribution for each asset type, set an expiry, and decide whether stale assets are excluded, re-requested, or weighted down. A feature that silently averages 2019 and 2026 signal is worse than no feature.

**Incorrect (computes embeddings over all photos regardless of upload date):**

```python
def encode_all_listing_photos() -> dict[str, np.ndarray]:
    listings = db.query("SELECT id, cover_photo_url FROM listings").all()
    return {l.id: clip_model.encode_image(fetch(l.cover_photo_url)) for l in listings}
```

**Correct (freshness gate + ask-for-refresh bucket):**

```python
FRESHNESS_CUTOFF = timedelta(days=540)  # 18 months

def encode_listing_photos() -> tuple[dict[str, np.ndarray], list[str]]:
    listings = db.query(
        "SELECT id, cover_photo_url, cover_photo_uploaded_at FROM listings"
    ).all()

    embeddings: dict[str, np.ndarray] = {}
    ask_for_refresh: list[str] = []

    for l in listings:
        age = datetime.now(timezone.utc) - l.cover_photo_uploaded_at
        if age > FRESHNESS_CUTOFF:
            ask_for_refresh.append(l.id)  # owner nudged to re-upload; listing excluded from vision features for now
            continue
        embeddings[l.id] = clip_model.encode_image(fetch(l.cover_photo_url))

    return embeddings, ask_for_refresh
```

Reference: [Airbnb — Amenity Detection and Beyond: New Frontiers of Computer Vision at Airbnb](https://medium.com/airbnb-engineering/amenity-detection-and-beyond-new-frontiers-of-computer-vision-at-airbnb-144a4441b72e)
