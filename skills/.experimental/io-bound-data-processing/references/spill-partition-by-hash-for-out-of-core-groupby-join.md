---
title: Partition by Hash for Out-of-Core GroupBy and Join
impact: HIGH
impactDescription: enables out-of-core join/aggregate; O(sqrt(N)) working memory
tags: spill, hash-partitioning, join, groupby, out-of-core
---

## Partition by Hash for Out-of-Core GroupBy and Join

Hash partitioning is the trick that makes joins and groupby's work when neither side fits in RAM: split both inputs into P partitions using `hash(key) mod P`, with P large enough that any single partition fits. Now the join/groupby for partition i depends *only* on partition i of each side — process partitions independently, write each result, concatenate. Total memory is O(one partition), total I/O is O(N) per pass, and you can parallelize across partitions trivially. This is what Spark, DuckDB, Polars, and every distributed engine do under the hood; understanding it lets you replicate it on a single small box.

**Incorrect (in-memory hash join — OOM on large inputs):**

```python
# Builds a dict from the smaller side; if smaller side > RAM, this OOMs.
right_index = {r["key"]: r for r in big_table_b}     # might be 50 GB
for row in big_table_a:                              # also 50 GB
    if r := right_index.get(row["key"]):
        process(row, r)
```

**Correct (hash-partition both sides; join per partition):**

```python
import os, tempfile, hashlib

P = 64    # pick so that ~N/P fits in RAM with margin

def partition_to_files(records, key_fn, prefix):
    files = [open(f"{prefix}_{i}", "wb") for i in range(P)]
    try:
        for r in records:
            i = int(hashlib.md5(str(key_fn(r)).encode()).hexdigest(), 16) % P
            pickle.dump(r, files[i])
    finally:
        for f in files:
            f.close()
    return [f"{prefix}_{i}" for i in range(P)]

a_parts = partition_to_files(iter_a(), lambda r: r["key"], "/tmp/a")
b_parts = partition_to_files(iter_b(), lambda r: r["key"], "/tmp/b")

# Now each partition i fits in RAM — do a normal in-memory hash join.
for i in range(P):
    b_index = {}
    with open(b_parts[i], "rb") as bf:
        try:
            while True:
                r = pickle.load(bf)
                b_index[r["key"]] = r
        except EOFError:
            pass
    with open(a_parts[i], "rb") as af:
        try:
            while True:
                row = pickle.load(af)
                if r := b_index.get(row["key"]):
                    emit(row, r)
        except EOFError:
            pass
```

**Same trick for groupby — partition once, then aggregate per partition:**

```python
# Partition rows by hash(group_key). Per-partition aggregation is in-memory.
# Final concat is one pass over all partition outputs.
```

**Picking P:**
- P too small → each partition exceeds RAM → recursion (multi-level partitioning)
- P too large → too many open files (Linux default is 1024 fds; raise with `ulimit -n`)
- Rule of thumb: P ≈ (estimated_input_bytes / available_ram) × 4

**Skew kills hash partitioning — handle hot keys:**

```python
# If one key has 90 % of the rows, that partition still OOMs.
# Detect skew and split hot keys further (salt the key: f"{key}_{random_bucket}").
```

**When NOT to roll your own:**
- DuckDB / Polars / Spark do this automatically and faster — prefer them
- Data is small enough to hash-join in RAM in one shot

Reference: [Designing Data-Intensive Applications — ch. 10](https://dataintensive.net/), [Hash-Partitioned Join Algorithms (Shapiro 1986)](https://dl.acm.org/doi/10.1145/15819.15823)
