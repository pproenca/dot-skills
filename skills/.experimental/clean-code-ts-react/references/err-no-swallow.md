---
title: Never Swallow Errors Silently
impact: HIGH
impactDescription: prevents silent bug factories at every catch site
tags: err, observability, telemetry, catch
---

## Never Swallow Errors Silently

`catch (e) {}` is the single highest-leverage bug factory in any codebase. Every silent catch is a future incident waiting to happen — by the time you notice the symptom, you've lost the cause. At minimum, log; ideally, report to telemetry and re-throw as a domain error. If you genuinely want to continue past a failure, say so explicitly with context.

**Incorrect (failure is invisible until it shows up as a metrics anomaly):**

```ts
async function placeOrder(cart: Cart) {
  const order = await createOrder(cart);

  try {
    await sendAnalytics({ event: 'order_placed', orderId: order.id });
  } catch {} // analytics shouldn't block checkout, so we swallow it

  // Three months later: nobody notices that the analytics endpoint
  // has been returning 500s for two weeks. Funnel data is corrupted.

  return order;
}
```

**Correct (same user outcome; failure is observable):**

```ts
async function placeOrder(cart: Cart) {
  const order = await createOrder(cart);

  try {
    await sendAnalytics({ event: 'order_placed', orderId: order.id });
  } catch (e) {
    // Checkout still succeeds, but the failure is recorded and alertable.
    reportError(e, { context: 'analytics', orderId: order.id });
  }

  return order;
}
```

**When NOT to apply this pattern:**
- This rule is nearly absolute; the closest legitimate exception is a documented fire-and-forget where the API explicitly contracts no error reporting — even then, prefer logging at debug level.
- Test teardowns where errors are expected and the test asserts on them — but use `.rejects.toThrow(...)` or `expect.assertions(...)` rather than an empty catch.
- `Promise.allSettled` consumers where the per-promise failure is intentionally collected as a result, not silenced — the rejection is captured in the settled result.

**Why this matters:** You can't fix what you can't see. A swallowed error is a future incident with the evidence already discarded.

Reference: [Clean Code, Chapter 7: Error Handling — Don't Return Null / Don't Pass Null](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Google SRE Book — Monitoring](https://sre.google/sre-book/monitoring-distributed-systems/)
