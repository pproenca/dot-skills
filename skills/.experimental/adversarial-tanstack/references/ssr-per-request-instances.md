---
title: Create the router and QueryClient per request inside getRouter
tags: ssr, query-client, singleton, request-isolation
---

## Create the router and QueryClient per request inside getRouter

The wrong default is the SPA habit of a module-level `export const queryClient = new QueryClient()` (or `export const router = createRouter(...)`). On the server a module is loaded once and shared across every concurrent SSR request, so a singleton cache bleeds one user's data into another user's rendered HTML. Start's scaffold exports a `getRouter()` **factory** precisely so each request constructs fresh instances — the Query integration docs state directly that a fresh `QueryClient` must be created per request in SSR environments.

**Evidence of violation:** `new QueryClient(` or `createRouter(` called at module scope and exported directly from `src/router.tsx` (or any module), rather than constructed inside the exported factory function.

**Incorrect (one cache shared by every SSR request):**

```tsx
export const queryClient = new QueryClient()
export const router = createRouter({ routeTree, context: { queryClient } })
```

**Correct (fresh instances per call, wired for SSR streaming):**

```tsx
export function getRouter() {
  const queryClient = new QueryClient()
  const router = createRouter({
    routeTree,
    context: { queryClient },
    scrollRestoration: true,
  })
  setupRouterSsrQueryIntegration({ router, queryClient })
  return router
}
```

Reference: [TanStack Router — TanStack Query Integration](https://tanstack.com/router/latest/docs/integrations/query)
