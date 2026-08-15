---
title: Treat handle calls as DeploymentResponse, not ObjectRef
tags: serve, handle, composition, deployment-response
---

## Treat handle calls as DeploymentResponse, not ObjectRef

`RayServeHandle`/`RayServeSyncHandle` are removed, and with them the old-corpus habit of `ray.get(handle.remote(...))`. A `DeploymentHandle.remote()` call returns a `DeploymentResponse`: call `.result()` from synchronous driver code, `await` it inside deployments (blocking `.result()` inside an async deployment method deadlocks the event loop), and use `handle.options(stream=True)` for generator endpoints. Handles come from `serve.run(app)`, `serve.get_app_handle(name)`, or — for composition — child deployments bound as constructor arguments.

```python
from ray import serve

@serve.deployment
class Preprocessor: ...

@serve.deployment
class ChurnPipeline:
    def __init__(self, preprocessor):        # DeploymentHandle injected by .bind()
        self.preprocessor = preprocessor

    async def __call__(self, request) -> dict:
        features = await self.preprocessor.transform.remote(await request.json())
        return {"score": self.score(features)}

app = ChurnPipeline.bind(Preprocessor.bind())
handle = serve.run(app)
print(handle.remote({"tenure_months": 34}).result())  # sync caller: .result()
```

Reference: [ray/serve/handle.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/handle.py)
