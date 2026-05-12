---
title: Extend the User Schema via additionalFields, Not Raw Columns
impact: CRITICAL
impactDescription: prevents type drift between database and Better Auth's session object
tags: db, additional-fields, type-safety, schema
---

## Extend the User Schema via additionalFields, Not Raw Columns

Adding a column directly to the `user` table — without telling Better Auth about it — leaves the field invisible to the auth API, the session response, and the client types. `additionalFields` is the canonical extension point: it generates the column when you run `auth generate`, includes the field on the user object returned by `auth.api.getSession`, and (paired with `inferAdditionalFields` on the client) flows the type through to `useSession()`. Bypassing it forces hand-rolled joins everywhere a downstream component needs the extra field.

**Incorrect (manual column, invisible to auth):**

```sql
-- Migration written by hand
ALTER TABLE "user" ADD COLUMN "role" TEXT NOT NULL DEFAULT 'user';
ALTER TABLE "user" ADD COLUMN "tenant_id" UUID;
```

```typescript
// session.user.role is undefined at the type level — must query separately
const session = await auth.api.getSession({ headers });
// @ts-expect-error — role isn't on the inferred user type
const role = session?.user.role;
```

**Correct (declare via additionalFields, regenerate schema):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  user: {
    additionalFields: {
      role: {
        type: ["user", "admin"],
        required: false,
        defaultValue: "user",
        input: false, // user can't set this themselves on signup
      },
      tenantId: {
        type: "string",
        required: false,
      },
    },
  },
});
```

```typescript
// lib/auth-client.ts (client-side type sync)
import { createAuthClient } from "better-auth/react";
import { inferAdditionalFields } from "better-auth/client/plugins";
import type { auth } from "@/lib/auth";

export const authClient = createAuthClient({
  plugins: [inferAdditionalFields<typeof auth>()],
});
```

```typescript
// Now typed correctly on both server and client
const session = await auth.api.getSession({ headers });
const role = session?.user.role; // typed as "user" | "admin" | undefined
```

**When NOT to use additionalFields:**
- Fields that don't belong on the user identity (e.g., profile preferences with their own lifecycle). Use a separate `profile` table with a foreign key to `user.id`.

Reference: [Better Auth — TypeScript: Additional Fields](https://www.better-auth.com/docs/concepts/typescript#additional-fields)
