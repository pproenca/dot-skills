---
title: Read Through a Typed Data-Access Factory, Not Raw `from('table')`
impact: HIGH
impactDescription: prevents table-knowledge scattering across UI and loaders
tags: server, feature-api, abstraction, repository
---

## Read Through a Typed Data-Access Factory, Not Raw `from('table')`

A typed data-access factory — `createAccountsApi(client)` — returns a small domain API (`getAccountWorkspace`, `hasPermission`, `getSubscription`, `loadUserAccounts`). Loaders, services, and routes call the API instead of constructing raw queries — when the underlying view or column changes, you update the API method once, not every consumer. The factory also lets you inject the request-scoped client for tenant-scoped reads or a privileged client when you've explicitly authorised the bypass. This is the repository pattern; the example builds the repository over Supabase.

**Incorrect (raw queries scattered through the codebase):**

```ts
// app/[locale]/home/(user)/page.tsx
const client = getServerClient();
const { data } = await client
  .from('user_account_workspace')
  .select('*')
  .single();
const workspace = data;

// app/[locale]/home/(user)/billing/page.tsx
const client = getServerClient();
const { data } = await client
  .from('subscriptions')
  .select('*, items: subscription_items !inner (*)')
  .eq('account_id', accountId)
  .maybeSingle();
const subscription = data;

// Now rename `user_account_workspace` view to `workspaces`,
// or add a column, and you have to find every call site.
```

**Correct (consumers depend on the API, not the table):**

```ts
// app/[locale]/home/(user)/page.tsx
import { createAccountsApi } from '@app/accounts/api';

const client = getServerClient();
const api = createAccountsApi(client);
const workspace = await api.getAccountWorkspace();

// app/[locale]/home/(user)/billing/page.tsx
import { createAccountsApi } from '@app/accounts/api';

const client = getServerClient();
const api = createAccountsApi(client);
const subscription = await api.getSubscription(accountId);
```

**The data-access factory itself (`packages/features/accounts/src/server/api.ts`):**

```ts
import { SupabaseClient } from '@supabase/supabase-js';
import { Database } from '@app/supabase/types';

class AccountsApi {
  constructor(private readonly client: SupabaseClient<Database>) {}

  async getAccountWorkspace() {
    const { data, error } = await this.client
      .from('user_account_workspace')
      .select('*')
      .single();
    if (error) throw error;
    return data;
  }

  async getSubscription(accountId: string) {
    const { data, error } = await this.client
      .from('subscriptions')
      .select('*, items: subscription_items !inner (*)')
      .eq('account_id', accountId)
      .maybeSingle();
    if (error) throw error;
    return data;
  }

  async hasPermission(params: {
    userId: string;
    accountId: string;
    permission: string;
  }) {
    const { data } = await this.client.rpc('has_permission', params);
    return data ?? false;
  }
}

export function createAccountsApi(client: SupabaseClient<Database>) {
  return new AccountsApi(client);
}
```

**Why "factory function returning a class" rather than module-level functions:**

- **Client injection.** Same API works against the request-scoped client (tenant-scoped) or a privileged client (for super-admin flows) without changing the caller.
- **Testability.** Tests pass a mock client. No module-level state.
- **Auto-completion.** IDE shows the full domain surface on `api.` — discoverability without grepping.

**When to add a method vs. when to use a raw query:**

| Add an API method | Use a raw query |
|-------------------|-----------------|
| Used in more than one place | One-off, page-local |
| Touches policy/permission logic | Pure data shape |
| Combines multiple tables | Single-table simple select |
| Returns a shape consumers depend on | Returns a shape consumers don't reuse |

**Cross-feature reads:** call the relevant feature's API. The billing service calls `createAccountsApi(client).getCustomerId(accountId)` — billing doesn't know how the customer ID is stored, just that the accounts API can hand it over.

*Transferable:* the principle is "queries live behind a typed repository, not in the UI." The example wraps the Supabase client, but the same factory-plus-repository shape works over a Drizzle `db` handle or a Prisma client — consumers depend on `getSubscription(accountId)`, never on the table name.

Reference: [Next.js data fetching and caching](https://nextjs.org/docs/app/getting-started/fetching-data)
