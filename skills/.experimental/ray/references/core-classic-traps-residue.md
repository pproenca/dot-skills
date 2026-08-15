---
title: Apply the classic scaling patterns where they hide
tags: core, ray-wait, ray-put, granularity
---

## Apply the classic scaling patterns where they hide

The headline anti-patterns — `ray.get` in a submission loop, re-sending a large argument per task, one task per tiny item — are well-worn; what still goes wrong is their less obvious residue. **Draining:** submit everything first, then process in *completion* order with `ray.wait(pending, num_returns=1)` — getting results in submission order stalls on stragglers even when everything was submitted up front. **Large objects:** `ray.put` once and pass the `ObjectRef`, and notice the two disguised copies — an array captured in the remote function's closure ships with the function definition, and a module-level global is re-materialized per worker process (workers are separate processes, so mutations never propagate; mutable shared state means an actor). **Granularity:** per-task overhead is ~half a millisecond, so tasks should run at least a few milliseconds — batch items, or let Ray Data's `map_batches` do the batching when the workload is a dataset.

```python
weights_ref = ray.put(large_weights)                  # stored once, shared per node

@ray.remote
def score_batch(weights, rows: list[dict]) -> list[float]:
    return [score(weights, row) for row in rows]      # thousands of items per task

pending = [score_batch.remote(weights_ref, b) for b in batches]  # submit all first
while pending:
    done, pending = ray.wait(pending, num_returns=1)  # completion order, bounded in-flight
    handle_result(ray.get(done[0]))
```

Reference: [Ray Core — Design patterns & anti-patterns](https://docs.ray.io/en/latest/ray-core/patterns/index.html) · [Ray Core — Tips for first-time users](https://docs.ray.io/en/latest/ray-core/tips-for-first-time.html)
