---
title: Serve LLMs with LLMConfig, not hand-rolled vLLM engines
tags: serve, llmconfig, build-openai-app, vllm
---

## Serve LLMs with LLMConfig, not hand-rolled vLLM engines

The two patterns an older corpus produces are both dead ends: the standalone `ray-project/ray-llm` repository with its YAML model configs was archived in March 2025, and wrapping a vLLM `AsyncLLMEngine` inside a plain `@serve.deployment` re-implements — worse — what core Ray now ships. `ray.serve.llm`'s `LLMConfig` + `build_openai_app` handles the engine lifecycle, tensor-parallel placement, autoscaling, LoRA multiplexing, engine metrics, and an OpenAI-compatible API in one declarative config; the same config inlines into a `serve build` YAML via `import_path: ray.serve.llm:build_openai_app`.

```python
from ray import serve
from ray.serve.llm import LLMConfig, build_openai_app

llm_config = LLMConfig(
    model_loading_config={"model_id": "qwen-7b-chat",
                          "model_source": "Qwen/Qwen2.5-7B-Instruct"},
    accelerator_type="L4",
    engine_kwargs={"tensor_parallel_size": 2, "max_model_len": 8192},
    deployment_config={"autoscaling_config": {"min_replicas": 1, "max_replicas": 4}},
)
app = build_openai_app({"llm_configs": [llm_config]})
serve.run(app, blocking=True)
```

Reference: [Ray Serve LLM — Quick start](https://docs.ray.io/en/latest/serve/llm/quick-start.html) · [ray-project/ray-llm (archived)](https://github.com/ray-project/ray-llm)
