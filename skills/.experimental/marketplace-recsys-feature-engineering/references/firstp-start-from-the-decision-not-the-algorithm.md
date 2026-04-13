---
title: Start from the Decision, Not the Algorithm
impact: CRITICAL
impactDescription: eliminates 60-80% of features that add cost without moving the outcome
tags: firstp, decomposition, decisions, outcome-first
---

## Start from the Decision, Not the Algorithm

Most feature engineering failures come from starting with the tools available ("we have CLIP, let's embed photos") instead of the specific decision the recommender is trying to improve ("does this owner trust this sitter enough to request a stay?"). Write the decision as a short sentence, decompose it into the 3-7 sub-judgments a human makes when answering it, and only then pick an extractor. Features that cannot trace back to a sub-judgment are almost certainly noise that will add maintenance cost without moving the primary metric.

**Incorrect (tool-driven — starts from CLIP, ends in a generic embedding):**

```python
# "We have CLIP, let's use it."
def build_listing_features(listing: Listing) -> dict:
    photo = fetch(listing.cover_photo_url)
    return {
        "clip_embedding": clip_model.encode_image(photo).tolist(),
    }
```

**Correct (decision-driven — decomposes "does this owner trust this sitter?" into sub-judgments):**

```python
# Decision: would an owner of a senior dog request this sitter?
# Sub-judgments a human makes:
#   1. Has this sitter cared for senior / medicated dogs? (experience signal)
#   2. Does this sitter's home look calm and safe for a senior dog? (vision signal)
#   3. Are there recent 5-star reviews specifically mentioning medication? (review signal)
#   4. Can this sitter commit to the timing? (availability signal)
#   5. Does the sitter's travel history overlap with this region? (geo signal)

def build_sitter_u2i_features(sitter: Sitter, listing: Listing) -> dict:
    return {
        "senior_dog_experience_count": sitter.stats.senior_dog_stays,
        "home_calmness_score": sitter.vision_features.calmness_score,  # narrow output, not raw embedding
        "medication_mentions_in_reviews": sitter.review_features.medication_mentions,
        "availability_overlaps_listing_dates": sitter.calendar.overlaps(listing.dates),
        "region_overlap_score": geo_overlap(sitter.travel_history, listing.region),
    }
```

Reference: [Google — Rules of Machine Learning, Rule #17: Start with directly observed and reported features as opposed to learned features](https://developers.google.com/machine-learning/guides/rules-of-ml)
