---
title: Prefer Categorical Fields over Free Text
impact: HIGH
impactDescription: enables per-value learned features
tags: schema, categorical, features
---

## Prefer Categorical Fields over Free Text

Personalize treats categorical fields as first-class features — it learns an embedding per value and uses them in ranking. Free-text fields are processed by a single unstructured text column and are far less discriminative. For attributes with a bounded vocabulary (region, price tier, listing type, verification status), declare them categorical so the model can learn preferences per value.

**Incorrect (free text for attributes that belong in categories):**

```json
{
  "type": "record",
  "name": "Items",
  "fields": [
    { "name": "ITEM_ID", "type": "string" },
    { "name": "REGION", "type": "string" },
    { "name": "PRICE_TIER", "type": "string" },
    { "name": "VERIFICATION", "type": "string" }
  ]
}
```

**Correct (categorical declaration unlocks per-value features):**

```json
{
  "type": "record",
  "name": "Items",
  "fields": [
    { "name": "ITEM_ID", "type": "string" },
    { "name": "REGION", "type": "string", "categorical": true },
    { "name": "PRICE_TIER", "type": "string", "categorical": true },
    { "name": "VERIFICATION", "type": "string", "categorical": true },
    { "name": "DESCRIPTION", "type": "string", "textual": true }
  ]
}
```

Reference: [AWS Personalize — Items Dataset Schema Requirements](https://docs.aws.amazon.com/personalize/latest/dg/item-dataset-requirements.html)
