---
title: Keep secrets and database clients out of route loaders
tags: boundary, loaders, secrets, isomorphic
---

## Keep secrets and database clients out of route loaders

The wrong default is treating a route `loader` as server-only code, a habit from Next.js `getServerSideProps`. Start loaders are isomorphic: they run on the server for the initial SSR request but on the **client** for every subsequent navigation. A `process.env.SECRET` read or a database client used directly in a loader body ships to the browser and executes there.

**Evidence of violation:** a `process.env` read, database-client call, or import of a server-only SDK used directly inside a `loader:` or `beforeLoad:` function body, instead of delegating to a `createServerFn`.

**Incorrect (loader body runs client-side on navigation):**

```tsx
export const Route = createFileRoute('/orders')({
  loader: async () => {
    const db = createDbClient(process.env.DATABASE_URL!)
    return db.orders.findMany()
  },
})
```

**Correct (loader calls a server function; only the RPC crosses the wire):**

```tsx
const getOrders = createServerFn().handler(async () => {
  const db = createDbClient(process.env.DATABASE_URL!)
  return db.orders.findMany()
})

export const Route = createFileRoute('/orders')({
  loader: () => getOrders(),
})
```

Reference: [TanStack Start — Execution Model](https://tanstack.com/start/latest/docs/framework/react/guide/execution-model)
