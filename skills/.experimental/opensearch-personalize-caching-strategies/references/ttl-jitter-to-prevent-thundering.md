---
title: Add Random Jitter to TTL to Prevent Synchronized Expiry
impact: HIGH
impactDescription: smooths origin-load spikes from cohort batch writes
tags: ttl, jitter, thundering-herd, expiry, synchronization
---

## Add Random Jitter to TTL to Prevent Synchronized Expiry

When many keys are written at the same time — a nightly batch precomputation, a deploy warm-up, a cohort refresh — they all get the same TTL and expire at the same instant. The next read after expiry triggers N simultaneous origin calls, one per key. Even with per-key stampede protection (each key has ONE origin call), the *aggregate* origin load spikes by 100-10000× for the duration of the refresh window. Adding random jitter (±10-25% of the TTL) spreads expiry across a window so the origin sees a sustained moderate load rather than a spike.

**Incorrect (fixed TTL — synchronized expiry from batch writes):**

```python
# Nightly batch at 02:00 writes 10000 cohort × surface entries with TTL=86400
for cohort in cohorts:
    for surface in surfaces:
        redis.set(f'recs:{surface}:{cohort}', json.dumps(recs), ex=86400)

# At 02:00 next day: ALL 10000 entries expire simultaneously.
# First requests after 02:00 trigger 10000 origin calls in seconds.
# Even with single-flight, that's 10000 distinct origin calls.
# Personalize TPS spikes, OpenSearch CPU saturates.
```

**Correct (jittered TTL):**

```python
import random

def jittered_ttl(base_seconds: int, jitter_pct: float = 0.15) -> int:
    """TTL with +/- jitter_pct% random jitter."""
    jitter = base_seconds * jitter_pct
    return base_seconds + random.randint(-int(jitter), int(jitter))

for cohort in cohorts:
    for surface in surfaces:
        # 86400 ± 15% = expires uniformly over a ~3.6-hour window
        redis.set(f'recs:{surface}:{cohort}', json.dumps(recs), ex=jittered_ttl(86400))

# Now expiries are spread across 02:00 ± 1.8h.
# Origin load is a smooth ramp, not a cliff.
```

**Application-side cache-aside variant:**

```typescript
const TTL_SEC = 600;
const JITTER_PCT = 0.15;

function jitteredTtl(base: number, pct = JITTER_PCT): number {
  const jitter = base * pct;
  return Math.floor(base + (Math.random() * 2 - 1) * jitter);
}

async function cacheSet<T>(key: string, value: T, baseTtlSec: number) {
  await redis.set(key, JSON.stringify(value), 'EX', jitteredTtl(baseTtlSec));
}
```

**Choosing jitter percentage:**
- 5-10%: smooths small bursts, minimal staleness impact
- 15-25%: default for batch-written entries; balances spread vs predictability
- 50%+: aggressive smoothing; only if origin load is the dominant constraint

**Avoid the negative-jitter pitfall.** `random.randint(-15, 15)` produces a TTL that may be *shorter* than expected. The batch job above generates a uniform distribution over `[base - jitter, base + jitter]`. If the product requires "no entry younger than 5 minutes is served stale," set the jitter range so the minimum is at least 5 minutes.

**Combine with soft/hard TTL.** The jitter applies to both the soft and hard TTL — keep their ratio constant. Soft = `0.8 * jitteredTtl()`, hard = `1.0 * jitteredTtl()`.

**Cohort-specific jitter seed (advanced):** instead of pure random, use `hash(key) % jitter_range` to make a key's TTL deterministic but spread across keys. Useful for debugging — the same key always has the same TTL within a run.

Reference: [AWS Architecture Center: TTL jitter patterns](https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/) · [Marc Brooker — Exponential Backoff and Jitter](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
