---
title: Use Views, Not Copies, for Slices and Masks
impact: CRITICAL
impactDescription: from O(slice) to O(1) memory
tags: mem, views, numpy, arrow, zero-copy
---

## Use Views, Not Copies, for Slices and Masks

NumPy and Arrow give you two operations that look identical and have very different memory costs: a *view* shares the underlying buffer (O(1) memory), a *copy* allocates a new one (O(size) memory). In a tight pipeline that takes 100 slices per chunk, materializing each as a copy turns a 200 MB working set into a 20 GB one. Most slicing in NumPy is a view; most fancy indexing is a copy — the difference is invisible unless you know to look.

**Incorrect (forces a copy at every slice/mask step):**

```python
import numpy as np
arr = np.fromfile("signal.f32", dtype=np.float32)   # e.g. 500 MB

# Each of these is a full copy of the matching subset.
positives = arr[arr > 0]                       # copy (boolean mask materializes)
window    = arr[1000:5000].copy()              # explicit copy
indexed   = arr[np.array([1, 5, 9, 13])]       # fancy index → copy

# In a hot loop, accumulating copies turns one 500 MB buffer into multi-GB working set.
```

**Correct (slice views; only materialize when you must):**

```python
import numpy as np
arr = np.fromfile("signal.f32", dtype=np.float32)   # same source as before

# Views share the underlying buffer; reductions consume them without copying.
window      = arr[1000:5000]                   # view (no copy)
mean_pos    = arr[arr > 0].mean()              # reduction fuses; no persisted copy
strided     = arr[::2]                         # view (every other element)

# When you must persist a subset, do it once at a pipeline boundary, not in a hot loop.
```

**For DataFrames — Polars / Arrow give zero-copy slicing by default:**

```python
import polars as pl
df = pl.read_parquet("events.parquet")
sub = df.slice(0, 1_000_000)         # zero-copy slice
recent = df.filter(pl.col("ts") > cutoff)  # may copy filtered cols but no row-data duplication
```

**When a copy is correct:**
- The view's lifetime would outlive the base array — keeping a 4 KB view alive pins the underlying 4 GB buffer
- You will mutate the slice and the base must not change

Reference: [NumPy — Views vs copies](https://numpy.org/doc/stable/user/basics.copies.html), [Arrow — Memory and IO](https://arrow.apache.org/docs/python/memory.html)
