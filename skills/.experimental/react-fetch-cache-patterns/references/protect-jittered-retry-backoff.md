---
title: Add Jitter to Retry Backoff
impact: CRITICAL
impactDescription: prevents thundering-herd recovery
tags: protect, retry, jitter, backoff, thundering-herd
---

## Add Jitter to Retry Backoff

When a backend goes down at T=0 and clients retry with pure exponential backoff (1s, 2s, 4s, 8s), every client retries at exactly the same moments. The recovering backend gets hit by every client simultaneously — a thundering herd — and crashes again. Random jitter spreads retries across the backoff window, so the recovering backend sees a smooth load curve instead of repeated spikes.

This is the AWS Architecture Blog standard: **full jitter** (`delay = random(0, base * 2^attempt)`) outperforms equal jitter and decorrelated jitter in most simulations.

**Incorrect (deterministic backoff — synchronized stampede):**

```ts
async function withRetry<T>(fn: () => Promise<T>, maxAttempts = 5): Promise<T> {
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try { return await fn(); }
    catch (e) {
      if (attempt === maxAttempts - 1) throw e;
      const delay = Math.pow(2, attempt) * 1000; // 1s, 2s, 4s, 8s — synchronized
      await new Promise(r => setTimeout(r, delay));
    }
  }
  throw new Error('unreachable');
}
```

**Correct (full jitter — spreads retries across the window):**

```ts
async function withRetry<T>(
  fn: () => Promise<T>,
  { maxAttempts = 5, baseMs = 200, capMs = 30_000 } = {}
): Promise<T> {
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try { return await fn(); }
    catch (e) {
      if (attempt === maxAttempts - 1) throw e;
      if (!isRetryable(e)) throw e; // don't retry 4xx
      const cap = Math.min(capMs, baseMs * 2 ** attempt);
      const delay = Math.random() * cap;          // full jitter: uniform [0, cap)
      await new Promise(r => setTimeout(r, delay));
    }
  }
  throw new Error('unreachable');
}

function isRetryable(e: unknown): boolean {
  if (!(e instanceof Response)) return true; // network error — retry
  return e.status >= 500 || e.status === 429; // server error or rate-limit
}
```

**TanStack Query equivalent:**

```tsx
new QueryClient({
  defaultOptions: {
    queries: {
      retry: 3,
      retryDelay: attempt =>
        Math.random() * Math.min(30_000, 1000 * 2 ** attempt), // full jitter
    },
  },
});
```

**What NOT to retry:**
- 4xx errors (the request is malformed; retry won't help)
- Mutations that aren't idempotent (don't double-charge)
- Aborted requests (the caller already moved on)

**Honor `Retry-After`:** if the server returns 429 with a `Retry-After: 5` header, use 5s — that's a contract.

Reference: [AWS — Exponential Backoff and Jitter](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
