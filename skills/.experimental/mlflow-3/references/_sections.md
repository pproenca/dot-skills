# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most often and cost most when wrong go first.

---

## 1. Model Logging & LoggedModel (log)

**Description:** MLflow 3 makes the model — not the run — the unit of record. `log_model` takes `name=` (not `artifact_path=`), works without an active run, stores artifacts under `models/<model_id>/` instead of the run's artifact tree, and returns a `models:/<model_id>` URI that everything downstream (registration, evaluation, serving) keys on. A model writing MLflow 2-era logging code produces deprecation warnings at best and, in the both-arguments case, an exception — and misses the signature inference, serving-input validation, and metric linkage that now happen at log time. Serialization defaults also changed under the same call in 3.14 (sklearn/lightgbm → skops, pytorch → torch.export), which breaks any consumer that reads the artifact bytes directly.

## 2. Model Registry & Promotion (reg)

**Description:** Registry stages — `Staging`, `Production`, `transition_model_version_stage`, `get_latest_versions` — are deprecated since 2.9 and scheduled for removal; every stage-based idiom a model reaches for rides that path. The current vocabulary is aliases (mutable named pointers like `@champion`), per-environment registered models (`dev.*` / `staging.*` / `prod.*`) with `copy_model_version` as the promotion primitive, model-version tags for gate state, and OSS registry webhooks for CI triggers. Getting this wrong wires a promotion pipeline to APIs with a removal date.

## 3. Tracking Backend & Server (track)

**Description:** The storage defaults an MLflow 2-era model assumes are gone — the client default is `sqlite:///mlflow.db`, not `./mlruns`, and since 3.13 any file-store use — client or server — raises outright. A production server is a database plus an `--artifacts-destination`, with artifact access proxied through the server by default so clients need exactly one credential — the tracking URI. Autolog and telemetry also carry defaults worth overriding deliberately.

## 4. Serving (serve)

**Description:** The serving stack was replaced twice — Flask/gunicorn gave way to FastAPI/uvicorn, and the MLServer backend was removed entirely in 3.13 — so tuning advice, middleware patterns, and `--enable-mlserver` flags from the MLflow 2 era target code that no longer exists. What remains is one built-in scoring server with a strict `/invocations` payload contract, a pre-deploy validation API (`mlflow.models.predict`), and `build-docker` as the container path for clusters.

## 5. Evaluation & Gates (eval)

**Description:** Top-level `mlflow.evaluate` is deprecated and its API surface shrank — `baseline_model` and `custom_metrics` are removed. Classic-ML evaluation lives at `mlflow.models.evaluate`; GenAI evaluation is a different API (`mlflow.genai.evaluate`) with different semantics, and conflating the two is the new failure mode. Baseline comparison — the core of a promotion gate — is now an explicit two-step: evaluate, then `mlflow.validate_evaluation_results` with thresholds.

## 6. Environment & Reproducibility (env)

**Description:** The serving environment is rebuilt from the files `log_model` generates — `python_env.yaml`, `requirements.txt` — not from whatever the training machine happened to have installed. Dependency pinning, uv lockfile capture, and bundling custom code with `code_paths` all happen at log time; skipping them produces models that load in the notebook and fail with `ModuleNotFoundError` or version drift in the serving container.
