---
title: Use Dictionary Encoding for Repetitive String Columns
impact: MEDIUM
impactDescription: 5-50x size reduction on low-cardinality columns
tags: codec, dictionary, parquet, arrow, categorical
---

## Use Dictionary Encoding for Repetitive String Columns

A column with 10 million rows but only 200 unique countries is repeating "Portugal" 50k times — at ~50 bytes each, that's 500 MB of redundant string data. Dictionary encoding (the same idea as `pd.Categorical` or Arrow's `DictionaryArray`) stores the 200 unique values once and represents each row as a 1–4 byte index into the dictionary. Effective size: 200 strings + 10M integers ≈ 20–40 MB. Parquet, Arrow, and Polars use dictionary encoding automatically when cardinality is low; the gotcha is keeping the dictionary across batches and across files.

**Incorrect (plain string column — repeated content stored row by row):**

```python
import pyarrow as pa, pyarrow.parquet as pq

# 'country' stored as plain string: ~50B × 10M = 500 MB before compression.
table = pa.Table.from_pydict({
    "user_id": user_ids,
    "country": countries,         # plain string array
})
pq.write_table(table, "events.parquet", compression="zstd",
               use_dictionary=False)          # explicitly disabled
```

**Correct (declare the column as dictionary-encoded):**

```python
import pyarrow as pa, pyarrow.parquet as pq

schema = pa.schema([
    ("user_id", pa.int64()),
    ("country", pa.dictionary(pa.int16(), pa.string())),   # explicit dict type
])

table = pa.Table.from_pydict(
    {"user_id": user_ids, "country": pa.array(countries, type=schema.field("country").type)},
    schema=schema,
)
pq.write_table(table, "events.parquet", compression="zstd")
# Dictionary pages encoded once per row group; column data is small int indices.
```

**With pandas — `category` dtype is the same idea:**

```python
df["country"] = df["country"].astype("category")
# In-memory: 200 string entries + 10M int16 codes ≈ 20 MB instead of 500 MB.
# Persists cleanly to Parquet as dictionary-encoded by default.
```

**With Polars — `Categorical` (per-DataFrame dictionary):**

```python
import polars as pl
df = df.with_columns(pl.col("country").cast(pl.Categorical))
```

**When dictionary encoding wins:**
- Cardinality is much smaller than row count (≪ 0.1 % unique typically)
- Column is repeatedly scanned (the index lookup is free, the dictionary lives in cache)
- Strings are non-trivial in length (saves more than the index size each)

**When dictionary encoding hurts:**
- Cardinality ≈ row count (every value unique) — dictionary is as big as the column, plus index overhead
- The column is written once and never read for analytics — overhead without payoff
- You need fast unique random access — encoded columns require dictionary lookup per cell

**Cross-batch dictionaries — the gotcha:**

```python
# Parquet writes one dictionary per row group; reading concatenates row groups.
# Polars `Categorical.from_global_string_cache()` makes dictionaries consistent across DataFrames.
import polars as pl
with pl.StringCache():
    df_a = df_a.with_columns(pl.col("country").cast(pl.Categorical))
    df_b = df_b.with_columns(pl.col("country").cast(pl.Categorical))
# Now country codes match across df_a and df_b.
```

Reference: [Parquet — Dictionary encoding](https://parquet.apache.org/docs/file-format/data-pages/encodings/), [Arrow — Dictionary type](https://arrow.apache.org/docs/python/data.html#dictionary-encoded-data)
