---
title: Prefetch Likely-Next Data on Idle
impact: MEDIUM-HIGH
impactDescription: maintains instant transitions for predictable paths
tags: prefetch, idle, requestIdleCallback, predictive
---

## Prefetch Likely-Next Data on Idle

Some user paths are highly predictable: after viewing a product, ~40% open the reviews tab; after opening a checkout, nearly 100% will see the shipping step. Prefetching this data during the browser's idle time (`requestIdleCallback`) costs nothing — main-thread work runs first, and the prefetch fills the gap when the browser would otherwise be idle.

The win is not just speed but consistency: even when prefetch *didn't* race to completion, you've shifted hundreds of milliseconds of work out of the user's click → render path.

**Incorrect (only fetch on demand — every step waits):**

```tsx
function ProductPage({ id }: { id: string }) {
  return (
    <Tabs>
      <Tab name="Details"><ProductDetails id={id} /></Tab>
      <Tab name="Reviews"><Reviews id={id} /></Tab> {/* fetches on activation */}
      <Tab name="Q&A"><QA id={id} /></Tab>          {/* fetches on activation */}
    </Tabs>
  );
  // User clicks Reviews → 300ms wait every single time
}
```

**Correct (prefetch likely-next during idle):**

```tsx
function ProductPage({ id }: { id: string }) {
  const queryClient = useQueryClient();

  useEffect(() => {
    // Reviews are opened ~40% of the time — worth prefetching at idle
    const handle = requestIdleCallback(() => {
      queryClient.prefetchQuery({
        queryKey: ['reviews', id],
        queryFn: () => fetchReviews(id),
        staleTime: 60_000,
      });
    });
    return () => cancelIdleCallback(handle);
  }, [id]);

  return <Tabs>{/* ... */}</Tabs>;
}
```

**Polyfill `requestIdleCallback` (Safari only added it in 17.4):**

```ts
type IdleCb = (deadline: IdleDeadline) => void;

const ric: (cb: IdleCb) => number =
  typeof window.requestIdleCallback === 'function'
    ? window.requestIdleCallback
    : (cb) => window.setTimeout(() => cb({
        didTimeout: false,
        timeRemaining: () => 50,
      } as IdleDeadline), 1) as unknown as number;
```

**For multi-step flows (prefetch the next step):**

```tsx
function CheckoutCart() {
  const queryClient = useQueryClient();
  // User landed on cart. Next step is nearly always shipping → prefetch.
  useEffect(() => {
    requestIdleCallback(() => {
      queryClient.prefetchQuery({
        queryKey: ['shipping-options'],
        queryFn: fetchShippingOptions,
      });
      queryClient.prefetchQuery({
        queryKey: ['saved-addresses'],
        queryFn: fetchSavedAddresses,
      });
    });
  }, []);
}
```

**When NOT to idle-prefetch:**
- Data that's expensive on the backend (a recommendation engine that takes 800ms of compute per call) — burning a hot backend query for users that never click is bad ROI
- Authenticated paths the user might not have permission for — wasted server work and surprising 401s
- Mobile connections — even idle prefetch costs bandwidth; gate on `navigator.connection.effectiveType !== '2g'`

Reference: [MDN — requestIdleCallback](https://developer.mozilla.org/en-US/docs/Web/API/Window/requestIdleCallback)
