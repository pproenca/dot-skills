---
title: Mark Server-Only Modules with `import 'server-only'`
impact: CRITICAL
impactDescription: prevents server secrets from bundling into the client
tags: auth, server-only, secrets, bundle
---

## Mark Server-Only Modules with `import 'server-only'`

A server action, loader, privileged client, or service that accidentally gets imported by a client component will be tree-shaken into the client bundle along with everything it imports — including service-role keys and webhook secrets. `import 'server-only'` is a build-time poison pill: the import resolves on the server and fails the build on the client, catching the mistake before deploy.

**Incorrect (privileged client with no server-only marker):**

```ts
// packages/supabase/src/clients/admin.ts
import { createClient } from '@supabase/supabase-js';
import { getServiceRoleKey } from '../get-service-role-key';

// A client component that imports this by mistake compiles fine
// and ships the service-role-key-reading code to the browser.
export function getServiceRoleClient() {
  const serviceRoleKey = getServiceRoleKey();
  return createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, serviceRoleKey);
}
```

**Correct (build fails if a client component imports this file):**

```ts
// packages/supabase/src/clients/admin.ts
import 'server-only';
import { createClient } from '@supabase/supabase-js';
import { getServiceRoleKey } from '../get-service-role-key';

export function getServiceRoleClient() {
  const serviceRoleKey = getServiceRoleKey();
  return createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, serviceRoleKey);
}
```

**Where this marker belongs:**

| File pattern | Add `import 'server-only'`? |
|--------------|-----------------------------|
| `**/clients/server.ts` (request-scoped client) | Yes |
| `**/clients/admin.ts` (privileged client) | Yes |
| `**/clients/middleware.ts` | Yes |
| `**/server/**/*.ts` (loaders, services) | Yes |
| `**/safe-action.ts` (action client factory) | Yes |
| `**/routes/index.ts` (route handler wrappers) | Yes |
| Files containing the `'use server'` directive | Optional (the directive already enforces this) |
| Files imported only by other server-only files | Inherited — not strictly required, but harmless |

**Why this isn't paranoid:** Next.js inlines `process.env.NEXT_PUBLIC_*` at build time. Anything else (`SUPABASE_SERVICE_ROLE_KEY`, `STRIPE_SECRET_KEY`) only exists on the server — but its *reference* in code, once bundled, throws at runtime and leaks the variable name. `'server-only'` prevents the bundle from being attempted in the first place.

Reference: [Next.js — keeping server-only code out of the client environment](https://nextjs.org/docs/app/getting-started/server-and-client-components#keeping-server-only-code-out-of-the-client-environment)
