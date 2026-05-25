---
title: Gate the Privileged Client Behind an Authorization Check Done Before You Construct It
impact: CRITICAL
impactDescription: prevents privilege escalation when the data layer is bypassed
tags: auth, admin-client, authorization, super-admin
---

## Gate the Privileged Client Behind an Authorization Check Done Before You Construct It

The privileged client (service-role key) is the only escape hatch from your data-layer authorization — once constructed, the caller can read or mutate any tenant's rows. Authorize *before* you construct it: run an explicit check (`isSuperAdmin()`, a feature-specific guard, or a verified webhook signature) and only then reach for the privileged client. The safest way to make that ordering impossible to forget is to bake the guard into a dedicated `adminActionClient`, so the check always runs before the handler body.

**Incorrect (privileged operation with no super-admin guard):**

```ts
'use server';
import { getServiceRoleClient } from '@app/supabase/admin';
import { authActionClient } from '@app/next/safe-action';
import { BanUserSchema } from './ban-user.schema';

// authActionClient only proves the caller is signed in — so any
// authenticated user can call this and ban anyone.
export const banUserAction = authActionClient
  .inputSchema(BanUserSchema)
  .action(async ({ parsedInput: { userId } }) => {
    const admin = getServiceRoleClient();
    await admin.auth.admin.updateUserById(userId, { ban_duration: '876000h' });
  });
```

**Correct (compose an admin action client that checks authorization first):**

```ts
// @app/next/admin-action-client.ts — a thin layer you own on top of
// authActionClient; the guard runs before any handler body executes.
import 'server-only';
import { authActionClient } from '@app/next/safe-action';
import { isSuperAdmin } from '@app/authz';
import { getServerClient } from '@app/supabase/server';

export const adminActionClient = authActionClient.use(async ({ next, ctx }) => {
  const isAdmin = await isSuperAdmin(getServerClient());
  if (!isAdmin) {
    throw new Error('Unauthorized'); // Thrown before the privileged client exists.
  }
  return next({ ctx }); // ctx.user is forwarded from authActionClient.
});
```

```ts
// features/admin/users/server/ban-user-action.ts
'use server';
import { adminActionClient } from '@app/next/admin-action-client';
import { getServiceRoleClient } from '@app/supabase/admin';
import { BanUserSchema } from './ban-user.schema';

// Non-admins now get a thrown error before the handler runs, so by the
// time getServiceRoleClient() is called the caller is already authorized.
export const banUserAction = adminActionClient
  .inputSchema(BanUserSchema)
  .action(async ({ parsedInput: { userId } }) => {
    const admin = getServiceRoleClient();
    await admin.auth.admin.updateUserById(userId, { ban_duration: '876000h' });
  });
```

**Correct (one-off privileged call inside an authenticated action) — still check first:**

```ts
import { isSuperAdmin } from '@app/authz';
import { getServerClient } from '@app/supabase/server';
import { getServiceRoleClient } from '@app/supabase/admin';

// Construct the privileged client only after the guard passes.
if (!(await isSuperAdmin(getServerClient()))) {
  throw new Error('Unauthorized');
}
const admin = getServiceRoleClient();
```

*Transferable:* the rule is "the bypass path must be gated, and the gate runs before the bypass exists." With Postgres the bypass is the service-role client that ignores RLS; with another store it is any repository or connection that skips your scoping layer — wrap it in the same check-then-construct guard so the authorization can never be reordered after the privileged handle is in hand.

Reference: [Supabase server-side auth for Next.js](https://supabase.com/docs/guides/auth/server-side/nextjs)
