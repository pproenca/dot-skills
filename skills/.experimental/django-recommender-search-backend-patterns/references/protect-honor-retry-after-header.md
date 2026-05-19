---
title: Honor Retry-After Headers from Downstreams
impact: HIGH
impactDescription: prevents 429 escalation and downstream bans
tags: protect, retry-after, 429, headers, throttle
---

## Honor Retry-After Headers from Downstreams

When a downstream returns 429 (Too Many Requests) or 503 (Service Unavailable), it typically includes a `Retry-After` header telling you how long to wait. Ignoring this header and retrying on your own schedule is the fastest way to escalate from "rate-limited briefly" to "IP blocked permanently." Some services (Stripe, GitHub, AWS APIs) ban clients that hammer 429s without honoring the header.

The header has two formats: integer seconds (`Retry-After: 5`) or HTTP-date (`Retry-After: Wed, 21 Oct 2026 07:28:00 GMT`). Parse both.

**Incorrect (ignore Retry-After, retry with own backoff):**

```python
async def call_with_retry(fn, max_attempts=3):
    for attempt in range(max_attempts):
        try:
            return await fn()
        except HttpError as err:
            if err.status == 429:
                await asyncio.sleep(2 ** attempt)  # ❌ ignores Retry-After
                continue
            raise
```

**Correct (parse Retry-After, fall back to jittered backoff if absent):**

```python
import asyncio
import random
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime

def parse_retry_after(value: str | None) -> float | None:
    """Returns seconds to wait, or None if header missing/malformed."""
    if not value:
        return None
    # Integer seconds form
    try:
        return max(0.0, float(value))
    except ValueError:
        pass
    # HTTP-date form
    try:
        dt = parsedate_to_datetime(value)
        if dt is None:
            return None
        return max(0.0, (dt - datetime.now(timezone.utc)).total_seconds())
    except (TypeError, ValueError):
        return None

async def call_with_retry(fn, *, max_attempts: int = 3, base_s: float = 0.2):
    for attempt in range(max_attempts):
        try:
            return await fn()
        except httpx.HTTPStatusError as err:
            if attempt == max_attempts - 1 or not _is_retriable(err):
                raise
            # 429 / 503 — read Retry-After
            retry_after = parse_retry_after(err.response.headers.get("Retry-After"))
            if retry_after is not None:
                # Cap at 60s so we don't hang the request indefinitely
                delay = min(retry_after, 60.0)
            else:
                # Fall back to full jitter
                delay = random.uniform(0, min(30.0, base_s * 2 ** attempt))
            await asyncio.sleep(delay)
        except (httpx.ConnectError, asyncio.TimeoutError):
            if attempt == max_attempts - 1:
                raise
            await asyncio.sleep(random.uniform(0, min(30.0, base_s * 2 ** attempt)))
```

**Pre-emptive slowdown using X-RateLimit-* headers:**

Many APIs (GitHub, Personalize) also return `X-RateLimit-Remaining` and `X-RateLimit-Reset`. Use them to slow yourself down *before* hitting 429:

```python
import time

# Module-level: track when we can next call each downstream
_next_allowed_at: dict[str, float] = {}

async def rate_aware_call(downstream: str, fn):
    if (next_at := _next_allowed_at.get(downstream)) and next_at > time.monotonic():
        await asyncio.sleep(next_at - time.monotonic())

    response = await fn()

    # Spread remaining quota across the rest of the window
    remaining = response.headers.get("X-RateLimit-Remaining")
    reset = response.headers.get("X-RateLimit-Reset")  # unix timestamp
    if remaining is not None and reset is not None:
        try:
            r = int(remaining)
            window_end = float(reset)
            window_left = max(0.0, window_end - time.time())
            if r < 10 and window_left > 0:
                _next_allowed_at[downstream] = time.monotonic() + (window_left / max(1, r))
        except ValueError:
            pass
    return response
```

**Treat 503 like 429 when Retry-After is set:**

```python
def _is_retriable(err: httpx.HTTPStatusError) -> bool:
    status = err.response.status_code
    if status == 429:
        return True
    if status == 503:
        # Service Unavailable — usually transient. Honor Retry-After.
        return True
    if 500 <= status < 600:
        return True  # other 5xx
    return False
```

**Cap the Retry-After value:**

A server can return `Retry-After: 86400` (one day). For a synchronous user-facing request, that's worse than failing. Cap at the request deadline or a sensible max:

```python
delay = min(retry_after, deadline_remaining(), 60.0)
```

**Production gotcha — AWS responses on rate limit:**

AWS Personalize returns `ThrottlingException` with HTTP 400 (not 429), but the boto3 client transforms it. Use boto3's built-in retry-mode or wrap with `botocore.config.Config(retries={"mode": "adaptive"})` which honors AWS's adaptive retry signals.

```python
import boto3
from botocore.config import Config

_personalize = boto3.client(
    "personalize-runtime",
    config=Config(
        retries={"mode": "adaptive", "max_attempts": 3},
    ),
)
# Adaptive mode tracks rate-limit feedback and slows down automatically
```

**Pair with [[protect-client-side-rate-limit]]:** the token bucket prevents you from hitting the limit; Retry-After handles it when you do. Both layers.

Reference: [MDN — Retry-After](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Retry-After) | [AWS — Adaptive retry mode](https://docs.aws.amazon.com/sdkref/latest/guide/feature-retry-behavior.html)
