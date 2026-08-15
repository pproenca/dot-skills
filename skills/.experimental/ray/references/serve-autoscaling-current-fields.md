---
title: Autoscale with target_ongoing_requests and factor fields
tags: serve, autoscaling, replicas, scale-to-zero
---

## Autoscale with target_ongoing_requests and factor fields

The autoscaling vocabulary an old-corpus model produces is renamed: `target_num_ongoing_requests_per_replica` is now `target_ongoing_requests` (default 2), and the `*_smoothing_factor` fields are deprecated in favor of `upscaling_factor`/`downscaling_factor`. Also new: `num_replicas="auto"` applies a default autoscaling bundle (target 2, replicas 1–100); setting `num_replicas` to a number *and* `autoscaling_config` together is an error, not an override; and `min_replicas=0` gives scale-to-zero at the price of cold-start latency on the first request (downscale waits `downscale_delay_s`, default 600s).

```python
from ray import serve

@serve.deployment(
    autoscaling_config={
        "min_replicas": 1,
        "max_replicas": 20,
        "target_ongoing_requests": 4,
        "upscale_delay_s": 30,
    },
    max_ongoing_requests=8,  # keep above target so autoscaling has headroom
)
class ChurnScorer: ...
```

Reference: [Ray Serve — Autoscaling guide](https://docs.ray.io/en/latest/serve/autoscaling-guide.html) · [ray/serve/config.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/config.py)
