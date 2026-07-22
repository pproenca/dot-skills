---
title: Create a QueryClient per request on the server
tags: rsc, query-client, hydration, cache-isolation
---

## Create a QueryClient per request on the server

`const queryClient = new QueryClient()` at module scope, imported wherever it is needed, is the shape every browser-only SPA uses and the shape that gets carried into an App Router project unchanged. In the browser it is correct — one tab, one user, one client. On a long-lived Node server the same module is evaluated once and that client outlives every request through it, so query results cached while rendering for one user are read back when the next user's request renders. This is not a staleness bug, it is a cross-user data leak, and it produces no error: the second user simply sees data that resolved correctly for somebody else. The docs are explicit that the getter must return the *same* client during a single request and a *different* one across requests.

Split the getter on the environment, and wrap the server branch in React's `cache` so every server component in one render tree shares one client without sharing it with the next request.

```tsx
// trpc/query-client.ts
import { QueryClient } from '@tanstack/react-query';

export function makeQueryClient() {
  return new QueryClient({
    defaultOptions: { queries: { staleTime: 30_000 } },
  });
}

// trpc/server.tsx  — server only
import { cache } from 'react';
import { makeQueryClient } from './query-client';

// `cache` scopes the client to one request: stable within it, fresh across requests
export const getQueryClient = cache(makeQueryClient);

// trpc/react.tsx  — browser
let browserQueryClient: QueryClient | undefined;

export function getQueryClient() {
  if (typeof window === 'undefined') {
    // Server: never reuse — a shared client would serve one user's orders to the next
    return makeQueryClient();
  }
  browserQueryClient ??= makeQueryClient();
  return browserQueryClient;
}
```

The difference is one line, and it is the whole guarantee:

**Incorrect (cache outlives the request):** `export const queryClient = new QueryClient();`
**Correct (fresh per request, stable within one):** `export const getQueryClient = cache(makeQueryClient);`

Every call site takes the getter, never a client instance — an exported instance is the leak, regardless of how it was constructed.

Reference: [tRPC — TanStack React Query: server components](https://trpc.io/docs/client/tanstack-react-query/server-components)
