---
title: Run Independent Async Operations in Parallel
impact: CRITICAL
impactDescription: sum(latencies) to max(latencies) — typical 5-20× wall-clock speedup
tags: io, async, promise-all, asyncio-gather, parallelism
---

## Run Independent Async Operations in Parallel

`for (const x of xs) { await fetch(x) }` runs the requests strictly one after another — total latency is the sum of all request latencies. When the operations don't depend on each other, this serial execution is purely wasteful: every request after the first is waiting on the previous response for no logical reason. `Promise.all` (JS) / `asyncio.gather` (Python) / `errgroup` (Go) issue them concurrently, so total latency collapses to roughly the slowest single request. The complexity class doesn't change but the wall-clock improvement is typically the most visible perf win in any service that fans out to external APIs.

**Incorrect (sequential — Σ latencies):**

```javascript
const results = [];
for (const id of userIds) {
  results.push(await fetchUser(id));    // each await blocks the next
}
// 50 users × 80ms = 4 seconds
```

**Correct (parallel — max latency):**

```javascript
const results = await Promise.all(
  userIds.map(id => fetchUser(id))      // fires all at once
);
// 50 users in ~80ms (slowest single request)
```

**Alternative (bounded concurrency for rate-limited APIs):**

```javascript
import pLimit from 'p-limit';
const limit = pLimit(10);               // at most 10 in flight
const results = await Promise.all(
  userIds.map(id => limit(() => fetchUser(id)))
);
```

**When NOT to use this pattern:**
- When operations depend on each other (need the result of step `i` to issue step `i+1`) — that data dependency forces sequencing.
- When the downstream system is rate-limited or fragile — use bounded concurrency (`p-limit`, `asyncio.Semaphore`) rather than unbounded `Promise.all`.

Reference: [MDN — `Promise.all`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all)
