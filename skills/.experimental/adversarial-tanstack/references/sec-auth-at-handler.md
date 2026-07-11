---
title: Enforce auth in the handler or its middleware, not only in beforeLoad
tags: sec, auth, middleware, authorization
---

## Enforce auth in the handler or its middleware, not only in beforeLoad

The wrong default is checking `context.user` in a route's `beforeLoad` and treating the routes behind it as protected. A route guard is navigation UX, not a data authorization boundary: every server function and server route is an independently callable HTTP endpoint, and a direct fetch to it never runs `beforeLoad`. Authorization must live on the endpoint that touches the private data — as attached middleware or an in-handler session check.

**Evidence of violation:** a `createServerFn` or `server.handlers` entry that reads or writes user- or tenant-scoped data with no auth middleware in its `.middleware([...])` chain and no session/token check inside the handler body — regardless of what `beforeLoad` checks.

**Incorrect (guard on the route, nothing on the endpoint that returns the data):**

```tsx
export const Route = createFileRoute('/billing')({
  beforeLoad: ({ context }) => {
    if (!context.user) throw redirect({ to: '/login' })
  },
  loader: () => getInvoices(),
})

const getInvoices = createServerFn().handler(async () => db.invoices.findMany())
```

**Correct (the endpoint itself enforces the session):**

```tsx
const getInvoices = createServerFn()
  .middleware([authMiddleware])
  .handler(async ({ context }) => db.invoices.findMany({ userId: context.user.id }))
```

Reference: [TanStack Start — Authentication Server Primitives](https://tanstack.com/start/latest/docs/framework/react/guide/authentication-server-primitives)
