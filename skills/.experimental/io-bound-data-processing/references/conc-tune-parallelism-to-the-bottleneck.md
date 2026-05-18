---
title: Tune Parallelism to the Bottleneck Resource
impact: MEDIUM
impactDescription: prevents wasted parallelism; 2-10x latency improvement when tuned
tags: conc, parallelism, bottleneck, tuning, throughput
---

## Tune Parallelism to the Bottleneck Resource

More workers is not always faster. Once you reach the bottleneck — disk throughput, network bandwidth, DB connection limit, target service capacity — adding workers just makes each one slower (more queueing, contention, and timeouts) without raising aggregate throughput. The right concurrency level is bounded by the *bottleneck resource*, not by `os.cpu_count()`. Measure: start with one worker, double until throughput stops climbing; that knee is the right setting. Going past it costs latency, memory (each worker has buffers and state), and often correctness (rate limits, deadlocks).

**Incorrect (parallelism set to a default, ignored thereafter):**

```python
from concurrent.futures import ThreadPoolExecutor

# 100 workers all hitting a DB with a 20-connection pool:
# 80 wait for connections, 20 work; same throughput as 20 workers, more memory, more contention.
with ThreadPoolExecutor(max_workers=100) as pool:
    results = list(pool.map(run_query, queries))
```

**Correct (cap by the actual bottleneck — here, the DB pool):**

```python
from concurrent.futures import ThreadPoolExecutor

DB_POOL = 20    # actual configured pool size on the DB

# Match worker count to the binding resource.
with ThreadPoolExecutor(max_workers=DB_POOL) as pool:
    results = list(pool.map(run_query, queries))
```

**A tuning method that works (binary search on the knee):**

```python
import time, statistics

def throughput(n_workers, items, work_fn):
    with ThreadPoolExecutor(max_workers=n_workers) as pool:
        t0 = time.perf_counter()
        list(pool.map(work_fn, items))
        return len(items) / (time.perf_counter() - t0)

for n in [1, 2, 4, 8, 16, 32, 64, 128]:
    t = throughput(n, sample_items, work_fn)
    print(f"workers={n:4d}  items/sec={t:8.1f}")
# Pick the smallest n where the next doubling gives <10% improvement.
```

**Common bottlenecks and their limits:**

| Bottleneck | Approximate cap | How to find it |
|---|---|---|
| **Disk throughput** | ~500 MB/s NVMe, ~100 MB/s HDD | `dd`, `fio`, `iostat -x 1` (watch %util → 100%) |
| **Network bandwidth** | NIC line rate | `iperf3`, `ifstat` |
| **DB connection pool** | configured pool size | `SHOW max_connections` (Postgres), pool config |
| **Remote API rate limit** | provider quota | 429 responses, Retry-After headers |
| **GIL (Python CPU)** | 1 core for pure Python | switch to processes or release GIL via C ext |
| **CPU cores** | physical cores (or 1.5× for SMT) | `os.cpu_count()`, `nproc` |

**Combining bottlenecks — pick the *minimum* limit:**

```python
# Workload: fetch from API (rate-limited 100 req/s) and write to DB (pool 20).
# Right answer: min(100 inflight, 20 DB conns) = 20.
# More than 20 will queue at the DB; more than 100 will 429 at the API.
workers = min(API_RATE_LIMIT, DB_POOL_SIZE)
```

**Signs you're past the knee:**
- Throughput flat or decreasing as workers increase
- Latency P99 climbs disproportionately to P50
- Errors increase (timeouts, rate limits, deadlocks)
- CPU utilization stays low (you're stuck waiting on the bottleneck)

**When to revisit:**
- Workload mix changes (one DB swap can move the bottleneck)
- Underlying capacity changes (faster disk, bigger pool, more cores)
- "It used to be fast" — assume bottleneck moved; re-measure

Reference: [Brendan Gregg — USE method](https://www.brendangregg.com/usemethod.html), [Little's Law](https://en.wikipedia.org/wiki/Little%27s_law)
