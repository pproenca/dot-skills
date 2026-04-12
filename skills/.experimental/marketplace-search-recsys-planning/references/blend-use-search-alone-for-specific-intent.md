---
title: Use Search Alone When Intent Is Specific
impact: MEDIUM
impactDescription: prevents noise on precision-oriented queries
tags: blend, search, precision
---

## Use Search Alone When Intent Is Specific

A seeker who types "sarah the dog sitter chiswick" has an exact target — injecting recommendations into that response shows unrelated listings ranked high by personalisation, which dilutes precision and frustrates the user. For queries with specific entities (named provider, exact location, exact species, specific date range), lexical search alone is the right answer, and the blending layer should recognise this and disable recommendation injection. Intent classification (from the `query-classify-before-routing` rule) provides the signal.

**Incorrect (recommendations always blended into search results):**

```python
def search_response(query: ClassifiedQuery, seeker: Seeker) -> list[Listing]:
    search_hits = opensearch_search(query, seeker)
    rec_hits = personalize_recommender(seeker)
    return interleave(search_hits, rec_hits, rec_ratio=0.3)[:24]
```

**Correct (specific intent bypasses the recommender blend):**

```python
def search_response(query: ClassifiedQuery, seeker: Seeker) -> list[Listing]:
    if query.intent == Intent.NAVIGATIONAL or query.has_named_entity:
        return opensearch_search(query, seeker)[:24]

    search_hits = opensearch_search(query, seeker)
    rec_hits = personalize_recommender(seeker)
    return interleave(search_hits, rec_hits, rec_ratio=0.3)[:24]
```

Reference: [Eugene Yan — Improving Recommendation Systems and Search](https://eugeneyan.com/writing/recsys-llm/)
