---
title: Configure expiresIn and updateAge Together for Sliding-Window Sessions
impact: HIGH
impactDescription: prevents both premature logout and indefinite session lifetime
tags: session, expiry, sliding-window, security
---

## Configure expiresIn and updateAge Together for Sliding-Window Sessions

Better Auth's session model is sliding-window: each session has a hard `expiresIn` lifetime, but `updateAge` controls how often the expiration is bumped forward on activity. Setting `expiresIn` without `updateAge` (or vice versa) gives you a non-sliding fixed-window session that boots active users back to sign-in mid-session. Setting `updateAge` to zero forces a DB write on every request. The canonical balance is ~7 day total lifetime with a daily slide.

**Incorrect (no updateAge — fixed 7-day window):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  session: {
    expiresIn: 60 * 60 * 24 * 7, // 7 days
    // updateAge missing — sessions never extend, active users logged out at day 7
  },
});
```

**Incorrect (updateAge: 0 — DB write per request):**

```typescript
session: {
  expiresIn: 60 * 60 * 24 * 7,
  updateAge: 0, // ← session.expiresAt rewritten on every request → write amplification
}
```

**Correct (sliding window, ~daily extension):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  session: {
    expiresIn: 60 * 60 * 24 * 7, // hard cap: 7 days from last extension
    updateAge: 60 * 60 * 24,     // slide forward at most once per day of activity
  },
});
```

**Benefits:**
- Active users never get unexpectedly logged out — each day of use extends the window.
- Inactive sessions expire on schedule (7 days from last activity).
- Database write pressure stays bounded (one update per user per day, not per request).

**When NOT to use sliding sessions:**
- Compliance contexts (PCI, HIPAA, SOC2 access control) sometimes mandate fixed absolute lifetimes. In those cases set a low `expiresIn` and require re-authentication — don't try to slide.

Reference: [Better Auth — Session Expiration](https://www.better-auth.com/docs/concepts/session-management#session-expiration)
