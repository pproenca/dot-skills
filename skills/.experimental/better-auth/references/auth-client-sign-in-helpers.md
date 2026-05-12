---
title: Use authClient.signIn.social with callbackURL Instead of Hand-Rolled Redirects
impact: HIGH
impactDescription: prevents bypassing the CSRF state token and provider linking logic
tags: auth, client, oauth, redirects
---

## Use authClient.signIn.social with callbackURL Instead of Hand-Rolled Redirects

It's tempting to skip the client SDK and `window.location.href = "/api/auth/sign-in/social?provider=github"` directly. This skips the CSRF state token Better Auth generates, the deep-link `callbackURL` parameter validation, and the `linkAccount` path that connects new OAuth identities to existing users. The result: OAuth completes but the user lands on a generic page, the state token is missing (request rejected), or accounts that should merge stay separate.

**Incorrect (hand-rolled redirect to the auth endpoint):**

```tsx
"use client";

export function SignInButton() {
  return (
    <button
      onClick={() => {
        window.location.href = "/api/auth/sign-in/social?provider=github&redirect=/dashboard";
        // ↑ no state token, no callbackURL validation, no link-account handling
      }}
    >
      Sign in with GitHub
    </button>
  );
}
```

**Correct (signIn.social with callbackURL):**

```tsx
"use client";
import { authClient } from "@/lib/auth-client";

export function SignInButton() {
  return (
    <button
      onClick={async () => {
        await authClient.signIn.social({
          provider: "github",
          callbackURL: "/dashboard",         // where to land after success
          errorCallbackURL: "/sign-in?err=1", // where to land on failure
          newUserCallbackURL: "/welcome",    // distinguishes first-time users
        });
      }}
    >
      Sign in with GitHub
    </button>
  );
}
```

**Correct (email/password with structured error handling):**

```typescript
const { data, error } = await authClient.signIn.email({
  email,
  password,
  callbackURL: "/dashboard",
});

if (error) {
  // Structured: error.code === "INVALID_EMAIL_OR_PASSWORD" | "EMAIL_NOT_VERIFIED" | ...
  toast.error(error.message);
  return;
}
// data.user is typed including any additionalFields
```

**Benefits:**
- The SDK adds the CSRF token, normalizes the response, and surfaces typed errors.
- `callbackURL` is validated against `trustedOrigins` — protects against open-redirect bugs.
- `newUserCallbackURL` lets you route first-time sign-ins to an onboarding flow without checking `createdAt` in the page.

Reference: [Better Auth — Client](https://www.better-auth.com/docs/concepts/client)
