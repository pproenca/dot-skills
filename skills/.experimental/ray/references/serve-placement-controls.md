---
title: Place replicas with deployment options, not manual PGs
tags: serve, placement, gang-scheduling, routing
---

## Place replicas with deployment options, not manual PGs

When replica placement matters — one replica per node, co-located resource bundles, all-or-nothing replica groups — the old-corpus reflex is hand-rolled placement groups around Serve, which fights the controller. The deployment options cover these cases natively: `max_replicas_per_node` spreads replicas, `placement_group_bundles`/`placement_group_strategy` give a replica its own multi-bundle placement group, the `gang_scheduling_config=` option (a `GangSchedulingConfig` or dict with `gang_size`) schedules replicas in atomic gangs — `num_replicas` must be a multiple of the gang size or validation fails — and `request_router_config` swaps the routing policy per deployment.

```python
from ray import serve

@serve.deployment(
    num_replicas=4,
    max_replicas_per_node=1,                       # spread across nodes
    ray_actor_options={"num_gpus": 1},
)
class EmbeddingScorer: ...
```

Reference: [ray/serve/api.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/api.py) · [ray/serve/config.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/config.py)
