---
title: Verify Rights and Privacy Before Running Extraction
impact: CRITICAL
impactDescription: prevents irreversible privacy and ToS violations
tags: audit, privacy, gdpr, pii, rights
---

## Verify Rights and Privacy Before Running Extraction

Listing photos frequently contain faces, house numbers, and car plates. Descriptions contain phone numbers and exact addresses. Wizard responses contain medical notes about pets. Extracting features from these assets without first confirming that the Terms of Service permit ML processing and that PII is stripped or hashed creates a compliance debt that is cheap to avoid at ingestion time and ruinous to unwind once embeddings are in production. The audit happens before the first `CLIP.encode()` call, not after.

**Incorrect (pulls photos directly into a vision model):**

```python
def build_image_embeddings(listing_ids: list[str]) -> dict[str, np.ndarray]:
    embeddings = {}
    for lid in listing_ids:
        photo = asset_client.fetch(f"s3://ths-listings/{lid}/cover.jpg")
        embeddings[lid] = clip_model.encode_image(photo)  # face of the host is now in the vector
    return embeddings
```

**Correct (ToS gate, PII scrubbing, and consent flag before extraction):**

```python
def build_image_embeddings(listing_ids: list[str]) -> dict[str, np.ndarray]:
    assert settings.ml_training_clause_version >= "2026-02", "ToS does not yet permit ML feature extraction"

    embeddings = {}
    for lid in listing_ids:
        listing = db.get(Listing, lid)
        if not listing.owner.ml_training_consent:
            continue  # explicit opt-out honoured
        photo = asset_client.fetch(listing.cover_photo_url)
        photo_scrubbed = face_blur.apply(photo)  # face detection + blur before the encoder
        embeddings[lid] = clip_model.encode_image(photo_scrubbed)
    return embeddings
```

Reference: [Airbnb — When a Picture Is Worth More Than Words](https://medium.com/airbnb-engineering/when-a-picture-is-worth-more-than-words-17718860dcc2)
