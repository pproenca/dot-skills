---
title: Checkpoint Progress for Resumability
impact: MEDIUM-HIGH
impactDescription: prevents full restart on crash; bounds redo work to one checkpoint interval
tags: pipe, checkpoint, idempotency, resumability, fault-tolerance
---

## Checkpoint Progress for Resumability

A long-running data job that crashes 90 % of the way through is a catastrophe if it has to restart from zero — hours of work and I/O lost, and the same crash often repeats. Checkpointing turns this from "all-or-nothing" into "redo at most one interval": after each batch, atomically record (a) what was just processed and (b) what's next to process. On restart, read the checkpoint and resume from there. The mechanism varies — a JSON file with the last offset, a row in a metadata table, a marker file in S3 — but the discipline is universal: never let the only record of progress live in process memory.

**Incorrect (progress only in memory; crash = restart from zero):**

```python
import pyarrow.parquet as pq

writer = pq.ParquetWriter("output.parquet", schema, compression="zstd")
for batch in source.iter_batches():       # 24 hours of work
    transformed = transform(batch)
    writer.write_batch(transformed)
    # crash here → 24h restart, no idea where we were
writer.close()
```

**Correct (atomic checkpoint after each batch; resumable on crash):**

```python
import json, os, tempfile
import pyarrow.parquet as pq

CKPT = "output.checkpoint.json"

def load_checkpoint():
    try:
        return json.load(open(CKPT))
    except FileNotFoundError:
        return {"next_batch": 0, "output_path": "output.parquet"}

def save_checkpoint(state):
    # Atomic write: write to a scratch path, then rename. Rename is atomic on POSIX.
    fd, scratch_path = tempfile.mkstemp(dir=os.path.dirname(CKPT) or ".")
    try:
        with os.fdopen(fd, "w") as f:
            json.dump(state, f)
        os.rename(scratch_path, CKPT)
    except Exception:
        os.unlink(scratch_path)
        raise

state = load_checkpoint()
writer = pq.ParquetWriter(state["output_path"], schema, compression="zstd")
for i, batch in enumerate(source.iter_batches()):
    if i < state["next_batch"]:
        continue                                # skip already-processed
    transformed = transform(batch)
    writer.write_batch(transformed)
    state["next_batch"] = i + 1
    save_checkpoint(state)                      # commit progress
writer.close()
```

**For database sinks — checkpoint is just the source cursor + sink commit:**

```python
# After each batch, COMMIT the inserts AND update a watermark row.
with conn.transaction():
    cur.executemany("INSERT INTO events ...", batch)
    cur.execute("UPDATE etl_state SET last_id = %s WHERE job = 'events'", (last_id,))
# Transaction makes "progress recorded" and "data written" atomic.
```

**For S3 / object outputs — write to a temp key, copy on commit:**

```python
# Each batch lands as an immutable object with the batch index in the key.
key = f"out/batch={i:08d}/part.parquet"
s3.put_object(Bucket=bucket, Key=key, Body=data)
# Checkpoint = "highest committed batch index"; restart skips existing keys.
```

**Checkpoint frequency tradeoff:**
- Too rare: lots of redo work after a crash
- Too frequent: checkpoint I/O dominates throughput
- Aim for redo of ≤ 1–5 minutes of work; for a 1h job, every 30 s is fine

**Make the job idempotent too — partial writes must not corrupt the output:**

```python
# Output files keyed by batch number so a re-run of batch i overwrites cleanly.
# Or use an output schema with a unique key + UPSERT semantics.
```

**When checkpoints are overkill:**
- Job runtime is short (< minutes) and a restart is cheap
- Idempotency is impossible to add — checkpoint without idempotency just creates duplicates

Reference: [Apache Spark — Structured Streaming checkpointing](https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html#recovering-from-failures-with-checkpointing), [Designing Data-Intensive Applications — ch. 11](https://dataintensive.net/)
