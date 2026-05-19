---
title: Include a Unique Tiebreaker in Every Sort
impact: HIGH
impactDescription: prevents duplicate/missing items on paginated queries
tags: search, opensearch, sort, tiebreaker, pagination
---

## Include a Unique Tiebreaker in Every Sort

When two documents have the same primary sort value (same score, same date, same price), OpenSearch's sort order between them is *non-deterministic across requests*. This breaks pagination: page 1 returns docs [A, B, C, D], page 2 with `search_after` returns [C, D, E, F] because B's position shifted on the second query. The user sees duplicates and missed items, and infinite scroll feeds become unreliable.

Always append a unique tiebreaker (`_id`, or a unique numeric field) as the last sort criterion. This guarantees a total ordering — every document has a unique position — and makes cursor pagination stable.

**Incorrect (no tiebreaker — non-deterministic for ties):**

```python
body = {
    "query": {"match": {"title": "headphones"}},
    "size": 20,
    "sort": [{"_score": "desc"}],   # ❌ ties in score = random order
}
# Hundreds of products with the same _score → cursor pagination shuffles them
```

**Correct (tiebreaker breaks ties deterministically):**

```python
body = {
    "query": {"match": {"title": "headphones"}},
    "size": 20,
    "sort": [
        {"_score": "desc"},
        {"_id": "asc"},              # ✅ unique tiebreaker
    ],
}
# Total ordering — every document has exactly one position regardless of how many times you query
```

**For non-score sorts, same rule applies:**

```python
# ❌ Many products have the same price; same created_at within a millisecond
"sort": [{"price": "asc"}, {"created_at": "desc"}]

# ✅ Unique tiebreaker last
"sort": [{"price": "asc"}, {"created_at": "desc"}, {"_id": "asc"}]
```

**Why `_id` works as a tiebreaker:**
- It's guaranteed unique per document
- It's available without changing the index mapping
- It sorts deterministically (lexicographically)

**For higher performance, sort by a numeric unique field:**

`_id` is a string sort, which is slightly slower than numeric. If you have a unique numeric field (auto-incrementing PK, snowflake ID), use that:

```python
"sort": [
    {"_score": "desc"},
    {"item_seq": "asc"},  # unique numeric — faster than _id for huge result sets
]
```

**For mixed-direction sorts, the tiebreaker direction matters:**

`search_after` requires the cursor's values to align with the sort direction. A tiebreaker of `_id: asc` means the cursor "after [score, id]" includes documents with the same score but *higher* id. Mixing directions (some `asc`, some `desc`) is fine as long as the cursor reflects them.

**Don't use a non-unique field as the only tiebreaker:**

```python
# ❌ category is non-unique — many products share the same category
"sort": [{"_score": "desc"}, {"category": "asc"}]
# Score-ties within the same category are still non-deterministic
```

**Symptom of missing tiebreaker:**
- Users report "I see the same item on both page 1 and page 2"
- Users report "the item I saw on page 1 isn't in any later page"
- Infinite scroll loses items as the user scrolls
- `search_after` cursors return overlapping or gapping result sets

**For relevance-only sorting on huge result sets:**

If you only need top-K by relevance and K is small (≤100), you can skip the tiebreaker — but only because you won't paginate. As soon as the result set might be paginated, add it.

**Aggregations don't need this:** aggregations operate on the full match set and order their buckets explicitly. The tiebreaker rule is specifically for the `hits` order in search responses.

Reference: [OpenSearch — Sort search results](https://opensearch.org/docs/latest/search-plugins/searching-data/sort/) | [Elastic — Tiebreaker for search_after](https://www.elastic.co/guide/en/elasticsearch/reference/current/paginate-search-results.html#search-after)
