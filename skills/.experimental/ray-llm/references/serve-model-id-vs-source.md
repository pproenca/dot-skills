---
title: Separate model_id from model_source in LLMConfig
tags: serve, model-loading, naming, huggingface
---

## Separate model_id from model_source in LLMConfig

A model conflates the two names in `model_loading_config` because vLLM alone has only one: `model_id` is the **client-facing** name — what callers put in the OpenAI request's `model` field and what `/v1/models` lists — while `model_source` is where weights come from (a Hugging Face ID, an S3/GCS mirror via `CloudMirrorConfig`, or a local path). Setting only a HF path as the id couples every client to the storage location; renaming the served model then breaks callers instead of being a config edit.

```python
from ray.serve.llm import LLMConfig

llm_config = LLMConfig(
    model_loading_config={
        "model_id": "support-summarizer",              # what clients request
        "model_source": "s3://ml-models/qwen2.5-7b-summarize-v3/",  # where weights live
    },
    accelerator_type="L4",
)
```

Reference: [Ray Serve LLM — Configuration guide](https://docs.ray.io/en/latest/serve/llm/user-guides/configuration.html) · [ray/llm/_internal/serve/core/configs/llm_config.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/serve/core/configs/llm_config.py)
