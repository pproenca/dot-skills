---
title: Services Receive the Data Client as a Constructor Argument
impact: MEDIUM-HIGH
impactDescription: enables client-choice injection and unit-test mocking
tags: server, service, dependency-injection, factory
---

## Services Receive the Data Client as a Constructor Argument

A service that calls `getServerClient()` internally is hard-wired to the request-scoped client. You can't pass the privileged client when you legitimately need to (e.g., a webhook handler with no session); you can't pass a fake client in tests. The pattern: a factory function (`createXService(client)`) that constructs a class taking the client through the constructor. The caller picks which client to inject. The principle is dependency injection — the example uses the Supabase client as the injected dependency.

**Incorrect (service self-constructs its client — no flexibility):**

```ts
class AccountBillingService {
  async createCheckout(params: CheckoutParams) {
    // Hardcoded to the request-scoped client. Webhooks (no user session) can't use this.
    // Tests can't pass a stub.
    const client = getServerClient();
    const api = createAccountsApi(client);
    // ...
  }
}

export const accountBillingService = new AccountBillingService();
```

**Correct (factory + constructor injection — caller picks the client):**

```ts
// apps/web/app/[locale]/home/[account]/billing/_lib/server/account-billing.service.ts
import { SupabaseClient } from '@supabase/supabase-js';
import { Database } from '@app/supabase/types';
import { requireUser } from '@app/supabase/require-user';
import { createAccountsApi } from '@app/accounts/api';

class AccountBillingService {
  private readonly namespace = 'billing.account';

  constructor(private readonly client: SupabaseClient<Database>) {}

  async createCheckout(params: CheckoutParams) {
    const { data: user } = await requireUser(this.client);
    if (!user) throw new Error('Authentication required');

    const api = createAccountsApi(this.client);

    const hasPermission = await api.hasPermission({
      userId: user.id,
      accountId: params.accountId,
      permission: 'billing.manage',
    });
    if (!hasPermission) throw new Error('Permission denied');

    // ... checkout creation
  }
}

// The factory is the public surface.
export function createAccountBillingService(client: SupabaseClient<Database>) {
  return new AccountBillingService(client);
}
```

**Why a factory and not `new AccountBillingService(...)`:** factories are a stable public API even if the implementation switches from class to module to whatever later. Callers never write `new`, so swapping the constructor signature is non-breaking.

**Call sites for each client choice:**

```ts
// Server action: request-scoped client, JWT-bound, RLS-enforced.
export const createCheckoutAction = authActionClient
  .inputSchema(AccountCheckoutSchema)
  .action(async ({ parsedInput }) => {
    const service = createAccountBillingService(getServerClient());
    return await service.createCheckout(parsedInput);
  });

// Webhook handler: privileged client, no user session.
export const POST = enhanceRouteHandler(
  async ({ request }) => {
    const service = createAccountBillingService(getServiceRoleClient());
    return await service.handleWebhook(request);
  },
  { auth: false },
);

// Test: mock client.
const fakeClient = createMockSupabaseClient({ accounts: [/* ... */] });
const service = createAccountBillingService(fakeClient);
const result = await service.createCheckout(testParams);
expect(result).toEqual(/* ... */);
```

**Don't accept a client and then call `getServerClient()` inside the service.** The injected client is the contract — using anything else defeats the abstraction. If a service genuinely needs both clients (request-scoped for the user's read, privileged for a cross-tenant write), accept both:

```ts
// Acceptable when the dual-client need is explicit.
constructor(
  private readonly client: SupabaseClient<Database>,
  private readonly adminClient: SupabaseClient<Database>,
) {}
```

**Services don't import the client constructors directly.** That import is a signal you broke the contract. The only places that import `getServerClient`/`getServiceRoleClient` are call sites that decide which client to pass in.

*Transferable:* the dependency being injected is "the thing that talks to your store." Swap the `SupabaseClient<Database>` type for a Drizzle `db` handle, a Prisma client, or a repository interface — the factory-plus-constructor shape is identical, and the same testability and client-choice benefits follow.

Reference: [Supabase server-side auth for Next.js](https://supabase.com/docs/guides/auth/server-side/nextjs)
