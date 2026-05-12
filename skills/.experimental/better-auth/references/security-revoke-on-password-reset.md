---
title: Enable revokeSessionsOnPasswordReset to Invalidate All Active Sessions
impact: HIGH
impactDescription: prevents a leaked session from surviving a password reset by the legitimate owner
tags: security, password-reset, session-revocation
---

## Enable revokeSessionsOnPasswordReset to Invalidate All Active Sessions

The whole point of "reset my password" is "lock out whoever has my account." If Better Auth doesn't revoke existing sessions on reset, an attacker who already grabbed a session cookie can keep using it after the legitimate owner resets. The `revokeSessionsOnPasswordReset` option deletes every session row for the user atomically with the password update. This is opt-in (off by default) because some teams want continuity for benign password rotations, but for any user-facing reset flow it should be on.

**Incorrect (default — sessions survive password reset):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
    sendResetPassword: async ({ user, url }) => { /* ... */ },
    // revokeSessionsOnPasswordReset defaults to false
    // → attacker keeps using stolen session after victim resets
  },
});
```

**Correct (revoke on reset, optionally notify user):**

```typescript
import { betterAuth } from "better-auth";
import { sendEmail } from "@/lib/email";

export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
    sendResetPassword: async ({ user, url }) => {
      await sendEmail({ to: user.email, subject: "Reset your password", text: `Reset: ${url}` });
    },
    revokeSessionsOnPasswordReset: true, // ← invalidate all sessions atomically
    onPasswordReset: async ({ user }) => {
      // Side-effect: notify the user a reset happened (anti-takeover signal)
      await sendEmail({
        to: user.email,
        subject: "Your password was changed",
        text: "If this wasn't you, contact support immediately.",
      });
    },
  },
});
```

**Benefits:**
- Stolen sessions are invalidated atomically — no race between the reset commit and the revoke step.
- The `onPasswordReset` callback gives you a single hook for security side-effects (audit log, anti-takeover email, MFA re-challenge).
- Pairs cleanly with `cookieCache: { maxAge: 5 * 60 }` — old cookie caches expire within minutes even on stale tabs.

**When NOT to enable:** Internal admin tools where forced periodic password rotation is mandated by policy and signing every user out on rotation creates a support flood.

Reference: [Better Auth — Email/Password Options](https://www.better-auth.com/docs/authentication/email-password)
