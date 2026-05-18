---
title: Push Predicates Into the Reader, Not the Loop
impact: HIGH
impactDescription: 5-100x less I/O when row-group statistics prune
tags: fmt, predicate-pushdown, parquet, column-pruning, row-group
---

## Push Predicates Into the Reader, Not the Loop

Parquet and Arrow store min/max statistics per row group (typically ~128 MB chunks); a filter pushed into the reader skips entire row groups *without reading them*. The pattern `read_parquet(...).filter(x > 100)` reads the whole file, decompresses every row, then drops most of it; `scan_parquet(...).filter(x > 100).collect()` (Polars) or `pq.read_table(..., filters=[("x", ">", 100)])` (PyArrow) reads only the row groups whose max(x) > 100 — often a small fraction of the file. The same applies to column projection: select 3 columns out of 30 and the reader fetches 10 % of the bytes.

**Incorrect (filter after loading; full file read):**

```python
import pandas as pd

# Reads the entire Parquet file, then drops 99 % of rows.
df = pd.read_parquet("events.parquet")
recent = df[df["ts"] >= "2026-05-01"]
```

**Correct (predicate + projection at read time):**

```python
import pyarrow.parquet as pq

# Reader prunes row groups whose max(ts) < cutoff; only required columns are decompressed.
table = pq.read_table(
    "events.parquet",
    columns=["user_id", "ts", "amount"],
    filters=[("ts", ">=", "2026-05-01")],
)
```

**With Polars (lazy plan, predicate pushdown automatic):**

```python
import polars as pl

recent = (pl.scan_parquet("events.parquet")
            .filter(pl.col("ts") >= "2026-05-01")
            .select(["user_id", "amount"])
            .collect(streaming=True))
# Polars pushes both filter and projection into the Parquet reader.
```

**Verification (check that row groups were skipped):**

```python
# Enable PyArrow's stats-based pruning logging:
import pyarrow.dataset as ds
dataset = ds.dataset("events.parquet", format="parquet")
scanner = dataset.scanner(filter=ds.field("ts") >= "2026-05-01", columns=["user_id"])
# scanner.count_rows() will only iterate non-pruned row groups
```

**When pushdown fails silently:**
- Predicate references a column not present in row-group stats (rare types, structs)
- Function in predicate isn't recognized by the reader — `filter(my_python_fn)` is post-read
- Statistics were never written — small files or older writer versions; check with `pq.read_metadata`

**Partitioning amplifies pushdown:**

```python
# Hive-style partitioning: `dt=2026-05-18/region=eu/file.parquet`
# Reader skips entire partition directories before opening any file.
pq.read_table("events/", filters=[("dt", "=", "2026-05-18"), ("region", "=", "eu")])
```

Reference: [Parquet — Predicate pushdown](https://parquet.apache.org/docs/file-format/), [PyArrow — Reading and writing single files](https://arrow.apache.org/docs/python/parquet.html#reading-parquet-files), [Polars — Predicate and projection pushdown](https://docs.pola.rs/user-guide/lazy/optimizations/)
