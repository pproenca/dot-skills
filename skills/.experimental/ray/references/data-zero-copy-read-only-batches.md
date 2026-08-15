---
title: Copy batches before mutating; zero-copy is the default
tags: data, zero-copy, batch-size, mutation
---

## Copy batches before mutating; zero-copy is the default

`map_batches` now defaults to `zero_copy_batch=True`: batches arrive as read-only views over shared object-store memory, so the old-corpus habit of mutating the batch in place (`batch["score"] = ...` on a NumPy view, `df.loc[...] = ...`) raises a read-only error at runtime. Copy what you mutate — or build a new dict — and keep the zero-copy win for the common transform that only reads. Separately, `batch_size=None` (the default) means "one whole block per batch", which silently becomes a memory spike with large blocks; set an explicit int (or `"auto"`) whenever the function's memory scales with batch size.

```python
import numpy as np

def add_score(batch: dict[str, np.ndarray]) -> dict[str, np.ndarray]:
    scores = model.predict(batch["features"])       # read-only input is fine
    return {**batch, "score": scores}               # new dict, no in-place mutation

scored = ds.map_batches(add_score, batch_size=1024)
```

Reference: [ray/data/dataset.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/dataset.py)
