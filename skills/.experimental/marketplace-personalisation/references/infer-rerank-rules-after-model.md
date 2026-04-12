---
title: Apply Business Rules After Model Scoring, Not Before
impact: MEDIUM-HIGH
impactDescription: preserves model distribution information
tags: infer, business-rules, reranking
---

## Apply Business Rules After Model Scoring, Not Before

Soft business rules (a provider's promotion boost, a fresh-listing bonus, a strategic category uplift) must run after the model has scored the candidates — not before. Applying them before model scoring biases the candidate set and the model loses the ability to learn what users actually prefer. Applying them after preserves the model's relevance signal and lets the business rule act as a transparent, tunable re-ordering layer that product teams can adjust without retraining.

**Incorrect (boosting a category by injecting it into the candidate set):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    feasible = retrieve_feasible(seeker)
    promoted = catalog.filter_by_category("verified_premium")
    candidates = list(set(feasible + promoted))
    ranked = rank_with_personalize(seeker, candidates)
    return ranked[:24]
```

**Correct (soft business rules applied as a post-hoc score adjustment):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    feasible = retrieve_feasible(seeker)
    scored = rank_with_personalize(seeker, feasible)

    for listing in scored:
        if listing.category == "verified_premium":
            listing.score *= 1.15
        if listing.created_at > datetime.utcnow() - timedelta(days=7):
            listing.score *= 1.10

    return sorted(scored, key=lambda listing: -listing.score)[:24]
```

Reference: [DoorDash — Homepage Recommendation with Exploitation and Exploration](https://careersatdoordash.com/blog/homepage-recommendation-with-exploitation-and-exploration/)
