---
title: Treat a row count as a query with a cost, not free metadata
tags: query, count, performance, estimates
---

## Treat a row count as a query with a cost, not free metadata

"Showing 1–20 of 4,182,113" costs more than the twenty rows above it. Postgres stores no row count anywhere — MVCC means visibility is per-transaction, so `count(*)` must actually visit rows to decide which ones this transaction can see. On a large table that is a full scan or an index-only scan of millions of entries, run on every page load, to render a number nobody acts on. Drizzle's `db.$count()` is the tidy way to spell it, and it does not make it cheaper. Decide what the number is for: exact counts belong on filtered subsets, and headline totals are better served by an estimate.

```typescript
// Exact — the filter is selective and indexed, so the count is bounded.
const openCount = await db.$count(invoices, and(
  eq(invoices.organizationId, organizationId),
  eq(invoices.status, 'issued'),
))

// Estimate — a whole-table headline figure, from the planner's statistics.
// node-postgres returns a QueryResult, so the rows are under `.rows`.
const result = await db.execute<{ estimate: number }>(sql`
  SELECT reltuples::bigint AS estimate
  FROM pg_class
  WHERE oid = 'invoices'::regclass
`)
const estimate = result.rows[0].estimate
```

The estimate is maintained by `ANALYZE` and autovacuum, so it lags reality by minutes and is wrong right after a bulk load — which is acceptable for "about 4.2 million" and not for a payment reconciliation. For infinite-scroll lists, the cheapest option is no count at all: fetch `limit + 1` rows and use the presence of the extra row as "there is more". The `db.execute()` above has a driver-dependent return shape — see [`query-execute-shape-is-driver-dependent`](query-execute-shape-is-driver-dependent.md).

Reference: [PostgreSQL — Row Estimation Examples](https://www.postgresql.org/docs/current/row-estimation-examples.html) · [Drizzle — `$count`](https://orm.drizzle.team/docs/select#count)
