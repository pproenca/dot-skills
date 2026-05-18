---
title: Prefer Binary Protocols Over JSON for High-Volume RPC
impact: MEDIUM
impactDescription: 3-10x smaller payloads; 5-20x faster decode
tags: codec, protobuf, msgpack, arrow-flight, rpc, serialization
---

## Prefer Binary Protocols Over JSON for High-Volume RPC

JSON is a debugging format that became a wire format. It's textual (every number becomes a string and back), self-describing (the schema is embedded in every message), and parses one character at a time. For high-volume RPC — internal services, streaming pipelines, batch ingest — a typed binary protocol (Protobuf, MessagePack, Apache Arrow IPC) cuts payload size by 3–10× and decode CPU by 5–20×. Reserve JSON for external/public APIs where ecosystem compatibility matters; use binary for internal hot paths.

**Incorrect (JSON on a hot pipe; decode dominates CPU):**

```python
import json, socket

# Producer: serialize 100k events/s as JSON.
for event in events:
    payload = json.dumps({
        "user_id": event.user_id,
        "ts": event.ts.isoformat(),
        "amount": float(event.amount),
    }).encode()
    sock.send(struct.pack(">I", len(payload)) + payload)

# Consumer pays ~10 µs/event in parsing — bottlenecks at ~100k events/s on one core.
```

**Correct (Protobuf — typed schema, compact binary, fast parser):**

```protobuf
// events.proto
message Event {
  int64    user_id = 1;
  int64    ts_us   = 2;       // microseconds since epoch
  double   amount  = 3;
}
```

```python
from gen import events_pb2

for event in events:
    pb = events_pb2.Event(user_id=event.user_id, ts_us=event.ts_us, amount=event.amount)
    payload = pb.SerializeToString()
    sock.send(struct.pack(">I", len(payload)) + payload)

# Consumer decodes ~10x faster than JSON; payload is 3-5x smaller on this schema.
```

**Apache Arrow IPC for record batches — zero-copy receive:**

```python
import pyarrow as pa, pyarrow.ipc as ipc

# Producer: writes typed RecordBatches over a stream.
schema = pa.schema([("user_id", pa.int64()), ("ts", pa.timestamp("us")), ("amount", pa.float64())])
with ipc.new_stream(sink, schema) as writer:
    for batch in iter_record_batches(events):
        writer.write_batch(batch)

# Consumer reads with zero-copy; batches become Arrow columns directly.
with ipc.open_stream(source) as reader:
    for batch in reader:
        process(batch)
```

**Picking a binary protocol:**

| Protocol | Schema | Speed | Use when |
|---|---|---|---|
| **Protobuf** | required (.proto) | fast | Most RPC; gRPC default; cross-language |
| **MessagePack** | schemaless | very fast | JSON-shaped data, want binary fastpath |
| **Arrow IPC** | required | zero-copy | Record-batch pipelines; analytics RPC |
| **Avro** | required | medium | Schema evolution central (Kafka ecosystem) |
| **CBOR** | optional | fast | IoT / constrained-resource interop |

**When JSON is correct:**
- External-facing public APIs (HTTP, browser consumers)
- Low throughput where developer ergonomics > performance
- One-off scripts / debugging dumps
- Configuration files (yaml/json/toml are equivalent there)

**Hybrid: JSON external, binary internal:**

```python
# External edge converts JSON → Protobuf once; all internal services consume Protobuf.
def http_to_internal(json_payload: bytes) -> bytes:
    j = orjson.loads(json_payload)
    return events_pb2.Event(**j).SerializeToString()
```

Reference: [Protocol Buffers](https://protobuf.dev/), [Apache Arrow IPC](https://arrow.apache.org/docs/format/Columnar.html#ipc-message-format), [MessagePack](https://msgpack.org/)
