---
title: Expose env vars to the client only through the public prefix
tags: boundary, env-vars, vite, rsbuild
---

## Expose env vars to the client only through the public prefix

The wrong default is reading an unprefixed env var from client code (`import.meta.env.API_URL`) and expecting a value. Only `VITE_`-prefixed vars (Vite) or `PUBLIC_`-prefixed vars (Rsbuild) are exposed to the client; everything else is `undefined` there. The compounding failure is the "fix": renaming a secret to `VITE_DATABASE_URL` to make the read work, which publishes the secret in the client bundle. Server-held values reach the client through a `createServerFn`, never through a prefix rename.

**Evidence of violation:** an `import.meta.env.X` read where `X` lacks the project's public prefix, in a file not marked server-only — or a prefixed var whose name indicates a secret (`VITE_*_KEY`, `VITE_*_SECRET`, `VITE_DATABASE_URL`).

```tsx
// Client-safe config uses the public prefix; secrets flow through server functions.
const appName = import.meta.env.VITE_APP_NAME

const getSignedUploadUrl = createServerFn().handler(async () => {
  return signUrl(process.env.S3_SECRET_KEY!)
})
```

Reference: [TanStack Start — Environment Variables](https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables)
