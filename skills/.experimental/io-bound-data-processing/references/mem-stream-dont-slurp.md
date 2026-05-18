---
title: Stream Files; Don't Read Them All Into Memory
impact: CRITICAL
impactDescription: from O(file size) RAM to O(chunk size) RAM
tags: mem, streaming, generators, iterators, out-of-core
---

## Stream Files; Don't Read Them All Into Memory

A constrained box has a fixed RAM budget — once peak resident set exceeds it, the kernel either thrashes or OOM-kills the process. Reading an entire 10 GB file with `f.read()` or `pd.read_csv()` makes peak memory proportional to the *file size* instead of the *chunk size*. Streaming converts the same job from "needs 16 GB RAM" to "runs anywhere", and the iterator-shaped code composes with every downstream rule in this skill.

**Incorrect (loads everything before processing):**

```python
import pandas as pd

# Loads all 10 GB into memory before .groupby() even sees a row.
df = pd.read_csv("events.csv")
totals = df.groupby("user_id")["amount"].sum()
totals.to_csv("totals.csv")
```

**Correct (streams chunks; peak memory bounded by chunk_size):**

```python
import pandas as pd
from collections import defaultdict

# Each chunk lives only as long as the loop body — peak RAM ~= one chunk.
totals = defaultdict(float)
for chunk in pd.read_csv("events.csv", chunksize=200_000):
    for user_id, amount in chunk.groupby("user_id")["amount"].sum().items():
        totals[user_id] += amount

pd.Series(totals, name="amount").to_csv("totals.csv")
```

**Alternative (lazy/streaming engines do this for you):**

```python
import polars as pl

# Polars `scan_*` builds a query plan; `sink_parquet` runs out-of-core, never materializing the full result.
(pl.scan_csv("events.csv")
   .group_by("user_id")
   .agg(pl.col("amount").sum())
   .sink_parquet("totals.parquet", compression="zstd"))
```

**When NOT to use streaming:**
- The dataset genuinely fits in RAM with margin (rule of thumb: file_size × 5–10 for CSV → DataFrame), and the operation needs random access across the whole set
- One-shot scripts where wall-clock matters more than memory ceiling

Reference: [pandas — Scaling to large datasets](https://pandas.pydata.org/docs/user_guide/scale.html), [Polars — Streaming](https://docs.pola.rs/user-guide/concepts/streaming/)
