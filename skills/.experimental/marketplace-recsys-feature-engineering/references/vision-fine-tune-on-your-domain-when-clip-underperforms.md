---
title: Apply Domain Fine-Tuning Only When Zero-Shot CLIP Plateaus
impact: HIGH
impactDescription: closes 10-30% of the i2i relevance gap on domain taxonomies
tags: vision, fine-tuning, domain-adaptation, contrastive
---

## Apply Domain Fine-Tuning Only When Zero-Shot CLIP Plateaus

Zero-shot CLIP confuses concepts its pretraining distribution did not prioritise — it cannot reliably distinguish a terraced house from a semi-detached, a small-breed-friendly garden from one full of hazards, or a studio from a one-bed flat. Once the zero-shot baseline is shipped and offline metrics on a golden i2i set plateau, fine-tune CLIP with contrastive learning using listing-level positives (pairs of photos of the same listing) and negatives (pairs from different listings in the same region). Fashion-CLIP demonstrates the pattern: a domain-tuned CLIP variant substantially outperforms zero-shot on domain-specific discrimination.

**Incorrect (continues to use zero-shot CLIP after the gap is proven):**

```python
# golden-set NDCG@10 plateaued at 0.41 three months ago; no fine-tuning attempted
def embed(photo: bytes) -> np.ndarray:
    return clip_model.encode_image(photo)
```

**Correct (domain-adapted CLIP via contrastive fine-tuning):**

```python
from sentence_transformers import SentenceTransformer, losses, InputExample
from torch.utils.data import DataLoader

base = SentenceTransformer("clip-ViT-B-32")

# positives: two photos from the same listing
# negatives: photos from a different listing in the same region (hard negatives)
train_examples = [
    InputExample(texts=[path_a, path_b], label=1.0)
    for path_a, path_b in positive_listing_photo_pairs()
] + [
    InputExample(texts=[path_a, path_neg], label=0.0)
    for path_a, path_neg in hard_negative_pairs(same_region=True)
]

loader = DataLoader(train_examples, batch_size=64, shuffle=True)
loss = losses.ContrastiveLoss(base)
base.fit([(loader, loss)], epochs=3, warmup_steps=100)
base.save("clip-ths-listings-2026-q2")

# A/B the fine-tuned model against zero-shot on the golden i2i set before switching production.
```

Reference: [Width.ai — Fashion CLIP for Product Similarity Search](https://www.width.ai/post/product-similarity-search-with-fashion-clip)
