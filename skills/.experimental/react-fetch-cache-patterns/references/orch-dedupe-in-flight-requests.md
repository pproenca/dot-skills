---
title: Deduplicate In-Flight Requests by Key
impact: CRITICAL
impactDescription: reduces M concurrent calls to 1
tags: orch, deduplication, in-flight, swr, request-collapsing
---

## Deduplicate In-Flight Requests by Key

When three components mount on the same render and all need `/me`, a naive setup fires three identical `/me` requests in parallel. The backend does three lookups; the client wastes three round-trips' worth of bandwidth. In-flight deduplication — keying ongoing promises by their request signature — collapses these to one shared promise that all three components await.

SWR and TanStack Query do this automatically when the same `queryKey` is used in multiple components. Raw `fetch` does not — you have to wire it.

**Incorrect (three components, three identical /me requests):**

```tsx
// Without dedup, each component independently calls fetch
function Header() { const me = useFetch('/me'); return <Avatar src={me?.avatar} />; }
function Sidebar() { const me = useFetch('/me'); return <span>{me?.name}</span>; }
function Footer()  { const me = useFetch('/me'); return <small>© {me?.org}</small>; }
// Network tab: GET /me, GET /me, GET /me — all in flight at once
```

**Correct (SWR/Query dedupe by key):**

```tsx
// Same queryKey across components → one in-flight request, three subscribers
function Header()  { const { data } = useQuery({ queryKey: ['me'], queryFn: fetchMe }); /*...*/ }
function Sidebar() { const { data } = useQuery({ queryKey: ['me'], queryFn: fetchMe }); /*...*/ }
function Footer()  { const { data } = useQuery({ queryKey: ['me'], queryFn: fetchMe }); /*...*/ }
// Network tab: GET /me — once
```

**Implementation (raw fetch with promise cache):**

```ts
const inflight = new Map<string, Promise<Response>>();

export function dedupedFetch(url: string, init?: RequestInit): Promise<Response> {
  const key = `${init?.method ?? 'GET'} ${url}`;
  let p = inflight.get(key);
  if (!p) {
    p = fetch(url, init).finally(() => inflight.delete(key));
    inflight.set(key, p);
  }
  return p.then(r => r.clone()); // clone so each caller can read the body
}
```

**Warning (dedup applies to GETs only):** Deduplicating POST/PUT/DELETE silently drops user actions. Key only safe-method calls.

Reference: [SWR — Automatic Deduplication](https://swr.vercel.app/docs/advanced/performance#deduplication)
