---
title: Use Engines That Spill Automatically; Don't Hand-Roll Out-of-Core
impact: HIGH
impactDescription: 5-50x faster than hand-rolled; handles spill, parallelism, optimization
tags: spill, duckdb, polars, dask, engine
---

## Use Engines That Spill Automatically; Don't Hand-Roll Out-of-Core

If your job is "scan a huge dataset, filter, group, join, write," the right answer in 2026 is almost never `pandas` plus chunking-by-hand — it's DuckDB, Polars streaming, or (at scale) Spark/Dask. These engines spill to disk automatically when memory pressure rises, parallelize across cores, push predicates and projections into the format readers, and apply query-plan optimizations no hand-rolled pipeline replicates. The same query that takes 200 lines of careful chunking, partitioning, and merging is 5 lines of declarative SQL or expression. Reach for hand-rolling only when no engine fits the workload.

**Incorrect (hand-rolled chunked join — works, but slow and fragile):**

```python
import pandas as pd
from collections import defaultdict

# 100+ lines of: chunk a, chunk b, partition by key, merge per partition, deduplicate keys...
# Brittle to skew; sequential; no automatic spill; no plan optimization.
```

**Correct (DuckDB — declarative, out-of-core, parallel):**

```python
import duckdb

# DuckDB streams Parquet, spills to disk if needed, parallelizes joins across cores.
duckdb.sql("""
    COPY (
      SELECT u.country, SUM(e.amount) AS total
      FROM 'events.parquet'  e
      JOIN 'users.parquet'   u USING (user_id)
      WHERE e.ts >= DATE '2026-05-01'
      GROUP BY u.country
    ) TO 'totals.parquet' (FORMAT 'parquet', COMPRESSION 'zstd')
""")
```

**Polars streaming — same declarative style in Python expressions:**

```python
import polars as pl

(pl.scan_parquet("events.parquet")
   .filter(pl.col("ts") >= pl.date(2026, 5, 1))
   .join(pl.scan_parquet("users.parquet"), on="user_id")
   .group_by("country")
   .agg(pl.col("amount").sum().alias("total"))
   .sink_parquet("totals.parquet", compression="zstd"))
```

**Picking the right engine on a constrained box:**

| Engine | Strength | Use when |
|---|---|---|
| **DuckDB** | Best out-of-core SQL on a single box, columnar exec | Analytical scans/joins on local files |
| **Polars** | Fast Rust dataframe, streaming + lazy | Pythonic dataframe API, ETL |
| **Dask** | Scales to clusters, pandas-compatible | Already-pandas codebase; need horizontal scale |
| **Spark** | Massive scale, mature ecosystem | Cluster available; multi-TB |
| **`sqlite` / `:memory:`** | Always-available, no install | Tiny ad-hoc joins on small files |

**Memory-pressure controls — bound the engine to the budget:**

```python
import duckdb
con = duckdb.connect()
con.sql("SET memory_limit = '4GB'")          # hard cap; spills above this
con.sql("SET threads = 4")
con.sql("SET temp_directory = '/var/tmp/duckdb-spill'")
```

```python
# Polars streaming reads via `collect(streaming=True)` or `sink_*`.
# Polars 1.x doesn't expose a hard memory cap; control by limiting `streaming_chunk_size`.
```

**When hand-rolling is appropriate:**
- Workload doesn't fit any engine's model (e.g., custom stream-state machines)
- You need to interleave with non-relational logic (calling a model, custom binary parse)
- Engine startup cost dominates for very small one-shot jobs

Reference: [DuckDB — Out-of-core](https://duckdb.org/docs/guides/performance/how_to_tune_workloads), [Polars — Streaming](https://docs.pola.rs/user-guide/concepts/streaming/), [Dask — Best Practices](https://docs.dask.org/en/stable/dataframe-best-practices.html)
