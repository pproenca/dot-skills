---
title: Enable crossSubDomainCookies for Multi-Subdomain Apps
impact: HIGH
impactDescription: prevents users from having to re-authenticate when navigating between subdomains
tags: session, cookies, subdomain, multi-app
---

## Enable crossSubDomainCookies for Multi-Subdomain Apps

When sign-in happens on `auth.example.com` but the dashboard lives on `app.example.com`, the default cookie scope (`Domain=auth.example.com`) prevents the dashboard from reading the session — the user appears unauthenticated after redirect. The fix is to scope the cookie to the parent domain (`.example.com`) via `crossSubDomainCookies` + add every subdomain to `trustedOrigins`. Setting only one or the other breaks the flow: scoping without trusting causes CSRF rejections; trusting without scoping leaves the cookie inaccessible.

**Incorrect (multi-subdomain app with default cookie scope):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  baseURL: "https://auth.example.com",
  // Default cookie domain = auth.example.com — invisible to app.example.com
});
```

**Correct (cookie scoped to parent domain + all origins trusted):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  baseURL: "https://auth.example.com",
  advanced: {
    crossSubDomainCookies: {
      enabled: true,
      domain: ".example.com", // leading dot makes the cookie visible to all subdomains
    },
  },
  trustedOrigins: [
    "https://app.example.com",
    "https://admin.example.com",
    "https://billing.example.com",
  ],
});
```

**Warning (eTLD+1 only):** The `domain` must be the registrable domain (`example.com`), not a public suffix (`co.uk`, `vercel.app`). Browsers reject cookies scoped to public suffixes. If you're on `*.vercel.app`, you cannot share cookies across vercel.app subdomains — you need a custom domain.

**When NOT to enable:**
- Single-domain apps. The default scope is more restrictive (safer) and shaves a few bytes off every request.
- When subdomains have different trust levels (e.g., `user-content.example.com` for user-uploaded HTML) — leaking the session cookie there is a security hole.

Reference: [Better Auth — Cross-Subdomain Cookies](https://www.better-auth.com/docs/concepts/cookies#cross-subdomain-cookies)
