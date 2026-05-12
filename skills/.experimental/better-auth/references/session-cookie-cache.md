---
title: Enable cookieCache to Cut Session Database Lookups by 99%
impact: HIGH
impactDescription: 100x improvement in session lookup latency on cached hits
tags: session, performance, cache, cookies
---

## Enable cookieCache to Cut Session Database Lookups by 99%

Every server-side `auth.api.getSession` call defaults to a database query on the `session` table — once per request per authenticated route. With dozens of server components on a page, this becomes the dominant database workload. `cookieCache` stores a signed snapshot of the session in a short-lived cookie; subsequent reads validate the signature locally and skip the DB until the cache expires (recommended 5 minutes). The DB is still consulted for sign-out and for sessions older than `maxAge`.

**Incorrect (no cookie cache, every request hits DB):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  // No session.cookieCache — every getSession() is a SELECT on session table
});
```

**Correct (signed cookie cache, 5-minute window):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  session: {
    cookieCache: {
      enabled: true,
      maxAge: 5 * 60, // 5 minutes in seconds
    },
    expiresIn: 60 * 60 * 24 * 7,
    updateAge: 60 * 60 * 24,
  },
});
```

**Warning (revocation latency):** When cookieCache is enabled, sign-out and admin-driven session revocation are still applied immediately on the server, but stale cookies on other tabs/devices can remain valid until the cache window expires. For security-critical apps where instant revocation matters more than DB load, lower `maxAge` to 30 seconds or leave the feature off.

**When NOT to use cookieCache:**
- You revoke sessions frequently in response to security events (account takeover defense, "sign out everywhere") and need <1s revocation propagation.
- You mutate session-attached state (e.g., active organization, role) and need clients to see the change immediately.

Reference: [Better Auth — Cookie Cache](https://www.better-auth.com/docs/concepts/session-management#cookie-cache)
