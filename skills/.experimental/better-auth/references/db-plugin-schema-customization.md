---
title: Rename Plugin Tables and Columns via the schema Option, Not Migrations
impact: HIGH
impactDescription: prevents Better Auth from querying wrong table/column names after manual renames
tags: db, schema, plugins, naming-convention
---

## Rename Plugin Tables and Columns via the schema Option, Not Migrations

Each plugin (`twoFactor`, `organization`, `admin`, `passkey`, etc.) introduces its own tables and columns with default names like `twoFactor`, `twoFactorEnabled`, `organizationId`. If your codebase uses snake_case columns (`two_factor_enabled`) or a different table prefix (`auth_*`), renaming via raw SQL migration leaves Better Auth still issuing queries against the original names. Plugin options accept a `schema` override that tells the library what names to use; this is the only safe way to align with your convention.

**Incorrect (renaming columns via migration, plugin queries break):**

```sql
ALTER TABLE "user" RENAME COLUMN "twoFactorEnabled" TO "two_factor_enabled";
ALTER TABLE "user" RENAME COLUMN "twoFactorSecret" TO "two_factor_secret";
```

```typescript
// twoFactor() still issues SELECT "twoFactorEnabled" FROM "user" — fails
plugins: [twoFactor()];
```

**Correct (tell the plugin what your column names are):**

```typescript
import { betterAuth } from "better-auth";
import { twoFactor } from "better-auth/plugins";

export const auth = betterAuth({
  plugins: [
    twoFactor({
      schema: {
        user: {
          fields: {
            twoFactorEnabled: "two_factor_enabled",
            secret: "two_factor_secret",
          },
        },
      },
    }),
  ],
});
```

```typescript
// Same pattern works for the core user/session/account/verification tables
export const auth = betterAuth({
  user: {
    modelName: "users",                // table renamed: user → users
    fields: {
      email: "email_address",          // column renamed
      emailVerified: "is_email_verified",
    },
  },
  session: {
    modelName: "user_sessions",
  },
});
```

**Implementation:** Always run `auth generate` after changing `schema`/`fields`/`modelName` — the CLI produces the correctly-named columns for your ORM.

Reference: [Better Auth — Database: Plugins Schema](https://www.better-auth.com/docs/concepts/database#plugins-schema)
