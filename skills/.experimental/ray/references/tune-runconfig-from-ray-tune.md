---
title: Pass ray.tune.RunConfig to Tuner, not ray.train's
tags: tune, runconfig, imports, migration
---

## Pass ray.tune.RunConfig to Tuner, not ray.train's

The `RunConfig`/`CheckpointConfig`/`FailureConfig` classes exist in three places — legacy `ray.air`, `ray.train` (V2), and `ray.tune` — and they are distinct classes, not aliases. Handing `Tuner` a `ray.train.RunConfig` (the natural move after writing Train code in the same file) triggers a deprecation warning telling you to import from `ray.tune`; `ray.air.RunConfig` is the legacy shim. The symmetry to remember: Train configs come from `ray.train`, Tune configs from `ray.tune`, nothing from `ray.air`.

```python
from ray import tune
from ray.tune import CheckpointConfig, RunConfig  # Tuner wants these...
from ray.train import ScalingConfig               # ...Trainer wants this

run_config = RunConfig(
    name="churn-sweep",
    storage_path="s3://ml-checkpoints/tune",
    checkpoint_config=CheckpointConfig(num_to_keep=2),
)
tuner = tune.Tuner(trainable, run_config=run_config)
```

Reference: [ray/tune/impl/tuner_internal.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/tune/impl/tuner_internal.py)
