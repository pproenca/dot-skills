---
title: Build batch pipelines with build_processor
tags: batch, build-processor, ray-data-llm, vllm
---

## Build batch pipelines with build_processor

`ray.data.llm.build_llm_processor` — the name in every published batch-inference example through the 2.5x line — was **removed** in Ray 2.56 (absent from the pinned 2.57); the function is `build_processor`. The shape around it is unchanged: an engine config (`vLLMEngineProcessorConfig` for local GPU inference), a `preprocess` mapping rows to `messages` + `sampling_params`, a `postprocess` extracting `generated_text`, and calling the processor on a `Dataset`.

```python
import ray
from ray.data.llm import build_processor, vLLMEngineProcessorConfig

config = vLLMEngineProcessorConfig(
    model_source="Qwen/Qwen2.5-7B-Instruct",
    engine_kwargs={"max_model_len": 8192},
    concurrency=2,
    batch_size=64,
)
processor = build_processor(
    config,
    preprocess=lambda row: dict(
        messages=[{"role": "user", "content": f"Summarize: {row['ticket_text']}"}],
        sampling_params=dict(temperature=0.2, max_tokens=200),
    ),
    postprocess=lambda row: dict(summary=row["generated_text"], **row),
)
summaries = processor(ray.data.read_parquet("s3://ml-datasets/tickets/"))
```

Reference: [Ray Data — Working with LLMs](https://docs.ray.io/en/latest/data/working-with-llms.html) · [ray/data/llm.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/llm.py)
