---
title: Make Prefix Queries Sargable in Postgres and Redis
impact: MEDIUM-HIGH
impactDescription: prevents full-table scans on proximity queries
tags: idx, postgres, redis, sargable, prefix
---

## Make Prefix Queries Sargable in Postgres and Redis

A geohash index only helps if your query can use it. `LIKE 'gcp%'` is sargable on a B-tree (Postgres uses the index for a left-anchored prefix with `text_pattern_ops`), but `LIKE '%gcp%'` or a function wrapped around the column is not and forces a scan. In Redis, store the integer geohash as a sorted-set score and use `ZRANGEBYSCORE` over each cell range. Match the query to what the index can serve.

**Incorrect (non-sargable predicates defeat the index):**

```typescript
// substring match and a function on the column -> sequential scan
await db.query("SELECT * FROM places WHERE geohash LIKE $1", [`%${region}%`]);
await db.query("SELECT * FROM places WHERE substr(geohash,1,3) = $1", [region]);
```

**Correct (left-anchored range; Redis sorted set):**

```sql
-- Let the B-tree serve LIKE 'region%' as well as range comparisons.
CREATE INDEX places_geohash_idx ON places USING btree (geohash text_pattern_ops);
```

```typescript
// Postgres: half-open range uses the B-tree directly.
await db.query(
  "SELECT * FROM places WHERE geohash >= $1 AND geohash < $2",
  [region, upperBound(region)],
);

// Redis: integer geohash as score; one ZRANGEBYSCORE per cell range.
for (const [lo, hi] of prefixRanges(cells)) {
  await redis.zRangeByScore("places:geo", lo, hi);
}
```

**When NOT to apply:**
- Tiny tables where a sequential scan is already fast do not need the index — but make the predicate sargable anyway so it keeps working as the table grows.

Reference: [Use The Index, Luke](https://use-the-index-luke.com/); [Redis Sorted Sets](https://redis.io/docs/latest/develop/data-types/sorted-sets/)
