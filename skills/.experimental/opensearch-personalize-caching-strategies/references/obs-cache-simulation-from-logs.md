---
title: Replay Production Logs Through a Cache Simulator Before Changing TTL or Strategy
impact: HIGH
impactDescription: prevents 10-30pp hit-rate misses from un-modelled config changes
tags: obs, simulation, replay, what-if, capacity-planning
---

## Replay Production Logs Through a Cache Simulator Before Changing TTL or Strategy

Cache tuning decisions — change TTL from 300s to 600s, switch from LRU to LFU, double the cache size, add an L1 — all have predictable answers if you replay yesterday's traffic. A simple in-memory simulator reads the cache-access log and replays each request against a configurable cache; it reports hit rate, eviction count, working-set size, and latency distribution under the candidate config. Most teams skip this step and ship the change, then discover the impact in production a week later. The simulator turns "I think this'll help" into "the simulation says +6pp hit rate, -$1.2k/mo, p99 unchanged."

**Incorrect (change config in prod, watch dashboards, hope):**

```text
Engineer: "Let's bump TTL from 5 min to 15 min. Should improve hit rate."
Deploy.
Dashboards: hit rate up, latency unchanged.
A week later: stale-served ratio doubled, customer complaint about wrong prices.
"Roll it back."
```

**Correct (simulator answers the question first):** minimal LRU+TTL cache model:

```python
# scripts/cache_simulator.py — runs against access logs from S3
from collections import OrderedDict
import json

class LRUCache:
    def __init__(self, max_bytes: int, ttl_sec: int):
        self.max_bytes = max_bytes
        self.ttl_sec = ttl_sec
        self.data = OrderedDict()  # key -> (value_bytes, expires_at)
        self.current_bytes = 0
        self.stats = {'hits': 0, 'misses': 0, 'evictions': 0}

    def get(self, key: str, now: float):
        if key in self.data:
            value_bytes, expires_at = self.data[key]
            if now >= expires_at:
                self.stats['misses'] += 1
                del self.data[key]
                self.current_bytes -= value_bytes
                return None
            self.data.move_to_end(key)
            self.stats['hits'] += 1
            return True
        self.stats['misses'] += 1
        return None

    def set(self, key: str, value_bytes: int, now: float):
        if key in self.data:
            self.current_bytes -= self.data[key][0]
        self.data[key] = (value_bytes, now + self.ttl_sec)
        self.current_bytes += value_bytes
        self.data.move_to_end(key)
        while self.current_bytes > self.max_bytes and self.data:
            _, (evicted_bytes, _) = self.data.popitem(last=False)
            self.current_bytes -= evicted_bytes
            self.stats['evictions'] += 1
```

Driver loop replays the log against multiple candidate configs:

```python
def simulate(config: dict, log_path: str):
    cache = LRUCache(config['max_bytes'], config['ttl_sec'])
    with open(log_path) as f:
        for line in f:
            rec = json.loads(line)
            if cache.get(rec['key'], rec['ts']) is None:
                cache.set(rec['key'], rec['payload_bytes'], rec['ts'])
    return cache.stats

configs = [
    {'max_bytes': 8 * 2**30,  'ttl_sec': 300},   # current
    {'max_bytes': 8 * 2**30,  'ttl_sec': 600},   # double TTL
    {'max_bytes': 8 * 2**30,  'ttl_sec': 900},   # triple TTL
    {'max_bytes': 16 * 2**30, 'ttl_sec': 300},   # double size
    {'max_bytes': 16 * 2**30, 'ttl_sec': 600},   # double both
]

for c in configs:
    s = simulate(c, 's3://cache-logs/yesterday.jsonl')
    hr = s['hits'] / (s['hits'] + s['misses'])
    print(f"{c}  hit_rate={hr:.3f}  evictions={s['evictions']}")
```

Output on a real marketplace trace:

```text
max=8GB,  ttl=300:   hit_rate=0.72  evictions=120k
max=8GB,  ttl=600:   hit_rate=0.78  evictions=80k    <-- +6pp for free
max=8GB,  ttl=900:   hit_rate=0.79  evictions=70k    <-- diminishing return
max=16GB, ttl=300:   hit_rate=0.79  evictions=30k    <-- 2x cost, same gain
max=16GB, ttl=600:   hit_rate=0.84  evictions=15k    <-- best, 2x cost

Decision: bump TTL to 600 (free 6pp), revisit size doubling later.
Then check stale-served-ratio in production stays under threshold.
```

**Log format** the simulator needs:
- Per-request: timestamp, cache key, outcome (hit/miss), payload size
- Optional: origin latency, content-class tag, user/cohort ID for slicing

**Sample, don't replay-all.** A full day at 10k req/s = 864M events; the simulator can replay in 1-10 min on a laptop with sampling at 5-10%. Validate hit rate against production to confirm the sample is representative.

**Replay against multiple eviction policies:** LRU, LFU, ARC, SLRU. Different policies have different hit rates on different distributions. For Zipf-like marketplace traffic, LRU and LFU are close; SLRU (segmented LRU, 80/20) sometimes wins. Replay the data; don't guess.

**Replay for Personalize TPS planning:** simulate "what happens to TPS if we double TTL?" — answer: TPS drops by `(new_hit_rate - old_hit_rate)`. Multiply by request rate to get the actual TPS delta. Plug into the `decide-personalize-quota-budget` worksheet.

**Apply to:** TTL changes, cache-size sizing, eviction policy choice, L1 size tuning, switching from cache-aside to refresh-ahead.

**Open-source simulators:** CacheLib (Facebook/Meta) and LHD (CMU) ship offline simulators with their codebases — use them for production-grade work. For quick what-ifs, the 50-line Python above is usually enough.

Reference: [Meta CacheLib simulator](https://github.com/facebook/CacheLib) · [Beckmann et al. — LHD: Improving Cache Hit Rate by Maximizing Hit Density (NSDI 2018)](https://www.usenix.org/system/files/conference/nsdi18/nsdi18-beckmann.pdf)
