---
title: Place nextCookies() as the LAST Plugin in Next.js Apps
impact: HIGH
impactDescription: prevents sign-in from server actions silently leaving cookies unset
tags: plugins, next-js, server-actions, cookies, ordering
---

## Place nextCookies() as the LAST Plugin in Next.js Apps

Next.js Server Actions run on the server but cannot set cookies via the `Response` object — they must call `cookies().set(...)` from `next/headers`. Better Auth's `nextCookies()` plugin intercepts cookie-setting operations and rewrites them to the Next API. It must run *after* every other plugin so it sees the final set of cookies each plugin wants to write. Placing it earlier (or omitting it entirely) makes `signIn.email`/`signUp.email`/`signOut` calls from server actions return success — but the browser never receives the session cookie, so the user appears unauthenticated on the next request.

**Incorrect (missing nextCookies, or not last):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { nextCookies } from "better-auth/next-js";
import { twoFactor, organization } from "better-auth/plugins";

export const auth = betterAuth({
  plugins: [
    nextCookies(),    // ← positioned first; later plugins set cookies it never sees
    twoFactor(),
    organization(),
  ],
});
```

**Correct (nextCookies LAST):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { nextCookies } from "better-auth/next-js";
import { twoFactor, organization } from "better-auth/plugins";

export const auth = betterAuth({
  plugins: [
    twoFactor(),
    organization(),
    nextCookies(), // ← always last in the array
  ],
});
```

**When NOT needed:**
- If you never call `auth.api.signInEmail`, `signUpEmail`, etc. from a server action (only from a route handler that returns its own `Response`), this plugin isn't required. But adding it is harmless and future-proofs against new server-action call sites.

**Warning:** This is Next.js-specific. SvelteKit, Astro, and Hono have their own cookie-setting paths that don't need this plugin.

Reference: [Better Auth — Next.js: Server Action Cookies](https://www.better-auth.com/docs/integrations/next#server-action-cookies-plugin)
