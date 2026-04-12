---
title: Use Best-of-Segment Popularity for New Users
impact: HIGH
impactDescription: prevents global-popularity blandness
tags: cold, segmentation, popularity
---

## Use Best-of-Segment Popularity for New Users

A global popularity fallback for a new seeker shows the same top listings to everyone — blandness that erases any chance of finding their niche. Best-of-segment popularity partitions the catalogue by a cheap signal (device locale, referral source, declared region, pet species) and shows the popular items within that segment. It is still heuristic, still cheap, but already personalised at the segment level and closes most of the gap to a fully-trained model for the first few sessions.

**Incorrect (global top-24 — every new seeker sees identical content):**

```python
def new_user_homefeed(seeker: Seeker) -> list[Listing]:
    return catalog.top_by_completed_bookings(window_days=30, limit=24)
```

**Correct (segmentation by declared intent and referral locale):**

```python
def new_user_homefeed(seeker: Seeker) -> list[Listing]:
    segment = (
        seeker.declared_region or seeker.geoip_region,
        seeker.declared_pet_species,
        seeker.referral_source,
    )
    cohort_top = catalog.top_by_completed_bookings_in_segment(
        region=segment[0],
        species=segment[1],
        referral=segment[2],
        window_days=30,
        limit=24,
    )
    if len(cohort_top) < 12:
        cohort_top.extend(catalog.top_by_completed_bookings(window_days=30, limit=24))
    return cohort_top[:24]
```

Reference: [Google — Recommendations: What and Why?](https://developers.google.com/machine-learning/recommendation/overview)
