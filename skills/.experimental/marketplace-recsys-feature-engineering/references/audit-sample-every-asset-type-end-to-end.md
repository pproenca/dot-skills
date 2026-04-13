---
title: Sample Every Asset Type End-to-End Before Planning Features
impact: CRITICAL
impactDescription: prevents silent garbage inputs to extraction pipelines
tags: audit, sampling, data-quality, ingestion
---

## Sample Every Asset Type End-to-End Before Planning Features

Schema documentation lies, migration scripts silently corrupt data, and photos stored as S3 URLs can be dead links by the time you train on them. Before committing to a feature plan, pull a random sample of 100 real instances per asset type — listing photos, listing descriptions, wizard responses — and open each one end-to-end through the same path the extractor will use. The 3-5 that fail to load reveal the ingestion bugs you would otherwise discover by training on broken data.

**Incorrect (trusts the DB row count without fetching the actual asset):**

```python
def count_trainable_listings() -> int:
    return db.query("SELECT COUNT(*) FROM listings WHERE cover_photo_url IS NOT NULL").scalar()

TRAINABLE = count_trainable_listings()  # 487,219 — but 4% of URLs 404
```

**Correct (sample end-to-end through the real fetch path):**

```python
def audit_photo_fetch(sample_size: int = 100) -> dict:
    rows = db.query(
        "SELECT listing_id, cover_photo_url FROM listings "
        "WHERE cover_photo_url IS NOT NULL ORDER BY RANDOM() LIMIT :n",
        n=sample_size,
    ).all()

    results = {"ok": 0, "404": 0, "corrupt": 0, "too_small": 0}
    for row in rows:
        resp = asset_client.fetch(row.cover_photo_url)
        if resp.status == 404:
            results["404"] += 1
        elif not is_valid_jpeg(resp.body):
            results["corrupt"] += 1
        elif image_dims(resp.body) < (200, 200):
            results["too_small"] += 1
        else:
            results["ok"] += 1
    return results

# Run before any extraction plan; a 4% 404 rate means re-hosting before training, not after.
```

Reference: [Eugene Yan — System Design for Recommendations and Search](https://eugeneyan.com/writing/system-design-for-discovery/)
