---
title: Override the Password Hash Function When Migrating from bcrypt/argon2
impact: HIGH
impactDescription: prevents forcing all migrated users to reset passwords on first sign-in
tags: security, password, hashing, migration
---

## Override the Password Hash Function When Migrating from bcrypt/argon2

Better Auth's default password hash is `scrypt`. NextAuth/Auth.js uses bcrypt, Clerk uses bcrypt, Auth0 uses bcrypt or scrypt-with-different-params. If you import legacy user rows with their existing hashes and don't tell Better Auth how to verify them, every migrated user fails to sign in and must reset their password — a destructive UX moment that bleeds users. Override `emailAndPassword.password.{hash, verify}` to use the legacy algorithm, or use a verify function that detects the format and dispatches.

**Incorrect (migrate bcrypt hashes from Clerk, use Better Auth defaults):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  emailAndPassword: { enabled: true },
  // Default scrypt verify against bcrypt hash → "invalid password" forever
});
```

**Correct (use bcrypt for hash AND verify):**

```typescript
import { betterAuth } from "better-auth";
import bcrypt from "bcryptjs";

export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
    password: {
      hash: async (password) => bcrypt.hash(password, 12),
      verify: async ({ hash, password }) => bcrypt.compare(password, hash),
    },
  },
});
```

**Alternative (gradual migration — accept both formats, rehash on next sign-in):**

```typescript
import { betterAuth } from "better-auth";
import bcrypt from "bcryptjs";
// scrypt verify imported from a small helper around node:crypto.scrypt

export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
    password: {
      hash: async (password) => {
        // New passwords use modern argon2/scrypt
        return scryptHash(password);
      },
      verify: async ({ hash, password }) => {
        // Detect legacy bcrypt format
        if (hash.startsWith("$2a$") || hash.startsWith("$2b$") || hash.startsWith("$2y$")) {
          const ok = await bcrypt.compare(password, hash);
          if (ok) {
            // Rehash with modern algorithm on next sign-in via databaseHooks.account.update
          }
          return ok;
        }
        return scryptVerify(password, hash);
      },
    },
  },
});
```

**Common use cases:**
- Migrating from Auth.js → Better Auth: stay on bcrypt to preserve all sessions; rehash gradually.
- Migrating from Auth0 with custom_password_hash: use Auth0's documented algorithm parameters in the verify function.

Reference: [Better Auth — Email/Password Custom Hashing](https://www.better-auth.com/docs/authentication/email-password#custom-password-hashing)
