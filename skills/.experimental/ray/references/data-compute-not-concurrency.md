---
title: Size map_batches pools with compute, not concurrency
tags: data, map-batches, actor-pool, gpu-inference
---

## Size map_batches pools with compute, not concurrency

This parameter reversed twice, so both eras of training corpus are wrong somewhere: mid-2.x deprecated `compute=ActorPoolStrategy(...)` in favor of `concurrency=`, and the 2.5x line reversed that — in 2.57 `concurrency` is the deprecated one, and `compute=` is current. Use `ray.data.TaskPoolStrategy(size=n)` for stateless functions and `ray.data.ActorPoolStrategy(size=n)` (or `min_size`/`max_size` for an autoscaling pool) for callable classes that hold expensive state like a loaded model; per-worker resources ride the `num_gpus`/`num_cpus` kwargs.

**Incorrect (the 2.9–2.4x idiom — deprecated in 2.57):**

```python
predictions = ds.map_batches(ChurnPredictor, concurrency=4, num_gpus=1)
```

**Correct (2.57 — compute strategy objects):**

```python
import ray.data

predictions = ds.map_batches(
    ChurnPredictor,                                    # callable class: loads model once
    compute=ray.data.ActorPoolStrategy(size=4),
    batch_size=256,
    num_gpus=1,
)
```

Reference: [ray/data/dataset.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/dataset.py)
