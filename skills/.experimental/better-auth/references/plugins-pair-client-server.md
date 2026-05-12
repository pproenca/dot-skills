---
title: Pair Every Server Plugin With Its Client Counterpart
impact: MEDIUM-HIGH
impactDescription: prevents authClient method calls from being undefined at runtime
tags: plugins, client-server, type-safety
---

## Pair Every Server Plugin With Its Client Counterpart

Most Better Auth plugins ship as two pieces: a server plugin (`better-auth/plugins`) that defines endpoints and a client plugin (`better-auth/client/plugins`) that adds method bindings (`authClient.twoFactor.enable`, `authClient.organization.create`, `authClient.magicLink.signIn`). Adding only the server side leaves the API surface accessible via raw `fetch`, but the typed methods are missing — every component that tries `authClient.magicLink.signIn({ email })` gets a TypeError at runtime and a missing-property error at compile time.

**Incorrect (server plugin enabled, no client plugin):**

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth";
import { magicLink, twoFactor, organization } from "better-auth/plugins";

export const auth = betterAuth({
  plugins: [magicLink({ sendMagicLink }), twoFactor(), organization({ ac, roles })],
});
```

```typescript
// lib/auth-client.ts — client plugins missing
import { createAuthClient } from "better-auth/react";

export const authClient = createAuthClient(); // ← no plugins → no .magicLink, .twoFactor, .organization
```

```tsx
await authClient.signIn.magicLink({ email }); // ← TypeError: signIn.magicLink is not a function
```

**Correct (every server plugin paired):**

```typescript
// lib/auth-client.ts
import { createAuthClient } from "better-auth/react";
import {
  magicLinkClient,
  twoFactorClient,
  organizationClient,
  inferAdditionalFields,
} from "better-auth/client/plugins";
import { ac, owner, admin, member } from "./permissions";
import type { auth } from "./auth";

export const authClient = createAuthClient({
  plugins: [
    inferAdditionalFields<typeof auth>(),
    magicLinkClient(),
    twoFactorClient({
      onTwoFactorRedirect() { window.location.href = "/two-factor"; },
    }),
    organizationClient({ ac, roles: { owner, admin, member } }),
  ],
});
```

**Implementation (pairing table — keep this in sync with `auth.ts`):**

| Server plugin | Client plugin |
|---|---|
| `magicLink` | `magicLinkClient` |
| `twoFactor` | `twoFactorClient` |
| `organization` | `organizationClient` |
| `admin` | `adminClient` |
| `username` | `usernameClient` |
| `passkey` | `passkeyClient` |
| `emailOTP` | `emailOTPClient` |
| `anonymous` | `anonymousClient` |
| `multiSession` | `multiSessionClient` |
| `jwt` | (no client plugin — JWT consumers use the JWKS endpoint) |
| `nextCookies` | (no client plugin — server-only) |

**Warning:** The reverse asymmetry is also a bug — a client plugin without its server counterpart will produce 404s when the client calls its endpoints.

Reference: [Better Auth — Plugins](https://www.better-auth.com/docs/concepts/plugins)
