---
title: Use Line-Delimited Formats for Streaming Row Ingest
impact: HIGH
impactDescription: O(1) memory per record vs O(file) for arrayed JSON
tags: fmt, ndjson, json-lines, csv, streaming
---

## Use Line-Delimited Formats for Streaming Row Ingest

For append-only logs and row-at-a-time ingest, the format question is "can I parse one record without seeing the rest of the file?" Line-delimited formats (NDJSON / JSONL, CSV, line-delimited Avro) answer yes — split on newline, parse the record, emit, repeat. A single JSON array (`[{...}, {...}, ...]`) wrapping the same data forces the parser to load the whole file before yielding the first record, blowing up memory and breaking streaming pipelines that expect to process records as they arrive.

**Incorrect (single JSON array; not streamable):**

```python
import json

# Forces the entire file into memory before any record is processed.
with open("events.json") as f:
    events = json.load(f)        # whole array materialized
for event in events:
    process(event)
```

**Correct (NDJSON / JSONL — one record per line, fully streamable):**

```python
import json

with open("events.ndjson") as f:
    for line in f:
        event = json.loads(line)   # one record's worth of memory
        process(event)
```

**Writing NDJSON safely (always include the trailing newline):**

```python
with open("events.ndjson", "w") as f:
    for event in events:
        f.write(json.dumps(event, separators=(",", ":")))
        f.write("\n")              # critical — the line is the record boundary
```

**Faster parsing with `orjson` or Arrow:**

```python
import orjson                       # 2-5x faster than stdlib json

with open("events.ndjson", "rb") as f:
    for line in f:
        event = orjson.loads(line)
```

```python
# Arrow's NDJSON reader gives you a typed table with vectorized parsing.
import pyarrow.json as pj
table = pj.read_json("events.ndjson")   # batches under the hood
```

**When NOT to use line-delimited:**
- Records contain embedded newlines (multi-line JSON values) — switch to CSV with quoting, or to length-prefixed framing
- High-throughput binary pipelines — Arrow IPC or length-prefixed Protobuf beat any text format
- Records are tiny and very numerous — fixed-width binary records read faster

Reference: [JSONLines spec](https://jsonlines.org/), [Apache Arrow — JSON reader](https://arrow.apache.org/docs/python/json.html)
