# Ray Serve LLM + Ray Data LLM (open-source Ray)

**Version 0.1.0**  
dot-skills  
August 2026

---

## Abstract

Library-reference skill for LLM workloads on open-source Ray: OpenAI-compatible serving via ray.serve.llm (LLMConfig, build_openai_app, vLLM engine) and batch inference via ray.data.llm (build_processor). 13 rules across 5 categories covering where this fast-churning surface broke with what a model produces: the archived ray-llm repo, renamed entry points, restructured stage configs, relocated classes, placement and accelerator validation, autoscaling, LoRA multiplexing, and routing. Pinned to ray 2.57.0 (whose llm extra pins its matching vLLM); claims verified against the unpacked wheel and installed package source, with every example config constructed under CPU-only pydantic validation; engine/GPU runtime behavior is source-verified, not executed.

---

## Table of Contents

1. [Serving Setup](references/_sections.md#1-serving-setup)
   - 1.1 [Import LLMServer and the ingress from their new modules](references/serve-deprecated-server-router.md)
   - 1.2 [Install ray[llm] and keep the pinned vLLM pairing](references/serve-ray-llm-extra-pins-vllm.md)
   - 1.3 [Separate model_id from model_source in LLMConfig](references/serve-model-id-vs-source.md)
   - 1.4 [Serve LLMs with LLMConfig, not hand-rolled vLLM engines](references/serve-builtin-not-handrolled.md)
2. [Batch Inference](references/_sections.md#2-batch-inference)
   - 2.1 [Build batch pipelines with build_processor](references/batch-build-processor-renamed.md)
   - 2.2 [Configure batch stages with stage configs, not booleans](references/batch-stage-configs-not-flags.md)
   - 2.3 [Set accelerator_type explicitly; CPU is the batch default](references/batch-concurrency-and-alternatives.md)
3. [Placement & Accelerators](references/_sections.md#3-placement-&-accelerators)
   - 3.1 [Let the engine build its placement group](references/place-engine-builds-pg.md)
   - 3.2 [Use canonical accelerator_type names](references/place-accelerator-type-validated.md)
4. [Autoscaling & Routing](references/_sections.md#4-autoscaling-&-routing)
   - 4.1 [Autoscale through deployment_config, replicas and ingress](references/scale-autoscaling-deployment-config.md)
   - 4.2 [Route same-prefix requests with PrefixCacheAffinityRouter](references/scale-prefix-cache-routing.md)
5. [LoRA & API Surface](references/_sections.md#5-lora-&-api-surface)
   - 5.1 [Expect the full OpenAI surface, validate configs without GPUs](references/api-endpoint-surface-cpu-validation.md)
   - 5.2 [Multiplex LoRA adapters dynamically, not one deployment each](references/api-lora-dynamic-multiplexing.md)

---

## References

1. [https://docs.ray.io/en/latest/serve/llm/quick-start.html](https://docs.ray.io/en/latest/serve/llm/quick-start.html)
2. [https://docs.ray.io/en/latest/serve/llm/user-guides/configuration.html](https://docs.ray.io/en/latest/serve/llm/user-guides/configuration.html)
3. [https://docs.ray.io/en/latest/data/working-with-llms.html](https://docs.ray.io/en/latest/data/working-with-llms.html)
4. [https://github.com/ray-project/ray/releases/tag/ray-2.57.0](https://github.com/ray-project/ray/releases/tag/ray-2.57.0)
5. [https://github.com/ray-project/ray-llm](https://github.com/ray-project/ray-llm)
6. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/llm/__init__.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/llm/__init__.py)
7. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/llm/ingress.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/llm/ingress.py)
8. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/llm/request_router.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/serve/llm/request_router.py)
9. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/llm.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/data/llm.py)
10. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/serve/core/configs/llm_config.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/serve/core/configs/llm_config.py)
11. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/batch/processor/base.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/batch/processor/base.py)
12. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/serve/engines/vllm/vllm_models.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/llm/_internal/serve/engines/vllm/vllm_models.py)
13. [https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/util/accelerators/accelerators.py](https://github.com/ray-project/ray/blob/ray-2.57.0/python/ray/util/accelerators/accelerators.py)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |