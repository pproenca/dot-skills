---
title: Route Surfaces to Search, Recs, or Hybrid Deliberately
impact: CRITICAL
impactDescription: prevents ad-hoc routing drift
tags: arch, routing, decisions
---

## Route Surfaces to Search, Recs, or Hybrid Deliberately

A surface decision — "homefeed uses recommendations, search results use lexical, item-page related uses SIMS, category landing uses hybrid" — must be recorded in a single source of truth that the team reviews when adding new surfaces. Without that record, each new surface is routed based on whoever builds it, assumptions drift, and six months later nobody can explain why category pages and homepage use different retrieval primitives. The documented record becomes a decision log that carries context across team changes.

**Incorrect (routing scattered across service files, no single source of truth):**

```python
def homefeed_service(seeker): return personalize.recommend(seeker)

def search_service(query, seeker): return opensearch.search(query)

def item_page_related(listing): return redis.get(f"sims:{listing.id}")

def category_page(cat): return db.select_by_cat(cat)
```

**Correct (surface routing table in a single config with rationale and owner):**

```python
SURFACE_ROUTES: dict[str, SurfaceRoute] = {
    "homefeed": SurfaceRoute(
        primitive="recommender",
        owner="personalisation-team",
        reason="Warm seekers benefit from personalised ordering; cold seekers fall back to segmented popularity.",
    ),
    "search_results": SurfaceRoute(
        primitive="lexical_search",
        owner="search-team",
        reason="Transactional queries with hard filters; precision matters more than diversity.",
    ),
    "item_page_related": SurfaceRoute(
        primitive="sims",
        owner="personalisation-team",
        reason="Seed item is the signal; user history is not available on anonymous item pages.",
    ),
    "category_landing": SurfaceRoute(
        primitive="hybrid",
        owner="search-team",
        reason="Category is the retrieval filter; ranking uses popularity plus trust signals.",
    ),
}
```

Reference: [Eugene Yan — Improving Recommendation Systems and Search](https://eugeneyan.com/writing/recsys-llm/)
