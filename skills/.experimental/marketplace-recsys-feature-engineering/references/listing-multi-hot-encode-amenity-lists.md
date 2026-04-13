---
title: Encode Amenity Lists as Multi-Hot Vectors, Not Free-Text Strings
impact: HIGH
impactDescription: prevents string-tokenization drift across training and serving
tags: listing, amenities, multi-hot, encoding
---

## Encode Amenity Lists as Multi-Hot Vectors, Not Free-Text Strings

Owners select amenities from a checklist of ~50 options (wifi, fenced garden, washing machine, pet-friendly yard, wheelchair-accessible, etc.) — the checklist is a fixed vocabulary, so the feature should be a multi-hot vector, not a comma-joined string. Multi-hot encoding gives the ranker a feature per amenity it can learn a weight for (sitters with large dogs care about fenced gardens), enables efficient AND/OR retrieval at candidate generation time, and makes amenity-based rules debuggable. A comma-joined string forces the downstream model to re-split the string at every inference and hopes the tokenization is consistent.

**Incorrect (joined string that requires re-tokenization downstream):**

```python
def amenity_feature(listing: Listing) -> str:
    return ",".join(listing.amenities)  # "wifi,fenced_garden,washing_machine,cat_flap"
    # downstream model string-splits and text-hashes at every inference, inconsistent across clients
```

**Correct (fixed-vocabulary multi-hot):**

```python
AMENITY_VOCAB = [
    "wifi", "fenced_garden", "washing_machine", "dryer", "dishwasher",
    "cat_flap", "pet_door", "garage", "driveway", "fireplace",
    "heating_central", "air_conditioning", "wheelchair_accessible",
    # ...complete, versioned vocabulary
]
AMENITY_INDEX = {a: i for i, a in enumerate(AMENITY_VOCAB)}

def amenity_feature(listing: Listing) -> list[int]:
    vector = [0] * len(AMENITY_VOCAB)
    for a in listing.amenities:
        if a in AMENITY_INDEX:
            vector[AMENITY_INDEX[a]] = 1
        # silently-ignored unknowns are a red flag — add an assert if strict
    return vector

# retrieval: candidate = amenities.contains_all(required_amenities)
# ranking: learned weight per position in the vector
```

Reference: [AWS Personalize — Items Dataset Schema Requirements](https://docs.aws.amazon.com/personalize/latest/dg/item-dataset-requirements.html)
