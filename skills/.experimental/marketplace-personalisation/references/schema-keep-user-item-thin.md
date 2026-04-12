---
title: Keep User and Item Metadata Thin and Stable
impact: CRITICAL
impactDescription: prevents training-serving skew
tags: schema, stability, training-serving-skew
---

## Keep User and Item Metadata Thin and Stable

The Users and Items datasets describe attributes that "rarely or never change". If you put price, availability, last-login or session state there, the model trains on a stale snapshot — by the time it serves, the feature means something different, and you have training-serving skew that manifests as silent ranking quality drift. Volatile attributes belong in event context, not metadata.

**Incorrect (volatile fields polluting the Items dataset):**

```json
{
  "type": "record",
  "name": "Items",
  "fields": [
    { "name": "ITEM_ID", "type": "string" },
    { "name": "CATEGORY", "type": "string", "categorical": true },
    { "name": "REGION", "type": "string", "categorical": true },
    { "name": "CURRENT_PRICE", "type": "float" },
    { "name": "AVAILABLE_THIS_WEEK", "type": "boolean" },
    { "name": "LAST_BOOKED_AT", "type": "long" }
  ]
}
```

**Correct (stable attributes in metadata, volatile signals in events):**

```json
{
  "type": "record",
  "name": "Items",
  "fields": [
    { "name": "ITEM_ID", "type": "string" },
    { "name": "CATEGORY", "type": "string", "categorical": true },
    { "name": "REGION", "type": "string", "categorical": true },
    { "name": "PRICE_TIER", "type": "string", "categorical": true },
    { "name": "CREATION_TIMESTAMP", "type": "long" }
  ]
}
```

Reference: [Google — Rules of Machine Learning (Rules 29, 32: training-serving skew)](https://developers.google.com/machine-learning/guides/rules-of-ml)
