---
title: Send invocations payloads under the documented keys
tags: serve, invocations, payload, rest-api
---

## Send invocations payloads under the documented keys

Clients written from MLflow 1.x/early-2.x memory post bare JSON records or the old `{"columns": [...], "data": [...]}` shape to `/invocations` — both are rejected. JSON requests must use one of four wrapper keys — `dataframe_split`, `dataframe_records`, `inputs` (tensor), `instances` (TF-serving style) — plus an optional `params` object, and the subtle half is that `params` is silently ignored unless the model's signature declares a params schema. (CSV and Parquet bodies are also accepted under their content types.) Health checks belong on `GET /ping` (or `/health`), and `GET /version` reports the serving MLflow version.

```bash
curl -s http://serving.internal.example.com:5001/invocations \
  -H 'Content-Type: application/json' \
  -d '{
    "dataframe_split": {
      "columns": ["tenure_months", "monthly_charges", "contract_type"],
      "data": [[34, 56.95, "month-to-month"]]
    },
    "params": {"threshold": 0.35}
  }'
```

Reference: [Deploy model locally — JSON input formats](https://mlflow.org/docs/latest/ml/deployment/deploy-model-locally/)
