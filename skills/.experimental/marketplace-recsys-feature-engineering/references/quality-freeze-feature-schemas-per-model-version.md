---
title: Freeze Feature Schemas per Model Version
impact: MEDIUM-HIGH
impactDescription: prevents mid-flight schema drift from silently retraining the wrong model
tags: quality, schema, versioning, model-version, immutability
---

## Freeze Feature Schemas per Model Version

Changing a feature's dtype, adding a new categorical value, or renaming a field mid-flight breaks the training-serving contract silently — the serving path keeps working on old inputs while the next training run sees the new schema and learns different weights. Freeze the feature schema per deployed model version: record the schema hash at training time, store it with the model artifact, and refuse to deploy a model whose schema hash does not match the current feature store state. Schema changes get a new model version; they never retroactively modify an existing one.

**Incorrect (schema changes ripple into deployed models):**

```python
# deployed model v14 was trained on amenity_vocab_v1 (50 items)
# someone adds a new amenity "ev_charger" — feature store now produces 51-dim multi-hot
# model v14 receives 51-dim input, silently truncates or errors
AMENITY_VOCAB.append("ev_charger")  # no version bump
```

**Correct (schema is pinned to the model version):**

```python
@dataclass(frozen=True)
class FeatureSchema:
    name: str
    dtype: str
    vocab_hash: str | None = None  # for categorical/multi-hot
    version: str = "v1"

AMENITY_SCHEMA_V1 = FeatureSchema(
    name="listing_amenities",
    dtype="multi_hot_50",
    vocab_hash="a1b2c3d4",  # sha1 of sorted(vocab)
    version="v1",
)

def train_model(features: dict[str, FeatureSchema]) -> Model:
    model = train(...)
    model.schema_hashes = {name: schema.vocab_hash for name, schema in features.items()}
    return model

def deploy_model(model: Model) -> None:
    for name, expected_hash in model.schema_hashes.items():
        current_hash = feature_registry.get(name).vocab_hash
        if current_hash != expected_hash:
            raise DeployError(
                f"{name} schema changed ({expected_hash} → {current_hash}); train a new model version"
            )
    deploy_to_production(model)
```

Reference: [Uber — Evolving Michelangelo Model Representation for Flexibility at Scale](https://www.uber.com/us/en/blog/michelangelo-machine-learning-model-representation/)
