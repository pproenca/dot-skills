---
title: Reach for Tuner; tune.run is legacy but present
tags: tune, tuner, tune-run, resultgrid
---

## Reach for Tuner; tune.run is legacy but present

Two symmetric mistakes exist here: writing new sweeps with `tune.run(...)` (the entire pre-Tuner corpus), and "correcting" old code with the claim that `tune.run` was removed — it was not; it is still `@PublicAPI` in 2.57, though several of its checkpoint kwargs (`keep_checkpoints_num`, `checkpoint_freq`, `checkpoint_score_attr`) have been deprecated since 2.7 and the documentation is `Tuner`-only. New code uses `Tuner` with `param_space`, `TuneConfig`, and `RunConfig`; inside function trainables, `tune.report(...)` and `tune.get_checkpoint()` mirror the Train idioms.

```python
from ray import tune
from ray.tune.schedulers import ASHAScheduler

tuner = tune.Tuner(
    train_churn_model,
    param_space={"lr": tune.loguniform(1e-5, 1e-2), "layers": tune.choice([2, 4, 8])},
    tune_config=tune.TuneConfig(
        metric="val_loss", mode="min",
        num_samples=64, scheduler=ASHAScheduler(),
    ),
    run_config=tune.RunConfig(name="churn-sweep", storage_path="s3://ml-checkpoints/tune"),
)
results = tuner.fit()          # ResultGrid
best = results.get_best_result()
```

Reference: [Ray Tune — Key concepts](https://docs.ray.io/en/latest/tune/key-concepts.html) · [ray/tune/tune.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/tune/tune.py)
