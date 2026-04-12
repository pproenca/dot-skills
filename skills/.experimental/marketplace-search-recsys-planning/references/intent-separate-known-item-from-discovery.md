---
title: Separate Known-Item Search from Discovery
impact: CRITICAL
impactDescription: prevents recall loss on known-item queries
tags: intent, known-item, discovery
---

## Separate Known-Item Search from Discovery

Known-item search ("the seeker already has a specific listing in mind and wants to find it") and discovery ("the seeker wants inspiration and would accept any of several good matches") have opposite failure modes: known-item fails on recall (the one right answer is not in the result set), discovery fails on diversity and personalisation. A single retrieval pipeline optimised for one collapses on the other. Identify the two at the routing layer and run separate retrieval strategies.

**Incorrect (single ranked list for both known-item and discovery):**

```python
def search(query: str, seeker: Seeker) -> list[Listing]:
    return opensearch.search(
        index="listings",
        body={
            "query": {"match": {"name": query}},
            "size": 24,
        },
    )["hits"]["hits"]
```

**Correct (known-item gets exact-match first, discovery gets ranked list):**

```python
def search(query: str, seeker: Seeker) -> list[Listing]:
    exact_candidates = opensearch.search(
        index="listings",
        body={
            "query": {"term": {"slug.keyword": normalise(query)}},
            "size": 1,
        },
    )["hits"]["hits"]
    if exact_candidates and looks_like_known_item(query):
        return exact_candidates

    return opensearch.search(
        index="listings",
        body={
            "query": {"multi_match": {"query": query, "fields": ["title^2", "description"]}},
            "size": 24,
        },
    )["hits"]["hits"]
```

Reference: [Doug Turnbull & John Berryman — Relevant Search](https://www.manning.com/books/relevant-search)
