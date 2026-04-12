---
title: Declare a Fallback Owner per Surface at Architecture Time
impact: CRITICAL
impactDescription: prevents fallback gaps on new surfaces
tags: arch, fallback, ownership
---

## Declare a Fallback Owner per Surface at Architecture Time

A zero-result response is a dead-end session, and the only thing worse than serving one is discovering six months later that a surface the team shipped has no fallback strategy at all because nobody was asked to own it. The architectural requirement — not the mechanics — is that every surface in the routing table declares *who owns the fallback*, *what the fallback strategy is*, and *what the target non-empty-rate SLO is*. The mechanics of the cascade belong to the blending rules (see [`blend-never-return-zero-results`](blend-never-return-zero-results.md)); this rule is about making the commitment visible in the routing table so it cannot be forgotten.

**Incorrect (routing table has no fallback column, new surfaces ship without one):**

```python
SURFACE_ROUTES = {
    "homefeed": SurfaceRoute(primitive="recommender", owner="personalisation-team"),
    "search_results": SurfaceRoute(primitive="lexical_search", owner="search-team"),
    "item_page_related": SurfaceRoute(primitive="sims", owner="personalisation-team"),
}
```

**Correct (routing table requires explicit fallback strategy, owner, SLO):**

```python
SURFACE_ROUTES = {
    "homefeed": SurfaceRoute(
        primitive="recommender",
        owner="personalisation-team",
        fallback_strategy="segment_popularity",
        fallback_owner="search-team",
        non_empty_slo=0.999,
    ),
    "search_results": SurfaceRoute(
        primitive="lexical_search",
        owner="search-team",
        fallback_strategy="relaxed_then_recommender_then_curated",
        fallback_owner="search-team",
        non_empty_slo=0.995,
    ),
    "item_page_related": SurfaceRoute(
        primitive="sims",
        owner="personalisation-team",
        fallback_strategy="same_category_popularity",
        fallback_owner="personalisation-team",
        non_empty_slo=0.99,
    ),
}
```

Reference: [Google SRE Book — Embracing Risk](https://sre.google/sre-book/embracing-risk/)
