---
title: Parallelise Independent Awaits
impact: MEDIUM-HIGH
impactDescription: faster wall-clock time by N for N independent I/O calls; eliminates accidental serial chains
tags: proc, async, parallelization, promises
---

## Parallelise Independent Awaits

When two or more `await` calls have no data dependency on each other, awaiting them sequentially turns a "max" into a "sum" of latencies. Each line looks innocent — `await getUser`, then `await getOrders` — but together they make the user wait for their sum. The mental-model gap is treating `await` as "I need this now" instead of "I need this *before the next line that uses it*." The fix is `Promise.all` (or `.allSettled`); spotting the opportunity is the judgment skill.

**Incorrect (three independent fetches happening one after another):**

```typescript
async function loadDashboard(userId: string) {
  const user        = await api.getUser(userId);          // 120ms
  const orders      = await api.getOrders(userId);        // 200ms — could start at t=0
  const recommendations = await api.getRecommendations(userId);  // 150ms — could start at t=0
  return { user, orders, recommendations };
  // Total: ~470ms. None of these depend on each other.
}
```

**Correct (kick them off in parallel):**

```typescript
async function loadDashboard(userId: string) {
  const [user, orders, recommendations] = await Promise.all([
    api.getUser(userId),
    api.getOrders(userId),
    api.getRecommendations(userId),
  ]);
  return { user, orders, recommendations };
  // Total: ~200ms (the slowest one). Same code, parallel execution.
}
```

**Distinguishing dependent vs independent awaits:**

| Dependent (must be sequential) | Independent (can be parallel) |
|--------------------------------|-------------------------------|
| `const user = await getUser(id); const orders = await getOrders(user.region);` | `const user = await getUser(id); const orders = await getOrders(id);` |
| Each step uses the previous step's value | Each step uses the *original* inputs only |

Test: can you reorder the lines without breaking the code? If yes — they're independent.

**A subtler variant: `for await` of N independent fetches:**

```typescript
// Incorrect (sequential, accidentally):
const results = [];
for (const id of ids) {
  results.push(await api.getItem(id));
}

// Correct (parallel):
const results = await Promise.all(ids.map(id => api.getItem(id)));

// Correct with concurrency limit (when you can't flood the upstream):
import pLimit from 'p-limit';
const limit = pLimit(5);
const results = await Promise.all(ids.map(id => limit(() => api.getItem(id))));
```

**When NOT to use this pattern:**

- The downstream service has tight rate limits — use `pLimit`/`pMap` with a concurrency cap rather than `Promise.all` over everything.
- An earlier call's *failure* should short-circuit and prevent later ones from running — `Promise.all` rejects fast but the others still fire. Use a guard or sequence if you specifically need that behaviour.
- The calls have shared state (write-then-read) — they're dependent even if it doesn't look that way. Keep them sequential.

**Watch for `Promise.all` over an `await` that's already done — that's just `[await x, await y]` with extra steps.** The fix is to *remove the awaits inside `.map`* so the promises start immediately:

```typescript
// Wrong (no parallelism — the awaits resolve before Promise.all is even called):
await Promise.all(ids.map(async id => await api.getItem(id)));
// (Actually fine — the inner await defers within the async arrow.)

// Common mistake — calling .then sequentially in a chain:
const a = await fetch('/a').then(r => r.json());
const b = await fetch('/b').then(r => r.json());
// Still sequential. Use Promise.all on the unawaited fetches.
```

Reference: [MDN — Promise.all](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all)
