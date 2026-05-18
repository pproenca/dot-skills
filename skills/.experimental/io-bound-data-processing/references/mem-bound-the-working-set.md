---
title: Bound the Working Set to a Measured Memory Budget
impact: CRITICAL
impactDescription: prevents OOM kills; enables predictable scaling
tags: mem, capacity-planning, psutil, chunk-size
---

## Bound the Working Set to a Measured Memory Budget

Every other rule in this category assumes you *know* the budget you're spending against. Most jobs don't — they hardcode "10 GB" or "the laptop has 16 GB" and silently OOM the moment they run inside a 2 GB container. This rule is about discovering the real budget at runtime: total RAM available to the process *now*, the cgroup limit when in a container, the headroom you must leave for OS + other workers, and a way to *verify* peak stayed under budget after the job ran. Per-batch chunk-size math is the companion rule [`batch-pick-chunk-size-by-memory-budget`](batch-pick-chunk-size-by-memory-budget.md); both rules feed the same number, but discovering the budget comes first.

**Incorrect (hardcoded constants, no relation to the actual box):**

```python
CHUNK_SIZE = 100_000   # works on the laptop; OOMs on the 2 GB worker
for chunk in pd.read_csv("events.csv", chunksize=CHUNK_SIZE):
    process(chunk)
```

**Correct (compute the budget from the runtime environment):**

```python
import psutil
import pandas as pd

# 1. Measure free RAM (or use a configured budget; never assume total RAM is yours).
budget_bytes = int(psutil.virtual_memory().available * 0.5)   # leave 50% for everything else

# 2. Sample row width from a tiny prefix (cheap and accurate enough).
sample = pd.read_csv("events.csv", nrows=1_000)
row_bytes = sample.memory_usage(deep=True).sum() / len(sample)
amplification = 6   # CSV → in-memory DataFrame, conservative

# 3. Derive chunk size from budget, not from a hardcoded constant.
chunk_rows = max(10_000, int(budget_bytes / (row_bytes * amplification)))

for chunk in pd.read_csv("events.csv", chunksize=chunk_rows):
    process(chunk)
```

**With explicit budget (containerized / Kubernetes):**

```python
# In a container, prefer the cgroup limit over node RAM.
def container_mem_limit() -> int:
    try:
        return int(open("/sys/fs/cgroup/memory.max").read())
    except (FileNotFoundError, ValueError):
        return psutil.virtual_memory().total
```

**Verification — assert the bound holds:**

```python
import resource
peak_kib = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss   # KiB on Linux, bytes on macOS
assert peak_kib < budget_bytes / 1024, f"working set exceeded budget: {peak_kib} KiB"
```

**When NOT to bother:**
- One-off ad-hoc analysis on a known-small dataset on a known-large laptop
- Inside an engine (Polars streaming, DuckDB, Spark) that manages spill for you — it already does this

Reference: [psutil docs](https://psutil.readthedocs.io/), [Linux — cgroup v2 memory](https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v2.html#memory)
