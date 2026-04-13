---
title: Fuse Modalities Before Computing Item Similarity
impact: MEDIUM-HIGH
impactDescription: multi-modal i2i beats any single modality alone
tags: derive, i2i, multimodal, fusion, embeddings
---

## Fuse Modalities Before Computing Item Similarity

Single-modality i2i is brittle: pure-visual similarity recommends visually-similar listings that have different pet requirements; pure-text similarity recommends listings with similar descriptions that look nothing alike; pure-metadata similarity recommends identical-category listings that don't actually match. The fix is to fuse modalities — visual CLIP embedding, description sentence-transformer embedding, and structured-feature one-hot vector — into a single item representation before building the ANN index. The simplest fusion is L2-normalised concatenation with per-modality weights learned offline against a golden i2i set.

**Incorrect (single modality, picks vision and ignores everything else):**

```python
def item_vector(listing: Listing) -> np.ndarray:
    return feature_store.get(listing.id, "cover_photo_embedding")
    # visually-similar villas with totally different pet requirements are "similar"
```

**Correct (normalised, weighted concatenation across modalities):**

```python
MODALITY_WEIGHTS = {
    "vision": 0.4,
    "text": 0.3,
    "structured": 0.3,
}  # tuned offline against a golden i2i set

def item_vector(listing: Listing) -> np.ndarray:
    vision = feature_store.get(listing.id, "listing_pooled_embedding")       # 512-dim
    text = feature_store.get(listing.id, "description_sentence_embedding")   # 384-dim
    structured = structured_feature_vector(listing)                          # 64-dim

    vision_n = vision / np.linalg.norm(vision) * MODALITY_WEIGHTS["vision"]
    text_n = text / np.linalg.norm(text) * MODALITY_WEIGHTS["text"]
    structured_n = structured / np.linalg.norm(structured) * MODALITY_WEIGHTS["structured"]

    return np.concatenate([vision_n, text_n, structured_n])
    # 960-dim fused vector fed to the ANN index
```

Reference: [Airbnb — WIDeText: A Multimodal Deep Learning Framework](https://medium.com/airbnb-engineering/widetext-a-multimodal-deep-learning-framework-31ce2565880c)
