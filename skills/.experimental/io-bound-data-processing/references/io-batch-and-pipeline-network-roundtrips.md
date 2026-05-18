---
title: Batch and Pipeline Network Roundtrips
impact: CRITICAL
impactDescription: 10-1000x throughput; N roundtrips collapse to 1
tags: io, network, batching, pipelining, http2
---

## Batch and Pipeline Network Roundtrips

Every network round-trip has a fixed latency floor — 0.5 ms within a data center, 30–100 ms cross-region, 200+ ms cross-continent — and *most* APIs let you do many things per call. A loop that issues 10,000 single-row `INSERT`s pays 10,000 × RTT in pure waiting; the same data in a single `COPY` or batched `INSERT...VALUES` pays one RTT. The same applies to HTTP (multi-key endpoints, GraphQL, batch APIs), Redis (`MGET`, pipelining), and S3 (`GetObjectRequest` with `Range`, `ListObjects` pagination). When the per-call latency exceeds the per-row work, batching is not an optimization — it is the difference between a job that finishes and one that doesn't.

**Incorrect (one row per RTT):**

```python
import psycopg

with psycopg.connect(DSN) as conn, conn.cursor() as cur:
    for row in rows:                              # 100_000 rows × 1 ms RTT = 100 s
        cur.execute(
            "INSERT INTO events (user_id, ts, payload) VALUES (%s, %s, %s)",
            (row.user_id, row.ts, row.payload),
        )
    conn.commit()
```

**Correct (server-side `COPY` / executemany / pipeline):**

```python
import psycopg

with psycopg.connect(DSN) as conn, conn.cursor() as cur:
    # `COPY` is the fastest bulk-ingest path for Postgres (orders of magnitude vs INSERT).
    with cur.copy("COPY events (user_id, ts, payload) FROM STDIN") as copy:
        for row in rows:
            copy.write_row((row.user_id, row.ts, row.payload))
    conn.commit()
```

**Redis — pipeline instead of N round-trips:**

```python
# Without pipelining: 10_000 round-trips.
# With pipelining: 1 round-trip; ~100x throughput.
with r.pipeline(transaction=False) as pipe:
    for k in keys:
        pipe.get(k)
    values = pipe.execute()
```

**HTTP — batch endpoints / multi-key GETs / HTTP/2 multiplexing:**

```python
# Bad: 1000 sequential GETs, 1000 × RTT.
# Good: one batched endpoint call returns 1000 results.
resp = httpx.post("/api/users/batch", json={"ids": user_ids})

# Or: HTTP/2 multiplexes many requests over one connection (use httpx with http2=True).
async with httpx.AsyncClient(http2=True) as client:
    responses = await asyncio.gather(*(client.get(f"/api/users/{u}") for u in user_ids))
```

**Sizing — batches have an upper limit too:**
- DB INSERTs: 1k–10k rows per batch is typical; beyond this, transaction log pressure
- Redis pipeline: 1k–10k commands per pipeline; beyond this, response buffer growth
- HTTP batches: cap by request size limit and timeout — a 60s batch that times out wastes the whole batch

Reference: [PostgreSQL — COPY](https://www.postgresql.org/docs/current/sql-copy.html), [Redis — Pipelining](https://redis.io/docs/latest/develop/use/pipelining/), [HTTP/2 multiplexing](https://httpwg.org/specs/rfc9113.html#StreamsLayer)
