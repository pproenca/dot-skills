---
title: Dedicate a Random Exploration Slice to New Features
impact: MEDIUM
impactDescription: prevents offline-metric overfitting from blocking good features
tags: prove, exploration, random-slice, offline-online-divergence
---

## Dedicate a Random Exploration Slice to New Features

A new feature that looks weak on the offline golden set can win online — because the offline set is a frozen snapshot of past behaviour and cannot reward a feature that unlocks new matches the system has never made. Reserve 3-5% of traffic as a permanent exploration slice where the current best model is replaced by candidate models that include features whose offline numbers are close-to-tied. The slice produces unbiased training data for the next model version and catches features that offline evaluation would reject.

**Incorrect (features that don't win offline are never tried online):**

```python
# ablation on golden set shows +0.2% NDCG, p = 0.08 → "not worth A/B-ing"
# the feature is shelved forever; online behaviour change is never measured
```

**Correct (exploration slice captures close calls):**

```python
EXPLORATION_SLICE_PCT = 0.04  # 4% of homefeed requests

def route_request(sitter_id: str) -> Model:
    session_hash = hash(f"{sitter_id}:{today()}") % 1000
    if session_hash < EXPLORATION_SLICE_PCT * 1000:
        return pick_exploration_candidate()  # rotates through offline-close-to-tied candidates
    return production_model()

def pick_exploration_candidate() -> Model:
    # currently rotating: model_v14_base, model_v14_with_description_embed, model_v14_with_h3_geo
    candidates = registry.models_tagged("exploration_candidate_active")
    return random.choice(candidates)

# log every exploration impression with candidate_id + outcome;
# each candidate graduates to full A/B when its exploration lift clears the noise floor.
```

Reference: [DoorDash — Homepage recommendation with exploitation and exploration](https://careersatdoordash.com/blog/homepage-recommendation-with-exploitation-and-exploration/)
