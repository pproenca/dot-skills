---
title: Avoid Hidden Side Effects (Especially in Render)
impact: CRITICAL
impactDescription: preserves React's purity contract and makes function behavior predictable
tags: func, side-effects, purity, render
---

## Avoid Hidden Side Effects (Especially in Render)

React's rendering model assumes components are pure functions of props and state: same inputs, same output, no observable mutation. A component that mutates a prop, writes to `localStorage`, or fires a `fetch` during render breaks this contract — React's StrictMode double-invocation will reveal the corruption, but only if you're looking. Side effects belong in `useEffect`, event handlers, or server actions; render is for derivation only.

**Incorrect (component mutates its prop and writes to storage during render):**

```tsx
// Mutates `order.total` — second render sees a doubled total.
// Calls localStorage during render — StrictMode runs it twice, audit log is wrong.
function OrderTotal({ order }: { order: Order }) {
  order.total = order.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  localStorage.setItem(`order_${order.id}_viewed_at`, new Date().toISOString());
  return <span>{order.total}</span>;
}
```

**Correct (derive locally, push side effects into the right primitive):**

```tsx
// Pure derivation — same input, same output, no mutation.
// Side effect moved into useEffect — runs once per mount, idempotent under StrictMode.
function OrderTotal({ order }: { order: Order }) {
  const total = order.items.reduce((sum, item) => sum + item.price * item.quantity, 0);

  useEffect(() => {
    localStorage.setItem(`order_${order.id}_viewed_at`, new Date().toISOString());
  }, [order.id]);

  return <span>{total}</span>;
}
```

**When NOT to apply this pattern:**
- This rule is non-negotiable *inside React render*. The "when not to apply" concerns the broader principle: outside React, pure functions can occasionally mutate their arguments for performance — sorting a 10M-element array in place is the canonical case. The cost is documentation and the surprise it creates for callers.
- Lazy initialization patterns (`const ref = useRef(); if (ref.current === null) ref.current = createExpensiveThing();`) technically mutate during render but are sanctioned by the React team for this specific use case.
- Logging and telemetry that are themselves idempotent and tolerant of double-invocation may live in render for diagnostic purposes — but prefer effects, and prefer once-per-event semantics.

**Why this matters:** Purity in render is the foundation that concurrent rendering, time-slicing, and the React Compiler all stand on; breaking it forfeits those guarantees silently.

Reference: [react.dev: Keeping Components Pure](https://react.dev/learn/keeping-components-pure), [Clean Code, Chapter 3: Functions — Side Effects](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
