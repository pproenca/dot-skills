---
title: Configure max_ongoing_requests, not max_concurrent_queries
tags: serve, deployment, concurrency, backpressure
---

## Configure max_ongoing_requests, not max_concurrent_queries

`max_concurrent_queries` — the parameter in essentially every pre-2.10 Serve example — is **removed** in 2.57, so old deployment decorators fail at definition time. The replacement pair: `max_ongoing_requests` caps in-flight requests per replica (default **5**, deliberately low — raise it for I/O-bound or batched handlers or replicas sit idle), and `max_queued_requests` bounds the per-caller queue so overload turns into fast backpressure instead of unbounded memory growth.

**Incorrect (removed parameter — fails on import):**

```python
@serve.deployment(max_concurrent_queries=32)
class ChurnScorer: ...
```

**Correct (2.57 names):**

```python
from ray import serve

@serve.deployment(max_ongoing_requests=32, max_queued_requests=200)
class ChurnScorer:
    async def __call__(self, request) -> dict:
        return {"score": await self.model.predict(await request.json())}
```

Reference: [ray/serve/api.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/api.py)
