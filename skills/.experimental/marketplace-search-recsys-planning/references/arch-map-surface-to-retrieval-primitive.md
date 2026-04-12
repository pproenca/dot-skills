---
title: Map Each Surface to a Retrieval Primitive Deliberately
impact: CRITICAL
impactDescription: prevents architectural drift across surfaces
tags: arch, mapping, primitives
---

## Map Each Surface to a Retrieval Primitive Deliberately

Every product surface that shows listings — homepage, search results, item-page related, category landing, saved-for-later, notification carousel — needs an explicit mapping to one retrieval primitive: lexical search, recommendations, curated/editorial, or hybrid blend. Without that mapping as a documented artefact, surfaces accrete retrieval code incrementally, each developer picks what they know, and the system grows inconsistent. A one-page surface → primitive table is the single most useful planning artefact in marketplace retrieval work.

**Incorrect (each surface implements whatever the engineer picked that sprint):**

```python
def homefeed(seeker): return opensearch_random(seeker)
def search_results(query, seeker): return opensearch_match(query)
def item_page_related(listing): return cache_get(f"related:{listing.id}")
def category_landing(cat): return db.select_by_category(cat)
```

**Correct (explicit per-surface mapping recorded as configuration):**

```python
SURFACE_PRIMITIVES = {
    "homefeed": Primitive.RECOMMENDER,
    "search_results": Primitive.LEXICAL_SEARCH,
    "item_page_related": Primitive.SIMS,
    "category_landing": Primitive.CURATED_PLUS_RANKING,
    "saved_for_later": Primitive.CURATED,
    "notification_carousel": Primitive.HYBRID,
}

def route(surface: str, seeker: Seeker, query: SearchQuery | None) -> list[Listing]:
    handler = PRIMITIVE_HANDLERS[SURFACE_PRIMITIVES[surface]]
    return handler(seeker=seeker, query=query)
```

Reference: [Eugene Yan — Improving Recommendation Systems and Search](https://eugeneyan.com/writing/recsys-llm/)
