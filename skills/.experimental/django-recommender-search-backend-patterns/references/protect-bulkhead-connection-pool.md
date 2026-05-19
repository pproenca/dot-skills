---
title: Isolate Connection Pools per Downstream
impact: HIGH
impactDescription: prevents one slow downstream from starving fast ones
tags: protect, bulkhead, connection-pool, isolation, httpx
---

## Isolate Connection Pools per Downstream

A single shared HTTP client (and therefore a single shared connection pool) means: when Databricks slows down and every connection sits idle waiting for the slow response, *every other downstream call* — Personalize, OpenSearch, internal services — queues for a free connection that may never come back. Connection-pool exhaustion looks identical to a downstream outage: 100% of new requests time out, but the root cause is one *other* slow service hogging the pool.

The bulkhead pattern: give each downstream its own pool with its own size. When one pool exhausts, calls to that downstream queue or fail — but calls to other downstreams keep flowing.

**Incorrect (one shared client, one shared pool — bulkhead missing):**

```python
# ❌ Anti-pattern: all downstreams share the same httpx client
_shared_client = httpx.AsyncClient(
    timeout=2.0,
    limits=httpx.Limits(max_connections=100),
)

async def get_personalize(user_id):
    return await _shared_client.post(settings.PERSONALIZE_URL, json={...})

async def invoke_databricks(user_id):
    return await _shared_client.post(settings.DATABRICKS_URL, json={...})
# Databricks gets slow → 100 connections held → Personalize calls queue → timeouts
```

**Correct (per-downstream client = per-downstream pool):**

```python
# clients/personalize.py
_personalize_client = httpx.AsyncClient(
    base_url=settings.PERSONALIZE_URL,
    timeout=httpx.Timeout(connect=0.3, read=0.6, write=0.3, pool=0.2),
    limits=httpx.Limits(
        max_connections=50,           # dedicated pool for Personalize only
        max_keepalive_connections=20,
        keepalive_expiry=30.0,
    ),
)

# clients/databricks.py
_databricks_client = httpx.AsyncClient(
    base_url=settings.DATABRICKS_URL,
    timeout=httpx.Timeout(connect=0.5, read=3.0, write=0.5, pool=0.5),
    limits=httpx.Limits(
        max_connections=20,           # smaller pool — slow service, bound the damage
        max_keepalive_connections=10,
        keepalive_expiry=30.0,
    ),
)

# clients/opensearch.py
_opensearch_client = httpx.AsyncClient(
    base_url=settings.OPENSEARCH_URL,
    timeout=httpx.Timeout(connect=0.3, read=1.5, write=0.5, pool=0.3),
    limits=httpx.Limits(max_connections=30, max_keepalive_connections=15),
)
# Slow Databricks → its 20 connections fill up → its calls fail fast
# Personalize and OpenSearch pools untouched → those calls still succeed
```

**Pool sizing rules:**

| Downstream type | Pool size |
|-----------------|-----------|
| Fast, reliable (Personalize, OpenSearch) | 30-50 |
| Slow ML inference (Databricks) | 10-20 (smaller — don't let it dominate) |
| Internal microservice | 30-50 |
| Background/batch (low traffic) | 5-10 |

**Why a smaller pool for slow services is counterintuitive but correct:**

If Databricks has a 2s p99 read time, even a healthy call holds a connection for 2s. With 100 connections, you can sustain 50 RPS to Databricks before queuing. But if you give it 100 conns out of a 150-conn shared pool, a Databricks slowdown can use *all* connections within seconds. A 20-conn dedicated pool caps Databricks throughput at ~10 RPS but *protects* the other downstreams.

**Pool-pool timeout matters:**

```python
limits=httpx.Limits(max_connections=20)
timeout=httpx.Timeout(pool=0.5)
# When all 20 connections are busy, the 21st caller waits up to 0.5s for a free one.
# After 0.5s: PoolTimeout — fail fast, don't queue forever.
```

**Don't share clients across event loops:** httpx clients are bound to the event loop that created them. In Django with sync views, ASGI middleware, and tests, you may have multiple loops. Create one client per loop or use the same loop throughout.

**For boto3 (sync AWS SDK), use Config(max_pool_connections):**

```python
import boto3
from botocore.config import Config

_personalize_runtime = boto3.client(
    "personalize-runtime",
    config=Config(
        max_pool_connections=50,  # per-boto3-client pool
        retries={"max_attempts": 0},
    ),
)
```

**Monitor pool utilization:** `httpx` doesn't expose this directly, but you can log `PoolTimeout` exceptions per downstream. If you see them, increase the pool size (within reason) or look for connection leaks.

Reference: [httpx — Pool limits](https://www.python-httpx.org/advanced/#pool-limit-configuration) | [Microsoft — Bulkhead pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/bulkhead)
