---
title: Honor Server Rate-Limit Headers Client-Side
impact: HIGH
impactDescription: prevents 429 retry loops + ban risk
tags: protect, rate-limit, 429, retry-after, headers
---

## Honor Server Rate-Limit Headers Client-Side

When the backend returns 429 (Too Many Requests), the typical retry-with-backoff path eventually succeeds — but only after several wasted attempts. The response usually carries a `Retry-After` header (seconds or HTTP date) and `X-RateLimit-*` headers indicating remaining quota. Read them: wait exactly as long as the server asks, and pre-emptively slow down when remaining quota is low.

Some APIs (Stripe, GitHub, Shopify) ban clients that hammer 429s without honoring `Retry-After`. Honoring the header is both correct and defensive.

**Incorrect (ignore Retry-After, retry with own backoff):**

```ts
async function fetchWithRetry(url: string): Promise<Response> {
  for (let i = 0; i < 5; i++) {
    const res = await fetch(url);
    if (res.status === 429) {
      await sleep(2 ** i * 1000); // ignores Retry-After header
      continue;
    }
    return res;
  }
  throw new Error('too many retries');
}
```

**Correct (read Retry-After, fall back to jittered backoff if absent):**

```ts
async function fetchWithRateLimitAwareness(url: string, init?: RequestInit): Promise<Response> {
  for (let attempt = 0; attempt < 5; attempt++) {
    const res = await fetch(url, init);
    if (res.status !== 429) return res;

    const retryAfter = parseRetryAfter(res.headers.get('Retry-After'));
    const delay = retryAfter ?? Math.random() * Math.min(30_000, 1000 * 2 ** attempt);
    await sleep(delay);
  }
  throw new Error('rate-limited after 5 attempts');
}

function parseRetryAfter(header: string | null): number | null {
  if (!header) return null;
  const secs = Number(header);
  if (!Number.isNaN(secs)) return secs * 1000;
  const date = Date.parse(header); // HTTP-date form
  return Number.isNaN(date) ? null : Math.max(0, date - Date.now());
}
```

**Pre-emptive slowdown (use X-RateLimit-Remaining to throttle before hitting 429):**

```ts
let nextAllowedAt = 0;

export async function rateAwareFetch(url: string, init?: RequestInit): Promise<Response> {
  const wait = nextAllowedAt - Date.now();
  if (wait > 0) await sleep(wait);

  const res = await fetch(url, init);
  const remaining = Number(res.headers.get('X-RateLimit-Remaining'));
  const resetAt = Number(res.headers.get('X-RateLimit-Reset')) * 1000;
  if (remaining < 10 && !Number.isNaN(resetAt)) {
    // Spread remaining quota across the rest of the window
    nextAllowedAt = Date.now() + (resetAt - Date.now()) / Math.max(1, remaining);
  }
  return res;
}
```

**Why this matters at scale:** an unrelated user with 200 favorites suddenly triggering parallel fetches can blow your team's quota across the entire app. Honoring rate-limit headers makes one user's load problem stay one user's problem.

Reference: [MDN — 429 Too Many Requests](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/429) | [IETF RFC 6585](https://datatracker.ietf.org/doc/html/rfc6585)
