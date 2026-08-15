---
title: Import Train configs from ray.train and scale elastically
tags: train, scalingconfig, elastic, resources
---

## Import Train configs from ray.train and scale elastically

`from ray.air.config import RunConfig, ScalingConfig` still imports — but those are the frozen V1 classes, not what a V2 `TorchTrainer` expects; the V2 classes shadow them under `ray.train`. Two V2-only capabilities are easy to miss: `ScalingConfig(num_workers=(2, 8))` requests **elastic** training that starts at 2 workers and grows to 8 as nodes appear (a single int is still fixed-size, `0` runs locally), and `resources_per_worker` keys are case-sensitive Ray resource names — `{"CPU": 4, "GPU": 1}`. A lowercase `{"cpu": 4}` does not error: it requests a custom resource named `cpu` that no node advertises, so the run hangs waiting to schedule instead of failing.

```python
from ray.train import ScalingConfig

scaling = ScalingConfig(
    num_workers=(2, 8),          # elastic: min 2, grow to 8
    use_gpu=True,
    resources_per_worker={"CPU": 4, "GPU": 1},  # case-sensitive keys
)
```

Reference: [ray/train/v2/api/config.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/train/v2/api/config.py)
