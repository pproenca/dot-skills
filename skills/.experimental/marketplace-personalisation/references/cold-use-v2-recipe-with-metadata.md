---
title: Use USER_PERSONALIZATION_v2 with Rich Item Metadata
impact: HIGH
impactDescription: enables same-day relevance for new listings
tags: cold, user-personalization, metadata
---

## Use USER_PERSONALIZATION_v2 with Rich Item Metadata

New listings enter the catalog constantly — they have no interaction history, so a collaborative-filtering model has no basis for ranking them beyond global popularity. USER_PERSONALIZATION_v2 combines interaction signals with rich item metadata, which lets the model extrapolate from attributes (region, category, price tier, verification level) before interactions accumulate. The weaker the item metadata, the longer the cold-start penalty; the richer the metadata, the faster a new listing earns its first relevance signal.

**Incorrect (Items dataset has only ID and category — cold items invisible):**

```json
{
  "type": "record",
  "name": "Items",
  "fields": [
    { "name": "ITEM_ID", "type": "string" },
    { "name": "CATEGORY", "type": "string", "categorical": true }
  ]
}
```

**Correct (rich categorical metadata lets v2 extrapolate to new listings):**

```json
{
  "type": "record",
  "name": "Items",
  "fields": [
    { "name": "ITEM_ID", "type": "string" },
    { "name": "CATEGORY", "type": "string", "categorical": true },
    { "name": "REGION", "type": "string", "categorical": true },
    { "name": "PRICE_TIER", "type": "string", "categorical": true },
    { "name": "VERIFICATION_LEVEL", "type": "string", "categorical": true },
    { "name": "ACCEPTS_SPECIES", "type": "string", "categorical": true },
    { "name": "CREATION_TIMESTAMP", "type": "long" }
  ]
}
```

Reference: [AWS Personalize — User-Personalization-v2 Recipe](https://docs.aws.amazon.com/personalize/latest/dg/native-recipe-user-personalization-v2.html)
