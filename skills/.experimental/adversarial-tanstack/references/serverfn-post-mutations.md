---
title: Use method POST for mutating server functions
tags: serverfn, http-method, mutations, preload
---

## Use method POST for mutating server functions

The wrong default is leaving `createServerFn()` on its default GET method for a handler that writes. GET server functions are treated as safe — cacheable by browsers and CDNs, and prefetchable (a loader-invoked one fires on link hover under `defaultPreload: 'intent'`) — so a GET-default mutation can execute or be cached without the user ever committing the action. HTTP semantics are load-bearing here, not ceremony.

**Evidence of violation:** a `createServerFn(` call with no `{ method: 'POST' }` (or PUT/PATCH/DELETE) whose handler body performs a write — `.create(`, `.insert(`, `.update(`, `.delete(`, sending email, charging a card.

**Incorrect (defaults to GET; preloading can fire it on hover):**

```ts
export const archiveProject = createServerFn()
  .validator(z.object({ projectId: z.string() }))
  .handler(async ({ data }) => db.projects.archive(data.projectId))
```

**Correct (POST marks it unsafe; it only runs when explicitly invoked):**

```ts
export const archiveProject = createServerFn({ method: 'POST' })
  .validator(z.object({ projectId: z.string() }))
  .handler(async ({ data }) => db.projects.archive(data.projectId))
```

Reference: [TanStack Start — Server Functions](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
