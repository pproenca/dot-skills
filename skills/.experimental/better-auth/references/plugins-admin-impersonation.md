---
title: Use admin Plugin's impersonate Method for Support Access, Not Manual Session Creation
impact: MEDIUM
impactDescription: prevents support sessions from looking indistinguishable from real user sessions in audit logs
tags: plugins, admin, impersonation, audit
---

## Use admin Plugin's impersonate Method for Support Access, Not Manual Session Creation

Support and admin teams routinely need to "log in as" a user to reproduce a bug or fix a state issue. The wrong pattern is to create a session row directly in the database for the target user — it works, but audit logs show "user X signed in from admin's IP" with no trace that an admin was the actor, and every downstream system sees a normal user session. The `admin` plugin's impersonation flow creates a session that carries both the impersonator's ID and the target's ID, so audit trails, suspicious-activity detection, and revocation policies can treat it correctly.

**Incorrect (manually creating a session for the target user):**

```typescript
// Admin clicks "Login as user" in internal tool
await db.insert(session).values({
  userId: targetUserId,
  expiresAt: new Date(Date.now() + 60 * 60 * 1000),
  token: generateToken(),
});
// No record of WHO impersonated → audit log shows the target user signed in
```

**Correct (admin plugin impersonation):**

```typescript
// lib/auth.ts (server)
import { betterAuth } from "better-auth";
import { admin } from "better-auth/plugins";

export const auth = betterAuth({
  plugins: [admin({ /* ac, roles */ })],
});
```

```typescript
// Internal admin tool
import { authClient } from "@/lib/auth-client";

// Only callable when authClient session has admin role
const { data } = await authClient.admin.impersonateUser({ userId: "target-user-id" });
// session is now the target user, but session.impersonatedBy = <admin user id>
```

```typescript
// Server-side audit middleware
const session = await auth.api.getSession({ headers });
if (session?.session.impersonatedBy) {
  await audit.log({
    event: "impersonated_action",
    impersonator: session.session.impersonatedBy,
    user: session.user.id,
    request: req.url,
  });
}
```

**Implementation (UX considerations):**
- Always render an obvious "Impersonating <name> — stop" banner in the UI when `session.impersonatedBy` is set.
- Use `authClient.admin.stopImpersonating()` to return to the original admin session in one step.
- Restrict the impersonate permission to support team roles, not all admins (least privilege).

Reference: [Better Auth — Admin Plugin](https://www.better-auth.com/docs/plugins/admin)
