---
title: Set Per-Downstream Timeout Budgets
impact: CRITICAL
impactDescription: prevents one slow service from blowing the whole budget
tags: protect, timeout, httpx, sla, downstream
---

## Set Per-Downstream Timeout Budgets

A single global `timeout=5s` is the worst of both worlds: too short for the slow service (Databricks model invocation legitimately takes 2-3s under load), too long for the fast one (Personalize p99 is 250ms — a 5s timeout means a degraded Personalize can hold up the whole request for 20× longer than its normal latency). Set timeouts based on each downstream's measured p99 + headroom, not a one-size-fits-all value.

Pair with [[orch-propagate-request-deadline]]: per-call timeouts cap how long *one downstream* can take; the request deadline caps how long *all of them combined* can take. Both are needed.

**Incorrect (one timeout for everything — fights every downstream):**

```python
# settings.py
DOWNSTREAM_TIMEOUT = 5.0  # ❌ used everywhere

# personalize.py
async def get(user_id):
    return await client.post(url, json={...}, timeout=DOWNSTREAM_TIMEOUT)

# databricks.py
async def invoke(user_id):
    return await client.post(url, json={...}, timeout=DOWNSTREAM_TIMEOUT)

# In Personalize is degraded: every call hangs for 5s instead of failing fast
# When Databricks is healthy: 5s timeout is way more than needed
```

**Correct (per-downstream timeout tier matched to each service's profile):**

```python
# config.py
from typing import NamedTuple

class Timeouts(NamedTuple):
    connect: float
    read: float
    write: float
    pool: float

# Measured from production p99 + 30% headroom
PERSONALIZE_TIMEOUTS = Timeouts(connect=0.3, read=0.6,  write=0.3, pool=0.2)
AFFINITY_TIMEOUTS    = Timeouts(connect=0.2, read=0.4,  write=0.2, pool=0.2)
DATABRICKS_TIMEOUTS  = Timeouts(connect=0.5, read=3.0,  write=0.5, pool=0.5)  # ML calls
OPENSEARCH_TIMEOUTS  = Timeouts(connect=0.3, read=1.5,  write=0.5, pool=0.3)

# clients/personalize.py
client = httpx.AsyncClient(
    base_url=settings.PERSONALIZE_URL,
    timeout=httpx.Timeout(*PERSONALIZE_TIMEOUTS),
    limits=httpx.Limits(max_connections=50, max_keepalive_connections=20),
)
```

**Why separate connect/read/write/pool timeouts?**

| Phase | What it bounds | Typical value |
|-------|---------------|---------------|
| `connect` | TCP + TLS handshake | 0.2-0.5s |
| `read` | Time between bytes during response read | service p99 + 30% |
| `write` | Time between bytes during request write | request_size / min_acceptable_bandwidth |
| `pool` | Time waiting for a free connection from the pool | 0.2-0.5s (longer means saturated pool) |

The `read` timeout being separate matters: a streaming response can take a long time to fully arrive, but no individual byte should take long. With a single overall timeout, you can't distinguish "slow connect" (network issue) from "slow first byte" (downstream overload) from "slow full response" (large payload).

**Different timeout for different request shapes within the same service:**

```python
# Some Personalize calls are "get_recommendations" (200ms p99)
# Others are "create_dataset_import_job" (slow batch operation)
# Use different clients with different timeouts:

_realtime_client = httpx.AsyncClient(
    base_url=settings.PERSONALIZE_URL,
    timeout=httpx.Timeout(connect=0.3, read=0.6, write=0.3, pool=0.2),
)

_batch_client = httpx.AsyncClient(
    base_url=settings.PERSONALIZE_URL,
    timeout=httpx.Timeout(connect=1.0, read=30.0, write=1.0, pool=1.0),
)
```

**Update timeouts when the data changes:**
- After a downstream deploys a model change that affects p99
- After traffic patterns shift (e.g., a marketing campaign drives more cold-start users)
- After scaling changes on the downstream

Don't set-and-forget. Measure p99 monthly and adjust.

**Symptom of bad timeout tuning:**
- Symptom: "p95 normal, p99 spikes" — read timeout too generous for the service's actual p99
- Symptom: "frequent timeouts on legitimate slow calls" — read timeout too tight
- Symptom: "request hangs for ~5 minutes" — no timeout at all (httpx default is `None` — infinite!)

Reference: [httpx — Timeouts](https://www.python-httpx.org/advanced/#timeout-configuration) | [AWS Personalize — Service Quotas](https://docs.aws.amazon.com/personalize/latest/dg/limits.html)
