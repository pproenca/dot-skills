---
title: Enforce Metadata Freshness as a First-Class Signal
impact: CRITICAL
impactDescription: prevents stale price and availability recommendations
tags: schema, freshness, staleness
---

## Enforce Metadata Freshness as a First-Class Signal

A recommender that returns a listing marked "available" when it is actually booked out erodes trust faster than any ranking quality problem. Metadata freshness is a product-level contract: the Items dataset must be updated when availability windows change, when a provider deactivates, when a price tier shifts. Treating re-import latency as an operational SLO prevents the "why is the recommender showing me ghosts" failure mode.

**Incorrect (weekly bulk re-import, days of stale metadata):**

```python
# Cron: every Sunday at 02:00 UTC
def weekly_items_refresh() -> None:
    export_items_to_s3(ITEMS_S3_URI)
    personalize.create_dataset_import_job(
        jobName=f"items-weekly-{date.today()}",
        datasetArn=ITEMS_DATASET_ARN,
        dataSource={"dataLocation": ITEMS_S3_URI},
        roleArn=PERSONALIZE_ROLE_ARN,
    )
```

**Correct (incremental PutItems stream on every metadata change):**

```python
def on_listing_metadata_changed(listing: Listing) -> None:
    personalize_events.put_items(
        datasetArn=ITEMS_DATASET_ARN,
        items=[{
            "itemId": listing.id,
            "properties": json.dumps({
                "CATEGORY": listing.category,
                "REGION": listing.region,
                "PRICE_TIER": listing.price_tier,
                "ACTIVE": listing.is_active,
            }),
        }],
    )
```

Reference: [AWS Personalize — PutItems API for Incremental Metadata Updates](https://docs.aws.amazon.com/personalize/latest/dg/recording-events.html)
