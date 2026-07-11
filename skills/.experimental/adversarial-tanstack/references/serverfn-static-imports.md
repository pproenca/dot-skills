---
title: Import server functions statically
tags: serverfn, imports, bundler, code-splitting
---

## Import server functions statically

The wrong default is lazy-loading server functions with `await import()` the way one code-splits ordinary modules. The Start compiler extracts server functions into server/client variants at build time based on static imports; a dynamic import bypasses that extraction and the docs flag it as a bundler-level failure mode. Server functions are already just RPC stubs on the client — there is no bundle-size win to chase.

**Evidence of violation:** an `import(` expression whose target module exports `createServerFn` wrappers (by convention `*.functions.ts` files).

```ts
// Static import everywhere, including client components — the stub is tiny.
import { getUser } from '~/utils/users.functions'

function Profile() {
  const { data } = useQuery({ queryKey: ['user'], queryFn: () => getUser() })
}
```

Reference: [TanStack Start — Server Functions](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
