---
title: Run auth generate Then Your ORM Migrate Before Every Deploy
impact: CRITICAL
impactDescription: prevents all auth endpoints from 500-erroring after a plugin is added
tags: db, schema, migration, cli
---

## Run auth generate Then Your ORM Migrate Before Every Deploy

Better Auth's schema is owned by the library and discovered from your auth config — including any plugins you've added (2FA, organization, admin, passkey each add tables and columns). The `auth generate` CLI inspects your config and writes a schema fragment (Drizzle/Prisma) or raw SQL (Kysely). You then apply it with your ORM's migration tool. Skipping `generate` after adding a plugin means the plugin's endpoints fail at runtime; skipping the migrate step means production starts without the tables.

**Incorrect (adding a plugin without regenerating schema):**

```typescript
// lib/auth.ts — added twoFactor plugin
import { betterAuth } from "better-auth";
import { twoFactor } from "better-auth/plugins";

export const auth = betterAuth({
  // ...
  plugins: [twoFactor()], // adds twoFactorEnabled, secret, backupCodes columns
});
```

```bash
# Forgot to regenerate — twoFactor table missing in prod
git push origin main
```

**Correct (regenerate + migrate as part of CI/CD):**

```bash
# 1. Regenerate Better Auth schema from current config
npx @better-auth/cli@latest generate

# 2. Apply with your ORM
# Drizzle:
npx drizzle-kit generate
npx drizzle-kit migrate

# Prisma:
npx prisma migrate dev --name add_two_factor
# (in CI) npx prisma migrate deploy

# Kysely (built-in adapter only):
npx @better-auth/cli@latest migrate
```

**Implementation (package.json scripts):**

```json
{
  "scripts": {
    "auth:generate": "better-auth generate",
    "db:migrate": "drizzle-kit migrate",
    "predeploy": "npm run auth:generate && drizzle-kit generate && npm run db:migrate"
  }
}
```

**Warning:** `better-auth migrate` only works with the built-in Kysely adapter. For Prisma/Drizzle, you must use the ORM's own migration command after `generate`.

Reference: [Better Auth — CLI](https://www.better-auth.com/docs/concepts/cli)
