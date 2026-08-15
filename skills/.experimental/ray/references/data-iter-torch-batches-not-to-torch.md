---
title: Feed training with iter_torch_batches or dataset shards
tags: data, torch, ingest, train
---

## Feed training with iter_torch_batches or dataset shards

`ds.to_torch(...)` is gone from `Dataset` (a deprecated remnant survives only on `DataIterator`), yet it is what the old corpus reaches for to bridge Ray Data and PyTorch. The current bridge is `iter_torch_batches(batch_size=..., dtypes=..., device=...)` for standalone loops, and inside Ray Train workers, `ray.train.get_dataset_shard("train")` — pass the dataset to the trainer via `datasets={"train": ds}` and each worker iterates its own shard, which is also how Ray Data's streaming ingest overlaps with GPU compute.

```python
def train_fn(config):
    import ray.train
    shard = ray.train.get_dataset_shard("train")
    for epoch in range(config["epochs"]):
        for batch in shard.iter_torch_batches(batch_size=256, device="cuda"):
            loss = step(model, batch["features"], batch["label"])
```

Reference: [ray/data/dataset.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/dataset.py) · [Ray Train — Getting started (PyTorch)](https://docs.ray.io/en/latest/train/getting-started-pytorch.html)
