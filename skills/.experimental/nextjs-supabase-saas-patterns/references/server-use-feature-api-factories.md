---
title: Query Through Feature API Factories, Not Raw `from('table')`
impact: HIGH
impactDescription: prevents table-knowledge scattering across UI and loaders
tags: server, feature-api, abstraction, repository
---

## Query Through Feature API Factories, Not Raw `from('table')`

`createAccountsApi(client)` and `createTeamAccountsApi(client)` return small domain APIs (`getAccountWorkspace`, `hasPermission`, `getSubscription`, `loadUserAccounts`). Loaders, services, and routes call the API instead of constructing raw Supabase queries — when the underlying view or column changes, you update the API method once, not every consumer. The factory pattern also lets you inject the standard client for RLS reads or the admin client when you've explicitly authorised the bypass.

**Incorrect (raw queries scattered through the codebase):**

```ts
// app/[locale]/home/(user)/page.tsx
const client = getSupabaseServerClient();
const { data } = await client
  .from('user_account_workspace')
  .select('*')
  .single();
const workspace = data;

// app/[locale]/home/(user)/billing/page.tsx
const client = getSupabaseServerClient();
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
const client = getSupabaseServerClient();
const api = createAccountsApi(client);
const workspace = await api.getAccountWorkspace();

// app/[locale]/home/(user)/billing/page.tsx
const client = getSupabaseServerClient();
const api = createAccountsApi(client);
const subscription = await api.getSubscription(accountId);
```

**The API factory itself (`packages/features/accounts/src/server/api.ts`):**

```ts
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

- **Client injection.** Same API works against the standard client (RLS-enforced) or admin client (for super-admin flows) without changing the caller.
- **Testability.** Tests pass a mock client. No module-level state.
- **Auto-completion.** IDE shows the full domain surface on `api.` — discoverability without grepping.

**When to add a method vs. when to use raw queries:**

| Add an API method | Use a raw query |
|-------------------|-----------------|
| Used in more than one place | One-off, page-local |
| Touches policy/permission logic | Pure data shape |
| Combines multiple tables | Single-table simple select |
| Returns a shape consumers depend on | Returns a shape consumers don't reuse |

**Cross-feature reads:** call the relevant feature's API. The billing service calls `createAccountsApi(client).getCustomerId(accountId)` — billing doesn't know how the customer ID is stored, just that the accounts API can hand it over.

Reference: [Makerkit feature APIs](https://makerkit.dev/docs/next-supabase-turbo/data-fetching/feature-apis)
