---
title: Distinguish Transactional from Exploratory Intent
impact: CRITICAL
impactDescription: prevents conversion loss on transactional sessions
tags: intent, transactional, exploratory
---

## Distinguish Transactional from Exploratory Intent

A transactional session has an unambiguous goal (seeker wants a sitter for specific dates in a specific city) and rewards hard filters, precision and exact availability. An exploratory session is open-ended (seeker is deciding whether to travel) and rewards diverse recall, personalisation and inspiration. Mixing them in one ranker makes transactional sessions drown in irrelevant inspiration and exploratory sessions starve of variety. Route by explicit signal (filter presence, date range specified, keyword specificity) and use different objectives per route.

**Incorrect (one ranking objective for both transactional and exploratory):**

```python
def rank(query: SearchQuery, seeker: Seeker) -> list[Listing]:
    candidates = retrieve(query, seeker)
    return sort_by_personalisation_score(candidates, seeker)[:24]
```

**Correct (route by transactional signals; transactional gets precision, exploratory gets diversity):**

```python
def rank(query: SearchQuery, seeker: Seeker) -> list[Listing]:
    candidates = retrieve(query, seeker)

    has_hard_filters = bool(query.date_range and query.region)
    if has_hard_filters:
        return sort_by_relevance_then_trust(candidates, query)[:24]

    return diversify_then_personalise(candidates, seeker)[:24]
```

Reference: [Eugene Yan — Improving Recommendation Systems and Search](https://eugeneyan.com/writing/recsys-llm/)
