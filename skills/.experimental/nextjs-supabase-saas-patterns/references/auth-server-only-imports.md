---
title: Mark Server-Only Modules with `import 'server-only'`
impact: CRITICAL
impactDescription: prevents server secrets from bundling into the client
tags: auth, server-only, secrets, bundle
---

## Mark Server-Only Modules with `import 'server-only'`

A server action, loader, admin client, or service that accidentally gets imported by a client component will be tree-shaken into the client bundle along with anything it imports — including service-role keys and webhook secrets. `import 'server-only'` is a build-time poison pill: the import resolves successfully on the server and fails the build on the client, catching the mistake before deploy.

**Incorrect (admin client with no server-only marker):**

```ts
// packages/supabase/src/clients/server-admin-client.ts
import { createClient } from '@supabase/supabase-js';
import { getSupabaseSecretKey } from '../get-secret-key';

// A client component that imports this by mistake compiles fine
// and ships the service-role-key reading code to the browser.
export function getSupabaseServerAdminClient() {
  const secretKey = getSupabaseSecretKey();
  return createClient(url, secretKey);
}
```

**Correct (build fails if a client component imports this file):**

```ts
// packages/supabase/src/clients/server-admin-client.ts
import 'server-only';
import { createClient } from '@supabase/supabase-js';
import { getSupabaseSecretKey } from '../get-secret-key';

export function getSupabaseServerAdminClient() {
  const secretKey = getSupabaseSecretKey();
  return createClient(url, secretKey);
}
```

**Where this marker belongs:**

| File pattern | Add `import 'server-only'`? |
|--------------|-----------------------------|
| `**/clients/server-client.ts` | Yes |
| `**/clients/server-admin-client.ts` | Yes |
| `**/clients/middleware-client.ts` | Yes |
| `**/_lib/server/**/*.ts` (loaders, services) | Yes |
| `**/server/services/*.ts` | Yes |
| `**/safe-action-client.ts` | Yes |
| `**/routes/index.ts` (route handler wrappers) | Yes |
| Files containing `'use server'` directive | Optional (the directive already enforces this) |
| Files imported only by other server-only files | Inherited — not strictly required, but harmless |

**Why this isn't paranoid:** Next.js inlines `process.env.NEXT_PUBLIC_*` at build time. Anything else (`SUPABASE_SECRET_KEY`, `STRIPE_SECRET_KEY`) only exists on the server — but its *reference* in code, once bundled, will throw at runtime and leak the variable name. `'server-only'` prevents the bundle from being attempted in the first place.

Reference: [Next.js server-only package](https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns#keeping-server-only-code-out-of-the-client-environment)
