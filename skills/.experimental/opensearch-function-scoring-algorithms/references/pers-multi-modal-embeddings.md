---
title: Use Multi-Modal Embeddings (Text + Image) for Recall
impact: MEDIUM-HIGH
impactDescription: 7-12% incremental recall over text-only embeddings
tags: pers, multi-modal, vision, clip, bilisting, pinterest
---

## Use Multi-Modal Embeddings (Text + Image) for Recall

Text-only listing embeddings miss visual concepts that drive marketplace search ("modern kitchen", "view of the bay", "industrial loft") — these concepts live in photos, not in titles. Multi-modal embeddings encode photos and text jointly (CLIP-style contrastive learning, or model-specific encoders like Pinterest's OmniSearchSage and Airbnb's BiListing). The fused vector goes into the same kNN index as a text-only vector would, but captures the visual axis that text fields cannot.

**Incorrect (text-only embedding misses visual queries):**

```python
# Embed title + description only — "modern industrial loft" matches on tokens, not aesthetic
listing_vec = text_encoder([listing.title, listing.description])
```

**Correct (joint text + image embedding via shared encoder):**

```python
# Pre-encode all photos with a vision model; mean-pool listing photos
import torch
from transformers import CLIPModel, CLIPProcessor

clip = CLIPModel.from_pretrained("openai/clip-vit-base-patch32")
proc = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

def embed_listing(listing):
    text_inputs = proc(text=[listing.title + " " + listing.description],
                       return_tensors="pt", truncation=True)
    text_vec = clip.get_text_features(**text_inputs)[0]

    image_vecs = []
    for img_url in listing.photo_urls[:5]:  # cap photos for cost
        img = load_image(img_url)
        img_inputs = proc(images=img, return_tensors="pt")
        image_vecs.append(clip.get_image_features(**img_inputs)[0])
    img_vec = torch.stack(image_vecs).mean(dim=0)

    # Concatenate or sum, then L2-normalize
    fused = torch.cat([text_vec, img_vec], dim=0)
    return torch.nn.functional.normalize(fused, dim=0).tolist()
```

**Index as `knn_vector`:**

```json
PUT /listings/_mapping
{
  "properties": {
    "multimodal_embedding": {
      "type": "knn_vector",
      "dimension": 1024,
      "method": { "name": "hnsw", "engine": "faiss" }
    }
  }
}
```

**Use the same vision encoder at query time for text queries:**

```python
query_text_inputs = proc(text=["modern industrial loft with view"], return_tensors="pt")
query_text_vec = clip.get_text_features(**query_text_inputs)[0]
query_vec = torch.nn.functional.normalize(query_text_vec, dim=0)
# Pad with zeros for the image-vec slots — CLIP text/image vectors live in same space
probe = torch.cat([query_vec, torch.zeros(512)]).tolist()
```

**Why this matters for marketplaces specifically:** Marketplace queries are increasingly visual ("show me clean modern places", "rustic cabins with fireplaces"). Sellers don't write these descriptors in titles — their photos show them. Without image features, the embedding model is blind to half the catalogue's information.

**Cost trade-off:** Pre-encoding all photos is expensive (one inference per photo per re-encode). Cache encodings by photo hash; only re-encode when a photo changes. Airbnb's BiListing paper reports tens of millions in incremental revenue from this approach.

Reference: [Pinterest — OmniSearchSage (arXiv 2404.16260)](https://arxiv.org/html/2404.16260v1) · [Airbnb — BiListing: Modality Alignment for Listings (CIKM 2025)](https://airbnb.tech/infrastructure/academic-publications-airbnb-tech-2025-year-in-review/) · [OpenAI CLIP](https://openai.com/research/clip)
