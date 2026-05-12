---
title: Run Better Auth Alongside Legacy Auth During Cutover, Don't Big-Bang Switch
impact: MEDIUM
impactDescription: prevents locking out users whose data didn't migrate cleanly
tags: migrate, cutover, deployment, strategy
---

## Run Better Auth Alongside Legacy Auth During Cutover, Don't Big-Bang Switch

Migrating from NextAuth/Auth.js, Clerk, Auth0, or Supabase Auth involves moving user rows, OAuth account links, password hashes, and active sessions — any of which can have data quality issues that surface only on first sign-in attempt. Cutting traffic from old auth → new auth atomically means every issue becomes a customer-facing outage. The safer pattern is dual-write/dual-read: both systems operate, Better Auth becomes the source of truth gradually, and rollback is a config change rather than a restore-from-backup.

**Incorrect (big-bang cutover):**

```text
Day N-1: NextAuth running, all users sign in fine
Day N:   Deploy → NextAuth removed, Better Auth replaces /api/auth
         ↓
         5% of users hit a bug: case-sensitive email mismatch, missing OAuth link, ...
         ↓
         5% of users are locked out, support gets buried, rollback is hard
```

**Correct (parallel deploy with feature flag, gradual cutover):**

```typescript
// app/api/auth/[...all]/route.ts
import { auth } from "@/lib/auth";              // Better Auth instance
import { handlers as nextAuth } from "@/lib/next-auth"; // legacy
import { toNextJsHandler } from "better-auth/next-js";

const betterAuthHandler = toNextJsHandler(auth);

export async function GET(req: Request) {
  // Cohort routing — flag controls which users go to new auth
  if (await shouldUseBetterAuth(req)) return betterAuthHandler.GET(req);
  return nextAuth.GET(req);
}

export async function POST(req: Request) {
  if (await shouldUseBetterAuth(req)) return betterAuthHandler.POST(req);
  return nextAuth.POST(req);
}
```

**Implementation (cohort cutover progression):**

```text
Week 1: 1% of new sign-ups → Better Auth.   Old users stay on legacy.
Week 2: 10% of new + 5% of returning.        Watch error rate, support tickets.
Week 3: 50% / 25%.                            Backfill failed migrations.
Week 4: 100% of new, 100% of returning.      Legacy in shadow mode (dual-write only).
Week 6: Disable legacy writes.
Week 8: Remove legacy auth code.
```

**Common use cases:**
- Migrate sign-up traffic first (no legacy state to honor) — gets you Better Auth in production faster.
- Backfill on read: when a legacy user signs in, lazy-migrate their row into Better Auth's schema.
- Keep legacy hash format for old users (see security-password-hash-interop) — don't force password resets.

**Warning:** Plan the cutover BEFORE writing migration scripts. Knowing the rollback story shapes what "successful migration" means — you cannot roll back schema changes that have been live for two weeks.

Reference: [Better Auth — Migration Guides](https://www.better-auth.com/docs/guides/next-auth-migration-guide)
