---
title: Use the Filters API for Hard Exclusions, Not Client Code
impact: MEDIUM-HIGH
impactDescription: prevents numResults shortfall on exclusion
tags: infer, filters, exclusion
---

## Use the Filters API for Hard Exclusions, Not Client Code

Filtering out already-booked or blocked listings in the client means Personalize returns 24 items and the client discards half, leaving gaps in the response. The Filters API applies the exclusion during retrieval — Personalize knows what was filtered, backfills with additional candidates, and returns a full `numResults` list. Filter DSL supports dynamic parameters so the same filter works for multiple users, and filter expressions can reference both Items and Interactions data.

**Incorrect (client-side filtering, visible gaps in response):**

```python
response = personalize_runtime.get_recommendations(
    campaignArn=CAMPAIGN_ARN,
    userId=seeker.id,
    numResults=24,
)
listings = hydrate_listings(response["itemList"])
already_booked_ids = bookings.completed_listing_ids(seeker.id)
listings = [l for l in listings if l.id not in already_booked_ids]
# Now returning ~13 items instead of 24 — UI gap
```

**Correct (server-side Filters API backfills to numResults):**

```python
response = personalize_runtime.get_recommendations(
    campaignArn=CAMPAIGN_ARN,
    userId=seeker.id,
    numResults=24,
    filterArn=EXCLUDE_ALREADY_BOOKED_FILTER_ARN,
    filterValues={
        "SEEKER_ID": seeker.id,
    },
)
listings = hydrate_listings(response["itemList"])
```

Reference: [AWS Personalize — Recommend and Dynamically Filter Based on User Context](https://aws.amazon.com/blogs/machine-learning/recommend-and-dynamically-filter-items-based-on-user-context-in-amazon-personalize/)
