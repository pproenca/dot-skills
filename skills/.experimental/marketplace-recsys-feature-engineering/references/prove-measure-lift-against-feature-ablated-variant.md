---
title: Measure Lift Against a Feature-Ablated Variant, Not the Old Model
impact: MEDIUM
impactDescription: prevents attribution confounds from hyperparameter or data changes
tags: prove, ablation, lift, variant
---

## Measure Lift Against a Feature-Ablated Variant, Not the Old Model

A/B testing a new feature by comparing "old model" vs "new model with the feature" confounds the feature's contribution with any incidental changes in the model version — different hyperparameters, different training data window, different code path. The correct comparison is "new model with the feature" vs "new model *without* the feature", trained with identical hyperparameters on identical data, varying only the presence of the feature. This is the ablation variant, and it is the only evidence that isolates the feature's specific contribution.

**Incorrect (compares new model against old; cannot isolate the feature's effect):**

```python
# control: model_v13 (from March, trained on February data)
# treatment: model_v14 (from April, trained on March data, adds the new feature)
# result: +3% lift — but was it the feature, the fresh data, or the new hyperparameters?
```

**Correct (ablation variant: same model, feature masked):**

```python
# both variants trained this week with identical hyperparameters, identical training window
FEATURE_UNDER_TEST = "listing_pooled_embedding"

control_features = ALL_V14_FEATURES - {FEATURE_UNDER_TEST}
treatment_features = ALL_V14_FEATURES

control_model = train_model(feature_set=control_features, seed=42, **v14_hparams)
treatment_model = train_model(feature_set=treatment_features, seed=42, **v14_hparams)

run_ab_test(
    experiment="listing_pooled_embedding_ablation",
    control=control_model,
    treatment=treatment_model,
    # any lift is attributable to the feature, not to training data or hyperparameter drift
)
```

Reference: [Kohavi — Trustworthy Online Controlled Experiments](https://experimentguide.com/)
