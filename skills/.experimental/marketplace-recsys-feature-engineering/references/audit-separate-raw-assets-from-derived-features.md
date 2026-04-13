---
title: Separate Raw Assets from Derived Features
impact: CRITICAL
impactDescription: prevents 1-way data loss that blocks re-extraction with better models
tags: audit, raw, derived, immutability, re-extraction
---

## Separate Raw Assets from Derived Features

Deriving features in place — overwriting a photo with a smaller JPEG, replacing a description with its TF-IDF vector, discarding the wizard's free text after encoding — locks you out of ever re-extracting features with a better model. The raw input is the irreplaceable asset; the derived feature is a cheap, versionable function of it. Store raw assets immutably in object storage, store derived features as versioned columns or entries in the feature store, and treat extraction as a reproducible pipeline, not a one-time import.

**Incorrect (derives features in place and discards the source):**

```python
def process_new_listing(listing: Listing) -> None:
    photo = asset_client.fetch(listing.cover_photo_url)
    embedding = clip_model.encode_image(photo)
    db.execute(
        "UPDATE listings SET cover_photo_embedding = :e WHERE id = :id",
        e=embedding.tolist(), id=listing.id,
    )
    asset_client.delete(listing.cover_photo_url)  # original lost forever
```

**Correct (raw preserved, derived feature versioned in the feature store):**

```python
VISION_MODEL_VERSION = "clip-vit-b32-2026-q2"

def process_new_listing(listing: Listing) -> None:
    photo = asset_client.fetch(listing.cover_photo_url)  # raw stays where it is

    embedding = clip_model.encode_image(photo)
    feature_store.put(
        entity_key=listing.id,
        feature_group="listing_vision",
        values={"cover_photo_embedding": embedding.tolist()},
        version=VISION_MODEL_VERSION,
    )
    # next month, swap CLIP for a domain-tuned model; re-extract from the intact raw asset.
```

Reference: [Feast — What is a Feature Store?](https://feast.dev/blog/what-is-a-feature-store/)
