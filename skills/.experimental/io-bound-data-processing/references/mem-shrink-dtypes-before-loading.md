---
title: Shrink Dtypes at Load Time
impact: CRITICAL
impactDescription: 2-8x memory reduction
tags: mem, dtypes, categorical, numpy, pandas
---

## Shrink Dtypes at Load Time

Pandas defaults to `int64`, `float64`, and Python-object strings — frequently 8× larger than the data needs to be. Loading a 10-million-row table with three int columns and one short-string column takes ~3 GB at defaults and ~400 MB with narrow ints + categorical strings, *for identical data*. Specifying dtypes at `read_csv` time avoids the wasted intermediate, since a wrong dtype can't be fixed retroactively without a full copy.

**Incorrect (8-byte ints, object strings, full duplication on conversion):**

```python
df = pd.read_csv("events.csv")
# Inferred: user_id int64, event_count int64, country object (Python str)
# 10M rows × 8B × 2 ints + 10M × ~50B (object) ≈ 660 MB just for these 3 cols.
```

**Correct (narrow ints, categorical for low-cardinality strings):**

```python
df = pd.read_csv(
    "events.csv",
    dtype={
        "user_id":     "int32",       # 0-2.1B users → fits in 32-bit
        "event_count": "int16",       # bounded by app logic, 0-32k
        "country":     "category",    # 250 codes × 50B + 10M × 2B ≈ 20 MB
    },
)
# Same data, ~90 MB instead of ~660 MB — 7x reduction.
```

**With Polars / Arrow (typed by default):**

```python
import polars as pl

# Polars infers narrower types and uses Arrow strings (4-byte offsets, no Python objects).
df = pl.read_csv("events.csv", schema_overrides={"user_id": pl.Int32})
```

**Verification (measure before and after):**

```python
df.memory_usage(deep=True).sum() / 1e6   # MB — `deep=True` counts object string content
```

**When NOT to shrink:**
- Values may exceed the narrow range — silent overflow on `int16` is worse than the memory win
- Repeated narrowing/widening in a pipeline — pick the type once at the boundary

Reference: [pandas — Categorical](https://pandas.pydata.org/docs/user_guide/categorical.html), [pandas — read_csv dtype](https://pandas.pydata.org/docs/reference/api/pandas.read_csv.html)
