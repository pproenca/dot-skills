---
title: Multiplex LoRA adapters dynamically, not one deployment each
tags: api, lora, multiplexing, adapters
---

## Multiplex LoRA adapters dynamically, not one deployment each

Given N fine-tuned adapters of one base model, the design a model produces is N deployments — N copies of the base weights on N sets of GPUs. `LoraConfig` inverts that: `dynamic_lora_loading_path` points at cloud storage (`s3://`, `gs://`, `abfss://`/`azure://`), adapters load on demand and multiplex onto shared base-model replicas (`max_num_adapters_per_replica`, default 16), and clients select an adapter per request through the model name. One base deployment serves the whole adapter family.

```python
from ray.serve.llm import LLMConfig

llm_config = LLMConfig(
    model_loading_config={"model_id": "qwen-7b-base", "model_source": "Qwen/Qwen2.5-7B-Instruct"},
    accelerator_type="L4",
    lora_config={
        "dynamic_lora_loading_path": "s3://ml-models/lora-adapters/qwen-7b/",
        "max_num_adapters_per_replica": 16,
    },
)
```

Reference: [ray/llm/_internal/serve/core/configs/llm_config.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/serve/core/configs/llm_config.py)
