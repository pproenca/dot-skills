---
title: Route same-prefix requests with PrefixCacheAffinityRouter
tags: scale, routing, prefix-cache, kv-cache
---

## Route same-prefix requests with PrefixCacheAffinityRouter

Serve's default routing spreads requests across replicas without knowing that LLM replicas hold KV caches — so multi-turn conversations and shared-system-prompt workloads recompute prefills a sibling replica already has cached. `PrefixCacheAffinityRouter` (public, under `ray.serve.llm.request_router`) routes same-prefix requests to the replica whose prefix cache already holds them, configured per deployment through `deployment_config.request_router_config`; Ray 2.57 adds experimental KV-cache-aware routing on prefill/decode load beyond it. This is a throughput knob a model doesn't reach for because generic Serve has no analogue.

```python
from ray.serve.llm import LLMConfig

llm_config = LLMConfig(
    model_loading_config={"model_id": "support-chat", "model_source": "Qwen/Qwen2.5-7B-Instruct"},
    accelerator_type="L4",
    deployment_config={
        "request_router_config": {
            "request_router_class": "ray.serve.llm.request_router.PrefixCacheAffinityRouter",
        },
    },
)
```

Reference: [ray/serve/llm/request_router.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/llm/request_router.py) · [Ray 2.57.0 release notes](https://github.com/ray-project/ray/releases/tag/ray-2.57.0)
