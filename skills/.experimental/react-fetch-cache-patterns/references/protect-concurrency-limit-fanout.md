---
title: Cap Concurrency on Client-Side Fan-Out
impact: CRITICAL
impactDescription: prevents browser connection exhaustion + backend overload
tags: protect, concurrency, p-limit, fanout, semaphore
---

## Cap Concurrency on Client-Side Fan-Out

Browsers limit themselves to ~6 concurrent connections per origin (HTTP/1.1) or several hundred multiplexed streams (HTTP/2). Fire 500 parallel `fetch()` calls and they queue inside the browser anyway — but their queueing is opaque, retries pile up, and the backend sees a sudden burst when the queue drains. Explicit concurrency caps make queueing visible and bound the burst.

The pattern: use a semaphore or `p-limit`-style limiter. 6-10 concurrent requests is a safe default for backend fetches; 2-4 for expensive operations.

**Incorrect (uncapped fan-out, opaque queueing, burst stampede):**

```ts
async function loadAllProducts(ids: string[]) {
  // 500 parallel fetches — browser queues them, backend sees a thundering burst
  // when the connection pool drains. Mobile networks may time out half the requests.
  return Promise.all(ids.map(id => fetchProduct(id)));
}
```

**Correct (bounded concurrency with p-limit):**

```ts
import pLimit from 'p-limit';

const limit = pLimit(6); // 6 concurrent fetches max

async function loadAllProducts(ids: string[]) {
  return Promise.all(ids.map(id => limit(() => fetchProduct(id))));
}
// Network tab: at most 6 in-flight at any moment, smooth backend pressure
```

**Implementation (no dependency — bounded queue):**

```ts
export function createLimiter(max: number) {
  let active = 0;
  const queue: Array<() => void> = [];

  const next = () => {
    if (active >= max || queue.length === 0) return;
    active++;
    queue.shift()!();
  };

  return <T,>(fn: () => Promise<T>): Promise<T> =>
    new Promise<T>((resolve, reject) => {
      queue.push(() =>
        fn().then(resolve, reject).finally(() => { active--; next(); })
      );
      next();
    });
}

const limit = createLimiter(6);
await Promise.all(ids.map(id => limit(() => fetchProduct(id))));
```

**Why this beats relying on browser queueing:**
- Visible: you can log queue depth, alert when it grows
- Tunable per endpoint (slow endpoint? cap at 2)
- Composable with retry/timeout middleware
- Backend sees predictable load instead of spiky bursts

**Pair with [[orch-prefer-bulk-endpoint-for-fanout]]** when possible — a bulk endpoint is always better than even a bounded fan-out.

Reference: [p-limit](https://github.com/sindresorhus/p-limit)
