---
title: Use the jwt Plugin Only for External Service Consumers, Not Your Own Frontend
impact: MEDIUM
impactDescription: prevents needlessly turning revocable session cookies into long-lived bearer tokens
tags: plugins, jwt, sessions, security
---

## Use the jwt Plugin Only for External Service Consumers, Not Your Own Frontend

Better Auth's primary session model is database-backed: every session is a row, sign-out deletes it, and revocation is instant. The `jwt` plugin issues stateless signed tokens — useful when you have a downstream service that can't share your database (mobile backends, microservices, third-party API consumers). It's not a "lighter alternative" to sessions: JWTs can't be revoked before expiry without a denylist, leak in browser history if put in URLs, and don't get the benefits of `cookieCache`. Use it as an addition for specific consumers, not a replacement.

**Incorrect (JWT plugin used for first-party web client just because it sounds modern):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { jwt } from "better-auth/plugins";

export const auth = betterAuth({
  plugins: [jwt()], // for the web frontend → sign-out can't revoke until token expires
});
```

```tsx
// frontend storing JWT in localStorage
const { data } = await authClient.signIn.email({ email, password });
localStorage.setItem("jwt", data.token); // ← XSS-readable, can't be revoked
```

**Correct (web frontend uses session cookies; JWT only for an external service):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { jwt } from "better-auth/plugins";

export const auth = betterAuth({
  plugins: [
    jwt({
      jwks: { /* key rotation config */ },
      jwt: {
        expirationTime: "15m", // SHORT — JWTs can't be revoked, keep window tight
        audience: "downstream-api.example.com",
      },
    }),
  ],
});
```

```typescript
// Web frontend: session cookies (default) — revocable, no JWT touched
const { data } = await authClient.signIn.email({ email, password });

// Backend issues a JWT only when forwarding to the downstream service
const session = await auth.api.getSession({ headers });
const token = await auth.api.getToken({ session }); // short-lived JWT
const downstreamResp = await fetch("https://downstream-api.example.com/...", {
  headers: { Authorization: `Bearer ${token}` },
});
```

**Alternative (mobile native app — JWT is appropriate; cookies aren't):**

```typescript
// React Native client can't use cookies easily; JWT in keychain is the right tradeoff
const { token } = await authClient.getToken();
await SecureStore.setItemAsync("auth-token", token);
```

**Warning:** If you must use JWT for a long-lived first-party client, pair with a server-side denylist (per-user "minimum-issued-at" timestamp) so security events can invalidate all outstanding tokens. Without that, "sign out everywhere" is impossible until natural expiry.

Reference: [Better Auth — JWT Plugin](https://www.better-auth.com/docs/plugins/jwt)
