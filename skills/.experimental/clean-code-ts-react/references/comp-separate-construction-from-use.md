---
title: Separate Setup (Effects, Subscriptions) from Rendering
impact: MEDIUM-HIGH
impactDescription: keeps render pure and aligns with React's contract
tags: comp, effects, rendering, react
---

## Separate Setup (Effects, Subscriptions) from Rendering

A component's render is for describing UI given the current state — it must be pure. Effects (fetches, subscriptions, side effects) belong in setup: `useEffect`, `useQuery`, the new `use(...)` Promise consumer, or in a Server Component. Mixing them — firing `fetch()` mid-render, mutating refs while rendering — violates React's contract and causes invisible bugs: extra requests, race conditions, missing re-renders.

**Incorrect (side effect fires inside render):**

```tsx
// fetch() runs on every render; the returned promise is never awaited correctly;
// React strict mode double-renders amplify the bug.
function OrderList() {
  const data = fetch('/api/orders').then(r => r.json());
  return <ul>{/* what is `data` even? a Promise, not a list */}</ul>;
}
```

**Correct (setup belongs in a hook; render reads the result):**

```tsx
// `use` (React 19) consumes a Promise during render with Suspense integration.
// Alternatives: useQuery, useEffect+useState, or fetch in a Server Component.
function OrderList() {
  const orders = use(fetchOrders());
  return (
    <ul>
      {orders.map(o => <li key={o.id}>{o.label}</li>)}
    </ul>
  );
}

// Or in a Server Component, fetch IS the render-time data:
async function OrderListServer() {
  const orders = await fetchOrders();
  return <ul>{orders.map(o => <li key={o.id}>{o.label}</li>)}</ul>;
}
```

**When NOT to apply this pattern:**
- Server Components and Route Handlers — the framework's contract IS to do data fetching during render. That's not a violation; that's the seam.
- Non-React code — small scripts and one-shot builders mixing construction and use are fine. This rule is about preserving React's purity contract specifically.
- Genuinely synchronous computed values that look like "setup" but aren't — deriving a memoized selector inside render is fine; deriving via `useMemo` only matters for perf.

**Why this matters:** Keeping render pure aligns with React's mental model and prevents an entire family of "why does this re-render forever?" bugs — the same separation principle as commands vs queries.

Reference: [Clean Code, Chapter 10: Classes (substituted: Composition)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [React Docs: Keeping Components Pure](https://react.dev/learn/keeping-components-pure)
