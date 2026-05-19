---
title: Collapse Identical Requests at the Fetch Layer
impact: HIGH
impactDescription: prevents auth-refresh storms and retry-original races
tags: protect, request-collapsing, auth-refresh, retry, imperative
---

## Collapse Identical Requests at the Fetch Layer

[[orch-dedupe-in-flight-requests]] handles the easy case: same `queryKey` across components → one network request. But several scenarios escape query-key dedup and need *fetch-layer* collapsing — coalescing concurrent calls to the same URL even when callers don't share a cache key (or aren't using a query library at all):

- **Token refresh storm.** 20 in-flight requests get 401 simultaneously. Each one's retry interceptor fires `/auth/refresh`. Without fetch-layer collapsing, the auth server sees 20 refresh calls and (often) rotates the refresh token 20 times, invalidating 19.
- **Retry-during-original.** A request appears to time out at the application layer but is still flying server-side. The retry fires before the original resolves → two identical requests in flight.
- **Cross-module duplicate URLs.** Module A uses queryKey `['user', id, { includeProfile: true }]`; module B uses `['profile', id]`. Different keys, but both resolve to `GET /users/:id/profile`. Query-layer dedup misses this.
- **Imperative code paths.** Auth setup, telemetry init, feature-flag bootstrap — code that runs outside `useQuery` and might race with itself across modules.

**Incorrect (every 401'd request fires its own /auth/refresh):**

```ts
// Axios interceptor — one per request
axios.interceptors.response.use(null, async (error) => {
  if (error.response?.status === 401) {
    await axios.post('/auth/refresh'); // ❌ 20 parallel requests = 20 refresh calls
    return axios.request(error.config); // retry original
  }
  throw error;
});
```

**Correct (collapse `/auth/refresh` by URL — one in-flight at a time):**

```ts
let refreshInFlight: Promise<void> | null = null;

async function refreshToken(): Promise<void> {
  if (refreshInFlight) return refreshInFlight; // existing refresh — wait for it
  refreshInFlight = axios.post('/auth/refresh').then(
    () => { refreshInFlight = null; },
    (e) => { refreshInFlight = null; throw e; }
  );
  return refreshInFlight;
}

axios.interceptors.response.use(null, async (error) => {
  if (error.response?.status === 401) {
    await refreshToken();        // 20 callers, 1 refresh
    return axios.request(error.config);
  }
  throw error;
});
```

**General-purpose fetch-layer collapser:**

```ts
const inflight = new Map<string, Promise<unknown>>();

export function collapsed<T>(signature: string, fn: () => Promise<T>): Promise<T> {
  const existing = inflight.get(signature) as Promise<T> | undefined;
  if (existing) return existing;
  const p = fn().finally(() => inflight.delete(signature));
  inflight.set(signature, p);
  return p;
}

// Imperative code path that might run from many modules
export function getFeatureFlags() {
  return collapsed('GET /api/flags', async () => {
    const res = await fetch('/api/flags');
    return res.json();
  });
}
```

**Why this is distinct from `orch-dedupe-in-flight-requests`:**

| Layer | What's collapsed by | Catches |
|-------|---------------------|---------|
| Query-layer ([[orch-dedupe-in-flight-requests]]) | `queryKey` match | Multiple components calling same `useQuery` |
| Fetch-layer (this rule) | `method + URL + body` match | Different keys → same URL; imperative paths; interceptors |

Query-layer dedup is the right default; fetch-layer is the safety net for cross-cutting cases. They're complementary — both should exist in apps with auth interceptors or many imperative call sites.

**Warning (mutation safety):** never collapse non-idempotent methods. `POST /charge` shared across two callers means one charge for two intents — a user-visible bug. Restrict the collapser to GET/HEAD by default. For POSTs, prefer the idempotency-key pattern ([[resilience-no-auto-retry-mutations]]).

**Bounded micro-cache for "just-completed" calls:** after the response, hold it for 100-500ms so callers that arrive moments after completion still hit the dedup before considering a network call. Avoids the race where two callers narrowly miss each other.

Reference: [SWR — Dedupe](https://swr.vercel.app/docs/api#options) | [Axios — Token Refresh Pattern](https://axios-http.com/docs/interceptors)
