---
title: Configure trustedOrigins for All Non-baseURL Callers
impact: CRITICAL
impactDescription: prevents CSRF-blocked sign-ins from extensions, mobile apps, and preview deploys
tags: setup, trusted-origins, csrf, cors
---

## Configure trustedOrigins for All Non-baseURL Callers

Better Auth's built-in CSRF defense rejects requests whose `Origin` header isn't `baseURL` and isn't in `trustedOrigins`. This is correct by default — it stops cross-site form posts that would otherwise authenticate a victim. But the moment you have a separate frontend host, a browser extension, a mobile WebView, a preview deploy URL, or a localhost dev origin pointing at a remote API, sign-in silently fails with a 403 until you list the origin.

**Incorrect (split-host app without trustedOrigins):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  baseURL: "https://api.example.com",
  // Frontend at https://app.example.com — every sign-in is rejected as CSRF
});
```

**Correct (all caller origins explicitly trusted):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  baseURL: "https://api.example.com",
  trustedOrigins: [
    "https://app.example.com",          // production web
    "https://*.preview.example.com",    // preview deploys (wildcard subdomain)
    "chrome-extension://abcdef...",     // browser extension
    "http://localhost:3000",            // local dev pointing at staging API
  ],
});
```

**Common use cases:**
- Browser extensions: the `chrome-extension://<id>` or `moz-extension://<id>` origin must be listed.
- Mobile apps using WebView: the WebView origin may be `null` or `capacitor://localhost` — list whichever applies.
- Monorepo dev: `pnpm dev` on a different port than the API needs `http://localhost:<port>` listed.

**Warning:** Never use a wildcard `"*"` or include user-controlled domains — this bypasses CSRF protection entirely. See [`security-trusted-origins-strict`](security-trusted-origins-strict.md) for the security implications and dynamic allowlist patterns.

Reference: [Better Auth — Options: trustedOrigins](https://www.better-auth.com/docs/reference/options#trustedorigins)
