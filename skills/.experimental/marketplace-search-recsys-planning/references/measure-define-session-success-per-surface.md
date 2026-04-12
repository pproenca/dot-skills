---
title: Define Session Success per Surface
impact: MEDIUM
impactDescription: enables surface-specific measurement
tags: measure, session, success
---

## Define Session Success per Surface

Each retrieval surface has a different definition of success. For a search surface, success might be "seeker clicked a result and did not reformulate within the session". For a homefeed, success might be "seeker spent more than 30 seconds on a listing or saved it". For item-page-related, success might be "seeker clicked a related listing and the related listing converted". A single success metric applied across surfaces gives the wrong answer for most of them. Define the success metric per surface as the first artefact of the project, alongside the intent mapping.

**Incorrect (one success metric applied across all surfaces):**

```python
def measure_success(sessions: list[Session]) -> float:
    return sum(1 for s in sessions if s.clicked_any_listing) / len(sessions)
```

**Correct (per-surface success definition):**

```python
SUCCESS_METRICS = {
    "homefeed": lambda s: s.spent_more_than(seconds=30) or s.saved_any_listing,
    "search_results": lambda s: s.clicked_any_listing and not s.reformulated_within(seconds=60),
    "item_page_related": lambda s: s.clicked_related_listing and s.related_click_converted,
    "category_landing": lambda s: s.scrolled_to_half_page and s.clicked_any_listing,
}

def measure_success(surface: str, sessions: list[Session]) -> float:
    success_fn = SUCCESS_METRICS[surface]
    return sum(1 for s in sessions if success_fn(s)) / len(sessions)
```

Reference: [Google — Rules of Machine Learning, Rule 2: First, Design and Implement Metrics](https://developers.google.com/machine-learning/guides/rules-of-ml)
