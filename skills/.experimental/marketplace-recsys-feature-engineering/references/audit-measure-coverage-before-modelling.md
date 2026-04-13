---
title: Measure Coverage Before Declaring a Field a Feature
impact: CRITICAL
impactDescription: prevents modelling features that only exist for 10% of items
tags: audit, coverage, nullability, data-quality
---

## Measure Coverage Before Declaring a Field a Feature

A field that is 88% null is not a feature — it is a fallback-handling problem that the model will silently average out, producing a score that is indistinguishable from the popularity baseline for most of the catalog. Before any extraction plan, run a coverage report across every candidate source field and reject anything below the coverage threshold (typically 80%) unless you are explicitly modelling a feature for a cohort and routing the other cohort to a different pipeline.

**Incorrect (assumes `garden_size_sqm` is always populated):**

```python
def build_listing_features(listing: Listing) -> dict:
    return {
        "listing_id": listing.id,
        "region": listing.region_code,
        "garden_size_sqm": listing.garden_size_sqm,  # silently NaN for 88% of listings
        "num_pets": listing.num_pets,
    }
```

**Correct (coverage audit gate before the field enters the feature plan):**

```python
COVERAGE_REPORT = run_coverage_audit(
    table="listings",
    fields=["region_code", "garden_size_sqm", "num_pets", "amenities", "cover_photo_url"],
)
# coverage_report = {"region_code": 0.99, "garden_size_sqm": 0.12, ...}

ELIGIBLE_FIELDS = {f for f, c in COVERAGE_REPORT.items() if c >= 0.80}

def build_listing_features(listing: Listing) -> dict:
    features = {"listing_id": listing.id}
    if "region_code" in ELIGIBLE_FIELDS:
        features["region"] = listing.region_code
    if "num_pets" in ELIGIBLE_FIELDS:
        features["num_pets"] = listing.num_pets
    # garden_size_sqm is excluded from the feature plan until coverage improves
    return features
```

Reference: [Google — Rules of Machine Learning, Rule #22: Clean up features you are no longer using](https://developers.google.com/machine-learning/guides/rules-of-ml)
