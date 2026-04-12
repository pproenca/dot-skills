---
title: Never Return Zero Results
impact: MEDIUM
impactDescription: prevents dead-end sessions
tags: blend, fallback, sessions
---

## Never Return Zero Results

Zero results is never the right response for a discovery-style surface — it ends the session, wastes the acquisition cost that brought the seeker to the page, and produces no telemetry signal the team can act on. The blending layer's final responsibility is to guarantee a non-empty response: cascade through search → relaxed search → recommender → segment popularity → global popularity → curated fallback, and the only acceptable outcome is that *something* gets returned with a strategy label telling the UI what to show. Zero results should be a monitored incident, not a normal state.

**Incorrect (empty list returned, session ends):**

```python
def final_response(query: ClassifiedQuery, seeker: Seeker) -> SearchResponse:
    hits = opensearch_search(query, seeker)
    return SearchResponse(listings=hits)
```

**Correct (guaranteed non-empty cascade through five fallback strategies):**

```python
def final_response(query: ClassifiedQuery, seeker: Seeker) -> SearchResponse:
    strategies = [
        ("strict_search", lambda: opensearch_search(query, seeker)),
        ("relaxed_search", lambda: opensearch_search(relax(query), seeker)),
        ("recommender", lambda: personalize_recommender(seeker, limit=24)),
        ("segment_popularity", lambda: segment_popularity(seeker.region, seeker.declared_species)),
        ("curated_fallback", lambda: curated_top_by_region(seeker.region)),
    ]
    for strategy_name, strategy_fn in strategies:
        hits = strategy_fn()
        if hits:
            return SearchResponse(listings=hits, strategy=strategy_name)

    raise ShouldNeverHappen("All fallback strategies returned empty — investigate inventory")
```

Reference: [Doug Turnbull & John Berryman — Relevant Search](https://www.manning.com/books/relevant-search)
