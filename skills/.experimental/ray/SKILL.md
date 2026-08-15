---
name: ray
description: Production Ray (open-source, pinned to 2.57) for classic-ML workloads from training to serving — Ray Train, Tune, Data, Serve, Core, and cluster deployment on KubeRay. Corrects the older-corpus defaults a model reaches for (ray.air session reporting, Trainer-inside-Tuner, tune.run, map_batches concurrency=, DatasetPipeline/to_torch, max_concurrent_queries, RayServeHandle + ray.get, Deployment.deploy, ray.state, ray.get-in-a-loop) with the 2.57 idioms that replaced them (Train V2 defaults, driver-function tuning, compute strategies, streaming datasets, DeploymentHandle/DeploymentResponse, serve build/deploy, ray.util.state, KubeRay CRDs and Jobs API). Use when writing, reviewing, or productionizing Python code that touches Ray distributed training, data pipelines, hyperparameter tuning, model serving, or Ray cluster operations. LLM serving/batch-inference on Ray lives in the sibling ray-llm skill.
---

# Ray

Library-reference skill for production, open-source Ray — 26 rules across 6 categories covering the path from training to serving. Ray's API surface churned hard through the 2.x line (Train V2 became the default, Serve removed parameters and handle classes outright, Ray Data reversed a deprecation), so a model fluent in the older corpus produces code that warns, errors, or silently means something else. Each rule names the wrong default it corrects; there is no rule for things a capable model already gets right.

Scope is classic-ML Ray on self-hosted/KubeRay clusters. LLM serving and batch inference (`ray.serve.llm`, `ray.data.llm`) are the sibling [`ray-llm`](../ray-llm/) skill.

Pinned to **ray 2.57.0** (Python ≥ 3.10). API claims were verified against the unpacked 2.57.0 wheel; classic-ML examples were exercised on a live local Ray 2.57.0 runtime.

## When to Apply

