---
title: Enable retry_exceptions deliberately; retries cover crashes only
tags: core, retries, fault-tolerance, actors
---

## Enable retry_exceptions deliberately; retries cover crashes only

The retry defaults invert what a model assumes in both directions. Tasks *do* retry — `max_retries=3` — but only on **system failures** (worker crash, node loss); an application exception propagates immediately unless `retry_exceptions=True` (or a list of exception types) opts in. Actors are the opposite: `max_restarts=0` and `max_task_retries=0`, so a died actor stays dead unless restarts are requested. Production actor code that must survive node loss needs both knobs set, and idempotency thought through — a retried task runs again from the start.

```python
@ray.remote(max_retries=3, retry_exceptions=[ConnectionError, TimeoutError])
def fetch_features(user_id: str) -> dict: ...

@ray.remote(max_restarts=5, max_task_retries=2)
class FeatureCache: ...
```

Reference: [ray/_common/ray_option_utils.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/_common/ray_option_utils.py)
