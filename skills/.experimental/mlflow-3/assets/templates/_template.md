---
title: Rule Title Here
tags: prefix, concept, concept
---

## Rule Title Here

Name the wrong default this rule corrects and its concrete consequence, in 1-3
sentences. For this skill that usually means naming the MLflow 2-era idiom the
model reproduces and what MLflow 3 does instead — the model generalizes from the
reason, not the instruction. Don't restate something the model already does
correctly, and verify every API claim against the pinned mlflow wheel before
adding a rule.

```python
import mlflow

model_info = mlflow.sklearn.log_model(
    churn_model,
    name="churn_classifier",
    input_example=X_sample,
)
```

Reference: [Source title](https://mlflow.org/docs/latest/)

<!-- Add an **Incorrect (…):** / **Correct (…):** pair ONLY when the wrong way is
     a genuine, common trap. Keep the diff minimal. A strawman foil is worse than
     a single good example. -->
