---
name: mlflow-3
description: MLflow 3 (open-source, pinned to 3.15) for classic-ML MLOps — logging and registering models, promoting versions across dev/staging/prod, standing up a tracking server, evaluating with gates, and serving. Corrects the MLflow 2-era defaults a model reaches for (artifact_path, registry stages and get_latest_versions, top-level mlflow.evaluate with baseline_model, runs-URI registration, pickle serialization, mlruns file stores, MLServer serving) with the MLflow 3 idioms that replaced them (named LoggedModels, aliases and copy_model_version, models.evaluate plus validate_evaluation_results, skops/torch.export defaults, database backends, the FastAPI scoring server). Use when writing, reviewing, or migrating Python code that touches MLflow tracking, the model registry, evaluation, or serving.
---

# MLflow 3

Library-reference skill for open-source MLflow 3 — 24 rules across 6 categories. MLflow 3 restructured the library around the model as a first-class entity, deprecated the registry-stage vocabulary, replaced the serving stack, and changed storage and serialization defaults; a model trained on the vast MLflow 2 corpus reproduces the old idioms fluently, which is exactly why each of these rules exists. There is no rule for things a capable model already gets right.

Scope is classic-ML MLOps on self-hosted OSS MLflow. GenAI features (`mlflow.genai`, tracing, prompt registry, AI Gateway) appear only where confusing them with the classic APIs is itself the trap. Databricks/Unity-Catalog-only features (Deployment Jobs) are flagged as out of scope where a model might scaffold them against OSS.

Pinned to **mlflow 3.15.1** (Python ≥ 3.10). API claims were verified against the unpacked `mlflow` / `mlflow-skinny` 3.15.1 wheels.

## When to Apply

- Writing or reviewing training code that logs models, metrics, params, or datasets with MLflow
- Registering model versions and wiring promotion across dev/staging/prod (aliases, `copy_model_version`, tags, webhooks)
- Standing up or hardening an `mlflow server` — backend store, artifact store, auth
- Evaluating candidate models and gating promotion on thresholds
- Serving models — `mlflow models serve`, `build-docker`, `/invocations` clients, pre-deploy validation
- Migrating an MLflow 2-era codebase (stages, `artifact_path`, `mlflow.evaluate`, `./mlruns`) to MLflow 3

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Model Logging & LoggedModel | `log-` | `name=` not `artifact_path`, models decoupled from runs, input-example-driven signatures, register-at-log-time, skops/torch.export serialization defaults, model-linked metrics and `search_logged_models` |
| 2 | Model Registry & Promotion | `reg-` | Aliases replacing stages, alias-based lookup, per-environment registered models with `copy_model_version`, gate state in tags, OSS webhooks vs Databricks-only Deployment Jobs |
| 3 | Tracking Backend & Server | `track-` | `sqlite:///mlflow.db` default, database-only server backends and `migrate-filestore`, proxied artifacts topology, telemetry opt-out, autolog input-example default |
| 4 | Serving | `serve-` | FastAPI scoring server (MLServer removed), `/invocations` payload contract, `mlflow.models.predict` pre-deploy validation, `build-docker` for clusters |
| 5 | Evaluation & Gates | `eval-` | `mlflow.models.evaluate` vs `mlflow.genai.evaluate`, threshold gating with `validate_evaluation_results` after `baseline_model`'s removal |
| 6 | Environment & Reproducibility | `env-` | Generated environment files as the serving source of truth, dependency pinning and uv capture, bundling custom code with `code_paths` |

## Quick Reference

### 1. Model Logging & LoggedModel

- [`log-name-not-artifact-path`](references/log-name-not-artifact-path.md) — `name=` creates a searchable LoggedModel; `artifact_path` is deprecated and warns
- [`log-models-are-not-run-artifacts`](references/log-models-are-not-run-artifacts.md) — no `start_run` required; artifacts live under `models/<model_id>/`, addressed by `model_uri`
- [`log-input-example-infers-signature`](references/log-input-example-infers-signature.md) — `input_example=` infers the signature and validates serving input at log time
- [`log-register-at-log-time`](references/log-register-at-log-time.md) — `registered_model_name=` or `register_model(model_info.model_uri)`, never composed `runs:/` paths
- [`log-serialization-defaults-changed`](references/log-serialization-defaults-changed.md) — sklearn/lightgbm write skops, pytorch writes torch.export, xgboost writes UBJSON
- [`log-link-metrics-search-models`](references/log-link-metrics-search-models.md) — `log_metric(model_id=, dataset=)` and `search_logged_models` rank models without run bookkeeping

