---
title: Use Full-Jitter Backoff for Server-to-Server Retries
impact: CRITICAL
impactDescription: prevents thundering-herd recovery storms
tags: protect, retry, jitter, backoff, thundering-herd
---

## Use Full-Jitter Backoff for Server-to-Server Retries

When a downstream goes down at T=0 and 50 Django workers all retry with deterministic backoff (1s, 2s, 4s), every worker retries at the same instants. The recovering service gets hit with 50 simultaneous requests every doubling, which crashes it again. Full jitter — `delay = random(0, base × 2^attempt)` — spreads retries uniformly across the backoff window, so the recovering service sees a smooth load curve instead of repeated spikes.

This is the AWS Architecture Blog standard. Especially important for shared internal services where every Django worker has the same retry logic.

**Incorrect (deterministic backoff — synchronized stampede):**

```python
async def call_with_retry(fn, max_attempts=5):
    for attempt in range(max_attempts):
        try:
            return await fn()
        except RetriableError:
            if attempt == max_attempts - 1:
                raise
            await asyncio.sleep(2 ** attempt)  # ❌ 1s, 2s, 4s — all workers in sync
```

**Correct (full jitter — uniform spread across the backoff window):**

```python
import asyncio
import random

class HttpError(Exception):
    def __init__(self, status: int, body: str = ""):
        self.status = status
        self.body = body
        super().__init__(f"HTTP {status}: {body[:200]}")

async def call_with_retry(fn, *, max_attempts: int = 3, base_s: float = 0.2,
                          cap_s: float = 30.0):
    for attempt in range(max_attempts):
        try:
            return await fn()
        except Exception as err:
            if attempt == max_attempts - 1:
                raise
            if not _is_retriable(err):
                raise  # see [[protect-no-retry-on-4xx]]
            cap = min(cap_s, base_s * (2 ** attempt))
            delay = random.uniform(0, cap)            # full jitter
            await asyncio.sleep(delay)

def _is_retriable(err: Exception) -> bool:
    if isinstance(err, HttpError):
        return err.status >= 500 or err.status == 429
    if isinstance(err, (asyncio.TimeoutError, ConnectionError)):
        return True
    if isinstance(err, httpx.RequestError):
        return True
    return False
```

**Use it (with circuit breaker — they layer):**

```python
async def get_personalize(user_id):
    return await PERSONALIZE_BREAKER.call(
        call_with_retry,
        lambda: personalize_client.get(user_id),
        max_attempts=2,  # tight retries — circuit breaker handles persistent failure
    )
```

**Tuning rules:**

| Parameter | Set to |
|-----------|--------|
| `max_attempts` | 2-3 for synchronous user-facing calls (more increases p99 dramatically); 5+ for background jobs |
| `base_s` | 100-500ms for fast services; 500ms-1s for ML services |
| `cap_s` | 30s general; lower if a user is waiting |

**Honor `Retry-After` when downstream sends one:**

```python
async def call_with_retry(fn, max_attempts=3, base_s=0.2):
    for attempt in range(max_attempts):
        try:
            return await fn()
        except HttpError as err:
            if attempt == max_attempts - 1 or not _is_retriable(err):
                raise
            # Server told us how long to wait — honor it
            retry_after = _parse_retry_after(err)
            if retry_after is not None:
                delay = retry_after
            else:
                delay = random.uniform(0, min(30, base_s * 2 ** attempt))
            await asyncio.sleep(delay)
```

See [[protect-honor-retry-after-header]] for parsing Retry-After.

**Don't retry mutations without idempotency keys:**

```python
# ❌ Dangerous — POST may have succeeded and the response was lost
await call_with_retry(lambda: api.post("/charge", json={...}), max_attempts=3)

# ✅ Safe: idempotency key + server-side dedup
idempotency_key = uuid.uuid4().hex
await call_with_retry(
    lambda: api.post("/charge", json={...}, headers={"Idempotency-Key": idempotency_key}),
    max_attempts=3,
)
```

**Symptom of bad retry policy:**
- "After a downstream blip, traffic to downstream stays elevated for 30+ minutes" — too many retries × too long backoff
- "Recovery wave kills the downstream again" — deterministic backoff (no jitter)
- "Errors propagate to users on transient blips" — too few retries

Reference: [AWS — Exponential Backoff and Jitter](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
