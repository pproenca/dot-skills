---
title: Use customSession to Add Computed Fields to the Session Response
impact: MEDIUM-HIGH
impactDescription: prevents N+1 database queries from every protected page joining session→user→role
tags: session, plugins, performance, custom-session
---

## Use customSession to Add Computed Fields to the Session Response

Every protected route typically needs more than just user.id from the session — current organization, active role, feature flags, subscription tier. The naive pattern is to call `getSession()` then issue another query for each derived field, creating an N+queries pattern on every authenticated request. `customSession` lets you augment the session response server-side at session-fetch time, computing those fields in a single round-trip that integrates with the cookie cache.

**Incorrect (multi-query pattern on every page):**

```typescript
// app/dashboard/page.tsx
const session = await auth.api.getSession({ headers });
if (!session) redirect("/sign-in");

const member = await db.query.member.findFirst({  // ← extra query
  where: and(eq(member.userId, session.user.id), eq(member.organizationId, activeOrg)),
});
const subscription = await stripe.subscriptions.retrieve(/* ... */); // ← extra round-trip
```

**Correct (customSession plugin computes fields once per session):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { customSession } from "better-auth/plugins";
import { db } from "@/db";

export const auth = betterAuth({
  plugins: [
    customSession(async ({ user, session }) => {
      const member = await db.query.member.findFirst({
        where: eq(member.userId, user.id),
        with: { organization: true },
      });
      return {
        user,
        session,
        activeOrganization: member?.organization,
        role: member?.role ?? "guest",
      };
    }),
  ],
  // Pair with cookieCache so the augmented payload is reused for 5 minutes
  session: { cookieCache: { enabled: true, maxAge: 5 * 60 } },
});
```

```typescript
// app/dashboard/page.tsx — single call, all fields available
const session = await auth.api.getSession({ headers: await headers() });
if (!session) redirect("/sign-in");
const { user, role, activeOrganization } = session; // typed correctly via inferAdditionalFields
```

**Warning (cache invalidation):** Fields added by customSession are baked into the cookie cache for `maxAge`. If you mutate the underlying data (e.g., switch the active organization), you must rotate the session via `auth.api.updateSession` or set `cookieCache.maxAge` low enough to tolerate staleness.

Reference: [Better Auth — customSession Plugin](https://www.better-auth.com/docs/plugins/custom-session)
