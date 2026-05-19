---
title: Bound Request Timeouts per Endpoint Class
impact: HIGH
impactDescription: prevents indefinite hangs on degraded backends
tags: resilience, timeout, abort-signal, sla
---

## Bound Request Timeouts per Endpoint Class

A request that never resolves blocks UI updates, retains memory, and holds a connection slot indefinitely. `fetch` has no default timeout — without explicit bounds, a stuck backend produces stuck clients. Set a timeout per endpoint class: typeahead 1-2s, list views 3-5s, deep queries 10s. When the timeout fires, the user gets a clear failure path instead of a forever spinner.

Use `AbortSignal.timeout()` (widely supported in 2026) or combine `AbortController` with `setTimeout`.

**Incorrect (no timeout — hung request blocks UI forever):**

```ts
async function fetchProduct(id: string): Promise<Product> {
  const res = await fetch(`/api/products/${id}`); // hangs if backend is unresponsive
  return res.json();
}
```

**Correct (per-endpoint timeout):**

```ts
const TIMEOUTS = {
  typeahead: 1500,   // user is waiting — fail fast and let them retry
  list:      5000,   // moderate load
  detail:    8000,   // deeper queries allowed more headroom
  export:    30_000, // long-running operations
} as const;

async function fetchProduct(id: string, { signal }: { signal?: AbortSignal } = {}) {
  const merged = signal
    ? AbortSignal.any([signal, AbortSignal.timeout(TIMEOUTS.detail)])
    : AbortSignal.timeout(TIMEOUTS.detail);

  try {
    const res = await fetch(`/api/products/${id}`, { signal: merged });
    if (!res.ok) throw new HttpError(res.status, res.statusText);
    return res.json();
  } catch (e) {
    if ((e as Error).name === 'TimeoutError') {
      throw new Error(`product fetch timed out after ${TIMEOUTS.detail}ms`);
    }
    throw e;
  }
}
```

**Polyfill `AbortSignal.timeout` if needed (older runtimes):**

```ts
export function timeoutSignal(ms: number): AbortSignal {
  if (typeof AbortSignal.timeout === 'function') return AbortSignal.timeout(ms);
  const ctrl = new AbortController();
  setTimeout(() => ctrl.abort(new DOMException('timeout', 'TimeoutError')), ms);
  return ctrl.signal;
}
```

**Show progress before failure (degrade gracefully):**

```tsx
function ProductPage({ id }: { id: string }) {
  const { data, error, isLoading } = useQuery({
    queryKey: ['product', id],
    queryFn: ({ signal }) => fetchProduct(id, { signal }),
    retry: 1,
  });

  // After 2s of loading, surface a "this is taking longer than usual" hint
  const [slow, setSlow] = useState(false);
  useEffect(() => {
    if (!isLoading) return;
    const t = setTimeout(() => setSlow(true), 2000);
    return () => clearTimeout(t);
  }, [isLoading]);

  if (error?.message.includes('timed out')) return <TimeoutError onRetry={refetch} />;
  if (isLoading) return slow ? <SlowLoadingState /> : <Skeleton />;
  return <Product product={data!} />;
}
```

**Server-side timeouts (don't waste compute on requests that already gave up):**

```ts
// On the server, propagate the client AbortSignal to the database query
app.get('/api/products/:id', async (req, res) => {
  const signal = AbortSignal.timeout(5000); // server-side bound too
  req.on('close', () => signal); // client disconnected — cancel
  const product = await db.products.findUnique({ where: { id: req.params.id }, signal });
  res.json(product);
});
```

Reference: [MDN — AbortSignal.timeout()](https://developer.mozilla.org/en-US/docs/Web/API/AbortSignal/timeout_static)
