---
title: Gate the Admin Client Behind an Explicit Authorization Check
impact: CRITICAL
impactDescription: prevents privilege escalation when RLS is bypassed
tags: auth, supabase, admin-client, super-admin
---

## Gate the Admin Client Behind an Explicit Authorization Check

`getSupabaseServerAdminClient()` is the only escape hatch from RLS — once constructed, the caller can read or mutate any tenant's data. Every call site must perform an explicit authorization check first (`isSuperAdmin()`, a feature-specific guard, or a verified webhook signature). The codebase ships `adminActionClient` exactly so this guard is impossible to forget.

**Incorrect (admin operation with no super-admin guard):**

```ts
'use server';
import { getSupabaseServerAdminClient } from '@kit/supabase/server-admin-client';
import { authActionClient } from '@kit/next/safe-action';

// Any authenticated user can call this and ban anyone.
export const banUserAction = authActionClient
  .inputSchema(BanUserSchema)
  .action(async ({ parsedInput: { userId } }) => {
    const admin = getSupabaseServerAdminClient();
    await admin.auth.admin.updateUserById(userId, { banned: true });
  });
```

**Correct (compose your own admin action client in `apps/web/lib/`):**

```ts
// apps/web/lib/admin-action-client.ts (the kit's own admin actions use the
// same pattern internally — @kit/admin only exports isSuperAdmin publicly,
// so product code composes its own wrapper from authActionClient).
import 'server-only';
import { authActionClient } from '@kit/next/safe-action';
import { isSuperAdmin } from '@kit/admin';
import { getSupabaseServerClient } from '@kit/supabase/server-client';

export const adminActionClient = authActionClient.use(async ({ next, ctx }) => {
  const isAdmin = await isSuperAdmin(getSupabaseServerClient());
  if (!isAdmin) {
    throw new Error('Unauthorized');
  }
  return next({ ctx });   // ctx.user is forwarded from authActionClient.
});
```

```ts
// apps/web/app/[locale]/admin/users/_lib/server/server-actions.ts
'use server';
import { adminActionClient } from '~/lib/admin-action-client';
import { getSupabaseServerAdminClient } from '@kit/supabase/server-admin-client';

// Non-admins now get a thrown error before the handler runs.
// Inside the handler, getSupabaseServerAdminClient is safe to call.
export const banUserAction = adminActionClient
  .inputSchema(BanUserSchema)
  .action(async ({ parsedInput: { userId } }) => {
    const admin = getSupabaseServerAdminClient();
    await admin.auth.admin.updateUserById(userId, { ban_duration: '876000h' });
  });
```

**Correct (one-off admin call inside an authenticated action):**

```ts
import { isSuperAdmin } from '@kit/admin';
// In a flow that needs admin only for a single cross-account read, check first.
if (!(await isSuperAdmin(getSupabaseServerClient()))) {
  throw new Error('Unauthorized');
}
const admin = getSupabaseServerAdminClient();
```

**Warning:** `getSupabaseServerAdminClient()` also calls `warnServiceRoleKeyUsage()` — when you see that warning in logs without a preceding super-admin check, it is a leak waiting to happen.

Reference: [Makerkit admin operations](https://makerkit.dev/docs/next-supabase-turbo/admin/admin-operations)
