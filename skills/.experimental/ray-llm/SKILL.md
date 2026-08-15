---
name: ray-llm
description: LLM workloads on open-source Ray (pinned to 2.57) — OpenAI-compatible serving with ray.serve.llm (vLLM-backed LLMConfig + build_openai_app) and batch inference with ray.data.llm (build_processor). Corrects the stale defaults a model produces — the archived ray-llm repo and its YAML configs, hand-rolled vLLM engines inside plain Serve deployments, the removed build_llm_processor name, deprecated boolean stage flags, top-level LLMServer/LLMRouter imports, free-form accelerator strings, one-deployment-per-LoRA-adapter designs — with the 2.57 idioms (stage configs, placement_group_config over hand-rolled PGs, deployment_config autoscaling, dynamic LoRA multiplexing, prefix-cache-affinity routing, the full OpenAI endpoint surface). Use when writing, reviewing, or productionizing LLM serving or batch inference on Ray. Classic-ML Ray (Train/Tune/Data/Serve/clusters) lives in the sibling ray skill.
---

# Ray LLM

Library-reference skill for LLM workloads on open-source Ray — 13 rules across 5 categories covering `ray.serve.llm` (OpenAI-compatible, vLLM-backed serving) and `ray.data.llm` (batch inference). This surface churned faster than any other part of Ray — a standalone repo was absorbed and archived, entry points were renamed, and config shapes restructured — so the examples a model learned from mostly no longer run. Each rule names the wrong default it corrects; there is no rule for things a capable model already gets right.

Scope is the LLM-specific layer. Generic Serve/Data/cluster decisions (deployment lifecycle, autoscaling semantics, KubeRay) are the sibling [`ray`](../ray/) skill — the two compose.

Pinned to **ray 2.57.0** (`ray[llm]` extra, which pins its matching vLLM). API claims were verified against the unpacked 2.57.0 wheel and the installed package source, and every config example in the rules was constructed under CPU-only pydantic validation (including the traps, which fail exactly as described); engine/GPU runtime behavior is source-verified only — no model was actually served.

## When to Apply

- Standing up or reviewing an OpenAI-compatible LLM serving deployment on Ray
- Writing batch LLM inference over datasets — summarization, embedding, scoring at scale
- Sizing or placing multi-GPU models — tensor/pipeline parallelism, accelerator selection
- Scaling LLM deployments — replica autoscaling, ingress sizing, request routing
- Serving families of LoRA fine-tunes of a shared base model
- Migrating code that uses the archived ray-llm repo, hand-rolled vLLM engines, or pre-2.5x `ray.data.llm` names

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Serving Setup | `serve-` | `LLMConfig` + `build_openai_app` over hand-rolled engines and the archived repo; `model_id` vs `model_source`; the `ray[llm]`↔vLLM version pin; relocated `LLMServer`/`OpenAiIngress` imports |
| 2 | Batch Inference | `batch-` | `build_processor` (old name removed), stage configs over boolean flags, CPU-default `accelerator_type` and autoscaling `concurrency`, HTTP/Serve processor alternatives |
| 3 | Placement & Accelerators | `place-` | The engine's own TP×PP placement group (and when to override its strategy), validated `accelerator_type` names |
| 4 | Autoscaling & Routing | `scale-` | `deployment_config.autoscaling_config` with engine-sized replicas, ingress replica sizing, prefix-cache-affinity routing |
| 5 | LoRA & API Surface | `api-` | Dynamic LoRA multiplexing over per-adapter deployments; the full OpenAI endpoint surface; GPU-free config validation |

## Quick Reference

### 1. Serving Setup

- [`serve-builtin-not-handrolled`](references/serve-builtin-not-handrolled.md) — `LLMConfig` + `build_openai_app`; the ray-llm repo is archived, hand-rolled engines re-implement less
- [`serve-model-id-vs-source`](references/serve-model-id-vs-source.md) — `model_id` is the client-facing name; `model_source` is where weights live
- [`serve-ray-llm-extra-pins-vllm`](references/serve-ray-llm-extra-pins-vllm.md) — `ray[llm]` pins its exact vLLM; don't mix independently chosen versions
- [`serve-deprecated-server-router`](references/serve-deprecated-server-router.md) — `LLMServer`/`LLMRouter` moved; the ingress class is `OpenAiIngress` (exact casing)

### 2. Batch Inference

- [`batch-build-processor-renamed`](references/batch-build-processor-renamed.md) — `build_llm_processor` is removed; `build_processor` + `vLLMEngineProcessorConfig`
- [`batch-stage-configs-not-flags`](references/batch-stage-configs-not-flags.md) — boolean `apply_chat_template`/`tokenize`/`detokenize` gave way to stage configs
- [`batch-concurrency-and-alternatives`](references/batch-concurrency-and-alternatives.md) — `accelerator_type=None` means CPU; `(min, max)` concurrency; HTTP/Serve processors

### 3. Placement & Accelerators

- [`place-engine-builds-pg`](references/place-engine-builds-pg.md) — the engine builds its TP×PP placement group; override strategy, don't hand-roll
- [`place-accelerator-type-validated`](references/place-accelerator-type-validated.md) — canonical accelerator constants; `"A10"` normalizes, most typos raise

### 4. Autoscaling & Routing

- [`scale-autoscaling-deployment-config`](references/scale-autoscaling-deployment-config.md) — standard Serve autoscaling nested in `deployment_config`; replicas are whole engines
- [`scale-prefix-cache-routing`](references/scale-prefix-cache-routing.md) — `PrefixCacheAffinityRouter` keeps same-prefix requests on warm KV caches

### 5. LoRA & API Surface

- [`api-lora-dynamic-multiplexing`](references/api-lora-dynamic-multiplexing.md) — dynamic adapter loading from cloud storage, not one deployment per adapter
- [`api-endpoint-surface-cpu-validation`](references/api-endpoint-surface-cpu-validation.md) — embeddings/transcription/score/tokenize are served too; configs validate without GPUs

## How to Use

Read a reference file when its decision comes up. Each rule names the wrong default it corrects, then shows the canonical way (with an incorrect/correct contrast only where the wrong way is a real trap).

- [Section definitions](references/_sections.md) — category structure
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Related Skills

- `ray` — the sibling rule pack for classic-ML Ray (Train, Tune, Data, Serve, Core, KubeRay production topology); generic Serve and cluster decisions live there

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and source references |
