---
title: Log Every Query with Full Context for Counterfactual Replay
impact: MEDIUM
impactDescription: enables post-hoc query debugging
tags: monitor, logging, replay
---

## Log Every Query with Full Context for Counterfactual Replay

A query log that stores only the raw query string is insufficient for diagnosis — a week later when the team wants to understand why a specific query underperformed, they cannot reproduce the retrieval because they do not know what filters were applied, which ranker ran, what context was in play, or what the result set actually was. A structured log entry per query that captures query, normalised form, classifier output, filters, ranker version, top-K result IDs with scores, and the strategy that was chosen lets any engineer replay the query later and audit the decision path.

**Incorrect (raw query logged as a line of text):**

```python
def search(raw_query: str, seeker: Seeker) -> list[Listing]:
    logger.info(f"search: seeker={seeker.id} query={raw_query}")
    return opensearch_search(normalise_query(raw_query), seeker)
```

**Correct (structured event with every decision point and result captured):**

```python
def search(raw_query: str, seeker: Seeker) -> list[Listing]:
    request_id = str(uuid4())
    classified = classify(raw_query)
    hits = opensearch_search(classified, seeker)
    event = QueryEvent(
        request_id=request_id,
        seeker_id=seeker.id,
        timestamp=datetime.utcnow(),
        raw=raw_query,
        normalised=classified.normalised,
        intent=classified.intent,
        filters=classified.filters,
        ranker_version=current_ranker_version(),
        strategy=hits.strategy,
        top_k=[(h.listing_id, h.score, h.slot) for h in hits.listings[:24]],
    )
    query_log.put(event)
    return hits.listings
```

Reference: [Eugene Yan — System Design for Discovery](https://eugeneyan.com/writing/system-design-for-discovery/)
