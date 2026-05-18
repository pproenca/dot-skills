---
title: Pick Chunk Size from the Memory Budget, Not a Round Number
impact: HIGH
impactDescription: prevents OOM; 2-5x throughput vs default
tags: batch, chunk-size, memory-budget, throughput
---

## Pick Chunk Size from the Memory Budget, Not a Round Number

Default chunk sizes (1000, 10000, 65536) are arbitrary — they coincidentally work on the developer's laptop and OOM on the constrained worker. The right chunk size derives from three measurements: the memory budget (rule `mem-bound-the-working-set`), the per-row footprint *after* dtype inflation (~5–10× CSV→DataFrame), and the per-call overhead (parsing, transaction, syscall). Too small and you pay overhead on every chunk; too large and you OOM. The sweet spot is "as big as fits in the budget, with margin" — usually 50–500 k rows for tabular data, 1–4 MiB for raw bytes.

**Incorrect (constant chunk size, no relation to box or data):**

```python
for chunk in pd.read_csv("events.csv", chunksize=1000):     # too small: 1000× overhead
    process(chunk)

for chunk in pd.read_csv("events.csv", chunksize=10_000_000):  # too large: OOM
    process(chunk)
```

**Correct (derive chunk size from budget and per-row footprint):**

```python
import pandas as pd, psutil

# 1. Probe per-row footprint cheaply.
probe = pd.read_csv("events.csv", nrows=2_000)
row_bytes = probe.memory_usage(deep=True).sum() / len(probe)

# 2. Take a fraction of available memory, account for amplification + GC headroom.
budget = psutil.virtual_memory().available * 0.4
amplification = 6   # CSV expansion factor

# 3. Cap at sane bounds (avoid microscopic and gigantic extremes).
chunk_rows = int(budget / (row_bytes * amplification))
chunk_rows = max(50_000, min(chunk_rows, 1_000_000))

for chunk in pd.read_csv("events.csv", chunksize=chunk_rows):
    process(chunk)
```

**For byte-streams — align to filesystem block size or larger:**

```python
import os

st = os.statvfs(".")
block_bytes = st.f_bsize                      # usually 4096
chunk_bytes = max(1024 * 1024, block_bytes * 256)   # 1 MiB minimum, multiple of block size

with open(src, "rb") as f, open(dst, "wb") as g:
    while data := f.read(chunk_bytes):
        g.write(data)
```

**Sizing reference (rough starting points):**

| Workload | Chunk size | Reason |
|---|---|---|
| Pandas `read_csv` on 16 GB box | 200k–500k rows | leaves room for the working DataFrame |
| Arrow `iter_batches` | 64k–1M rows | matches Parquet default row group |
| File copy (sequential) | 1–4 MiB | amortizes syscall, fits L2 cache |
| DB `executemany` insert | 1k–10k rows | balances network RTT vs txn log |
| Network HTTP batch | bounded by request limit | server-side limit dictates |

**When NOT to tune:**
- Streaming engines (Polars `collect(streaming=True)`, DuckDB) — they pick chunk sizes from the budget for you
- One-off scripts where memory is abundant — defaults are fine

Reference: [pandas — Scaling chunksize](https://pandas.pydata.org/docs/user_guide/scale.html#load-less-data), [Arrow — Reading Parquet in batches](https://arrow.apache.org/docs/python/parquet.html#reading-parquet-and-memory-mapping)
