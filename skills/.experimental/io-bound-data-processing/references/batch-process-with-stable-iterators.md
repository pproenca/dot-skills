---
title: Use Stable Batch Iterators From Format Libraries
impact: HIGH
impactDescription: O(batch) memory; matches reader's natural granularity
tags: batch, iterator, parquet, arrow, polars
---

## Use Stable Batch Iterators From Format Libraries

Almost every modern format library exposes a "give me one batch at a time" API: `pd.read_csv(chunksize=...)`, `pq.ParquetFile(...).iter_batches(...)`, `pl.scan_parquet(...).collect(streaming=True)`, `pyarrow.dataset.scanner().to_batches()`. These iterators batch at the format's natural boundary (CSV chunk, Parquet row group, Arrow record batch), respect predicate pushdown, and keep peak memory at one batch — not the whole file. Building this yourself with manual `seek`s and `read`s is slower, brittle, and often skips compression-aware batching.

**Incorrect (load the whole file, then chunk):**

```python
import pandas as pd

# Defeats the point — peak memory = full file size.
df = pd.read_parquet("events.parquet")
for i in range(0, len(df), 100_000):
    process(df.iloc[i:i+100_000])
```

**Correct (let the reader emit batches):**

```python
import pyarrow.parquet as pq

# Each batch is independent; reader aligns to row groups and pushes filters down.
pf = pq.ParquetFile("events.parquet")
for batch in pf.iter_batches(batch_size=100_000, columns=["user_id", "amount"]):
    process(batch)   # arrow RecordBatch — zero-copy slicing
```

**With Polars streaming:**

```python
import polars as pl

# `collect(streaming=True)` processes in batches, spilling to disk when needed.
result = (pl.scan_parquet("events.parquet")
            .filter(pl.col("status") == 200)
            .group_by("user_id")
            .agg(pl.col("amount").sum())
            .collect(streaming=True))
```

**With Arrow dataset (multi-file, partitioned):**

```python
import pyarrow.dataset as ds

dataset = ds.dataset("events/", format="parquet", partitioning="hive")
for batch in dataset.to_batches(
    columns=["user_id", "amount"],
    filter=ds.field("dt") == "2026-05-18",
    batch_size=200_000,
):
    process(batch)
```

**Pandas `read_csv` chunking — same pattern, different API:**

```python
for chunk in pd.read_csv("events.csv", chunksize=200_000, dtype={"user_id": "int32"}):
    process(chunk)
```

**Tuning batch size:**
- Too small (< 10k rows for tabular): per-batch overhead (dispatch, validation) dominates
- Too large (> few million rows for tabular): peak memory exceeds budget, defeats the purpose
- Default to ~64k–500k rows; align to Parquet row-group size when possible (default 1M)

**When NOT to iterate batches:**
- The whole dataset fits in memory comfortably and you need random access — load once
- The downstream step requires global state (sort, full join) — use a spill-capable engine instead (`spill-use-engines-that-spill-automatically`)

Reference: [PyArrow — ParquetFile.iter_batches](https://arrow.apache.org/docs/python/generated/pyarrow.parquet.ParquetFile.html#pyarrow.parquet.ParquetFile.iter_batches), [Polars — Streaming](https://docs.pola.rs/user-guide/concepts/streaming/)
