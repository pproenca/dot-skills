---
title: Encode Pet Requirements as Structured Triples
impact: HIGH
impactDescription: enables per-axis matching that free text cannot
tags: listing, pet, structured, triples, matching
---

## Encode Pet Requirements as Structured Triples

"Two dogs, one cat, one needs medication twice a day" as a free-text description forces every downstream model to re-parse the same sentence with its own errors. Decomposing pet requirements into a list of structured triples — `(species, count, special_needs_tags)` — lets the retrieval layer filter by species exactly, lets the ranker learn per-species acceptance probabilities, and lets the u2i matcher check each sitter's experience vector against each pet's specific needs. The owner still writes free text for flavour; the structured representation is what the system reasons on.

**Incorrect (single free-text pet description):**

```python
def pet_feature(listing: Listing) -> str:
    return listing.pet_description
    # "Two small dogs and a senior cat who needs a pill each morning"
    # downstream models string-match on "senior" and "pill" hoping they catch it
```

**Correct (structured triples + free text alongside):**

```python
@dataclass
class PetRecord:
    species: str            # from PET_SPECIES_VOCAB
    count: int
    size: str               # "xsmall" | "small" | "medium" | "large" | "xlarge"
    age_bucket: str         # "puppy_kitten" | "adult" | "senior"
    special_needs: list[str]  # ["medication", "anxiety", "mobility", "reactive"]

def pet_feature(listing: Listing) -> dict:
    return {
        "pet_records": [asdict(p) for p in listing.pet_records],
        "pet_description_text": listing.pet_description,  # still stored, used for vector embedding
        "total_pets": sum(p.count for p in listing.pet_records),
        "species_set": sorted({p.species for p in listing.pet_records}),
        "has_senior_pet": any(p.age_bucket == "senior" for p in listing.pet_records),
        "has_medicated_pet": any("medication" in p.special_needs for p in listing.pet_records),
    }
```

Reference: [Airbnb — Applying Deep Learning To Airbnb Search](https://arxiv.org/pdf/1810.09591)
