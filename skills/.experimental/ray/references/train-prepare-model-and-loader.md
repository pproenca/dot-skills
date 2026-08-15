---
title: Wrap models and loaders with the prepare utilities
tags: train, prepare-model, ddp, data-loader
---

## Wrap models and loaders with the prepare utilities

A training function ported into `TorchTrainer` without `prepare_model`/`prepare_data_loader` runs — on every worker, each training the *same* full dataset on an unwrapped model, so "distributed" training is N copies of single-process training with no gradient synchronization and no speedup. `ray.train.torch.prepare_model(model)` wraps DDP and moves the model to the worker's device (`parallel_strategy="ddp"` default, FSDP available); `prepare_data_loader(loader)` adds the `DistributedSampler` and device transfer so each worker sees its shard. Skip `prepare_data_loader` only when ingest comes through Ray Data shards (`get_dataset_shard`), which shard on their own.

```python
import ray.train.torch

def train_fn(config):
    model = ray.train.torch.prepare_model(build_model(config))       # DDP + device
    loader = ray.train.torch.prepare_data_loader(build_loader(config))  # sampler + device
    for epoch in range(config["epochs"]):
        for features, labels in loader:
            loss = torch.nn.functional.mse_loss(model(features), labels)
            ...
```

Reference: [Ray Train — Getting started (PyTorch)](https://docs.ray.io/en/latest/train/getting-started-pytorch.html) · [ray/train/torch/train_loop_utils.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/train/torch/train_loop_utils.py)
