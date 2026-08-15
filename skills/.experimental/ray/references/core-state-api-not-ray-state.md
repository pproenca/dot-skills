---
title: Inspect clusters with ray.util.state
tags: core, state-api, observability, debugging
---

## Inspect clusters with ray.util.state

The old introspection surface — `ray.state`, `ray.actors()`, `ray.tasks()` — no longer exists; `ray/state.py` is gone from the package. Programmatic cluster inspection is `ray.util.state`: `list_actors`, `list_tasks`, `list_nodes`, `list_objects`, and the `summarize_*` aggregations, each with filter support, mirrored by the `ray list` / `ray summary` CLI. One dependency surprises: the state API is served by the **dashboard API server**, so a cluster started with `include_dashboard=False` (or without the `default` extra) answers every state call with `ServerUnavailable` — health-check tooling built on this API requires the dashboard to be running.

```python
from ray.util.state import list_actors, summarize_tasks

stuck = list_actors(filters=[("state", "=", "PENDING_CREATION")])
print(summarize_tasks())
```

Reference: [ray/util/state (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/util/state/__init__.py)
