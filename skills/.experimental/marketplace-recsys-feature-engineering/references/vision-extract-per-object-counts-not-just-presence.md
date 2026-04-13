---
title: Extract Per-Object Counts, Not Just Presence
impact: HIGH
impactDescription: prevents conflating a studio with a 6-bedroom villa
tags: vision, object-detection, counts, capacity
---

## Extract Per-Object Counts, Not Just Presence

`has_bed = true` tells the recommender nothing about whether the listing is a studio or a family home. `n_bed = 1` versus `n_bed = 4` tells it directly, and that number is what a sitter or owner actually cares about. Object detectors produce a list of detections with bounding boxes, so the count is free — the only extra cost is storing an integer instead of a boolean. The same logic applies to couches (style signal: formal vs casual), dogs (current pet count), kitchens (multi-unit dwelling). Aggregate by label and store per-class counts.

**Incorrect (boolean presence flags):**

```python
AMENITIES = ["bed", "couch", "tv", "bbq", "oven", "fireplace"]

def extract_amenity_flags(photos: list[bytes]) -> dict[str, bool]:
    flags = {a: False for a in AMENITIES}
    for photo in photos:
        for label, conf in detector.detect(photo):
            if label in flags and conf > 0.6:
                flags[label] = True
    return flags  # "has_bed" is 1 for a studio and 1 for a 6-bed villa
```

**Correct (per-object counts with deduplication across photos):**

```python
AMENITY_LABELS = {"bed", "couch", "tv", "bbq", "oven", "fireplace"}

def extract_amenity_counts(photos: list[bytes]) -> dict[str, int]:
    # union-find or IoU-based dedup across photos of the same room is required
    # to avoid double-counting a bed visible from two angles
    detections_per_photo = [detector.detect(p) for p in photos]
    deduped = dedupe_across_photos(detections_per_photo, iou_threshold=0.6)

    counts: dict[str, int] = defaultdict(int)
    for d in deduped:
        if d.label in AMENITY_LABELS and d.confidence > 0.6:
            counts[f"n_{d.label}"] += 1
    return dict(counts)  # {"n_bed": 4, "n_couch": 2, "n_tv": 1}
```

Reference: [Airbnb — Amenity Detection and Beyond](https://medium.com/airbnb-engineering/amenity-detection-and-beyond-new-frontiers-of-computer-vision-at-airbnb-144a4441b72e)
