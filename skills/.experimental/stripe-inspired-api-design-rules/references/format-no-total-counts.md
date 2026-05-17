---
title: Use `has_more` Boolean; Never Return Total Counts
impact: HIGH
impactDescription: prevents slow full-table scans on every paginated request
tags: format, pagination, performance, counts
---

## Use `has_more` Boolean; Never Return Total Counts

The list envelope returns `has_more: boolean` and nothing else about size. There is no `total_count`, no `total_pages`, no `page_count`. Total counts on a paginated list endpoint are operationally expensive (every paginated request triggers a `COUNT(*)` or scan on a huge table) and **semantically meaningless on a changing dataset** — by the time the count is reported, items may have been added or removed.

If integrators truly need an approximate count, expose it as a separate, explicitly-approximate endpoint that can be cached aggressively (`GET /v1/customers/count` returning `{ approximate_count: 142000, as_of: 1747699200 }`). Don't let count-aggregation cost ride on every page request.

**Incorrect (totals on every page response):**

```json
{
  "object": "list",
  "data": [ ... ],
  "total_count": 142387,
  "total_pages": 14239,
  "current_page": 73
}
```

```text
// Every page request triggers a COUNT(*) on a 142k-row table.
// Counts go stale immediately — by the time the response renders, the number is wrong.
// SQL plans for COUNT(*) often dominate the request cost for large tables.
```

**Correct (boolean only — `has_more`):**

```json
{
  "object": "list",
  "url": "/v1/customers",
  "has_more": true,
  "data": [ ... ]
}
```

```text
// `has_more` is cheap: SELECT (limit+1), check if extra row exists.
// No expensive aggregation. No stale numbers. No false confidence.
```

**How `has_more` is implemented cheaply:**
- Fetch `limit + 1` rows from the index
- If you got `limit + 1`, drop the last one and set `has_more: true`
- Otherwise return what you have and set `has_more: false`

This is O(limit) regardless of total table size, whereas `COUNT(*)` is O(n).

**When integrators really need a count:** ship a dedicated endpoint and document its semantics explicitly:

```text
GET /v1/customers/count
{
  "approximate_count": 142000,
  "as_of": 1747699200
}
```

- Mark it `approximate_` so consumers don't treat it as authoritative
- Cache the value (refresh hourly, not on every request)
- Document that "for exact counts, iterate the list endpoint"

**Don't ship totals "for the UI to render a page picker."** UI page pickers are themselves an anti-pattern with cursor pagination — there's no Nth page when the dataset is changing. Show "Load more" or infinite scroll instead.

Reference: [Stripe pagination](https://docs.stripe.com/api/pagination)
