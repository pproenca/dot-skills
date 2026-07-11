---
title: Use the current v1 RC API names, not renamed or removed ones
tags: serverfn, api-surface, stale-api, server-routes
---

## Use the current v1 RC API names, not renamed or removed ones

Models trained before mid-2026 emit three stale TanStack Start APIs. `.inputValidator()` was deprecated in favor of `.validator()` in `@tanstack/react-start@1.168.25` (2026-06-06) and now emits compiler warnings. `createServerFileRoute` and `createAPIFileRoute` no longer exist — server routes unified into a `server` property on the ordinary `createFileRoute`. The package itself is `@tanstack/react-start`; `@tanstack/start` is the abandoned pre-rename name.

**Evidence of violation:** any occurrence of `.inputValidator(`, `createServerFileRoute`, `createAPIFileRoute`, or an import from `@tanstack/start` (no `react-` segment).

**Incorrect (pre-unification server route API — these symbols no longer exist):**

```ts
import { createServerFileRoute } from '@tanstack/start'

export const ServerRoute = createServerFileRoute('/api/health').methods({
  GET: async () => new Response('ok'),
})
```

**Correct (unified API — server handlers live on createFileRoute):**

```ts
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/api/health')({
  server: {
    handlers: {
      GET: async () => new Response('ok'),
    },
  },
})
```

Reference: [TanStack Start — Server Routes](https://tanstack.com/start/latest/docs/framework/react/guide/server-routes), [@tanstack/react-start CHANGELOG](https://github.com/TanStack/router/blob/main/packages/react-start/CHANGELOG.md)
