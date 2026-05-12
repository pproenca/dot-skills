---
title: Match the Client baseURL to the Server baseURL
impact: CRITICAL
impactDescription: prevents cross-origin auth failures and silent CORS rejections
tags: setup, client, base-url, cors
---

## Match the Client baseURL to the Server baseURL

`createAuthClient({ baseURL })` tells the client where to send sign-in, sign-up, and session requests. When the client and server share a domain you can omit it, but in any split deployment (separate API host, mobile app, browser extension, monorepo with multiple ports) it must point at the exact server `baseURL`. Mismatched origins fail CORS at the browser before Better Auth even sees the request, producing confusing "network error" UX with no server-side logs.

**Incorrect (mobile/extension/SPA with missing or wrong baseURL):**

```typescript
// apps/web/lib/auth-client.ts
import { createAuthClient } from "better-auth/react";

// Frontend on https://app.example.com, API on https://api.example.com
// — defaults to current origin, hits the wrong host
export const authClient = createAuthClient();
```

**Correct (explicit baseURL that matches the server):**

```typescript
// apps/web/lib/auth-client.ts
import { createAuthClient } from "better-auth/react";

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_API_URL, // https://api.example.com
});
```

```typescript
// lib/auth.ts (server)
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  baseURL: "https://api.example.com",
  trustedOrigins: ["https://app.example.com"], // also required — see security-trusted-origins
});
```

**Warning (framework imports):** Use the framework-specific entry — `better-auth/react`, `better-auth/vue`, `better-auth/svelte`, `better-auth/solid` — so `useSession()` returns the right reactive primitive (React hook, Vue ref, Svelte store).

Reference: [Better Auth — Installation: Create Client Instance](https://www.better-auth.com/docs/installation#create-client-instance)
