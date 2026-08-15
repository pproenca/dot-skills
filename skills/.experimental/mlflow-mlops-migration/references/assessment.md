# Phase 0 — Reading the Assessment Report

`scripts/00-assess.sh <codebase-dir>` writes `mlflow-assessment.md`. It is a grep census, not a
verdict — its job is to make the phase-1 interview concrete. How to read each section, and the
questions each one should trigger with the developer:

## 1. ML frameworks in use

Determines which MLflow flavors phase 3 uses (`mlflow.sklearn`, `mlflow.pytorch`, …) and which
serialization-default changes apply (sklearn/lightgbm → skops, pytorch → torch.export,
xgboost → UBJSON). Multiple frameworks usually means multiple registered models — feed that into
domain modelling rather than assuming one model.

**Ask:** "Which of these are production models vs experiments someone abandoned?"

## 2. Existing MLflow usage

- **Zero hits:** greenfield — often *easier* than a partial MLflow 2 setup, because there is
  nothing to migrate and no `./mlruns` history to preserve. Phase 3 instruments from scratch.
- **Hits without registry usage:** tracking-only adoption; the registry, promotion, and serving
  phases are all new ground for this team — budget more interview time in phase 1.
- **Registry hits:** look carefully at section 3 — stage-based promotion is almost certainly
  present and is the highest-effort part of the migration.

## 3. MLflow 2-era idioms

Each subsection header names the sibling `mlflow-3` rule that phase 3 applies to those hits.
Counts here size the phase-3 effort. Two hits deserve special attention:

- **Stage-based URIs / `transition_model_version_stage`:** these encode the team's *current*
  promotion process. Before rewriting them, extract what the process actually is (who promotes,
  on what evidence) — that is phase-1 input, not just code to fix.
- **MLflow Recipes:** removed entirely in MLflow 3 — this is a re-architecture of those
  pipelines, not a rename. Scope it explicitly with the user; it may deserve its own project.

## 4. Model shipping outside MLflow

`joblib.load` / `pickle.load` hits are the hidden consumers that break after phase 3 (see
../gotchas.md on skops). Hand-rolled Flask/FastAPI serving apps are candidates for replacement by
the scoring server in phase 5 — or, when they contain real business logic beyond `predict`, for
keeping and re-pointing at `mlflow.pyfunc.load_model("models:/…@champion")`.

**Ask:** "Who consumes the model file today, and how do they find out a new one exists?" The
answer is the current promotion process in disguise.

## 5. Environment management

- `uv.lock` / `poetry.lock` present: dependency pinning is healthy; MLflow 3 captures uv
  lockfiles automatically at log time.
- Only a loose `requirements.txt` (or nothing): expect `mlflow.models.predict` to fail on the
  first phase-5 attempt — that failure is the feature; fix pins at log time.
- Existing `mlruns/` or `mlflow.db`: legacy data. Decide in phase 2 — migrate
  (`mlflow migrate-filestore`, SQLite target only) or abandon consciously. Abandoning history is
  often fine; ask the team what they'd actually miss.

## Output of this phase

Not a document — a shared understanding, plus corrections. The greps can't see training runs
launched from notebooks, cron jobs on other machines, or models trained elsewhere and copied in.
Ask for each, and append what you learn to the report by hand before phase 1.
