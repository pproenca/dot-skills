---
title: Use canonical accelerator_type names
tags: place, accelerator, gpu, validation
---

## Use canonical accelerator_type names

`accelerator_type` is not a free-form label — it is validated against Ray's accelerator constants (`"T4"`, `"L4"`, `"L40S"`, `"A10G"`, `"A100-40G"`, `"A100-80G"`, `"H100"`, `"H200"`, `"B200"`, TPU generations, and AMD Instinct entries prefixed `AMD-Instinct-`, e.g. `"AMD-Instinct-MI300X-OAM"`) and drives which nodes the engine workers can schedule on. The near-miss behavior is asymmetric: `"A10"` is silently normalized to `"A10G"`, but other invalid strings — including bare `"MI300X"` — raise at config validation. Match the string to the cluster's advertised accelerator resource, or replicas never schedule.

```python
from ray.serve.llm import LLMConfig

llm_config = LLMConfig(
    model_loading_config={"model_id": "reranker", "model_source": "BAAI/bge-reranker-v2-m3"},
    accelerator_type="A100-80G",   # exact constant, not "A100 80GB" or "a100-80g"
)
```

Reference: [ray/util/accelerators/accelerators.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/util/accelerators/accelerators.py) · [ray/llm/_internal/serve/core/configs/llm_config.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/serve/core/configs/llm_config.py)
