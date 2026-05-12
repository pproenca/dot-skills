---
title: Set minPasswordLength to At Least 10, Not the Default 8
impact: MEDIUM-HIGH
impactDescription: prevents trivially-brute-forceable passwords from being accepted at signup
tags: security, password, policy
---

## Set minPasswordLength to At Least 10, Not the Default 8

Better Auth's default `minPasswordLength` is 8 — a value carried forward from the NIST 800-63B 2017 guidance that is now considered weak. Modern recommendation (NIST 800-63B-4 draft, OWASP ASVS) is at least 8 with strong rate-limiting, or 10+ for general accounts and 14+ for admin. Raising the minimum at signup costs nothing and immediately deflects the most common credential-spray attempts. Combine with `rateLimit` on the sign-in path — neither setting alone is sufficient.

**Incorrect (default 8 with no enforcement of complexity):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
    // minPasswordLength defaults to 8
  },
});
```

**Correct (10 minimum, plus complementary rate-limiting):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
    minPasswordLength: 10,
    maxPasswordLength: 256, // allow passphrases; default 128 is okay too
  },
  rateLimit: {
    enabled: true,
    customRules: {
      "/sign-in/email": { window: 60, max: 5 }, // 5 attempts/min/IP
    },
  },
});
```

**Implementation (UI-level password strength check on the client):**

```tsx
"use client";
import { zxcvbn } from "@zxcvbn-ts/core";

export function PasswordField({ value, onChange }) {
  const score = zxcvbn(value).score; // 0..4
  return (
    <>
      <input type="password" value={value} onChange={(e) => onChange(e.target.value)} />
      <meter min={0} max={4} value={score} />
      {value.length < 10 && <span>At least 10 characters</span>}
    </>
  );
}
```

**Warning:** Don't combine length minimums with mandatory character-class rules ("must contain a symbol") — modern guidance is that such rules push users to predictable patterns (`Password1!`) and add no entropy. Length + a breach-list check (HIBP API) gives more security than complexity rules.

Reference: [Better Auth — Options: emailAndPassword](https://www.better-auth.com/docs/reference/options)
