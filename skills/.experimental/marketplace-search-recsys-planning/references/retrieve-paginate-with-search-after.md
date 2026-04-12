---
title: Paginate with search_after for Deep Result Sets
impact: MEDIUM-HIGH
impactDescription: prevents deep-pagination memory cost
tags: retrieve, pagination, search-after
---

## Paginate with search_after for Deep Result Sets

The `from`/`size` pagination pattern loads all documents up to `from + size` on every shard, then discards `from` of them — at page 50 with size 24, each shard loads 1224 documents to return 24. The memory and CPU cost grows linearly with page depth and breaks at the `index.max_result_window` limit (default 10,000). The `search_after` pattern uses the sort values of the last document from the previous page as a continuation cursor, so each page costs the same as the first page regardless of depth.

**Incorrect (deep pagination with from and size, memory cost grows linearly):**

```json
{
  "from": 1200,
  "size": 24,
  "sort": [{ "trust_score": "desc" }, { "listing_id": "asc" }],
  "query": { "match": { "region": "london" } }
}
```

**Correct (search_after continuation cursor, constant cost per page):**

```json
{
  "size": 24,
  "sort": [{ "trust_score": "desc" }, { "listing_id": "asc" }],
  "search_after": [4.82, "listing_91273"],
  "query": { "match": { "region": "london" } }
}
```

Reference: [OpenSearch Documentation — Paginate Search Results](https://docs.opensearch.org/latest/search-plugins/searching-data/paginate/)
