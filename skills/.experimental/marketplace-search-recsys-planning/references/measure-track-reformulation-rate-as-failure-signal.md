---
title: Track Reformulation Rate as a Failure Signal
impact: MEDIUM
impactDescription: enables implicit query-failure detection
tags: measure, reformulation, failure
---

## Track Reformulation Rate as a Failure Signal

When a seeker types a query, scrolls through results, and then types a different query within the same session, that is a strong implicit signal the first query failed — the seeker did not find what they wanted and had to try again. The reformulation rate (percentage of sessions with two or more queries within 60 seconds) is a near-universal proxy for search quality that requires no human judgments and no explicit feedback. It is the cheapest search-quality metric a team can add, and a rising reformulation rate is an early warning long before CTR or booking rate move.

**Incorrect (reformulations not tracked; failed queries invisible):**

```python
def log_search_query(seeker_id: str, query: str) -> None:
    query_log.append({"seeker_id": seeker_id, "query": query, "ts": datetime.utcnow()})
```

**Correct (reformulations detected via session-level query grouping):**

```python
def compute_reformulation_rate(window_days: int) -> float:
    sessions = session_store.fetch_with_queries(window_days=window_days)
    reformulated = 0
    for session in sessions:
        queries = sorted(session.queries, key=lambda q: q.timestamp)
        for earlier, later in zip(queries, queries[1:]):
            gap = (later.timestamp - earlier.timestamp).total_seconds()
            if gap < 60 and earlier.normalised != later.normalised:
                reformulated += 1
                break
    return reformulated / len(sessions) if sessions else 0.0
```

Reference: [Doug Turnbull & John Berryman — Relevant Search](https://www.manning.com/books/relevant-search)
