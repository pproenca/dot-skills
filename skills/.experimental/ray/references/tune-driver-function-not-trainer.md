---
title: Tune trainers through a driver function
tags: tune, train, integration, tune-report-callback
---

## Tune trainers through a driver function

The pre-rework idiom — `Tuner(TorchTrainer(...), param_space={"train_loop_config": {...}})` — is deprecated with an explicit removal notice; the Tune↔Train integration was redesigned. The current pattern inverts control: each Tune trial runs a **driver function** that constructs and fits the `TorchTrainer` itself. Two bridges are mandatory, not optional: `TuneReportCallback` on the inner `RunConfig` forwards Train's reported metrics to Tune (without it every trial "succeeds" and the sweep ends with *no best trial found*), and the inner run needs a per-trial unique `name` or trials collide in shared storage. Cap parallelism with `TuneConfig(max_concurrent_trials=...)` sized to the cluster's GPUs per trial.

```python
from ray import tune
from ray.train import RunConfig, ScalingConfig
from ray.train.torch import TorchTrainer
from ray.tune.integration.ray_train import TuneReportCallback

def train_driver(config: dict):
    trial_id = tune.get_context().get_trial_id()
    trainer = TorchTrainer(
        train_loop_per_worker=train_fn,
        train_loop_config=config,
        scaling_config=ScalingConfig(num_workers=2, use_gpu=True),
        run_config=RunConfig(
            name=f"train-{trial_id}",                  # unique per trial
            storage_path="s3://ml-checkpoints/tune-trials",
            callbacks=[TuneReportCallback()],          # metrics reach Tune through this
        ),
    )
    trainer.fit()

tuner = tune.Tuner(
    train_driver,
    param_space={"lr": tune.loguniform(1e-5, 1e-2)},
    tune_config=tune.TuneConfig(
        metric="loss", mode="min", num_samples=16,
        max_concurrent_trials=4,     # total_gpus // gpus_per_trial
    ),
)
```

Reference: [Ray Train — Hyperparameter optimization with Ray Tune](https://docs.ray.io/en/latest/train/user-guides/hyperparameter-optimization.html) · [ray/tune/impl/tuner_internal.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/tune/impl/tuner_internal.py)
