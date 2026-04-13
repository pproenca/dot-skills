---
title: Use CLIP for Zero-Shot Listing Embeddings Before Fine-Tuning
impact: HIGH
impactDescription: ships the vision pipeline 10-15x faster than training from scratch
tags: vision, clip, zero-shot, embeddings
---

## Use CLIP for Zero-Shot Listing Embeddings Before Fine-Tuning

CLIP produces listing photo embeddings out of the box that are usable for i2i nearest-neighbour retrieval and u2i ranking features without any domain-specific training. Zero-shot CLIP is not the ceiling — a domain-tuned model will outperform it on fine-grained discrimination — but it is the correct first rung of the ladder because it lets you prove the entire vision pipeline end-to-end (ingest → embed → store → serve → A/B) in a week rather than a quarter. Only after zero-shot CLIP is in production and has delivered measurable lift does domain-tuning become justified work.

**Incorrect (trains a ResNet from scratch on listing photos before shipping anything):**

```python
# 6 weeks of training infrastructure, no online metrics yet
model = torchvision.models.resnet50(weights=None)
train_loop(model, listing_photo_dataset, epochs=40, lr=1e-4, ...)  # no proof it beats baseline
```

**Correct (CLIP ViT-B/32 zero-shot as v1, shipped behind a flag):**

```python
from transformers import CLIPModel, CLIPProcessor

CLIP_MODEL_ID = "openai/clip-vit-base-patch32"
processor = CLIPProcessor.from_pretrained(CLIP_MODEL_ID)
model = CLIPModel.from_pretrained(CLIP_MODEL_ID).eval()

def embed_listing_photo(image_bytes: bytes) -> np.ndarray:
    image = Image.open(BytesIO(image_bytes)).convert("RGB")
    inputs = processor(images=image, return_tensors="pt")
    with torch.no_grad():
        features = model.get_image_features(**inputs)
    return features.squeeze().numpy()  # 512-dim embedding, ready for ANN index

# ship behind a flag, run A/B against a no-vision baseline, then decide whether to fine-tune.
```

Reference: [OpenAI CLIP model card on Hugging Face](https://huggingface.co/docs/transformers/model_doc/clip)
