---
title: Use Error Boundaries for Render-Time Failures
impact: HIGH
impactDescription: contains component crashes so one bad subtree doesn't blank the whole app
tags: err, react, error-boundary, resilience
---

## Use Error Boundaries for Render-Time Failures

React renders are pure functions — a thrown error escapes any surrounding synchronous `try/catch` because React calls the component, not your code. Error Boundaries catch errors during render, lifecycle, and constructor execution of the components below them and let you show a fallback UI. Without boundaries, a single failure in a leaf component crashes the entire tree.

**Incorrect (try/catch in effects can't catch render errors; no fallback):**

```tsx
function OrdersPage() {
  // This try/catch CANNOT catch a render error inside <OrderList />.
  // If `<OrderList />` throws during render, the whole app unmounts.
  useEffect(() => {
    try {
      // ... unrelated effect work ...
    } catch (e) {
      console.error(e);
    }
  }, []);

  return (
    <div>
      <Header />
      <OrderList /> {/* one bad row -> white screen for everything */}
      <Footer />
    </div>
  );
}
```

**Correct (boundary scoped to the feature; rest of page survives):**

```tsx
import { ErrorBoundary } from 'react-error-boundary';

function OrdersPage() {
  return (
    <div>
      <Header />
      <ErrorBoundary
        FallbackComponent={OrdersErrorFallback}
        onError={(error, info) => reportError(error, { component: info.componentStack })}
      >
        <OrderList /> {/* a render error here shows OrdersErrorFallback, header + footer stay */}
      </ErrorBoundary>
      <Footer />
    </div>
  );
}

function OrdersErrorFallback({ error, resetErrorBoundary }: FallbackProps) {
  return (
    <div role="alert">
      <p>Couldn't load orders: {error.message}</p>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  );
}
```

**When NOT to apply this pattern:**
- Leaf components inside a tree that already has an appropriate boundary — adding another boundary just fragments the fallback UX.
- Tiny utility components where a per-component fallback makes no sense (e.g., a `<Tooltip>` — let the parent boundary handle it).
- Framework-managed pages — Next.js `error.tsx` and Remix `ErrorBoundary` exports already wire boundaries for you; don't duplicate at the route level.

**Why this matters:** Error Boundaries are React's equivalent of `try/catch` for the render phase. Without them, your app has no recovery story for component bugs.

Reference: [react.dev — Error Boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary), [react-error-boundary](https://github.com/bvaughn/react-error-boundary)
