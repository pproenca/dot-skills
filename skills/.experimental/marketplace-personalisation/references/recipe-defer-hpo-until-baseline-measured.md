---
title: Defer HPO Until the Baseline Is Measured
impact: MEDIUM
impactDescription: prevents wasted training spend
tags: recipe, hpo, cost-control
---

## Defer HPO Until the Baseline Is Measured

Hyperparameter optimisation multiplies training cost and duration, so it is only justifiable after a default-hyperparameter baseline has demonstrated lift over the popularity baseline on online metrics. Running HPO before the baseline exists optimises a model you have not yet proven is worth deploying, and spends budget that would be better used on instrumentation or richer metadata. The correct order is: popularity baseline → default-hyperparameter ML → HPO only if the ML baseline is beaten and further tuning is warranted.

**Incorrect (HPO enabled on the first solution version):**

```python
personalize.create_solution(
    name="homefeed-v1-hpo",
    datasetGroupArn=DATASET_GROUP_ARN,
    recipeArn="arn:aws:personalize:::recipe/aws-user-personalization-v2",
    performHPO=True,
    solutionConfig={
        "hpoConfig": {
            "algorithmHyperParameterRanges": {
                "integerHyperParameterRanges": [
                    {"name": "bptt", "minValue": 20, "maxValue": 40},
                ],
            },
        },
    },
)
```

**Correct (default hyperparameters first, HPO deferred to a later iteration):**

```python
personalize.create_solution(
    name="homefeed-v1",
    datasetGroupArn=DATASET_GROUP_ARN,
    recipeArn="arn:aws:personalize:::recipe/aws-user-personalization-v2",
    performHPO=False,
)
```

Reference: [Amazon Personalize Cheat Sheet — Premature HPO Pitfall](https://github.com/aws-samples/amazon-personalize-samples/blob/master/PersonalizeCheatSheet2.0.md)
