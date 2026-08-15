---
title: Set accelerator_type explicitly; CPU is the batch default
tags: batch, concurrency, accelerator, processors
---

## Set accelerator_type explicitly; CPU is the batch default

`ProcessorConfig.accelerator_type` defaults to `None`, which schedules the engine workers on **CPU** — a batch job "runs" and crawls, and nothing errors to say the GPUs sat idle. Set `accelerator_type` for GPU inference. Also easy to miss: `concurrency` (default 1) accepts either an int or a `(min, max)` tuple for an autoscaling worker pool (`resources_per_bundle` is deprecated). When local GPU inference is the wrong tool, the sibling configs cover the alternatives — `HttpRequestProcessorConfig` for OpenAI-compatible HTTP APIs, `ServeDeploymentProcessorConfig` to run batches against an already-deployed Serve LLM.

```python
from ray.data.llm import vLLMEngineProcessorConfig

config = vLLMEngineProcessorConfig(
    model_source="Qwen/Qwen2.5-7B-Instruct",
    accelerator_type="L4",       # default None = CPU workers
    concurrency=(1, 4),          # autoscaling pool
    batch_size=64,
)
```

Reference: [Ray Data — Working with LLMs](https://docs.ray.io/en/latest/data/working-with-llms.html) · [ray/llm/_internal/batch/processor/base.py (ray-2.57.0)](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/batch/processor/base.py)
