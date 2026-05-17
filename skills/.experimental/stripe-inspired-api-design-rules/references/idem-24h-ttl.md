---
title: Keep Idempotency Keys for 24 Hours, Reap at 72
impact: MEDIUM-HIGH
impactDescription: prevents unbounded storage growth while covering near-term retry windows
tags: idem, ttl, storage, expiration
---

## Keep Idempotency Keys for 24 Hours, Reap at 72

Idempotency keys are stored for ~24 hours after the operation; a background reaper deletes records older than 72 hours. The two windows separate the *guarantee* (24h — within this window, retries are safe and return the cached response) from the *housekeeping* (72h — by this time the record is gone regardless). Keys are for near-term correctness during the retry window of a failed operation, not for permanent deduplication.

If integrators need permanent deduplication ("only ever charge for invoice #6735 once, forever"), the right mechanism is at the business-domain layer — store a unique constraint on `invoice_id` in the database, or check before submitting. Idempotency keys aren't designed for, and shouldn't be used as, a permanent fact store.

**Why 24 hours is the right guarantee window:**

| Time since first request | What's likely happening |
|--------------------------|-------------------------|
| 0-5 minutes | Active retry storm — network blip, immediate retry |
| 5 min - 1 hour | Backoff retries from outage recovery |
| 1-6 hours | Async job retried after partial failure |
| 6-24 hours | Cron job or queue worker retrying overnight |
| > 24 hours | Almost certainly not a retry — it's a new logical operation |

**Why 72 hours for the reaper:**
- Buffer beyond the 24h guarantee for safety
- Matches typical incident-response and post-mortem windows
- Keeps the keyspace bounded for storage and index size

**Incorrect (permanent storage — unbounded growth):**

```sql
-- No expiration. Table grows forever.
CREATE TABLE idempotent_responses (
  account_id VARCHAR(255),
  idempotency_key VARCHAR(255),
  response_body JSONB,
  created_at TIMESTAMPTZ,
  PRIMARY KEY (account_id, idempotency_key)
);
```

```text
// After a year: billions of rows, index is huge, queries slow down.
// Integrators start using keys as a business-level deduplication store — wrong abstraction.
// Backup and migration costs balloon.
```

**Incorrect (5-minute TTL — too short for real retry patterns):**

```sql
-- Cached for 5 minutes only
DELETE FROM idempotent_responses WHERE created_at < NOW() - INTERVAL '5 minutes';
```

```text
// Async retry from a queue worker an hour later → key already expired.
// Server treats it as a fresh request → duplicate charge.
// Defeats the whole point of idempotency for any non-immediate retry.
```

**Correct (24h guarantee + 72h reaper):**

```sql
-- Reaper job runs hourly
DELETE FROM idempotent_responses
WHERE created_at < NOW() - INTERVAL '72 hours';
```

**Document the guarantee window explicitly:**

> Idempotency keys are guaranteed for 24 hours after the original request. Retries within this window will return the cached response. Keys submitted after this window may be treated as new requests.

**For longer-running operations** (a multi-day batch import), the right mechanism is a job/task resource (`POST /v1/import_jobs` returning a job ID, then `GET /v1/import_jobs/{id}` to poll). The job ID is the permanent deduplication key for that operation — not the idempotency key.

**For multi-step idempotency** within the 24h window (creating a charge involves multiple foreign-state mutations), see [`idem-recovery-points`](idem-recovery-points.md).

Reference: [Brandur — idempotency key TTLs](https://brandur.org/idempotency-keys)
