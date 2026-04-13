---
title: Declare Categorical Fields for Bounded Vocabularies
impact: HIGH
impactDescription: enables per-value learned features instead of text-bag processing
tags: listing, categorical, schema, vocabulary
---

## Declare Categorical Fields for Bounded Vocabularies

Fields with a small, enumerable vocabulary — region, property type, verification status, pet species, pet size class — should be declared as categorical features, not stuffed into a free-text description column. Categorical declaration lets the downstream model learn an embedding per value and condition ranking on exact values; free text is processed by a single text-bag tower that cannot discriminate between "terraced" and "semi-detached" meaningfully. Enumerate the vocabulary once in the schema, validate on write, and reject out-of-vocabulary values at ingestion so the feature store never sees dirty inputs.

**Incorrect (free text for bounded attributes):**

```python
def build_listing_row(listing: Listing) -> dict:
    return {
        "listing_id": listing.id,
        "description": f"{listing.property_type} in {listing.region_name}, "
                       f"for {listing.pet_species} ({listing.pet_size}). "
                       f"{listing.user_description}",
        # all structure is in free text; model can't easily learn "semi-detached is popular in Leeds"
    }
```

**Correct (structured categoricals with validated vocabularies):**

```python
PROPERTY_TYPE_VOCAB = {"detached", "semi_detached", "terraced", "apartment", "studio", "villa", "cottage"}
PET_SPECIES_VOCAB = {"dog", "cat", "rabbit", "reptile", "bird", "small_mammal", "fish"}
PET_SIZE_VOCAB = {"xsmall", "small", "medium", "large", "xlarge"}

def build_listing_row(listing: Listing) -> dict:
    assert listing.property_type in PROPERTY_TYPE_VOCAB
    assert listing.pet_species in PET_SPECIES_VOCAB
    assert listing.pet_size in PET_SIZE_VOCAB
    return {
        "listing_id": listing.id,
        "region_code": listing.region_code,           # categorical
        "property_type": listing.property_type,       # categorical
        "pet_species": listing.pet_species,           # categorical
        "pet_size": listing.pet_size,                 # categorical
        "description_text": listing.user_description, # free text only for what doesn't fit a vocabulary
    }
```

Reference: [AWS Personalize — Items Dataset Schema Requirements](https://docs.aws.amazon.com/personalize/latest/dg/item-dataset-requirements.html)
