---
title: Prefer Schema-on-Write When You Control the Producer
impact: HIGH
impactDescription: 2-10x smaller; 5-50x faster reads; type errors caught at write
tags: fmt, schema, parquet, avro, arrow
---

## Prefer Schema-on-Write When You Control the Producer

Schema-on-read formats (JSON, CSV) defer type decisions to every reader, which means every reader pays to parse strings into types, every consumer re-derives the schema, and a single bad row breaks downstream without warning. Schema-on-write formats (Parquet, Avro, Arrow IPC) record the schema once in the file header, store data in the typed representation, and validate at write time. The size and speed wins compound: typed columns compress 2–10× better, decode is a memcpy instead of a parse, and the schema doubles as documentation.

**Incorrect (schema-on-read JSON; every reader re-derives types):**

```python
# Producer emits NDJSON; types are implicit strings.
with open("events.ndjson", "w") as f:
    for e in events:
        f.write(json.dumps({
            "user_id": str(e.user_id),    # int written as string
            "ts": e.ts.isoformat(),       # datetime written as ISO string
            "amount": str(e.amount),      # decimal written as string
        }) + "\n")

# Each reader reparses: `int(row["user_id"])`, `datetime.fromisoformat(row["ts"])`, etc.
# A typo in one row breaks downstream silently.
```

**Correct (Parquet with declared schema; types preserved end-to-end):**

```python
import pyarrow as pa
import pyarrow.parquet as pq

schema = pa.schema([
    ("user_id", pa.int64()),
    ("ts",      pa.timestamp("us", tz="UTC")),
    ("amount",  pa.decimal128(18, 4)),
    ("country", pa.dictionary(pa.int16(), pa.string())),   # dictionary-encoded
])

table = pa.Table.from_pylist(events, schema=schema)
pq.write_table(table, "events.parquet", compression="zstd")

# Reader gets typed columns directly — no parsing, no type errors at read time.
table = pq.read_table("events.parquet")    # arrow types, zero string→int conversions
```

**With Polars / Arrow IPC for hot intra-job paths:**

```python
import polars as pl

# Arrow IPC: schema-on-write, zero-copy with mmap, ideal for intermediate files.
df.write_ipc("intermediate.arrow")
again = pl.read_ipc("intermediate.arrow", memory_map=True)
```

**When schema-on-read is justified:**
- The schema is genuinely unknown (raw logs from many heterogeneous sources)
- Interchange with systems that only speak JSON/CSV — convert at the boundary, work in typed formats internally
- Exploratory analysis on one-off data — convenience wins

Reference: [Apache Parquet — Logical types](https://github.com/apache/parquet-format/blob/master/LogicalTypes.md), [Apache Avro — Schemas](https://avro.apache.org/docs/current/specification/), [Designing Data-Intensive Applications — ch. 4](https://dataintensive.net/)
