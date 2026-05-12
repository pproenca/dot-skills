---
title: Match OAuth redirectURI Exactly With the Provider Console
impact: HIGH
impactDescription: prevents redirect_uri_mismatch on every OAuth attempt in non-default environments
tags: auth, oauth, redirect-uri, providers
---

## Match OAuth redirectURI Exactly With the Provider Console

OAuth providers (Google, GitHub, Apple, Discord, Facebook) compare the `redirect_uri` parameter byte-for-byte with the URLs registered in their developer console. Any mismatch — trailing slash, http vs https, different port, preview deploy URL — produces a `redirect_uri_mismatch` error before the user ever sees a sign-in screen. Better Auth defaults `redirectURI` to `{baseURL}/api/auth/callback/{provider}`; if your `baseURL` is correct this works out of the box, but multi-environment deployments need either explicit `redirectURI` or every URL registered upstream.

**Incorrect (default redirectURI but provider only has prod URL registered):**

```typescript
// lib/auth.ts on a preview deploy at https://pr-42.preview.example.com
export const auth = betterAuth({
  baseURL: process.env.BETTER_AUTH_URL, // = preview URL
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
      // Google Cloud Console only has https://app.example.com/api/auth/callback/google registered
      // → redirect_uri_mismatch on every preview
    },
  },
});
```

**Correct (single registered prod URL, force redirectURI to match):**

```typescript
export const auth = betterAuth({
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
      redirectURI: "https://app.example.com/api/auth/callback/google", // always prod
    },
  },
});
```

**Alternative (register every callback URL in the provider console):**

```text
Google Cloud Console → OAuth 2.0 Client → Authorized redirect URIs:
  https://app.example.com/api/auth/callback/google
  https://staging.example.com/api/auth/callback/google
  https://*.preview.example.com/api/auth/callback/google   ← if provider supports wildcards
  http://localhost:3000/api/auth/callback/google
```

```typescript
// Default redirectURI now resolves correctly for each environment
export const auth = betterAuth({
  baseURL: process.env.BETTER_AUTH_URL,
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
  },
});
```

**Warning:** Google does not support wildcards in production redirect URIs. For per-PR previews against Google, use the forced-prod-URI approach and pass the original location through state, or use a separate Google project for staging.

Reference: [Better Auth — Social Providers](https://www.better-auth.com/docs/authentication/google)