- Writing or reviewing distributed training code — `TorchTrainer`, `ScalingConfig`, checkpointing, fault tolerance
- Building data pipelines with Ray Data — reads, `map_batches`, GPU inference pools, training ingest
- Running hyperparameter sweeps with Ray Tune, especially combined with Ray Train
- Writing or reviewing Ray Serve deployments — scaling, handles, composition, production config
- Using Ray Core primitives directly — tasks, actors, object store, retries
- Standing up or reviewing production Ray infrastructure — KubeRay CRDs, job submission, fault tolerance, observability

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Ray Train | `train-` | Train V2 as the default (deprecated config fields), `ray.train.report` over `ray.air` session, config imports and elastic scaling, the `prepare_model`/`prepare_data_loader` wrappers |
| 2 | Ray Serve | `serve-` | `max_ongoing_requests` (old name removed), current autoscaling fields, `DeploymentResponse` handles, `serve.run`/`build`/`deploy` lifecycle, replica placement options |
| 3 | Ray Data | `data-` | `compute=` strategies (the `concurrency` reversal), `override_num_blocks`, streaming execution replacing pipelines, torch ingest, zero-copy read-only batches |
| 4 | Ray Core | `core-` | The classic anti-patterns' non-obvious residue, retry/restart defaults, object store & `/dev/shm` sizing, `ray.util.state` |
| 5 | Ray Tune | `tune-` | `Tuner` as canonical (with `tune.run`'s true status), `ray.tune.RunConfig` imports, the driver-function Train integration |
| 6 | Production & Clusters | `prod-` | KubeRay CRD choice, Jobs API submission, GCS fault tolerance with Redis, baked images vs `runtime_env`, Prometheus/Grafana wiring |

## Quick Reference

### 1. Ray Train

- [`train-v2-default-changed-semantics`](references/train-v2-default-changed-semantics.md) — V2 is the default since 2.51; `sync_config`/`verbose`/`fail_fast` are gone
- [`train-report-not-air-session`](references/train-report-not-air-session.md) — `ray.train.report(metrics, checkpoint=)`; `ray.air` is a legacy shim
- [`train-configs-from-ray-train-elastic`](references/train-configs-from-ray-train-elastic.md) — V2 config imports, elastic `num_workers=(min, max)`, case-sensitive resource keys
- [`train-prepare-model-and-loader`](references/train-prepare-model-and-loader.md) — without `prepare_model`/`prepare_data_loader`, N workers train N unsynchronized copies

### 2. Ray Serve

- [`serve-max-ongoing-requests`](references/serve-max-ongoing-requests.md) — `max_concurrent_queries` is removed; `max_ongoing_requests` (default 5) + `max_queued_requests`
- [`serve-autoscaling-current-fields`](references/serve-autoscaling-current-fields.md) — `target_ongoing_requests`, `*_factor` fields, `num_replicas="auto"`, scale-to-zero
- [`serve-deployment-response-handles`](references/serve-deployment-response-handles.md) — `DeploymentResponse.result()`/`await`, never `ray.get`; composition via `.bind()`
- [`serve-run-build-deploy`](references/serve-run-build-deploy.md) — `serve.run` + `serve build`/`deploy`; `Deployment.deploy()` era is removed
- [`serve-placement-controls`](references/serve-placement-controls.md) — `max_replicas_per_node`, per-replica placement groups, gang scheduling, request routers

### 3. Ray Data

- [`data-compute-not-concurrency`](references/data-compute-not-concurrency.md) — `concurrency=` is deprecated (again); `compute=ActorPoolStrategy/TaskPoolStrategy`
- [`data-override-num-blocks`](references/data-override-num-blocks.md) — `parallelism` is deprecated in read APIs
- [`data-streaming-replaced-pipelines`](references/data-streaming-replaced-pipelines.md) — `DatasetPipeline`/`window`/`repeat` removed; execution streams on consumption
- [`data-iter-torch-batches-not-to-torch`](references/data-iter-torch-batches-not-to-torch.md) — `to_torch` is gone; `iter_torch_batches` and Train dataset shards
- [`data-zero-copy-read-only-batches`](references/data-zero-copy-read-only-batches.md) — batches are read-only views by default; set an explicit `batch_size`

### 4. Ray Core

- [`core-classic-traps-residue`](references/core-classic-traps-residue.md) — the non-obvious residue of the classic anti-patterns: `ray.wait` draining, closure/global copies, few-ms task floor
- [`core-retries-system-failures-only`](references/core-retries-system-failures-only.md) — `retry_exceptions` is opt-in; actors don't restart by default
- [`core-object-store-sizing`](references/core-object-store-sizing.md) — 30% default, `/dev/shm` in containers, spilling to local disk
- [`core-state-api-not-ray-state`](references/core-state-api-not-ray-state.md) — `ray.state` is gone; `ray.util.state` is the introspection API

### 5. Ray Tune

- [`tune-tuner-canonical`](references/tune-tuner-canonical.md) — `Tuner` is the API; `tune.run` is legacy but not removed
- [`tune-runconfig-from-ray-tune`](references/tune-runconfig-from-ray-tune.md) — Tuner takes `ray.tune.RunConfig`, not `ray.train`'s or `ray.air`'s
- [`tune-driver-function-not-trainer`](references/tune-driver-function-not-trainer.md) — Trainer-inside-Tuner is deprecated; use a driver function + `with_resources`

### 6. Production & Clusters

- [`prod-kuberay-crd-choice`](references/prod-kuberay-crd-choice.md) — RayCluster vs RayJob (`shutdownAfterJobFinishes` defaults false) vs RayService
- [`prod-jobs-api-not-head-driver`](references/prod-jobs-api-not-head-driver.md) — `ray job submit` for long-lived clusters; Ray Client is a dev tool
- [`prod-gcs-ft-redis`](references/prod-gcs-ft-redis.md) — head-crash survival for RayService needs external Redis GCS
- [`prod-baked-images-not-runtime-env`](references/prod-baked-images-not-runtime-env.md) — images carry prod dependencies; `runtime_env` (now incl. `uv`, `image_uri`) is for iteration
- [`prod-metrics-wiring`](references/prod-metrics-wiring.md) — the dashboard needs external Prometheus/Grafana to show time series

## How to Use

Read a reference file when its decision comes up. Each rule names the wrong default it corrects, then shows the canonical way (with an incorrect/correct contrast only where the wrong way is a real trap).

- [Section definitions](references/_sections.md) — category structure
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Related Skills

- `ray-llm` — the sibling rule pack for LLM serving (`ray.serve.llm`) and batch inference (`ray.data.llm`) on Ray
- `mlflow-3` — experiment tracking and model registry; pairs with Ray Train for the tracking side of the MLOps cycle

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and source references |
