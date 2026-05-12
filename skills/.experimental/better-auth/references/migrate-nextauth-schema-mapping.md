---
title: Map NextAuth v5 Tables to Better Auth Schema Field-by-Field
impact: MEDIUM
impactDescription: prevents silent data loss when adapter expects fields the legacy schema doesn't have
tags: migrate, next-auth, auth-js, schema-mapping
---

## Map NextAuth v5 Tables to Better Auth Schema Field-by-Field

NextAuth/Auth.js v5 and Better Auth use similar but non-identical schemas. The table names match (`user`, `session`, `account`, `verification`) but several columns differ in name, type, or nullability — and silently inserting the new schema on top of the old one drops the fields that don't match. The migration must explicitly map each Auth.js column to its Better Auth equivalent. The most common mismatches:

| Auth.js column | Better Auth column | Notes |
|---|---|---|
| `user.emailVerified` (Date or null) | `user.emailVerified` (boolean) | Type change — null/`new Date(...)` → false/true |
| `account.access_token` | `account.accessToken` | snake_case → camelCase |
| `account.expires_at` (unix seconds) | `account.accessTokenExpiresAt` (Date) | format change |
| `account.session_state` | (removed) | not used by Better Auth |
| `session.sessionToken` | `session.token` | renamed |
| `verificationToken` (table) | `verification` (table) | renamed |

**Incorrect (rename only the table, leave columns mismatched):**

```sql
ALTER TABLE "verificationToken" RENAME TO "verification";
-- Better Auth queries verification.identifier but the column is named identifier too — looks fine
-- but session.sessionToken still queried as session.token → reads return null on every session
```

**Correct (explicit per-column migration):**

```sql
-- user: emailVerified Date → boolean
ALTER TABLE "user" ADD COLUMN "emailVerified_new" BOOLEAN NOT NULL DEFAULT false;
UPDATE "user" SET "emailVerified_new" = ("emailVerified" IS NOT NULL);
ALTER TABLE "user" DROP COLUMN "emailVerified";
ALTER TABLE "user" RENAME COLUMN "emailVerified_new" TO "emailVerified";

-- account: rename + reshape OAuth token fields
ALTER TABLE "account" RENAME COLUMN "access_token" TO "accessToken";
ALTER TABLE "account" RENAME COLUMN "refresh_token" TO "refreshToken";
ALTER TABLE "account" ADD COLUMN "accessTokenExpiresAt" TIMESTAMP;
UPDATE "account" SET "accessTokenExpiresAt" = to_timestamp("expires_at") WHERE "expires_at" IS NOT NULL;
ALTER TABLE "account" DROP COLUMN "expires_at";
ALTER TABLE "account" DROP COLUMN "session_state";

-- session: rename column
ALTER TABLE "session" RENAME COLUMN "sessionToken" TO "token";

-- verification token table rename
ALTER TABLE "verificationToken" RENAME TO "verification";
```

**Alternative (run a script through the adapter rather than raw SQL):**

```typescript
// Safer: use the adapter so you get type checking and Better Auth's own normalization
for (const legacy of await legacyDb.query.user.findMany()) {
  await ctx.adapter.create({
    model: "user",
    data: {
      id: legacy.id,
      email: legacy.email,
      emailVerified: legacy.emailVerified !== null, // Date → boolean
      name: legacy.name,
      image: legacy.image,
    },
    forceAllowId: true,
  });
}
```

**Implementation:** Run `npx @better-auth/cli@latest generate` against your target config first to see the exact schema Better Auth expects, then diff against your legacy schema to identify every mismatch. Don't trust the table names matching.

Reference: [Better Auth — NextAuth Migration Guide](https://www.better-auth.com/docs/guides/next-auth-migration-guide)
