# Phase 5 — Serving

Order matters here: validate the environment before serving anything, serve locally before
building images, smoke-test before pointing consumers. Serving always loads through an alias
(`models:/<name>@champion`) so phase 4's alias flip is the deployment mechanism.

## 1. Validate the model's environment

```python
import mlflow

mlflow.models.predict(
    model_uri="models:/staging.growth.churn_classifier@candidate",
    input_data=holdout_df.head(5),
    env_manager="uv",
)
```

This rebuilds the environment from the model's generated requirement files and runs the same
pyfunc path the scoring server uses. A failure here is a *logging* problem — fix pins with the
sibling `env-*` rules and re-log the model; do not proceed to serving and patch containers.

## 2. Serve locally (dev / debugging)

```bash
mlflow models serve \
  -m "models:/dev.growth.churn_classifier@candidate" \
  -p 5001 --env-manager uv
```

The built-in FastAPI scoring server is the only backend (MLServer and Flask/gunicorn are gone —
sibling rule `serve-fastapi-scoring-server-only`).

## 3. Smoke-test /invocations

Health first, then a real domain payload under the documented keys (`dataframe_split`,
`dataframe_records`, `inputs`, `instances`; `params` only if the signature declares them):

```bash
curl -fsS localhost:5001/ping
curl -s localhost:5001/invocations -H 'Content-Type: application/json' -d '{
  "dataframe_split": {
    "columns": ["tenure_months", "monthly_charges", "contract_type"],
    "data": [[34, 56.95, "month-to-month"]]
  }
}'
```

Assert on the *response body shape* (a `predictions` array of the expected length and type), not
just the 200 — a model serving the wrong signature can still answer 200. Keep this payload in the
repo (e.g. `smoke/invocations.json`) so `verify.sh`'s serving note and CI use the same one.

## 4. Container images for staging/prod

```bash
mlflow models build-docker \
  --model-uri "models:/prod.growth.churn_classifier@champion" \
  --name registry.internal.example.com/ml/churn-classifier:v<version> \
  --env-manager uv
```

- The image serves on **port 8080** (nginx + uvicorn inside; `MLFLOW_MODELS_WORKERS` to scale
  workers, `DISABLE_NGINX=true` where an ingress already terminates).
- Tag images with the resolved model *version*, not the alias — the alias moves; the image is
  immutable. The alias-to-version resolution happens at build time, so an alias flip means a
  rebuild+redeploy (that's the deploy pipeline), or alternatively run a thin service that loads
  `models:/…@champion` at startup and restart it to pick up flips. Pick one mechanism and write
  it down; mixing both makes "what is prod running?" unanswerable.
- Deploy to any container platform. The MLflow Helm chart is *not* for this — it deploys the
  tracking server.
- Managed alternatives (SageMaker, AzureML) exist behind `mlflow deployments` — out of this
  workflow's scope; the registry/alias structure above transfers unchanged.

## Exit criteria

`scripts/verify.sh <env>` passes including `/ping` and `/version`; the smoke payload returns
correct-shaped predictions; a deliberate alias flip + redeploy demonstrably changes the served
version (check `/version` won't tell you — log the model version at startup or expose it in a
response header from your deploy pipeline).
