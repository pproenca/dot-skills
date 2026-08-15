# Phase 4 — Evaluation-Gated Promotion

The promotion pipeline is one repeatable script/CI job per hop (dev→staging, staging→prod), each
with the same five steps. Aliases carry deployment state, tags carry gate state, and
`copy_model_version` is the only way a version crosses environments. API details live in the
sibling `mlflow-3` rules (`reg-*`, `eval-*`); this file is the composition.

## The five steps (per hop)

```python
import mlflow
from mlflow import MlflowClient
from mlflow.models import MetricThreshold

client = MlflowClient()
SRC = "staging.growth.churn_classifier"
DST = "prod.growth.churn_classifier"

# 1. Resolve the candidate (never "latest" — an assigned alias or explicit version)
candidate = client.get_model_version_by_alias(SRC, "candidate")
candidate_uri = f"models:/{SRC}/{candidate.version}"

# 2. Evaluate the candidate — and the current champion, if one exists yet.
#    The very first promotion into DST has no champion; resolving the alias raises.
cand_res = mlflow.models.evaluate(model=candidate_uri, data=holdout_df,
                                  targets="churned", model_type="classifier")
try:
    champ = client.get_model_version_by_alias(DST, "champion")
except mlflow.exceptions.MlflowException:
    champ = None
champ_res = None
if champ is not None:
    champ_res = mlflow.models.evaluate(model=f"models:/{DST}/{champ.version}", data=holdout_df,
                                       targets="churned", model_type="classifier")

# 3. Gate — raises ModelValidationFailedException on failure, which fails the CI job.
#    With a champion: require improvement. Without one: absolute floor only.
if champ_res is not None:
    thresholds = {"f1_score": MetricThreshold(min_absolute_change=0.01, greater_is_better=True)}
else:
    thresholds = {"f1_score": MetricThreshold(threshold=0.80, greater_is_better=True)}
mlflow.validate_evaluation_results(
    validation_thresholds=thresholds,
    candidate_result=cand_res,
    baseline_result=champ_res,
)

# 4. Record the verdict, then copy across the environment boundary
client.set_model_version_tag(SRC, candidate.version, "validation_status", "approved")
promoted = client.copy_model_version(src_model_uri=f"models:/{SRC}/{candidate.version}",
                                     dst_name=DST)

# 5. Flip the pointer — this IS the deploy for anything loading models:/DST@champion
client.set_registered_model_alias(DST, "champion", promoted.version)
```

Numbers, dataset, and model names come from the phase-1 domain doc — never invent thresholds in
the pipeline code.

## Shape per hop

- **dev → staging:** steps 1–4 fully automatic on each candidate; the *first* version has no
  champion to beat — gate on absolute thresholds (`MetricThreshold(threshold=…)`) instead of
  improvement.
- **staging → prod:** insert the human where phase 1 said so — typically between 4 and 5: the
  pipeline copies and tags, a person flips the alias (or approves the CI stage that does).
  Champion alias flips in prod are the one promotion step this skill always confirms with the
  user before executing.

## Rollback

Rollback is an alias flip back to the previous version — no artifacts move:

```python
client.set_registered_model_alias(DST, "champion", previous_champion_version)
```

Record the outgoing champion's version in the pipeline log (or a `previous_champion` tag on the
registered model) *before* step 5, or rollback becomes an archaeology exercise mid-incident.

## Triggering

- **Simplest (start here):** the promotion job runs on a schedule or manually after training.
- **Event-driven:** OSS registry webhooks (≥3.3) fire on `model_version.created`,
  `model_version_tag.set`, `model_version_alias.created` — point them at CI to chain
  train → gate → promote without polling. Verify delivery with the HMAC secret; webhook CRUD
  needs an admin account.

## Failure modes

- **Gate fails:** working as designed; candidate keeps `validation_status: rejected` and stays
  put. Nothing to clean up.
- **Crash between copy (4) and alias flip (5):** the copied version exists in DST with no alias —
  harmless. Re-running the pipeline copies again, producing a duplicate version; prefer resuming
  at step 5 with the already-copied version, and delete duplicates through the UI only.
- **Evaluation dataset drift:** if the holdout changes, champion and candidate must both be
  re-evaluated on the new data — comparing metrics measured on different datasets is the classic
  silent gate corruption.
