---
title: Skip Retry on 4xx and Non-Idempotent Failures
impact: HIGH
impactDescription: prevents wasted retries on permanent errors
tags: protect, retry, 4xx, idempotency, errors
---

## Skip Retry on 4xx and Non-Idempotent Failures

Retrying a `400 Bad Request` or `404 Not Found` never succeeds — the request is malformed or the resource doesn't exist. Retrying adds latency (the user waits for 3 attempts × backoff) and burns rate-limit budget for no possible gain. Retry only on transient failures: network errors, timeouts, 5xx server errors, and 429 (with `Retry-After`).

The dual concern: non-idempotent mutations (POST without idempotency key) should never auto-retry even on 5xx — a 500 may mean "the operation succeeded but the response was lost," and a retry double-applies the side effect.

**Incorrect (retry every failure, including 400s and non-idempotent POSTs):**

```python
async def call_with_retry(fn, max_attempts=3):
    for attempt in range(max_attempts):
        try:
            return await fn()
        except Exception:
            if attempt == max_attempts - 1:
                raise
            await asyncio.sleep(2 ** attempt)

# Usage:
# - 400 Bad Request → retried 3× → user waits 7s for a deterministic failure
# - 500 on POST /charge → retried 3× → can produce 3 charges
```

**Correct (whitelist what's retriable; treat mutations specially):**

```python
import httpx

# Define retriable errors precisely
def is_retriable(err: BaseException, *, idempotent: bool) -> bool:
    # 4xx = client error, never retriable
    if isinstance(err, httpx.HTTPStatusError):
        status = err.response.status_code
        if 400 <= status < 500:
            # Exception: 429 Too Many Requests — retriable with Retry-After
            return status == 429
        if 500 <= status < 600:
            # 5xx — only retry idempotent operations
            return idempotent
        return False
    # Network-layer errors — retriable for both idempotent and non-idempotent
    # (Idempotent: safe. Non-idempotent: the request likely didn't reach the server.)
    if isinstance(err, (httpx.ConnectError, httpx.ConnectTimeout, httpx.WriteError)):
        return True
    # Read-side errors on non-idempotent operations — the server MIGHT have processed it
    if isinstance(err, (httpx.ReadTimeout, httpx.ReadError, httpx.RemoteProtocolError)):
        return idempotent
    if isinstance(err, asyncio.TimeoutError):
        return idempotent
    return False

async def call_with_retry(fn, *, idempotent: bool, max_attempts: int = 3):
    for attempt in range(max_attempts):
        try:
            return await fn()
        except BaseException as err:
            if attempt == max_attempts - 1 or not is_retriable(err, idempotent=idempotent):
                raise
            await asyncio.sleep(random.uniform(0, 2 ** attempt))
```

**Usage:**

```python
# GET — safe to retry
async def get_recommendations(user_id):
    return await call_with_retry(
        lambda: personalize_client.get(user_id),
        idempotent=True,
        max_attempts=3,
    )

# POST without idempotency key — only retry on connect-side errors
async def submit_feedback(user_id, item_id):
    return await call_with_retry(
        lambda: feedback_client.post(user_id, item_id),
        idempotent=False,  # only retries on connect failures
        max_attempts=2,
    )

# POST with idempotency key — server dedupes, safe to retry
async def create_charge(amount, idempotency_key):
    return await call_with_retry(
        lambda: payment_client.post(amount, headers={"Idempotency-Key": idempotency_key}),
        idempotent=True,  # server-side idempotency makes this safe
        max_attempts=3,
    )
```

**Why connect-side errors are safe on non-idempotent calls:**

| Error class | When it fires | Server state |
|------------|---------------|--------------|
| `ConnectError` / `ConnectTimeout` | Before sending bytes | Server never received request — safe to retry |
| `WriteError` (mid-request) | While sending bytes | Server may have partially received — unsafe |
| `ReadTimeout` / `ReadError` | After fully sending, waiting for response | Server may have processed — unsafe |
| `RemoteProtocolError` | Server sent invalid bytes | Unclear if processed — unsafe |

For non-idempotent operations, only retry on `ConnectError` — the request demonstrably never reached the server.

**Pair with [[protect-honor-retry-after-header]]:** even when retry is legal, honor `Retry-After` on 429 to avoid worsening the rate-limit situation.

Reference: [Stripe — Idempotent Requests](https://docs.stripe.com/api/idempotent_requests) | [MDN — HTTP Status 4xx](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#client_error_responses)
