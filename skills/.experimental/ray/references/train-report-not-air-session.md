---
title: Report through ray.train, not ray.air session
tags: train, report, checkpoint, ray-air
---

## Report through ray.train, not ray.air session

`from ray.air import session` / `session.report(...)` is the idiom the pre-2.5x corpus overwhelmingly uses, and its failure mode under default Train V2 is the worst kind: the run **succeeds** while every reported metric is silently discarded (`result.metrics` comes back `None`, with only a buried worker-log warning) — `ray.air` survives only as a legacy V1 shim. The real API lives on `ray.train` directly: `report(metrics, checkpoint=...)`, `get_context()`, `get_checkpoint()` for restoration, `get_dataset_shard()` for Ray Data ingest. V2 `report` also grew capabilities the old idiom can't express: `checkpoint_upload_mode=CheckpointUploadMode.ASYNC` uploads without blocking the training step.

**Incorrect (V1 shim — legacy imports):**

```python
from ray.air import session

session.report({"loss": loss}, checkpoint=checkpoint)
```

**Correct (V2 — the ray.train module is the API):**

```python
import ray.train
from ray.train import Checkpoint

def train_fn(config):
    ckpt = ray.train.get_checkpoint()  # resume point on restart, else None
    for epoch in range(config["epochs"]):
        loss = train_epoch(model, shard)
        with checkpoint_dir(epoch) as tmpdir:
            ray.train.report(
                {"loss": loss, "epoch": epoch},
                checkpoint=Checkpoint.from_directory(tmpdir),
            )
```

Reference: [Ray Train — Getting started (PyTorch)](https://docs.ray.io/en/latest/train/getting-started-pytorch.html) · [ray/train/v2/api/train_fn_utils.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/train/v2/api/train_fn_utils.py)
