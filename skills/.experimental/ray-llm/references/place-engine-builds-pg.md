---
title: Let the engine build its placement group
tags: place, placement-group, tensor-parallel, multi-node
---

## Let the engine build its placement group

Hand-rolling a placement group around an LLM deployment — the reflex from classic Ray Serve work — fights machinery that already exists: the vLLM engine creates a placement group with one bundle per worker (`tensor_parallel_size × pipeline_parallel_size`), packed by default. Overriding it has two traps. First, a `placement_group_config` must carry bundles (`bundle_per_worker` or an explicit `bundles` list) alongside the optional `strategy` — a strategy-only dict makes hardware inference read the empty bundles as CPU-only and fail validation against `accelerator_type`. Second, the classic Serve options `placement_group_bundles`/`placement_group_strategy` inside `deployment_config` are rejected at deploy time for LLM deployments; `placement_group_config` on the `LLMConfig` is the one override point.

```python
from ray.serve.llm import LLMConfig

llm_config = LLMConfig(
    model_loading_config={"model_id": "qwen-72b", "model_source": "Qwen/Qwen2.5-72B-Instruct"},
    accelerator_type="H100",
    engine_kwargs={"tensor_parallel_size": 8},           # 8 bundles, PACK by default
    placement_group_config={                              # only when multi-node is intended
        "bundle_per_worker": {"CPU": 1, "GPU": 1},        # bundles required, not just strategy
        "strategy": "SPREAD",
    },
)
```

Reference: [Ray Serve LLM — Configuration guide](https://docs.ray.io/en/latest/serve/llm/user-guides/configuration.html) · [ray/llm/_internal/serve/engines/vllm/vllm_models.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/serve/engines/vllm/vllm_models.py)
