---
title: Stream Listing Updates via CDC, Not Periodic Full Re-Import
impact: HIGH
impactDescription: reduces index staleness from hours to seconds
tags: index, cdc, freshness
---

## Stream Listing Updates via CDC, Not Periodic Full Re-Import

A listing index that refreshes on a nightly or hourly batch pulls the entire listings table from the source-of-truth database, rebuilds a bulk-import job, and ships it to OpenSearch. The window between a provider updating their availability and that update reaching the index is hours, and the index is therefore always stale. Change Data Capture (CDC) — streaming row-level changes from the source database to OpenSearch via Debezium, native CDC connectors, or outbox polling — brings staleness down to seconds. Bulk re-import remains useful as a rebuild path for schema changes and disaster recovery, but it is not the refresh mechanism for production traffic.

**Incorrect (nightly full re-import, hours of stale metadata):**

```python
def nightly_reindex() -> None:
    listings = source_db.execute("SELECT * FROM listings WHERE active = true")
    bulk_body = []
    for listing in listings:
        bulk_body.append({"index": {"_index": "listings", "_id": listing.id}})
        bulk_body.append(listing.to_search_document())
    opensearch.bulk(body=bulk_body, refresh=True)
```

**Correct (CDC stream writes each row change as it happens):**

```python
async def consume_cdc_stream() -> None:
    async for change in cdc_consumer.consume(topic="listings.public.listings"):
        if change.op in ("c", "u"):
            opensearch.index(
                index="listings",
                id=change.after.id,
                body=listing_to_search_document(change.after),
                refresh=False,
            )
        elif change.op == "d":
            opensearch.delete(
                index="listings",
                id=change.before.id,
                refresh=False,
            )
```

Reference: [OpenSearch Documentation — Bulk API and Ingestion](https://docs.opensearch.org/latest/field-types/)
