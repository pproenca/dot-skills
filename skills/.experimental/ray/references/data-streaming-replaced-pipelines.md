---
title: Stream datasets; DatasetPipeline is gone
tags: data, streaming, execution, materialize
---

## Stream datasets; DatasetPipeline is gone

`DatasetPipeline`, `ds.window()`, and `ds.repeat()` — the pre-streaming-era tools for datasets larger than memory — are removed entirely, because streaming execution made them redundant: operators are lazy, blocks stream through the operator graph with backpressure when you consume the dataset (iterate, write, or pass to Train), and nothing requires the whole dataset in memory. The inverted habit matters too: `materialize()` pins the full dataset in the object store, so call it only deliberately (a small dataset reused across many downstream consumers), never as a "make it run" reflex.

```python
import ray

ds = (
    ray.data.read_parquet("s3://ml-datasets/transactions/2026/")
    .map_batches(engineer_features, batch_size=1024)
)
# Nothing has executed yet. Consumption drives streaming execution:
ds.write_parquet("s3://ml-datasets/features/2026/")
```

Reference: [Ray Data — Internals and streaming execution](https://docs.ray.io/en/latest/data/data-internals.html)
