---
title: Add inferAdditionalFields to the Client to Keep Types in Sync
impact: HIGH
impactDescription: prevents type drift between server-defined user fields and client useSession types
tags: auth, client, type-safety, additional-fields
---

## Add inferAdditionalFields to the Client to Keep Types in Sync

When you extend the user schema via `additionalFields` on the server, the columns are created and the runtime API returns them — but the client SDK doesn't know about them by default. `authClient.useSession().data.user.role` shows up as `unknown` or doesn't exist at the type level, and every component reaches for `as any` to access the field. `inferAdditionalFields` reads the auth instance type at compile time and inflates the client types to match — no schema duplication, no runtime cost.

**Incorrect (server has additionalFields, client types are stale):**

```typescript
// lib/auth.ts
export const auth = betterAuth({
  user: {
    additionalFields: {
      role: { type: ["user", "admin"], required: false },
      tenantId: { type: "string", required: false },
    },
  },
});
```

```typescript
// lib/auth-client.ts
import { createAuthClient } from "better-auth/react";

export const authClient = createAuthClient();
```

```tsx
// component.tsx
const { data } = authClient.useSession();
const role = data?.user.role; // ← TS error: Property 'role' does not exist
```

**Correct (server type imported via inferAdditionalFields):**

```typescript
// lib/auth-client.ts
import { createAuthClient } from "better-auth/react";
import { inferAdditionalFields } from "better-auth/client/plugins";
import type { auth } from "@/lib/auth"; // type-only import — server bundle stays out of client

export const authClient = createAuthClient({
  plugins: [inferAdditionalFields<typeof auth>()],
});
```

```tsx
const { data } = authClient.useSession();
const role = data?.user.role; // typed as "user" | "admin" | undefined
```

**Alternative (cross-package monorepo without direct import):**

```typescript
// When the server auth lives in a different package, declare the shape inline
import { inferAdditionalFields } from "better-auth/client/plugins";

export const authClient = createAuthClient({
  plugins: [
    inferAdditionalFields({
      user: {
        role: { type: "string" },
        tenantId: { type: "string" },
      },
    }),
  ],
});
```

**Implementation:** Use `import type` (not a value import) so bundlers tree-shake the server `auth` instance entirely. The plugin only uses the type information at compile time.

Reference: [Better Auth — TypeScript: inferAdditionalFields](https://www.better-auth.com/docs/concepts/typescript#additional-fields)
