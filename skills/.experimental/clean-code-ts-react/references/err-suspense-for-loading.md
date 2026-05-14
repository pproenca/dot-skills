---
title: Use Suspense for Loading States, Not Boolean Flags
impact: HIGH
impactDescription: declares loading once at the boundary instead of repeating conditionals in every component
tags: err, react, suspense, loading-state
---

## Use Suspense for Loading States, Not Boolean Flags

The `const [isLoading, setIsLoading] = useState(true)` pattern forces every data-displaying component to repeat the same `if (loading) return <Spinner />; if (error) return <Err />;` prelude. Suspense inverts this: declare a loading boundary once at the page or section level, and child components consume data as if it's always present. Combined with React 19's `use()` or Suspense-aware query hooks, this collapses three branches into one.

**Incorrect (every component carries its own loading/error scaffolding):**

```tsx
function OrderDetails({ orderId }: { orderId: string }) {
  const { data: order, isLoading, error } = useQuery({
    queryKey: ['order', orderId],
    queryFn: () => fetchOrder(orderId),
  });

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!order) return null;

  return (
    <div>
      <h1>Order #{order.number}</h1>
      <CustomerCard customerId={order.customerId} />
      {/* CustomerCard repeats the same isLoading/error pattern internally. */}
    </div>
  );
}
```

**Correct (boundaries at the section level; child components are linear):**

```tsx
function OrderDetailsPage({ orderId }: { orderId: string }) {
  return (
    <ErrorBoundary FallbackComponent={OrderErrorFallback}>
      <Suspense fallback={<Spinner />}>
        <OrderDetails orderId={orderId} />
      </Suspense>
    </ErrorBoundary>
  );
}

function OrderDetails({ orderId }: { orderId: string }) {
  // useSuspenseQuery (or React 19 `use(promise)`) guarantees `order` is defined.
  const { data: order } = useSuspenseQuery({
    queryKey: ['order', orderId],
    queryFn: () => fetchOrder(orderId),
  });

  // Linear render — no loading/error branches in the body.
  return (
    <div>
      <h1>Order #{order.number}</h1>
      <CustomerCard customerId={order.customerId} />
    </div>
  );
}
```

**When NOT to apply this pattern:**
- Legacy components using non-Suspense data fetching — don't rewrite working code just to switch idioms; migrate as you touch them.
- Per-row or per-cell loading UIs (e.g., a table where each row independently fetches and shows a spinner) — local `isLoading` per row is clearer than nested Suspense boundaries.
- Non-data async state like form submission (`isSubmitting`) or button-level "saving..." indicators — local state is the right tool.

**Why this matters:** Suspense moves loading from a per-component concern to a per-region concern, which is where designers think about it anyway.

Reference: [react.dev — Suspense](https://react.dev/reference/react/Suspense), [TkDodo: React 19 and Suspense — a Drama in 3 Acts](https://tkdodo.eu/blog/react-19-and-suspense-a-drama-in-3-acts)
