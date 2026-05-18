---
title: Avoid Deeply Nested JSON for Hot Paths
impact: HIGH
impactDescription: 3-30x decode cost; 2-5x size
tags: fmt, json, flat-schema, decoding, hot-path
---

## Avoid Deeply Nested JSON for Hot Paths

Deeply nested JSON pays for every level of structure on every record — opening brace, key string, colon, value, closing brace — and the parser allocates a tree of dicts/lists you have to descend through to reach the leaves. A 200-byte flat record costs ~3 µs to parse; the same data wrapped in five levels of nesting balloons to 1–2 KB and 10–20 µs. On a hot path processing millions of records, that's the difference between a job that runs in minutes and one that runs in hours. Flatten the schema at the producer, or use a typed binary format (Protobuf, Arrow) that doesn't pay per-level overhead.

**Incorrect (deeply nested; high decode cost, no predicate pushdown possible):**

```json
{
  "metadata": {
    "schema_version": "v2",
    "envelope": {
      "producer": {"service": "checkout", "host": "h42"},
      "trace": {"span_id": "abc", "parent": "xyz"}
    }
  },
  "payload": {
    "user": {"id": 1, "profile": {"country": "PT"}},
    "event": {"type": "click", "data": {"amount": 12.5}}
  }
}
```

**Correct (flat record; one parse pass, direct field access):**

```json
{
  "schema_version": "v2",
  "producer_service": "checkout",
  "producer_host": "h42",
  "trace_span_id": "abc",
  "trace_parent_id": "xyz",
  "user_id": 1,
  "user_country": "PT",
  "event_type": "click",
  "amount": 12.5
}
```

**Even better — a typed binary format on hot paths:**

```python
# Protobuf decodes ~10-20x faster than equivalent JSON and is ~3-5x smaller on the wire.
from gen import event_pb2
event = event_pb2.Event()
event.ParseFromString(payload)
process(event.user_id, event.amount)
```

```python
# Arrow IPC: zero-copy decode for record batches on hot pipelines.
import pyarrow.ipc as ipc
with ipc.open_stream(source) as reader:
    for batch in reader:
        # batch.column("user_id") — zero-copy, typed Int64 array
        process_batch(batch)
```

**When deep nesting is appropriate:**
- Schema is genuinely tree-shaped (configuration, document storage) and isn't on a hot path
- You need to preserve a foreign system's exact structure for round-tripping
- Storage size is irrelevant and decode happens once per session

**Migration tip:** at the boundary, flatten nested JSON into typed columns; store the flattened version in Parquet for analytics, keep the original JSON only as raw archive if needed.

Reference: [Protocol Buffers](https://protobuf.dev/), [Arrow IPC](https://arrow.apache.org/docs/format/Columnar.html#ipc-message-format), [orjson — Fast JSON](https://github.com/ijl/orjson)
