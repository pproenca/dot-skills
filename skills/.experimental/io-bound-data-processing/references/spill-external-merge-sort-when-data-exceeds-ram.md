---
title: Spill to External Merge Sort When Data Exceeds RAM
impact: HIGH
impactDescription: enables O(N) sort on N >> RAM with O(sqrt(N)) memory
tags: spill, external-sort, out-of-core, merge, temp-files
---

## Spill to External Merge Sort When Data Exceeds RAM

Sorting a 100 GB file on an 8 GB box is the canonical out-of-core problem. The standard solution is two phases: (1) read the input in RAM-sized chunks, sort each chunk in memory, write each sorted run to a temp file; (2) k-way-merge all runs with a min-heap. Total I/O is roughly 2× the input, working memory is ~one chunk plus k buffers, and the result is correct for any N — even N >> RAM. You almost never need to write this by hand: GNU `sort` does it on Linux, and SQL engines and `duckdb`/`polars` do it transparently. But understanding the pattern lets you apply it to grouping, joining, and de-duping too.

This rule is the I/O-pragmatic counterpart to the algorithmic primitive in [`computer-science-algorithms/scale-external-merge-sort-for-out-of-memory-data`](../../computer-science-algorithms/references/scale-external-merge-sort-for-out-of-memory-data.md) — that rule explains the algorithm; this one focuses on *when to reach for which tool* on a constrained box.

**Incorrect (in-memory sort blows up on data > RAM):**

```python
# 100 GB of records won't fit in 8 GB RAM.
records = []
with open("events.bin", "rb") as f:
    while r := f.read(RECORD_SIZE):
        records.append(r)
records.sort()                    # MemoryError or OOM kill
```

**Correct (delegate to a tool that spills, when possible):**

```bash
# GNU sort spills to disk automatically; the --buffer-size sets the in-memory run size.
sort --buffer-size=1G --parallel=4 -k1,1 -t, events.csv > sorted.csv
```

```python
# DuckDB sorts out-of-core automatically.
import duckdb
duckdb.sql("""
    COPY (SELECT * FROM 'events.parquet' ORDER BY user_id)
    TO 'sorted.parquet' (FORMAT 'parquet')
""")
```

**When you must implement it (no suitable tool available):**

```python
import heapq, tempfile, pickle, os

def external_sort(records, key, chunk_size=1_000_000):
    runs = []
    while True:
        chunk = list(itertools.islice(records, chunk_size))
        if not chunk:
            break
        chunk.sort(key=key)
        # Write each sorted run to a temp file.
        tmp = tempfile.NamedTemporaryFile(delete=False, mode="wb")
        for r in chunk:
            pickle.dump(r, tmp)
        tmp.close()
        runs.append(tmp.name)

    def read_run(path):
        with open(path, "rb") as f:
            try:
                while True:
                    yield pickle.load(f)
            except EOFError:
                return

    try:
        # heapq.merge does a k-way merge using a heap; constant memory.
        for r in heapq.merge(*(read_run(p) for p in runs), key=key):
            yield r
    finally:
        for p in runs:
            os.unlink(p)
```

**The pattern generalizes:**
- **External groupby** — partition by key into temp files, then process each partition independently
- **External join** — partition both sides on the join key; matching partitions fit in RAM
- **External dedup** — sort, then `uniq`; or partition by hash, dedup within partition

**When NOT to roll your own:**
- DuckDB, Polars streaming, Spark, Dask, GNU coreutils — all handle out-of-core; pick one
- Data fits with margin — in-memory sort is faster and simpler

Reference: [Knuth TAOCP vol. 3 — External sorting](https://www-cs-faculty.stanford.edu/~knuth/taocp.html), [GNU coreutils — sort](https://www.gnu.org/software/coreutils/manual/html_node/sort-invocation.html), [DuckDB — Out-of-core](https://duckdb.org/docs/guides/performance/how_to_tune_workloads)
