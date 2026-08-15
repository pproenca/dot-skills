# Phase 2 — Tracking Infrastructure per Environment

Goal: a reachable tracking server per environment tier, all on database backends, with clients
holding exactly one setting (`MLFLOW_TRACKING_URI`). The topology mirrors production semantics
at every tier so nothing about MLflow changes between a laptop and prod except scale and auth.

## Decide: how many servers?

| Setup | When | Environment separation via |
|-------|------|---------------------------|
| One shared server | Small team, one trust domain | Per-env registered-model names (`dev.*`/`prod.*`) + auth permissions |
| Server per env | Different trust domains / networks (typical prod) | Network + separate backing stores; names stay per-env anyway |

Either is legitimate; per-env *names* are used in both, so the choice is reversible later. When
in doubt: one server now, split when prod gets its own network. (MLflow ≥3.10 also has server-side
Workspaces for logical isolation on one server — consider it only if the team already runs
multi-tenant.)

## Dev

`scripts/scaffold-dev-tracking.sh <repo-root>` writes `docker-compose.mlflow-dev.yml` — Postgres
backend + MLflow 3.15.1 server with proxied artifacts on a local volume. Confirm with the user,
then:

```bash
docker compose -f docker-compose.mlflow-dev.yml up -d
export MLFLOW_TRACKING_URI=http://localhost:5000
bash scripts/verify.sh dev   # tracking assertion should pass
```

Why not zero-infra local tracking (`sqlite:///mlflow.db`, no server)? It works, and it's fine for
a solo spike — but the migration's point is one workflow across all tiers, and the compose stack
costs minutes. Solo developers can still start with plain SQLite and adopt the stack when the
registry phases begin.

## Staging and prod

The same shape, production-grade parts:

```bash
mlflow server \
  --backend-store-uri postgresql+psycopg2://mlflow:<password>@<db-host>/mlflow \
  --artifacts-destination s3://<bucket>/mlflow \
  --host 0.0.0.0 --port 5000 --workers 4 \
  --app-name basic-auth \
  --allowed-hosts mlflow.internal.example.com \
  --cors-allowed-origins https://mlflow.internal.example.com
```

`--allowed-hosts` / `--cors-allowed-origins` are not optional decoration: the 3.x security
middleware defaults to a localhost + private-IP allowlist, so a server reached by hostname
rejects every request with `403 Invalid Host header` — while `/health` (exempt from the check)
still returns 200. List every DNS name clients will use.

- **Backend store:** PostgreSQL (or MySQL). The server refuses file stores since 3.13 — that
  refusal is protecting you; never override it for a shared server.
- **Artifacts:** `--artifacts-destination` + default proxying means only the server holds object
  store credentials. Clients never see S3 keys.
- **Auth:** `pip install mlflow[auth]`, set `MLFLOW_FLASK_SERVER_SECRET_KEY`, start with
  `--app-name basic-auth`, then immediately rotate the bootstrap admin credentials (see
  ../gotchas.md). Map the phase-1 "who may promote" answers to permissions — grants bind to
  individual registered-model names (OSS auth has no glob patterns), so give humans READ and the
  promotion pipeline's service account EDIT on each `prod.`-named model.
- **Kubernetes:** the official Helm chart (`oci://ghcr.io/mlflow/charts/mlflow`) deploys exactly
  this shape — use it instead of hand-rolling manifests. It deploys the *tracking server*; model
  serving is phase 5's `build-docker` images.
- **Telemetry:** set `MLFLOW_DISABLE_TELEMETRY=true` in server and job images if the org requires
  it (on by default since 3.2).

Pin `mlflow==3.15.1` everywhere — server, training env, CI, serving images — and upgrade them
together (`mlflow db upgrade` per backend, staging before prod, DB snapshot first).

## Legacy data

Existing `./mlruns` directories (phase-0 report, section 5): decide per the "what history
matters" answer from phase 1.

- **Migrate:** `mlflow migrate-filestore --source ./mlruns --target sqlite:///mlflow.db`. The
  target is SQLite *only* — reaching Postgres is a second, generic DB migration (../gotchas.md).
- **Abandon:** archive the directory (`tar` it into cold storage) and start clean. For most teams
  the old runs are never looked at again — say so out loud and let the team decide.

## Exit criteria

`scripts/verify.sh <env>` passes both tracking assertions — `/health` *and* the authenticated
API call, which is the one that catches a missing `--allowed-hosts` or broken auth — for every
environment stood up, from a machine that reaches the server the way real clients will (by
hostname, not localhost); `config.json` URIs filled; legacy data migrated or consciously
archived; auth verified by logging in as a non-admin user.
