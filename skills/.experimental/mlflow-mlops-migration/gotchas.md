# Gotchas

Failure points discovered while running this workflow. Append new ones with dates — this is the
highest-signal file in the skill.

## `mlflow migrate-filestore` only targets SQLite

The migration command's `--target` must be a `sqlite:///` URI — it refuses PostgreSQL/MySQL
outright. Migrating a legacy `./mlruns` directory to a production Postgres backend is therefore
two steps: `mlflow migrate-filestore --source ./mlruns --target sqlite:///mlflow.db`, then move
the SQLite contents to Postgres with a generic DB migration tool, or accept SQLite where the data
only needs to be readable.
Added: 2026-08-15

## Basic-auth bootstrap credentials and required secret key

`mlflow server --app-name basic-auth` will not start without `MLFLOW_FLASK_SERVER_SECRET_KEY`
set, and it creates a default admin user (`admin` / `password1234`) on first boot. Change that
password immediately after the first start — before handing the URL to anyone — and store the
admin credentials outside the repo. Clients authenticate via `MLFLOW_TRACKING_USERNAME` /
`MLFLOW_TRACKING_PASSWORD`.
Added: 2026-08-15

## Phase-3 refactors surface hidden serialization consumers

Codebases that shipped models by copying pickle files often have consumers that `joblib.load`
the artifact directly. After restructuring to MLflow 3 logging, sklearn/lightgbm artifacts are
skops (not cloudpickle) since 3.14, so those side-loaders break even though training is green.
The phase-0 assessment greps for `joblib.load`/`pickle.load` precisely to find them early —
migrate consumers to `mlflow.pyfunc.load_model` in phase 3, not after serving fails.
Added: 2026-08-15
