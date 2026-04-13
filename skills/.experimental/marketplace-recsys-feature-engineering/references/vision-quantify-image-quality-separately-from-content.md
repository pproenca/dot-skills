---
title: Quantify Image Quality Separately from Content
impact: HIGH
impactDescription: prevents low-quality photos from flattening content embeddings
tags: vision, quality, blur, lighting, aesthetics
---

## Quantify Image Quality Separately from Content

Blur, low resolution, poor lighting, and heavy occlusion distort content embeddings in ways that look like content drift — a well-staged bedroom and a blurry bedroom produce embeddings that are further apart than the underlying rooms warrant. Extract quality features (Laplacian blur variance, mean brightness, resolution, detected-object occlusion ratio, NIMA aesthetic score) as a separate feature group and use them both (a) to gate which photos enter the content embedding and (b) as standalone features for ranking (Airbnb's homefeed uses aesthetic score as a feature directly).

**Incorrect (content embedding absorbs quality noise):**

```python
def embed(photo: bytes) -> np.ndarray:
    return clip_model.encode_image(photo)

# a blurry photo of the same room produces a very different embedding from a sharp one
# downstream i2i similarity sorts by quality artefact as much as by content
```

**Correct (quality features extracted, gated, and served separately):**

```python
@dataclass
class ListingPhotoFeatures:
    content_embedding: np.ndarray
    blur_variance: float
    brightness_mean: float
    resolution_megapixels: float
    aesthetic_score: float  # NIMA, 1.0 - 10.0
    accepted_for_embedding: bool

def build_photo_features(photo: bytes) -> ListingPhotoFeatures:
    blur = laplacian_variance(photo)
    brightness = mean_brightness(photo)
    res = resolution_megapixels(photo)
    aesthetic = nima_scorer.predict(photo)

    accepted = blur > 100 and brightness > 40 and res > 0.5
    content = clip_model.encode_image(photo) if accepted else np.zeros(512)

    return ListingPhotoFeatures(content, blur, brightness, res, aesthetic, accepted)
```

Reference: [Airbnb — When a Picture Is Worth More Than Words](https://medium.com/airbnb-engineering/when-a-picture-is-worth-more-than-words-17718860dcc2)
