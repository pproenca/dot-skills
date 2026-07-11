---
title: Never mark session-dependent responses Cache-Control public
tags: sec, caching, cdn, cross-tenant
---

## Never mark session-dependent responses Cache-Control public

The wrong default is adding `Cache-Control: public, max-age=...` to a handler to "speed it up" without noticing the handler reads a session, cookie, or auth header. `public` tells every CDN and proxy the response can be served to anyone: the first user's response gets cached and replayed to the next user — a cross-tenant data leak, quoted verbatim as a warning in the Start docs.

**Evidence of violation:** a `Cache-Control` header containing `public` set in the same handler body that reads `Cookie`, `Authorization`, or calls a session helper (`requireSession`, `getSession`, auth middleware context).

**Incorrect (one user's dashboard cached for everyone):**

```ts
export const getDashboard = createServerFn()
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    setResponseHeader('Cache-Control', 'public, max-age=300')
    return db.dashboards.forUser(context.user.id)
  })
```

**Correct (private, keyed to the credential):**

```ts
export const getDashboard = createServerFn()
  .middleware([authMiddleware])
  .handler(async ({ context }) => {
    setResponseHeader('Cache-Control', 'private, max-age=300')
    setResponseHeader('Vary', 'Cookie')
    return db.dashboards.forUser(context.user.id)
  })
```

Reference: [TanStack Start — Server Functions](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
