---
title: Design Schemas Conservatively Because They Are Immutable
impact: CRITICAL
impactDescription: avoids full dataset rebuild
tags: schema, immutability, dataset-group
---

## Design Schemas Conservatively Because They Are Immutable

The Interactions dataset schema cannot be altered after creation — adding a field forces you to create a new dataset group and re-import every historical interaction. Users and Items datasets do support schema replacement to add nullable fields, but every added field still costs a full re-import of that dataset. This makes schema design a lifetime commitment for the Interactions table and a painful migration for Users/Items: add only fields that are stable, predictive and worth months of production history. Volatile or speculative fields belong in event properties, not the schema.

**Incorrect (speculative fields that will be churned within a month):**

```json
{
  "type": "record",
  "name": "Interactions",
  "fields": [
    { "name": "USER_ID", "type": "string" },
    { "name": "ITEM_ID", "type": "string" },
    { "name": "TIMESTAMP", "type": "long" },
    { "name": "EVENT_TYPE", "type": "string" },
    { "name": "EXPERIMENT_BUCKET", "type": "string" },
    { "name": "PROMO_CAMPAIGN_ID", "type": ["null", "string"] },
    { "name": "UI_VARIANT", "type": "string" }
  ]
}
```

**Correct (only stable, predictive fields in the schema):**

```json
{
  "type": "record",
  "name": "Interactions",
  "fields": [
    { "name": "USER_ID", "type": "string" },
    { "name": "ITEM_ID", "type": "string" },
    { "name": "TIMESTAMP", "type": "long" },
    { "name": "EVENT_TYPE", "type": "string" },
    { "name": "EVENT_VALUE", "type": ["null", "float"] },
    { "name": "SURFACE", "type": "string", "categorical": true },
    { "name": "DEVICE", "type": "string", "categorical": true }
  ]
}
```

Reference: [AWS Personalize — Custom Datasets and Schemas](https://docs.aws.amazon.com/personalize/latest/dg/custom-datasets-and-schemas.html) · [AWS Personalize — Replacing a Dataset's Schema to Add New Columns](https://docs.aws.amazon.com/personalize/latest/dg/updating-dataset-schema.html)
