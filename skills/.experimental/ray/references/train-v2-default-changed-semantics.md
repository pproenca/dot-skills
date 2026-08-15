---
title: Write Train code against V2, the default since 2.51
tags: train, train-v2, runconfig, failureconfig
---

## Write Train code against V2, the default since 2.51

Train V2 stopped being opt-in at Ray 2.51 — `RAY_TRAIN_V2_ENABLED` defaults to true — so code written from the pre-V2 corpus hits hard-deprecated surface: `RunConfig`'s `sync_config`, `verbose`, `stop`, `progress_reporter`, and `log_to_file` fields are rejected, and so is `FailureConfig(fail_fast=...)` (it raises, same as the RunConfig fields) — fault tolerance is `max_failures` (default 0, `-1` = unlimited) plus the new `controller_failure_limit`. Set `RAY_TRAIN_V2_ENABLED=0` only as a migration bridge, not a fix.

```python
from ray.train import CheckpointConfig, FailureConfig, RunConfig, ScalingConfig
from ray.train.torch import TorchTrainer

trainer = TorchTrainer(
    train_loop_per_worker=train_fn,
    train_loop_config={"lr": 3e-4, "epochs": 10},
    scaling_config=ScalingConfig(num_workers=4, use_gpu=True),
    run_config=RunConfig(
        name="churn-classifier",
        storage_path="s3://ml-checkpoints/train",
        failure_config=FailureConfig(max_failures=3),
        checkpoint_config=CheckpointConfig(num_to_keep=2),
    ),
)
result = trainer.fit()
```

Reference: [Ray Train — Getting started (PyTorch)](https://docs.ray.io/en/latest/train/getting-started-pytorch.html) · [ray/train/v2/api/config.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/train/v2/api/config.py)
