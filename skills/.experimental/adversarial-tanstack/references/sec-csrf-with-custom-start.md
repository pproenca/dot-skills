---
title: Keep CSRF middleware when defining a custom start config
tags: sec, csrf, start-config, middleware
---

## Keep CSRF middleware when defining a custom start config

Start auto-installs `createCsrfMiddleware()` for server functions only when no `src/start.ts` exists. The wrong default is adding a `src/start.ts` for some other global concern (logging, request middleware) without re-adding CSRF — the file's mere presence drops CSRF protection from every server function in production, with only a dev-mode warning to notice.

**Evidence of violation:** a `src/start.ts` calling `createStart(...)` whose `requestMiddleware` array contains no `createCsrfMiddleware` usage.

```ts
// src/start.ts — defining ANY custom config means re-adding CSRF explicitly.
import { createStart, createCsrfMiddleware } from '@tanstack/react-start'

const csrfMiddleware = createCsrfMiddleware({
  filter: (ctx) => ctx.handlerType === 'serverFn',
})

export const startInstance = createStart(() => ({
  requestMiddleware: [csrfMiddleware, loggingMiddleware],
}))
```

Reference: [TanStack Start — Server Functions](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
