---
title: Control read fan-out with override_num_blocks
tags: data, read, blocks, parallelism
---

## Control read fan-out with override_num_blocks

`ray.data.read_parquet(path, parallelism=200)` is the old-corpus spelling and `parallelism` is deprecated across the read APIs — the parameter is `override_num_blocks`, named to say what it actually does: force the block count instead of letting Ray Data size blocks from the data. Leaving it unset is usually right; reach for it when the default produces too few blocks to occupy the cluster or so many that per-block overhead dominates.

```python
import ray

ds = ray.data.read_parquet(
    "s3://ml-datasets/transactions/2026/",
    override_num_blocks=200,   # only when the auto-chosen block count is wrong
)
```

Reference: [ray/data/read_api.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/read_api.py)
