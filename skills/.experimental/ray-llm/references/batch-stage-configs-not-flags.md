---
title: Configure batch stages with stage configs, not booleans
tags: batch, chat-template, tokenize, stages
---

## Configure batch stages with stage configs, not booleans

The boolean knobs from the original API — `vLLMEngineProcessorConfig(apply_chat_template=True, tokenize=True, detokenize=True)` — are deprecated; each pipeline stage is now its own config object (`chat_template_stage=ChatTemplateStageConfig(...)`, `tokenize_stage=`, `detokenize_stage=`, plus `prepare_multimodal_stage=` for images), which is what made per-stage options like chat-template kwargs expressible at all. Related knobs live on `build_processor` itself, not the config (the configs forbid extra fields): `preprocess_map_kwargs`/`postprocess_map_kwargs` pass Ray Data resources to the user stages, and `builder_kwargs` reaches the builder.

```python
from ray.data.llm import ChatTemplateStageConfig, build_processor, vLLMEngineProcessorConfig

config = vLLMEngineProcessorConfig(
    model_source="Qwen/Qwen2.5-7B-Instruct",
    chat_template_stage=ChatTemplateStageConfig(
        chat_template_kwargs={"enable_thinking": False},  # per-stage option the booleans couldn't express
    ),
)
processor = build_processor(
    config,
    preprocess=to_messages,
    postprocess=extract_summary,
    preprocess_map_kwargs={"num_cpus": 0.5},   # build_processor kwarg, not a config field
)
```

Reference: [ray/data/llm.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/llm.py) · [ray/llm/_internal/batch/processor/base.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/batch/processor/base.py)
