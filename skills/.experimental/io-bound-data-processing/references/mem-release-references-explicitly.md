---
title: Release References Explicitly After Use
impact: CRITICAL
impactDescription: prevents reference leaks; up to N×working-set peak
tags: mem, garbage-collection, references, lifetime, leaks
---

## Release References Explicitly After Use

Python's reference-counted GC reclaims memory the *moment* the last reference drops — but only if there *is* a last reference. A loop variable that captures the previous chunk, a DataFrame held alive by a column reference, a closure that pins the surrounding scope: each of these keeps the working set of *every previous iteration* alive, turning O(chunk) peak into O(chunks × chunk). The fix is mechanical and explicit: drop columns when done, `del` the chunk before reading the next, and avoid accidentally capturing large objects in long-lived containers.

**Incorrect (every chunk's intermediate stays alive in `results`):**

```python
results = []
for chunk in pd.read_csv("events.csv", chunksize=200_000):
    df = chunk.merge(dim_table, on="key")        # df pins chunk + dim_table
    summary = df.groupby("country").sum()        # summary pins df
    results.append(summary)
    # df, chunk never go out of scope between iterations → peak = N × chunk
```

**Correct (release intermediates; keep only the small reduction):**

```python
results = []
for chunk in pd.read_csv("events.csv", chunksize=200_000):
    merged = chunk.merge(dim_table, on="key")
    summary = merged.groupby("country").sum().copy()   # `.copy()` detaches from merged
    del merged, chunk                                  # explicit drop before next read
    results.append(summary)                            # only small summaries accumulate

final = pd.concat(results).groupby(level=0).sum()
```

**Watch for column references pinning the parent:**

```python
# A single column reference keeps the whole DataFrame alive.
big = pd.read_parquet("billion-rows.parquet")
col = big["user_id"]    # `col` shares `big`'s blocks; del big won't free it
del big                 # ineffective — `col` still pins the underlying block manager
processed = col.copy()  # break the link explicitly when needed
del col
```

**For NumPy / Arrow buffers — the same rule applies to slices:**

```python
view = huge_array[:1000]   # view pins the entire huge_array buffer
needed = view.copy()       # detach
del view                   # now huge_array can be reclaimed
```

**When NOT to micromanage:**
- Short-lived scripts where peak only happens once and fits — premature `del` is noise
- The data is owned by a streaming engine (Polars, DuckDB) — it manages buffers internally

Reference: [Python — Reference counting](https://docs.python.org/3/c-api/refcounting.html), [pandas — Copy-on-Write](https://pandas.pydata.org/docs/user_guide/copy_on_write.html)
