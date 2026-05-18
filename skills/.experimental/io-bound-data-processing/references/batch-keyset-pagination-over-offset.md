---
title: Use Keyset Pagination, Not OFFSET, for Large Cursors
impact: HIGH
impactDescription: O(1) per page vs O(N) for OFFSET
tags: batch, pagination, cursor, database, keyset
---

## Use Keyset Pagination, Not OFFSET, for Large Cursors

`LIMIT N OFFSET M` is a footgun for streaming data out of a database: the engine has to *fetch and discard* M rows before it can return any. Page 1 is fast, page 1000 is slow, page 10000 times out. The fix is keyset (a.k.a. seek-method) pagination: page boundaries are anchored to the indexed key of the last row of the previous page (`WHERE id > $last_id ORDER BY id LIMIT N`), so every page does an index seek + small scan — O(1) regardless of how deep you are.

**Incorrect (OFFSET grows linearly with depth):**

```python
import psycopg

# Page 10000 has to scan 1M rows server-side before returning anything.
def fetch_pages(page_size=10_000):
    offset = 0
    with psycopg.connect(DSN) as conn, conn.cursor() as cur:
        while True:
            cur.execute(
                "SELECT id, user_id, amount FROM events ORDER BY id LIMIT %s OFFSET %s",
                (page_size, offset),
            )
            rows = cur.fetchall()
            if not rows:
                return
            yield rows
            offset += page_size       # cost grows with offset
```

**Correct (keyset — anchor on last seen indexed key):**

```python
def fetch_pages(page_size=10_000):
    last_id = 0
    with psycopg.connect(DSN) as conn, conn.cursor() as cur:
        while True:
            cur.execute(
                "SELECT id, user_id, amount FROM events "
                "WHERE id > %s ORDER BY id LIMIT %s",
                (last_id, page_size),
            )
            rows = cur.fetchall()
            if not rows:
                return
            yield rows
            last_id = rows[-1][0]     # constant cost per page
```

**Multi-column keysets (when ordering on a non-unique column):**

```sql
-- Order by (ts, id) so the seek is unique even when many rows share a timestamp.
SELECT ts, id, user_id
FROM events
WHERE (ts, id) > ($last_ts, $last_id)
ORDER BY ts, id
LIMIT 10000;
```

**Server-side cursors are an alternative (when ORDER BY is fixed):**

```python
# Postgres named cursor — server holds the cursor; client fetches in batches.
with psycopg.connect(DSN) as conn:
    with conn.cursor(name="events_scan") as cur:
        cur.itersize = 10_000
        cur.execute("SELECT id, user_id, amount FROM events ORDER BY id")
        for row in cur:
            process(row)
```

**For S3 / object storage — use the continuation token, not "skip first N":**

```python
# boto3 paginator handles continuation tokens automatically.
paginator = s3.get_paginator("list_objects_v2")
for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
    for obj in page.get("Contents", []):
        process(obj)
```

**When OFFSET is fine:**
- Page count is small and bounded (UI with a few pages)
- The result set is naturally small (< few thousand rows total)

**Warning:**
- Keyset requires a *stable, indexed ordering*. `ORDER BY` on a column without an index makes every page do a full sort — even slower than OFFSET.
- Concurrent inserts can shift OFFSET pagination (the same row appears on two pages or skips); keyset is naturally stable.

Reference: [Markus Winand — Faster Pagination](https://use-the-index-luke.com/no-offset), [PostgreSQL — Cursors](https://www.postgresql.org/docs/current/plpgsql-cursors.html)
