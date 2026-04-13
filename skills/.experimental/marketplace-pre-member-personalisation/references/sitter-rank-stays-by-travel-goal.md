---
title: Rank Stays by the Sitter's Travel Goal, Not Just Supply Density
impact: HIGH
impactDescription: prevents mismatch between inventory and actual desire
tags: sitter, ranking, goals
---

## Rank Stays by the Sitter's Travel Goal, Not Just Supply Density

A sitter looking for "long stays in Portugal to work remotely" has a fundamentally different success criterion than one looking for "short city breaks in European capitals", and ranking both visitors' preview feeds by global supply density produces the wrong ordering for both. Airbnb's work on traveller intent classification (KDD 2018) shows that stated or inferred travel goals (duration, region cluster, urban-versus-rural, language) are stronger ranking signals than raw popularity. Extract the sitter's goal from the URL path, search referrer, explicit onboarding answer, or inferred cluster, and rank by match quality against that goal.

**Incorrect (global popularity ranking regardless of the sitter's travel goal):**

```python
def sitter_homefeed(visitor: AnonVisitor) -> list[Stay]:
    return stays.query(
        available_after=datetime.utcnow(),
        sort=[("application_volume", "desc")],
        limit=24,
    )
```

**Correct (goal-aware ranking with match-quality scoring):**

```python
def sitter_homefeed(visitor: AnonVisitor) -> list[Stay]:
    goal = visitor.profile.get("travel_goal") or infer_travel_goal(visitor)

    candidates = stays.query(
        available_after=datetime.utcnow(),
        region_in=goal.regions,
        duration_range=goal.duration_range,
        limit=300,
    )

    scored = [
        (stay, match_score(
            stay,
            region_fit=goal.region_weights,
            duration_fit=goal.duration_range,
            urbanicity_fit=goal.urbanicity_preference,
            language_fit=goal.language_preference,
        ))
        for stay in candidates
    ]
    return [stay for stay, _ in sorted(scored, key=lambda x: -x[1])[:24]]
```

Reference: [Real-time Personalization using Embeddings for Search Ranking at Airbnb (KDD 2018)](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
