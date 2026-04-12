---
title: Avoid Mono-Stack Retrieval
impact: CRITICAL
impactDescription: prevents single-point-of-failure in retrieval
tags: arch, redundancy, resilience
---

## Avoid Mono-Stack Retrieval

Putting every surface behind a single OpenSearch cluster with a single query template creates a brittle system: one cluster outage, one schema migration error, one noisy-neighbour shard and the entire marketplace goes blank. Diversifying retrieval — lexical search on OpenSearch, a recommender on AWS Personalize, a curated content store for editorial, a simple popularity fallback — means no single dependency can take down the whole experience. The cost is operational complexity; the benefit is a system that degrades gracefully instead of failing catastrophically.

**Incorrect (all surfaces behind the same OpenSearch cluster with no fallback):**

```python
def unified_retrieval(surface: str, seeker: Seeker, query: SearchQuery | None) -> list[Listing]:
    body = build_body_for(surface, seeker, query)
    response = opensearch.search(index="listings", body=body)
    return hydrate(response["hits"]["hits"])
```

**Correct (each surface has a primary plus a degraded-mode fallback):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    try:
        return personalize_recommender(seeker, limit=24)
    except PersonalizeUnavailable:
        logger.warning("personalize_down, falling back to opensearch popularity")
        return opensearch_popularity_by_region(seeker.region, limit=24)

def search_results(query: SearchQuery, seeker: Seeker) -> list[Listing]:
    try:
        return opensearch_search(query, seeker)
    except OpenSearchUnavailable:
        logger.warning("opensearch_down, falling back to curated")
        return curated_top_by_region(query.region, limit=24)
```

Reference: [Google SRE Book — Embracing Risk](https://sre.google/sre-book/embracing-risk/)
