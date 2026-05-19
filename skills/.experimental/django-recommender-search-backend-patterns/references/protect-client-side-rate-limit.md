---
title: Throttle Outbound Calls with a Token Bucket
impact: HIGH
impactDescription: prevents downstream rate-limit bans
tags: protect, rate-limit, token-bucket, throttle, quota
---

## Throttle Outbound Calls with a Token Bucket

Every external service has a quota — AWS Personalize has per-second TPS limits, Databricks endpoints have model-specific concurrency, OpenSearch has shard-level circuit breakers. When your traffic spikes (marketing campaign, viral page) and exceeds the downstream's rate limit, you get 429s. With aggressive retries (see [[protect-jittered-retry-backoff]]), the retries themselves exceed the limit, creating a positive feedback loop: more requests → more 429s → more retries → more requests. The downstream eventually blocks your IP.

Client-side rate limiting prevents this: a token bucket caps your outbound rate to slightly below the downstream's limit. Excess requests wait or fail fast locally, never hitting the downstream.

**Incorrect (no client-side limit — exceeds downstream quota):**

```python
async def get_recommendations_bulk(user_ids: list[str]):
    # 1000 users, no limit → 1000 parallel calls → Personalize 429s → retries → ban
    return await asyncio.gather(
        *(personalize_client.get(uid) for uid in user_ids),
        return_exceptions=True,
    )
```

**Correct (token bucket per downstream):**

```python
import asyncio
import time

class TokenBucket:
    """Token bucket rate limiter. Refills at `rate` tokens/second up to `capacity`."""

    def __init__(self, rate: float, capacity: int):
        self.rate = rate           # tokens added per second
        self.capacity = capacity   # max burst size
        self.tokens = float(capacity)
        self.updated = time.monotonic()
        self._lock = asyncio.Lock()

    async def acquire(self, tokens: int = 1, max_wait_s: float | None = None):
        """Block until `tokens` are available or `max_wait_s` elapses."""
        async with self._lock:
            self._refill()
            if self.tokens >= tokens:
                self.tokens -= tokens
                return

            shortage = tokens - self.tokens
            wait_s = shortage / self.rate
            if max_wait_s is not None and wait_s > max_wait_s:
                raise RateLimitedLocally(
                    f"would need {wait_s:.2f}s for {tokens} tokens"
                )

        await asyncio.sleep(wait_s)
        # Recurse rather than re-acquire — handles races cleanly
        await self.acquire(tokens, max_wait_s)

    def _refill(self):
        now = time.monotonic()
        elapsed = now - self.updated
        self.tokens = min(self.capacity, self.tokens + elapsed * self.rate)
        self.updated = now

class RateLimitedLocally(Exception):
    pass

# Per-downstream buckets — sized below the downstream's quota
PERSONALIZE_BUCKET = TokenBucket(rate=180, capacity=200)   # 180 RPS sustained, 200 burst
                                                            # (Personalize quota is 200; leave headroom)
DATABRICKS_BUCKET  = TokenBucket(rate=20,  capacity=30)    # ML calls — slow, low rate
OPENSEARCH_BUCKET  = TokenBucket(rate=500, capacity=600)
```

**Wire the bucket into clients:**

```python
async def get_recommendations(user_id: str):
    # Wait up to 200ms for a token; longer than that means we're overloaded
    await PERSONALIZE_BUCKET.acquire(max_wait_s=0.2)
    return await PERSONALIZE_BREAKER.call(
        call_with_retry,
        lambda: personalize_client.get(user_id),
        idempotent=True,
    )
```

**Distributed rate limiting (multiple Django workers, shared downstream quota):**

```python
# In-process token bucket caps per-worker. With N workers sharing a Personalize
# quota of 200 RPS, configure each worker for 200 / N. Better: a Redis-backed
# token bucket coordinates across workers.

# Example using redis-cell module (an atomic rate limiter):
async def acquire_token_redis(key: str, max_burst: int, refill_per_sec: int) -> bool:
    # CL.THROTTLE returns [is_limited, remaining, tokens_in_window, retry_in_ms, reset_in_ms]
    result = await redis.execute_command(
        "CL.THROTTLE", key, max_burst, refill_per_sec, 60, 1
    )
    return result[0] == 0  # not limited

# Usage in the client layer:
if not await acquire_token_redis("personalize:tokens", 200, 180):
    raise RateLimitedLocally("global Personalize quota exhausted")
```

**Sizing rules:**

| Setting | Set to |
|---------|--------|
| `rate` | downstream_quota × 0.9 / num_workers (10% headroom) |
| `capacity` | rate × 1.5 (allow brief bursts without queueing) |
| `max_wait_s` | < per-call timeout (don't queue longer than the call would take) |

**Combine with circuit breaker:** the bucket prevents *predictable* over-quota; the breaker handles *unpredictable* failure modes. Both layers are needed.

**Symptom of missing rate limiting:**
- Sudden 429 storms during traffic spikes
- "We got blacklisted by Personalize" — your team is now in a Slack thread with AWS support
- Aggressive retry loops making the problem worse

Reference: [Stripe — Rate Limiters](https://stripe.com/blog/rate-limiters) | [redis-cell](https://github.com/brandur/redis-cell)
