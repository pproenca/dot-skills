---
title: Separate Hard Constraints from Soft Preferences in the Wizard
impact: HIGH
impactDescription: prevents 30-50% of requests ending in owner rejection
tags: wizard, constraints, preferences, filters, ranking
---

## Separate Hard Constraints from Soft Preferences in the Wizard

Asking "willing to sit dogs?" as a yes/no and treating it as a soft ranking feature is a category error — "no" is a hard constraint, not a preference weight. Hard constraints belong in the retrieval layer as filters ("exclude listings with dogs"); soft preferences belong in the ranking layer as continuous features ("prefers coastal regions but willing elsewhere"). The wizard UX should make the distinction explicit: ask separately, store separately, and feed the two different consumers.

**Incorrect (everything is a soft preference scored by the ranker):**

```python
def wizard_question_species() -> dict:
    return {
        "id": "species_preference",
        "type": "multi_select",
        "prompt": "Which species are you interested in?",
        "options": ["dog", "cat", "rabbit", "reptile", "bird"],
    }
# later: ranker scores "dog" listings lower for sitters who did not tick "dog"
# but still shows them — producing requests the owner then rejects
```

**Correct (hard constraints split from soft preferences):**

```python
def wizard_questions_species() -> list[dict]:
    return [
        {
            "id": "species_hard_no",
            "type": "multi_select",
            "prompt": "Are there species you will NOT care for? (deal-breakers)",
            "options": ["dog", "cat", "rabbit", "reptile", "bird", "farm_animal"],
        },
        {
            "id": "species_preference_weight",
            "type": "matrix_1_to_5",
            "prompt": "For the rest, how much do you enjoy them?",
            "rows": ["dog", "cat", "rabbit", "reptile", "bird", "farm_animal"],
            "scale": [1, 2, 3, 4, 5],
        },
    ]

def retrieval_filter(sitter: Sitter) -> Filter:
    return Filter(exclude_species=sitter.wizard.species_hard_no)

def ranking_feature(sitter: Sitter, listing: Listing) -> float:
    weights = sitter.wizard.species_preference_weight  # {"dog": 5, "cat": 3, ...}
    return max(weights.get(s, 3) for s in listing.species_set) / 5.0
```

Reference: [Airbnb — Applying Deep Learning To Airbnb Search](https://arxiv.org/pdf/1810.09591)
