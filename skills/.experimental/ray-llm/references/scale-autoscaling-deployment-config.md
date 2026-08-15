---
title: Autoscale through deployment_config, replicas and ingress
tags: scale, autoscaling, deployment-config, ingress
---

## Autoscale through deployment_config, replicas and ingress

The units are what a model gets wrong here: an LLM "replica" is a whole engine — all of its tensor-parallel workers and their GPUs — so autoscaling moves capacity in engine-sized, multi-GPU steps, and the knobs live nested under `LLMConfig.deployment_config` (standard Serve `autoscaling_config` semantics, not a bespoke LLM system). The ingress tier scales alongside: the router runs ~2 ingress replicas per model replica by default, overridable via `experimental_configs={"num_ingress_replicas": ...}` when the HTTP tier, not the engine, is the bottleneck.

```python
from ray.serve.llm import LLMConfig

llm_config = LLMConfig(
    model_loading_config={"model_id": "qwen-7b-chat", "model_source": "Qwen/Qwen2.5-7B-Instruct"},
    accelerator_type="L4",
    engine_kwargs={"tensor_parallel_size": 2},
    deployment_config={
        "autoscaling_config": {"min_replicas": 1, "max_replicas": 4,
                               "target_ongoing_requests": 16},
        "max_ongoing_requests": 64,
    },
)
```

Reference: [Ray Serve LLM — Configuration guide](https://docs.ray.io/en/latest/serve/llm/user-guides/configuration.html) · [ray/llm/_internal/serve/core/configs/llm_config.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/serve/core/configs/llm_config.py)