### 2. Model Registry & Promotion

- [`reg-aliases-not-stages`](references/reg-aliases-not-stages.md) — `set_registered_model_alias` + `models:/name@alias` replace the deprecated stage APIs
- [`reg-resolve-by-alias-not-latest-versions`](references/reg-resolve-by-alias-not-latest-versions.md) — deployment code resolves an assigned alias, never `get_latest_versions` or `/latest`
- [`reg-per-environment-registered-models`](references/reg-per-environment-registered-models.md) — `dev.*`/`staging.*`/`prod.*` models with `copy_model_version` as the promotion primitive
- [`reg-gate-state-in-tags`](references/reg-gate-state-in-tags.md) — `validation_status` tags carry the review state stages used to imply
- [`reg-webhooks-oss-deployment-jobs-not`](references/reg-webhooks-oss-deployment-jobs-not.md) — registry webhooks are OSS; Deployment Jobs are Databricks-only

### 3. Tracking Backend & Server

- [`track-default-is-sqlite-not-mlruns`](references/track-default-is-sqlite-not-mlruns.md) — the local default is `sqlite:///mlflow.db`, not `./mlruns`
- [`track-server-needs-database-backend`](references/track-server-needs-database-backend.md) — the file store raises at server startup since 3.13; `migrate-filestore` + `db upgrade`
- [`track-proxied-artifacts-one-credential`](references/track-proxied-artifacts-one-credential.md) — server proxies artifacts by default; clients need only `MLFLOW_TRACKING_URI`
- [`track-telemetry-on-by-default`](references/track-telemetry-on-by-default.md) — anonymized telemetry ships on; disable explicitly in production images
- [`track-autolog-input-examples-off`](references/track-autolog-input-examples-off.md) — `autolog(log_input_examples=True)` for deployment-candidate models

### 4. Serving

- [`serve-fastapi-scoring-server-only`](references/serve-fastapi-scoring-server-only.md) — FastAPI/uvicorn is the only scoring server; MLServer and Flask/gunicorn are gone
- [`serve-invocations-payload-keys`](references/serve-invocations-payload-keys.md) — `/invocations` takes `dataframe_split`/`dataframe_records`/`inputs`/`instances` (+ signature-declared `params`)
- [`serve-predict-before-deploy`](references/serve-predict-before-deploy.md) — `mlflow.models.predict` rebuilds the real env; `validate_serving_input` is deprecated
- [`serve-build-docker-for-clusters`](references/serve-build-docker-for-clusters.md) — `build-docker` is the container path; the Helm chart deploys the tracking server, not models

### 5. Evaluation & Gates

- [`eval-models-evaluate-split`](references/eval-models-evaluate-split.md) — classic ML uses `mlflow.models.evaluate`; `mlflow.genai.evaluate` is a different API
- [`eval-gate-with-validate-evaluation-results`](references/eval-gate-with-validate-evaluation-results.md) — `baseline_model` is removed; gate with `validate_evaluation_results` + `MetricThreshold`

### 6. Environment & Reproducibility

- [`env-generated-files-drive-serving`](references/env-generated-files-drive-serving.md) — serving envs rebuild from the generated files; pin via `pip_requirements`/`extra_pip_requirements`/uv
- [`env-bundle-custom-code-paths`](references/env-bundle-custom-code-paths.md) — `code_paths`/`infer_code_paths` ship the import graph with the model

## How to Use

Read a reference file when its decision comes up. Each rule names the wrong default it corrects, then shows the canonical way (with an incorrect/correct contrast only where the wrong way is a real trap).

- [Section definitions](references/_sections.md) — category structure
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Related Skills

- `mlflow-mlops-migration` — the sibling composition workflow that takes an arbitrary ML codebase through assessment, restructuring, and a dev/staging/prod MLflow 3 setup, citing these rules at each phase

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and source references |
