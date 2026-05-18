---
title: Coalesce Writes; Don't Flush One Record at a Time
impact: HIGH
impactDescription: 10-1000x write throughput
tags: batch, writes, buffering, parquet, bulk-insert
---

## Coalesce Writes; Don't Flush One Record at a Time

Writes are syscalls, network round-trips, and transaction-log appends — each one pays a fixed cost that dwarfs the bytes involved. Writing 1 row at a time to Postgres pays ~1 ms per row even on localhost; the same rows in a `COPY` finish in seconds. Writing 1 row at a time to Parquet (re-opening the file each call) destroys the format's compression and row-group layout. The fix is to coalesce: buffer in memory up to a budget, flush as a batch, repeat. The same logic applies to file writers, DB writers, and network writers — the buffer just lives in a different layer.

**Incorrect (one row, one round-trip — write storm):**

```python
import psycopg

with psycopg.connect(DSN) as conn, conn.cursor() as cur:
    for r in rows:                            # 100k rows × ~1 ms RTT = 100 s
        cur.execute(
            "INSERT INTO events VALUES (%s, %s, %s)",
            (r.user_id, r.ts, r.amount),
        )
        conn.commit()                         # commit-per-row destroys throughput
```

**Correct (coalesce into batches; one syscall/RTT per batch):**

```python
BATCH = 5_000
buf = []
with psycopg.connect(DSN) as conn, conn.cursor() as cur:
    def flush():
        if buf:
            cur.executemany(
                "INSERT INTO events VALUES (%s, %s, %s)", buf,
            )
            buf.clear()

    for r in rows:
        buf.append((r.user_id, r.ts, r.amount))
        if len(buf) >= BATCH:
            flush()
    flush()
    conn.commit()                              # one commit at the end
```

**For Parquet — keep one writer open across batches and let it size row groups:**

```python
import pyarrow as pa, pyarrow.parquet as pq

with pq.ParquetWriter("events.parquet", schema, compression="zstd") as writer:
    for batch in iter_record_batches(source):     # arrow RecordBatch
        writer.write_batch(batch)
# Closing finalizes row-group metadata once; never reopen-append for Parquet.
```

**For file output, sized buffers:**

```python
# Bad: tiny writes; one syscall per record.
with open("out.bin", "wb") as f:
    for r in records:
        f.write(r.to_bytes())

# Good: explicit large buffer; Python flushes on close.
with open("out.bin", "wb", buffering=4 * 1024 * 1024) as f:
    for r in records:
        f.write(r.to_bytes())
```

**For high-throughput DB writes, use the bulk path, not the row path:**

| Database | Bulk-load path |
|---|---|
| PostgreSQL | `COPY ... FROM STDIN` (10–100× INSERT) |
| MySQL | `LOAD DATA INFILE` or `INSERT ... VALUES (...), (...)` with multi-row |
| ClickHouse | `INSERT INTO ... FORMAT Native/RowBinary` |
| SQLite | One transaction wrapping many INSERTs, prepared statement |

**When NOT to coalesce:**
- Strict per-record durability required (financial events, audit trails) — accept the throughput hit, but consider WAL-style append-only batching
- Low-throughput streams where latency-to-durability matters more than rows/sec

Reference: [PostgreSQL — COPY](https://www.postgresql.org/docs/current/sql-copy.html), [PyArrow — ParquetWriter](https://arrow.apache.org/docs/python/generated/pyarrow.parquet.ParquetWriter.html)
