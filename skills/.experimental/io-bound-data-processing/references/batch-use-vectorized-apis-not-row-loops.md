---
title: Use Vectorized APIs Instead of Per-Row Python Loops
impact: HIGH
impactDescription: 10-100x speedup
tags: batch, vectorization, numpy, polars, pandas
---

## Use Vectorized APIs Instead of Per-Row Python Loops

Python's interpreter pays ~100 ns of overhead *per operation* — function dispatch, attribute lookup, type checking. A loop over 10 million rows pays a full second of pure interpreter overhead before any work happens. Vectorized APIs (NumPy ufuncs, Polars expressions, Arrow compute kernels) push the loop into C/Rust, processing the whole array in a single dispatch. The same arithmetic that takes 12 s as `for row in df.iterrows(): ...` finishes in 80 ms as `df["a"] * df["b"]` — and the vectorized version uses SIMD on modern CPUs.

**Incorrect (per-row Python loop; interpreter dominates):**

```python
import pandas as pd

# 10M rows × ~1 µs per iteration = 10 s — and that's before the actual work.
result = []
for _, row in df.iterrows():
    result.append(row["price"] * row["quantity"] * (1 - row["discount"]))
df["total"] = result
```

**Correct (vectorized; the loop runs in C):**

```python
# Single operation, dispatched once, SIMD under the hood.
df["total"] = df["price"] * df["quantity"] * (1 - df["discount"])
```

**For row-shaped logic, use vectorized conditionals:**

```python
import numpy as np

# Bad: `df.apply(lambda r: ..., axis=1)` — still per-row Python.
df["bucket"] = df.apply(lambda r: "high" if r["amount"] > 100 else "low", axis=1)

# Good: np.where (or np.select for multiway).
df["bucket"] = np.where(df["amount"] > 100, "high", "low")

# Multiway:
df["tier"] = np.select(
    [df["amount"] > 1000, df["amount"] > 100, df["amount"] > 10],
    ["t1",                "t2",                "t3"],
    default="t4",
)
```

**With Polars — expressions compile to Rust kernels:**

```python
import polars as pl

df = df.with_columns(
    (pl.col("price") * pl.col("quantity") * (1 - pl.col("discount"))).alias("total"),
    pl.when(pl.col("amount") > 100).then(pl.lit("high")).otherwise(pl.lit("low")).alias("bucket"),
)
```

**For groupby aggregations — use built-in aggregators, not Python `apply`:**

```python
# Bad: per-group Python callback.
df.groupby("user_id").apply(lambda g: g["amount"].sum())

# Good: built-in aggregator, runs in C.
df.groupby("user_id")["amount"].sum()
```

**When NOT to vectorize:**
- Logic genuinely depends on the previous row's *computed* result (sequential state machines) — `numpy.frompyfunc` and `numba` are escape hatches; otherwise accept the loop
- The dataset is tiny (< few thousand rows) — vectorization setup cost dominates

Reference: [NumPy — Universal functions](https://numpy.org/doc/stable/user/basics.ufuncs.html), [Polars — Expressions](https://docs.pola.rs/user-guide/concepts/expressions/), [pandas — Enhancing performance](https://pandas.pydata.org/docs/user_guide/enhancingperf.html)
