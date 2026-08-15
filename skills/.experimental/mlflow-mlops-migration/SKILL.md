---
name: mlflow-mlops-migration
description: Guided workflow for taking any ML codebase — including one with no experiment tracking at all, or one full of MLflow 2-era idioms — to a production-grade open-source MLflow 3 setup with dev/staging/prod environments, registry-based promotion, and served models. Walks seven phases with a developer who may have zero MLflow 3 experience — assess the codebase (scripted read-only audit), model the registry domain (per-environment model names, aliases, gates), stand up tracking per environment, restructure training code to MLflow 3 idioms, wire evaluation-gated promotion, serve and smoke-test, then run the ongoing MLOps loop. Use when asked to set up MLflow, migrate to MLflow 3, productionize model training and serving, or design a dev/staging/prod MLOps cycle. Pairs with the sibling mlflow-3 rule pack for every API decision.
---

# MLflow MLOps Migration

A phased, gated workflow that turns an arbitrary ML codebase — however unstructured — into a
production-grade **open-source MLflow 3** setup covering the full MLOps cycle: tracked experiments,
a domain-modelled registry, dev/staging/prod separation, evaluation-gated promotion, and served
models. It is written to be driven *with* a developer who has no MLflow 3 experience: every phase
produces a reviewable artifact before anything is changed, and every API decision defers to the
sibling [`mlflow-3`](../mlflow-3/) rule pack (which is pinned to mlflow 3.15.1 and names the
MLflow 2-era idioms this migration exists to remove).

## When to Apply

Use this skill when:
- A team wants MLflow (or has a messy/partial MLflow 2 setup) and needs the path to a
  production-grade MLflow 3 deployment — not just API fixes.
- Training code exists but experiments are untracked, models are shipped by copying files, or
  "deployment" means a pickle in a bucket.
- You are asked to design or review a dev/staging/prod model-promotion story.
- An MLflow 2 → 3 migration touches infrastructure (stages, `./mlruns` file stores, MLServer),
  not only client code.

Don't use it for a single API question — read the relevant `mlflow-3` rule directly.

## Workflow Overview

```
0 assess ─▶ 1 domain-model ─▶ 2 environments ─▶ 3 instrument ─▶ 4 promote ─▶ 5 serve ─▶ 6 operate
  audit        registry           tracking per      training code    eval-gated    validate,     retrain loop,
  report       naming, alias      env (dev local,   → MLflow 3       copy_model_   serve,        challenger,
  (script,     + gate design      stg/prod DB+S3    idioms (rule     version +     smoke-test    maintenance
  read-only)   (interview)        + auth)           pack)            alias flip    /invocations  (gated)
```

| Phase | Action | Deliverable | Risk |
|-------|--------|-------------|------|
| 0 | Run `scripts/00-assess.sh <codebase>` — read-only audit | `mlflow-assessment.md` report | read-only |
| 1 | Interview + [domain modelling](references/domain-modelling.md) | Registry domain doc (names, aliases, gates) | read-only |
| 2 | Stand up tracking per [environments](references/environments.md); dev via `scripts/scaffold-dev-tracking.sh` | Reachable tracking server(s), `config.json` filled | write |
| 3 | Restructure training code to MLflow 3 idioms (sibling rule pack) | Refactored code, first LoggedModels registered | write |
| 4 | Wire [promotion](references/promotion.md) — evaluate gate, tags, `copy_model_version`, alias flip | Promotion script/CI job | write |
| 5 | [Serve](references/serving.md) — `mlflow.models.predict`, then serve/`build-docker`, smoke `/invocations` | Served model per environment | write |
| 6 | Operate — retraining, challenger evaluation, maintenance (see [workflow](references/workflow.md)) | Runbook habits, scheduled jobs | write |
| ✓ | Run `scripts/verify.sh` after phases 2–5 | Pass/fail assertion report | read-only |

Phases run in order — each has entry/exit criteria in [references/workflow.md](references/workflow.md),
and `scripts/verify.sh` is the exit gate for the infrastructure phases. Re-running any phase is safe:
`00-assess.sh` regenerates only its own report (and refuses to clobber anything else),
`scaffold-dev-tracking.sh` refuses to overwrite (exit code 2 = already done), and `verify.sh` only
reads. The one non-idempotent step is promotion's `copy_model_version` — see
[references/promotion.md](references/promotion.md) for how to resume instead of re-copying.

## Risk Level: Write

This workflow edits training code, writes infrastructure files, and stands up services. Guardrails:
- Nothing in phase 0–1 modifies anything — always complete both before touching code or infra.
- Confirm with the user before: starting/replacing any tracking server, rewriting a training
  entrypoint, flipping a **prod** `@champion` alias (dev/staging flips may be automated by the
  phase-4 pipeline), and exposing a serving endpoint beyond localhost.
- Two maintenance commands are destructive and must be run only with explicit user confirmation and
  a stated reason: `mlflow gc` (permanently deletes soft-deleted runs and experiments — registry
  entities are untouched) and `mlflow db upgrade` (irreversible schema migration — snapshot the
  database first). A PreToolUse hook in [hooks/hooks.json](hooks/hooks.json) blocks both unless
  `MLFLOW_MAINTENANCE_ACK=yes` is set for that command, so they cannot run un-confirmed by accident.

## Requirements

- **Python ≥ 3.10** with `mlflow==3.15.1` installed in the project environment
- **bash, curl, jq** — the scripts use them
- **uv** — the serving phase uses `--env-manager uv` for fast isolated environment rebuilds
  (substitute `virtualenv` everywhere if uv is unavailable)
- **Docker + docker-compose** — for the dev tracking stack and `build-docker` serving images
- **A database + object store per shared environment** (staging/prod) — PostgreSQL/MySQL and
  S3/GCS/Azure; dev runs on the scaffolded local stack
- **The sibling `mlflow-3` skill** — phase 3 cites its rules; if it is not installed, read the
  MLflow 3 migration guide instead (the workflow still works, with more manual verification)

## Setup

`config.json` starts empty. Phase 2 fills it (tracking URIs per environment, registry namespace,
model name, serving URL). If fields are empty when a script needs them, the script says which ones —
fill them via the `_setup_instructions` in the file.

## Quick Reference

| I need to… | Go to |
|------------|-------|
| Audit what the codebase does today | `scripts/00-assess.sh <dir>` + [references/assessment.md](references/assessment.md) |
| Decide model names / aliases / gates | [references/domain-modelling.md](references/domain-modelling.md) |
| Stand up dev tracking in one command | `scripts/scaffold-dev-tracking.sh <dir>` |
| Design staging/prod tracking topology | [references/environments.md](references/environments.md) |
| Rewrite `log_model` / stages / evaluate calls | sibling `mlflow-3` rules (`log-*`, `reg-*`, `eval-*`) |
| Build the promotion pipeline | [references/promotion.md](references/promotion.md) |
| Serve and smoke-test a model | [references/serving.md](references/serving.md) |
| Check the setup actually works | `scripts/verify.sh` |
| See every phase's entry/exit criteria | [references/workflow.md](references/workflow.md) |

## Gotchas

See [gotchas.md](gotchas.md) — failure points discovered while running this workflow, including the
`migrate-filestore` SQLite-only target and the basic-auth bootstrap credentials.

## Related Skills

- `mlflow-3` — the sibling library-reference rule pack this workflow cites at every API decision
