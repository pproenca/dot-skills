---
title: Abort Requests on Unmount or Navigation
impact: HIGH
impactDescription: prevents stale-response races and memory leaks
tags: resilience, abort-controller, cancellation, race-conditions
---

## Abort Requests on Unmount or Navigation

When a user types "a" in a search box (fires request 1, 800ms), then "ab" (fires request 2, 100ms), the responses arrive out of order: request 2 lands first, then request 1 overwrites it. The UI shows results for "a" while the user is staring at "ab". `AbortController` cancels the previous request when a new one starts — and it also cancels in-flight requests when components unmount, preventing the "setState on unmounted component" warning.

TanStack Query and SWR pass an `AbortSignal` to your queryFn automatically — your job is to forward it to `fetch`.

**Incorrect (stale response races overwrite fresh state):**

```tsx
function Search({ term }: { term: string }) {
  const [results, setResults] = useState<Result[]>([]);
  useEffect(() => {
    fetch(`/search?q=${term}`).then(r => r.json()).then(setResults);
    // Two quick typings race; whichever resolves last wins
  }, [term]);
}
```

**Correct (forward AbortSignal — automatic cancellation):**

```tsx
function Search({ term }: { term: string }) {
  const { data } = useQuery({
    queryKey: ['search', term],
    queryFn: async ({ signal }) => {
      const res = await fetch(`/search?q=${encodeURIComponent(term)}`, { signal });
      if (!res.ok) throw new Error(`search failed: ${res.status}`);
      return res.json();
    },
    enabled: term.length > 0,
  });
}
```

**Manual AbortController (when not using a query library):**

```tsx
function Search({ term }: { term: string }) {
  const [results, setResults] = useState<Result[]>([]);
  useEffect(() => {
    const ctrl = new AbortController();
    fetch(`/search?q=${term}`, { signal: ctrl.signal })
      .then(r => r.json())
      .then(setResults)
      .catch(e => {
        if (e.name !== 'AbortError') throw e; // expected on cancel
      });
    return () => ctrl.abort(); // cancel on unmount or term change
  }, [term]);
}
```

**Timeout via AbortSignal.timeout (built-in):**

```ts
const res = await fetch('/slow-endpoint', {
  signal: AbortSignal.timeout(5000), // auto-aborts after 5s
});
```

**Combine multiple cancellation sources:**

```ts
const userCtrl = new AbortController();
const signal = AbortSignal.any([userCtrl.signal, AbortSignal.timeout(5000)]);
const res = await fetch(url, { signal });
// Cancels if EITHER the user navigates away OR the 5s timeout fires
```

**Don't forget the server side:** an aborted client request frees the client, but if the server doesn't notice the closed connection, it'll keep computing the response. For expensive endpoints, propagate cancellation server-side (e.g., Express `req.on('close', ...)` to abort the upstream query).

Reference: [MDN — AbortController](https://developer.mozilla.org/en-US/docs/Web/API/AbortController) | [TanStack Query — Query Cancellation](https://tanstack.com/query/latest/docs/framework/react/guides/query-cancellation)
