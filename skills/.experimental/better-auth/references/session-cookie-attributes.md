---
title: Set sameSite, secure, and partitioned for Cross-Site Auth Flows
impact: HIGH
impactDescription: prevents browsers from silently dropping cookies in third-party contexts
tags: session, cookies, samesite, cross-site
---

## Set sameSite, secure, and partitioned for Cross-Site Auth Flows

Better Auth's default cookies use `sameSite: "lax"` — safe for same-site flows but rejected by browsers when the auth API is on a different site than the frontend (subdomain in third-party context, iframe, embedded WebView). The required combination for cross-site cookies is `sameSite: "none"` + `secure: true` + `partitioned: true`. Setting only `sameSite: "none"` without `secure` makes Chrome and Firefox drop the cookie without an error. Missing `partitioned` will break in browsers enforcing CHIPS.

**Incorrect (third-party context with lax-default cookies):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  baseURL: "https://api.example.com",
  // App embedded as iframe at https://partner.com/dashboard
  // Default sameSite: "lax" — browser drops the auth cookie on the iframe
});
```

**Correct (cross-site cookie attributes):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  baseURL: "https://api.example.com",
  advanced: {
    defaultCookieAttributes: {
      sameSite: "none",
      secure: true,        // required when sameSite: "none"
      partitioned: true,   // CHIPS — required for third-party cookies in Chrome
    },
  },
});
```

**Alternative (override only the session cookie):**

```typescript
export const auth = betterAuth({
  advanced: {
    cookies: {
      sessionToken: {
        attributes: {
          sameSite: "none",
          secure: true,
          partitioned: true,
        },
      },
    },
  },
});
```

**Common use cases:**
- Embedded widget on a customer's site, auth API on yours.
- Mobile app loading a WebView from a different origin.
- Multi-app SSO where each app is a different effective top-level domain.

**Warning:** `secure: true` requires HTTPS — these settings will not work over `http://localhost` for cross-site testing. Use `mkcert` or a tunnel (ngrok, Cloudflare Tunnel) with TLS.

Reference: [Better Auth — Cookies](https://www.better-auth.com/docs/concepts/cookies)
