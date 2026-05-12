---
title: Configure an Explicit baseURL Per Environment
impact: CRITICAL
impactDescription: prevents OAuth callback failures and incorrect redirect URLs
tags: setup, base-url, environment, oauth
---

## Configure an Explicit baseURL Per Environment

Better Auth uses `baseURL` to build callback URLs, redirect targets, and links it emails to users. When unset, it falls back to `BETTER_AUTH_URL` and then infers from the incoming `Host` header — which is wrong behind reverse proxies, in preview deploys, and when the client sends a different origin than the canonical URL. Wrong `baseURL` means OAuth providers reject the callback ("redirect_uri mismatch"), passwordless email links point to `localhost`, and password reset emails 404.

**Incorrect (relying on inference for OAuth-heavy app):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  // baseURL inferred from request — breaks on proxy/preview deploys
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
  },
});
```

**Correct (explicit baseURL from environment):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  baseURL: process.env.BETTER_AUTH_URL, // e.g. https://app.example.com in prod
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
  },
});
```

```env
# .env.production
BETTER_AUTH_URL=https://app.example.com

# .env.development
BETTER_AUTH_URL=http://localhost:3000
```

**Common use cases:**
- Vercel/Netlify preview deploys: set `BETTER_AUTH_URL` from the platform's preview URL env var, OR add the preview origin to provider redirect allowlists.
- Reverse proxy (Cloudflare, nginx): the proxy sets `X-Forwarded-Host` but Better Auth uses the raw `Host` unless told otherwise — explicit `baseURL` is the safe path.

Reference: [Better Auth — Options: baseURL](https://www.better-auth.com/docs/reference/options#baseurl)
