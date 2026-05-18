---
title: Use a Columnar Format for Analytical Scans
impact: HIGH
impactDescription: 10-100x less I/O on projection-heavy queries
tags: fmt, parquet, arrow, columnar, analytics
---

## Use a Columnar Format for Analytical Scans

Analytical queries touch a few columns out of many — but row-oriented formats (CSV, JSON-lines, row-Avro) force the reader to scan every byte of every row to find those columns. Parquet, ORC, and Arrow IPC store each column contiguously, so reading 3 of 30 columns reads ~10 % of the bytes; combined with per-column compression and dictionary encoding, the same 100 GB CSV is often 5–15 GB of Parquet that *also* reads 10× faster. CSV remains useful as an interchange format, not a working format.

**Incorrect (CSV for repeated analytical scans):**

```python
import pandas as pd

# 100 GB CSV; every query reads all 100 GB even though only 3 columns are used.
df = pd.read_csv("events.csv", usecols=["user_id", "ts", "amount"])
result = df.groupby("user_id")["amount"].sum()
```

**Correct (convert once to Parquet, then scan only the columns needed):**

```python
import pyarrow as pa
import pyarrow.parquet as pq
import pyarrow.csv as csv

# One-time conversion (typically 5-15x size reduction).
csv_to_parquet = csv.read_csv("events.csv")
pq.write_table(csv_to_parquet, "events.parquet", compression="zstd")

# Every subsequent read touches only the relevant columns.
import polars as pl
result = (pl.scan_parquet("events.parquet")
            .select(["user_id", "amount"])
            .group_by("user_id")
            .agg(pl.col("amount").sum())
            .collect())
```

**Why columnar wins on small boxes:**
- I/O bytes scale with *columns touched*, not row count
- Per-column compression ratios are 3–10× higher than row-level (homogeneous types compress better)
- Dictionary + run-length encoding on low-cardinality columns is near-free decompression
- Row-group statistics let the reader skip entire row groups without decompressing

**When NOT to convert:**
- Single-pass write-once-read-once jobs — conversion cost dominates
- Append-only logs where you'll always read the whole row — JSON-lines is fine
- Tiny datasets (<100 MB) — convenience of CSV beats the format win

Reference: [Apache Parquet — File Format](https://parquet.apache.org/docs/file-format/), [Arrow — Columnar format](https://arrow.apache.org/docs/format/Columnar.html)
