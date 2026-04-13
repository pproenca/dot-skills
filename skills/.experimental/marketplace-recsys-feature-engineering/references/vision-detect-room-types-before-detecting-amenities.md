---
title: Detect Room Type Before Detecting Amenities
impact: HIGH
impactDescription: makes amenity counts per-room, cutting false positives by 50%
tags: vision, room-type, amenity-detection, classification
---

## Detect Room Type Before Detecting Amenities

An amenity detector that runs over all photos without first knowing the room type will happily report "oven in living room" and "couch in kitchen" because the detections are noisy in isolation. Running a room-type classifier first (bedroom, kitchen, living room, bathroom, outdoor, garden) lets you condition the amenity detector's acceptance threshold per room — a detection of an oven in a kitchen is high-confidence, in a living room it is almost certainly an error. Airbnb's vision pipeline follows this pattern: classify the scene, then detect conditionally within it.

**Incorrect (runs amenity detection on every photo without a room prior):**

```python
def detect_amenities(photos: list[bytes]) -> dict[str, int]:
    counts = defaultdict(int)
    for photo in photos:
        for label, conf in detector.detect(photo):
            if conf > 0.5:
                counts[label] += 1  # "oven" detected in a backyard photo → false positive
    return counts
```

**Correct (room type first, then per-room amenity acceptance threshold):**

```python
ROOM_AMENITY_PRIOR = {
    "kitchen": {"oven": 0.4, "fridge": 0.4, "microwave": 0.4, "couch": 0.95},
    "living_room": {"couch": 0.4, "tv": 0.4, "oven": 0.95, "fridge": 0.95},
    "garden": {"bbq": 0.4, "fence": 0.4, "oven": 0.99},
}

def detect_amenities(photos: list[bytes]) -> dict[str, int]:
    counts = defaultdict(int)
    for photo in photos:
        room = room_classifier.predict(photo)  # single-label per photo
        thresholds = ROOM_AMENITY_PRIOR.get(room, {})
        for label, conf in detector.detect(photo):
            min_conf = thresholds.get(label, 0.6)  # default for unknown room
            if conf >= min_conf:
                counts[f"{room}__{label}"] += 1
    return counts
```

Reference: [Airbnb — Amenity Detection and Beyond](https://medium.com/airbnb-engineering/amenity-detection-and-beyond-new-frontiers-of-computer-vision-at-airbnb-144a4441b72e)
