---
title: Build the Index Once When Queries Dominate
impact: MEDIUM-HIGH
impactDescription: O(q*n) to O(n + q) — break-even at q ≥ 1 for most index types
tags: search, indexing, amortization, query-vs-insert, batch-lookup
---

## Build the Index Once When Queries Dominate

A hash index, a sorted array, or a trie costs O(n) (or O(n log n)) to build but turns each subsequent lookup from O(n) to O(1) or O(log n). When the data is static during a batch of queries — common in batch jobs, request-scoped caches, and analytics pipelines — build the index once outside the query loop. The amortized cost over q queries is O(n + q) instead of O(q*n). Even a single extra lookup against the same data is often enough to justify the build.

The decision question: how many lookups will this index serve? If it's "one," skip it. If it's "two or more," build it.

**Incorrect (linear scan per query, no shared work):**

```python
def annotate(orders, users):
    enriched = []
    for o in orders:                                # q = len(orders)
        user = next((u for u in users if u.id == o.user_id), None)
        enriched.append((o, user))
    return enriched
# 10,000 orders × 50,000 users = 500,000,000 comparisons
```

**Correct (build once, query many — O(n + q)):**

```python
def annotate(orders, users):
    by_id = {u.id: u for u in users}                # O(|users|) once
    return [(o, by_id.get(o.user_id)) for o in orders]   # O(1) each
# 50,000 + 10,000 = 60,000 ops
```

**Alternative (request-scoped cache — reuse index across requests):**

```python
# Build an index at startup, refresh on data change
USER_INDEX = {}

def reload_users():
    global USER_INDEX
    USER_INDEX = {u.id: u for u in fetch_all_users()}

def get_user(user_id):
    return USER_INDEX.get(user_id)
# Cost of build is amortized over every request the index serves
```

**When NOT to use this pattern:**
- When the index would consume more memory than the working set tolerates — sort-and-bisect uses no extra memory.
- When data changes between every query — the index is stale before it's used. Use a database with maintained indexes instead.

Reference: [Use The Index, Luke — indexing for query speed](https://use-the-index-luke.com/)
