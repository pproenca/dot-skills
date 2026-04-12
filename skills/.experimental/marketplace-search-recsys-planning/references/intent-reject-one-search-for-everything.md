---
title: Reject the One-Search-For-Everything Temptation
impact: CRITICAL
impactDescription: prevents system-wide compromise
tags: intent, architecture, boundaries
---

## Reject the One-Search-For-Everything Temptation

The most common architectural mistake in marketplace retrieval is trying to serve every surface from one query shape — one OpenSearch query, one ranker, one candidate set — because it is "simpler". The simplicity is a trap: you end up with a query that is sub-optimal for every surface, hard to tune, impossible to A/B test per surface, and brittle when one surface changes. Accept the cost of having multiple query shapes per surface (homefeed, search, item-page similar, category landing) so each can be tuned against its own metric.

**Incorrect (one query template reused across homefeed, search and category):**

```python
def generic_listings(surface: str, seeker: Seeker, query: str | None) -> list[Listing]:
    body = {
        "query": {"multi_match": {"query": query or "*", "fields": ["title", "description"]}},
        "size": 24,
    }
    return opensearch.search(index="listings", body=body)["hits"]["hits"]
```

**Correct (surface-specific query shapes each tuned for their own metric):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    return opensearch.search(index="listings", body=homefeed_query(seeker))["hits"]["hits"]

def search(query: SearchQuery, seeker: Seeker) -> list[Listing]:
    return opensearch.search(index="listings", body=search_query(query, seeker))["hits"]["hits"]

def category_landing(category: str, seeker: Seeker) -> list[Listing]:
    return opensearch.search(index="listings", body=category_query(category, seeker))["hits"]["hits"]
```

Reference: [Airbnb — Real-time Personalization using Embeddings for Search Ranking](https://www.kdd.org/kdd2018/accepted-papers/view/real-time-personalization-using-embeddings-for-search-ranking-at-airbnb)
