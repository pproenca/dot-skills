---
title: Set appName as the 2FA Issuer for Authenticator App Display
impact: MEDIUM
impactDescription: prevents users seeing "Better Auth" in their authenticator app instead of your brand
tags: plugins, 2fa, totp, branding
---

## Set appName as the 2FA Issuer for Authenticator App Display

When the `twoFactor` plugin enrolls a user, it embeds an `issuer` field in the otpauth:// URI scanned by Google Authenticator, 1Password, Authy, etc. That string is what users see next to the rotating code: "Better Auth (user@example.com)" by default — confusing for end users who don't know what Better Auth is, and a support headache when they have multiple TOTP entries from different apps. Better Auth uses your top-level `appName` as the issuer, so setting `appName` correctly is the entire fix.

**Incorrect (no appName, generic display):**

```typescript
import { betterAuth } from "better-auth";
import { twoFactor } from "better-auth/plugins";

export const auth = betterAuth({
  plugins: [twoFactor()], // issuer falls back to "Better Auth"
});
```

**Correct (appName flows through as TOTP issuer):**

```typescript
import { betterAuth } from "better-auth";
import { twoFactor } from "better-auth/plugins";

export const auth = betterAuth({
  appName: "Example",   // ← shown as "Example (user@example.com)" in authenticator apps
  plugins: [
    twoFactor({
      // Optional: customize OTP length, expiry, backup codes
      otpOptions: { period: 30, digits: 6 },
      backupCodes: { length: 10, amount: 10 },
    }),
  ],
});
```

```typescript
// Client side — pair with the matching client plugin
import { createAuthClient } from "better-auth/react";
import { twoFactorClient } from "better-auth/client/plugins";

export const authClient = createAuthClient({
  plugins: [
    twoFactorClient({
      onTwoFactorRedirect() {
        window.location.href = "/two-factor";
      },
    }),
  ],
});
```

**Warning:** Don't rename `appName` after launch — users with existing TOTP enrollments will see two entries (old + new) in their authenticator app and the new entry won't match secrets they've already saved. If a rename is unavoidable, force re-enrollment via a migration.

Reference: [Better Auth — Two Factor Plugin](https://www.better-auth.com/docs/plugins/2fa)
