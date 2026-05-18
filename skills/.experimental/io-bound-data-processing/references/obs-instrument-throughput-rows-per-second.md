---
title: Instrument Throughput in Rows-per-Second, Not Just Wall-Clock
impact: LOW-MEDIUM
impactDescription: catches regressions wall-clock hides; enables apples-to-apples comparison
tags: obs, throughput, metrics, profiling, regression
---

## Instrument Throughput in Rows-per-Second, Not Just Wall-Clock

"It took 45 minutes" tells you almost nothing on its own — different input sizes, different file formats, different days mean different baselines. Rate metrics (rows/sec, MB/sec, batches/sec) normalize across runs and inputs: 50k rows/sec last week vs 30k rows/sec this week is a regression that wall-clock would have hidden if the input grew. Log rates at logical milestones (per batch, per partition, per phase), persist them, and compare across runs. The cost is a few lines of timing code; the win is regressions caught the day they appear.

**Incorrect (wall-clock only; comparison impossible across runs):**

```python
import time, pyarrow.parquet as pq

t0 = time.perf_counter()
process_all("events.parquet")
print(f"done in {time.perf_counter() - t0:.1f} s")
# "45 s" doesn't say anything actionable.
```

**Correct (log throughput per batch + at the end):**

```python
import time, logging, pyarrow.parquet as pq

logger = logging.getLogger(__name__)

def process_with_metrics(path):
    pf = pq.ParquetFile(path)
    t_total = time.perf_counter()
    rows_total = 0

    for i, batch in enumerate(pf.iter_batches(batch_size=100_000)):
        t_batch = time.perf_counter()
        process(batch)
        dt = time.perf_counter() - t_batch
        rows = batch.num_rows
        rows_total += rows

        logger.info(
            "batch=%d rows=%d duration_ms=%.1f rate_rps=%.0f",
            i, rows, dt * 1000, rows / dt,
        )

    total_dt = time.perf_counter() - t_total
    logger.info(
        "summary rows=%d duration_s=%.1f avg_rps=%.0f",
        rows_total, total_dt, rows_total / total_dt,
    )
```

**Compute MB/sec too — it normalizes across schemas:**

```python
import sys

bytes_processed = sum(batch.nbytes for batch in batches)   # arrow recordbatch.nbytes
mb_per_s = (bytes_processed / 1e6) / total_dt
logger.info("throughput_mb_s=%.1f", mb_per_s)
```

**Persist for cross-run comparison:**

```python
import json, time

def log_run(metrics):
    metrics["timestamp"] = int(time.time())
    metrics["git_sha"]   = os.environ.get("GIT_SHA", "unknown")
    with open("runs.ndjson", "a") as f:
        f.write(json.dumps(metrics) + "\n")
# Now `jq '.avg_rps' runs.ndjson | awk '{print $1, NR}'` plots the trend over time.
```

**With OpenTelemetry / Prometheus — for long-running services:**

```python
from prometheus_client import Counter, Histogram

ROWS_PROCESSED = Counter("rows_processed_total", "rows processed", ["pipeline"])
BATCH_DURATION = Histogram("batch_duration_seconds", "per-batch duration", ["pipeline"])

with BATCH_DURATION.labels("events").time():
    process(batch)
ROWS_PROCESSED.labels("events").inc(batch.num_rows)
```

**What to log together at minimum:**
- rows/sec and MB/sec for both *input* and *output* (writers can be a hidden bottleneck)
- Per-batch and aggregate; per-batch catches stalls aggregates hide
- Resource utilization (CPU%, RSS, iowait) sampled at the same moments
- Build/commit identifier so changes can be traced back

**When throughput metrics are overkill:**
- One-shot scripts that won't be rerun
- Pipelines where wall-clock is already <1 min — measurement overhead dominates the signal

Reference: [OpenTelemetry — Metrics](https://opentelemetry.io/docs/concepts/signals/metrics/), [USE method on benchmarks](https://www.brendangregg.com/usemethod.html)
