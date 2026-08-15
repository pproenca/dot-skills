# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. Serving Setup (serve)

**Description:** The corpus a model learned LLM-on-Ray from is two generations stale: the standalone ray-llm repository (archived March 2025) with its YAML model configs, and hand-rolled vLLM engines inside plain Serve deployments. The current surface is `LLMConfig` + `build_openai_app` inside core Ray — engine lifecycle, placement, autoscaling, LoRA, and the OpenAI API handled — and even the 2.44-era beta names have moved (`LLMServer`/`LLMRouter` top-level imports are deprecated). Version pairing is load-bearing: `ray[llm]` pins an exact vLLM release, and mismatched pairs are the top breakage source.

## 2. Batch Inference (batch)

**Description:** `ray.data.llm` renamed its entry point (`build_llm_processor` is gone — `build_processor`) and restructured its configuration (boolean `apply_chat_template`/`tokenize`/`detokenize` flags gave way to stage configs), so the published examples a model reproduces no longer run. The processor defaults also matter: `accelerator_type=None` means CPU, and `concurrency` accepts an autoscaling `(min, max)` tuple, not just an int.

## 3. Placement & Accelerators (place)

**Description:** The vLLM engine builds its own placement group — one bundle per tensor-parallel × pipeline-parallel worker, packed by default — so the reflex of hand-rolling placement groups around the deployment fights the machinery that already exists. `accelerator_type` is validated against Ray's accelerator constants and drives node selection; near-miss strings either normalize silently or raise.

## 4. Autoscaling & Routing (scale)

**Description:** LLM deployments autoscale through the same Serve `autoscaling_config` semantics as any deployment — nested under `LLMConfig.deployment_config` — with an ingress tier that scales alongside model replicas. Routing is pluggable, and for LLM workloads the router choice is a throughput decision: prefix-cache-affinity routing keeps same-prefix requests on replicas that already hold the KV cache.

## 5. LoRA & API Surface (api)

**Description:** Two capability gaps a model fills with worse designs: it builds one deployment per fine-tuned adapter when dynamic LoRA multiplexing loads adapters from cloud storage on demand, and it assumes the OpenAI surface is chat/completions when the ingress also serves embeddings, transcription, scoring, and tokenize endpoints. Configs themselves are plain pydantic — validating them needs no GPU.
