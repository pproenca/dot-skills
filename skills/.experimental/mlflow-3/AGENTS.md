# MLflow 3 (open-source)

**Version 0.1.0**  
dot-skills  
August 2026

---

## Abstract

Library-reference skill for open-source MLflow 3, scoped to classic-ML MLOps. 24 rules across 6 categories covering the decisions where MLflow 3 broke with the MLflow 2 idioms a model produces by default: named LoggedModels instead of run-artifact models, registry aliases and copy_model_version instead of stages, database tracking backends instead of ./mlruns, the FastAPI scoring server instead of MLServer/Flask, the split evaluate APIs with explicit threshold gates, and skops/torch.export serialization. Pinned to mlflow 3.15.1; API claims verified against the unpacked mlflow and mlflow-skinny wheels.

---

## Table of Contents

1. [Model Logging & LoggedModel](references/_sections.md#1-model-logging-&-loggedmodel)
   - 1.1 [Expect skops and torch.export defaults, not pickle](references/log-serialization-defaults-changed.md)
   - 1.2 [Link metrics to models and search logged models](references/log-link-metrics-search-models.md)
   - 1.3 [Log models with name, not artifact_path](references/log-name-not-artifact-path.md)
   - 1.4 [Pass an input example and let the signature infer](references/log-input-example-infers-signature.md)
   - 1.5 [Register at log time through the model URI](references/log-register-at-log-time.md)
   - 1.6 [Treat logged models as entities, not run artifacts](references/log-models-are-not-run-artifacts.md)
2. [Model Registry & Promotion](references/_sections.md#2-model-registry-&-promotion)
   - 2.1 [Create one registered model per environment](references/reg-per-environment-registered-models.md)
   - 2.2 [Promote with aliases, not registry stages](references/reg-aliases-not-stages.md)
   - 2.3 [Resolve versions by alias, not get_latest_versions](references/reg-resolve-by-alias-not-latest-versions.md)
   - 2.4 [Track approval gates with model version tags](references/reg-gate-state-in-tags.md)
   - 2.5 [Use registry webhooks for CI triggers in OSS MLflow](references/reg-webhooks-oss-deployment-jobs-not.md)
3. [Tracking Backend & Server](references/_sections.md#3-tracking-backend-&-server)
   - 3.1 [Disable telemetry deliberately in production images](references/track-telemetry-on-by-default.md)
   - 3.2 [Expect sqlite as the local default, not mlruns](references/track-default-is-sqlite-not-mlruns.md)
   - 3.3 [Point clients at one tracking URI with proxied artifacts](references/track-proxied-artifacts-one-credential.md)
   - 3.4 [Run the tracking server on a database, never the file store](references/track-server-needs-database-backend.md)
   - 3.5 [Turn on input examples when autologging](references/track-autolog-input-examples-off.md)
4. [Serving](references/_sections.md#4-serving)
   - 4.1 [Build serving images with build-docker for clusters](references/serve-build-docker-for-clusters.md)
   - 4.2 [Send invocations payloads under the documented keys](references/serve-invocations-payload-keys.md)
   - 4.3 [Serve with the built-in FastAPI scoring server](references/serve-fastapi-scoring-server-only.md)
   - 4.4 [Validate with mlflow.models.predict before deploying](references/serve-predict-before-deploy.md)
5. [Evaluation & Gates](references/_sections.md#5-evaluation-&-gates)
   - 5.1 [Evaluate classic models with mlflow.models.evaluate](references/eval-models-evaluate-split.md)
   - 5.2 [Gate promotions with validate_evaluation_results](references/eval-gate-with-validate-evaluation-results.md)
6. [Environment & Reproducibility](references/_sections.md#6-environment-&-reproducibility)
   - 6.1 [Bundle custom code with code_paths or infer_code_paths](references/env-bundle-custom-code-paths.md)
   - 6.2 [Pin dependencies through the generated environment files](references/env-generated-files-drive-serving.md)

---

## References

1. [https://mlflow.org/docs/latest/ml/mlflow-3/](https://mlflow.org/docs/latest/ml/mlflow-3/)
2. [https://mlflow.org/docs/latest/ml/model-registry/](https://mlflow.org/docs/latest/ml/model-registry/)
3. [https://mlflow.org/docs/latest/ml/model-registry/workflow/](https://mlflow.org/docs/latest/ml/model-registry/workflow/)
4. [https://mlflow.org/docs/latest/self-hosting/architecture/overview/](https://mlflow.org/docs/latest/self-hosting/architecture/overview/)
5. [https://mlflow.org/docs/latest/self-hosting/architecture/backend-store/](https://mlflow.org/docs/latest/self-hosting/architecture/backend-store/)
6. [https://mlflow.org/docs/latest/self-hosting/architecture/artifact-store/](https://mlflow.org/docs/latest/self-hosting/architecture/artifact-store/)
7. [https://mlflow.org/docs/latest/self-hosting/migrate-from-file-store](https://mlflow.org/docs/latest/self-hosting/migrate-from-file-store)
8. [https://mlflow.org/docs/latest/self-hosting/kubernetes-helm/](https://mlflow.org/docs/latest/self-hosting/kubernetes-helm/)
9. [https://mlflow.org/docs/latest/ml/deployment/](https://mlflow.org/docs/latest/ml/deployment/)
10. [https://mlflow.org/docs/latest/ml/deployment/deploy-model-locally/](https://mlflow.org/docs/latest/ml/deployment/deploy-model-locally/)
11. [https://mlflow.org/docs/latest/ml/model/signatures/](https://mlflow.org/docs/latest/ml/model/signatures/)
12. [https://mlflow.org/docs/latest/ml/model/dependencies/](https://mlflow.org/docs/latest/ml/model/dependencies/)
13. [https://mlflow.org/docs/latest/community/usage-tracking/](https://mlflow.org/docs/latest/community/usage-tracking/)
14. [https://mlflow.org/docs/latest/api_reference/python_api/mlflow.html](https://mlflow.org/docs/latest/api_reference/python_api/mlflow.html)
15. [https://github.com/mlflow/mlflow/blob/v3.15.1/CHANGELOG.md](https://github.com/mlflow/mlflow/blob/v3.15.1/CHANGELOG.md)
16. [https://github.com/mlflow/mlflow/releases/tag/v3.15.0](https://github.com/mlflow/mlflow/releases/tag/v3.15.0)
17. [https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/models/model.py](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/models/model.py)
18. [https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/tracking/client.py](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/tracking/client.py)
19. [https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/tracking/fluent.py](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/tracking/fluent.py)
20. [https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/sklearn/__init__.py](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/sklearn/__init__.py)
21. [https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/store/tracking/file_store.py](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/store/tracking/file_store.py)
22. [https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/models/python_api.py](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/models/python_api.py)
23. [https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/environment_variables.py](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/environment_variables.py)
24. [https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/pyfunc/__init__.py](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/pyfunc/__init__.py)
25. [https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/models/evaluation/deprecated.py](https://github.com/mlflow/mlflow/blob/v3.15.1/mlflow/models/evaluation/deprecated.py)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |