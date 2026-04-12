---
title: Map Queries to Intent Classes Before Touching Retrieval
impact: CRITICAL
impactDescription: prevents retrieval-strategy mismatch with user goal
tags: intent, classification, discovery
---

## Map Queries to Intent Classes Before Touching Retrieval

User intent drives retrieval strategy: a navigational query ("sarah-the-sitter") wants an exact hit at rank 1, an informational query ("sitter with dog experience") wants a diverse ranked list, and an exploratory query ("london dog sitters for the holidays") wants personalisation and cold-start fallbacks. Applying one retrieval strategy to all three produces a system that is wrong for every query type in a different way. Classify queries first, then route to the right retrieval strategy.

**Incorrect (one query handler for all intent classes):**

```python
def search(query: str, seeker: Seeker) -> list[Listing]:
    return opensearch.search(
        index="listings",
        body={
            "query": {"multi_match": {"query": query, "fields": ["title", "description"]}},
            "size": 24,
        },
    )["hits"]["hits"]
```

**Correct (intent classifier routes to a specific strategy per class):**

```python
def search(query: str, seeker: Seeker) -> list[Listing]:
    intent = classify_intent(query, seeker)
    if intent == Intent.NAVIGATIONAL:
        return exact_match_top_1(query)
    if intent == Intent.TRANSACTIONAL:
        return filtered_ranked(query, seeker, filters=seeker.hard_filters)
    if intent == Intent.EXPLORATORY:
        return hybrid_bm25_knn_with_personalisation(query, seeker)
    return default_blended(query, seeker)
```

Reference: [OpenSource Connections — What Is a Relevant Search Result?](https://opensourceconnections.com/blog/2019/12/11/what-is-a-relevant-search-result/)
