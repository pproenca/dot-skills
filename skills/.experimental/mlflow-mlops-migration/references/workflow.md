# Workflow — Phases, Gates, Error Handling

The master sequence. Each phase lists entry criteria, actions, exit criteria, and what to do on
failure. Never skip ahead: phases 0–1 are read-only and produce the documents every later phase
consumes; the cost of skipping them is rework in every phase after.

## Phase 0 — Assess (read-only)

- **Entry:** access to the codebase; nothing else.
- **Action:** `scripts/00-assess.sh <codebase-dir>`; walk the report with the developer
  ([assessment.md](assessment.md) explains how to read each section).
- **Exit:** `mlflow-assessment.md` reviewed; the developer agrees it reflects reality (they know
  about training entrypoints the greps can't see — ask).
- **On failure:** none possible — the script only reads.

## Phase 1 — Domain modelling (read-only)

- **Entry:** phase 0 report in hand.
- **Action:** interview per [domain-modelling.md](domain-modelling.md); write the registry domain
  doc (model names, experiments, aliases, gate metrics and thresholds).
- **Exit:** the domain doc names every model as `<env>.<namespace>.<name>`, every alias, and every
  gate with a numeric threshold; `registry_namespace`, `model_name`, `experiment_name` filled in
  `config.json`.
- **On failure:** if the team can't name a gate metric yet, record the gate as "manual approval"
  explicitly — an undefined gate defaults to no gate, silently.

## Phase 2 — Environments (write; confirm before starting services)

- **Entry:** domain doc approved.
- **Action:** per [environments.md](environments.md) — dev via `scripts/scaffold-dev-tracking.sh`,
  staging/prod as database + object store + auth. Fill the remaining `config.json` URIs.
- **Exit:** `scripts/verify.sh dev` passes its tracking-server assertion (and per environment as
  each comes up). Legacy `./mlruns` data migrated or consciously abandoned.
- **On failure:** the compose stack not starting is almost always a port-5000 collision or Docker
  not running — nothing here mutates the codebase, so tear down (`docker compose down`) and retry
  freely. Never point a shared server at a file store; the server refuses it for a reason.

## Phase 3 — Instrument (write; confirm before rewriting entrypoints)

- **Entry:** dev tracking reachable; MLflow 3.15.1 installed in the project env.
- **Action:** restructure training code to MLflow 3 idioms. Work from the assessment report's
  "MLflow 2-era idioms" section — each hit names the sibling `mlflow-3` rule to apply (`log-*` for
  logging, `reg-*` for registry calls, `eval-*` for evaluation). Minimum bar for each training
  entrypoint: set experiment, log params/metrics, `log_model` with `name=` and `input_example=`,
  register as `dev.<namespace>.<name>`. Migrate any direct pickle/joblib consumers found in
  phase 0 to `mlflow.pyfunc.load_model` (see ../gotchas.md on skops).
- **Exit:** a full training run against dev tracking produces a registered version, and
  `scripts/verify.sh dev` passes the experiment + registered-model assertions. Training still
  produces the same model quality as before the refactor (compare metrics).
- **On failure:** revert per file — instrument one entrypoint end-to-end before touching the next,
  so a broken refactor never spans the codebase.

## Phase 4 — Promotion (write; confirm before prod champion flips)

- **Entry:** dev registers versions reliably; gates defined in the domain doc.
- **Action:** build the promotion pipeline per [promotion.md](promotion.md): evaluate → threshold
  gate → `validation_status` tag → `copy_model_version` to the next environment → alias flip.
- **Exit:** one candidate has traveled dev → staging via the pipeline (not by hand), and
  `scripts/verify.sh staging` passes.
- **On failure:** a failed gate is the pipeline working, not failing — the candidate stays where
  it is. Pipeline bugs: fix and re-run steps 1–3 freely; the copy step is **not** idempotent
  (each re-copy mints a new version), so after a crash resume at the alias flip with the
  already-copied version — see promotion.md's failure modes — and clean up duplicate versions
  through the registry UI only, don't script deletion.

## Phase 5 — Serve (write; confirm before exposing endpoints)

- **Entry:** staging holds an aliased, gate-approved version.
- **Action:** per [serving.md](serving.md): `mlflow.models.predict` first, then serve locally,
  then `build-docker` for shared environments; smoke-test `/invocations` with a domain payload.
- **Exit:** `scripts/verify.sh <env>` passes including the serving assertions; an alias flip
  changes what the endpoint serves after restart/redeploy.
- **On failure:** environment-rebuild failures at `mlflow.models.predict` are the point of running
  it — fix dependency pinning at log time (sibling `env-*` rules) and re-log; don't patch the
  container by hand, the next build loses the patch.

## Phase 6 — Operate (ongoing)

The steady-state loop once phases 0–5 are done:

- **Retrain** on schedule or drift signal → new version in `dev.*` → the phase-4 pipeline carries
  it forward. Retraining reuses the same entrypoints phase 3 instrumented — if a retrain needs
  manual steps, that's a phase-3 gap to fix.
- **Challenger evaluation:** register the candidate under `@challenger` alongside `@champion`,
  compare on live or holdout data, flip aliases when the challenger wins (see promotion.md).
- **Maintenance (destructive — explicit user confirmation + stated reason, every time; the
  PreToolUse hook blocks both commands unless `MLFLOW_MAINTENANCE_ACK=yes`):**
  - `mlflow gc` permanently deletes soft-deleted runs and experiments (registry entities are
    untouched). Confirm scope first with a dry look at what's deleted in the UI.
  - `mlflow db upgrade <uri>` after upgrading the mlflow package — snapshot the database before,
    upgrade staging before prod.
- **Watch:** server disk/DB growth (artifacts accumulate per version), and pin the mlflow version
  in training, server, and serving images to move in lockstep — client/server skew across a major
  version is unsupported territory.
