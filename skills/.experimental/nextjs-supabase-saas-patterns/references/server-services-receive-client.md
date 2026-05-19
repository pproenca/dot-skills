---
title: Services Receive the Supabase Client as a Constructor Argument
impact: MEDIUM-HIGH
impactDescription: enables client-choice injection and unit-test mocking
tags: server, service, dependency-injection, factory
---

## Services Receive the Supabase Client as a Constructor Argument

A service that calls `getSupabaseServerClient()` internally is hard-wired to the standard client. You can't pass the admin client when you legitimately need to (e.g., a webhook handler with no session); you can't pass a fake client in tests. The kit's pattern: a factory function (`createXService(client)`) that constructs a class taking the client through the constructor. The caller picks which client to inject.

**Incorrect (service self-constructs its client — no flexibility):**

```ts
class TeamBillingService {
  async createCheckout(params: CheckoutParams) {
    // Hardcoded to the standard client. Webhooks (no user session) can't use this.
    // Tests can't pass a stub.
    const client = getSupabaseServerClient();
    const api = createTeamAccountsApi(client);
    // ...
  }
}

export const teamBillingService = new TeamBillingService();
```

**Correct (factory + constructor injection — caller picks the client):**

```ts
// apps/web/app/[locale]/home/[account]/billing/_lib/server/team-billing.service.ts
import { SupabaseClient } from '@supabase/supabase-js';
import { Database } from '@kit/supabase/database';

class TeamBillingService {
  private readonly namespace = 'billing.team-account';

  constructor(private readonly client: SupabaseClient<Database>) {}

  async createCheckout(params: CheckoutParams) {
    const { data: user } = await requireUser(this.client);
    if (!user) throw new Error('Authentication required');

    const api = createTeamAccountsApi(this.client);

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
export function createTeamBillingService(client: SupabaseClient<Database>) {
  return new TeamBillingService(client);
}
```

**Why a factory and not `new TeamBillingService(...)`:** factories are a stable public API even if the implementation switches from class to module to whatever later. Callers never write `new`, so swapping the constructor signature is non-breaking.

**Call sites for each client choice:**

```ts
// Server action: standard client, JWT-bound, RLS-enforced.
export const createCheckoutAction = authActionClient
  .inputSchema(TeamCheckoutSchema)
  .action(async ({ parsedInput }) => {
    const service = createTeamBillingService(getSupabaseServerClient());
    return await service.createCheckout(parsedInput);
  });

// Webhook handler: admin client, no user session.
export const POST = enhanceRouteHandler(
  async ({ request }) => {
    const service = createTeamBillingService(getSupabaseServerAdminClient());
    return await service.handleWebhook(request);
  },
  { auth: false },
);

// Test: mock client.
const fakeClient = createMockSupabaseClient({ accounts: [...] });
const service = createTeamBillingService(fakeClient);
const result = await service.createCheckout(testParams);
expect(result).toEqual(...);
```

**Don't accept a `SupabaseClient` and then call `getSupabaseServerClient()` inside the service.** The injected client is the contract — using anything else defeats the abstraction. If a service genuinely needs both clients (standard for the user's read, admin for a cross-tenant write), accept both:

```ts
// Acceptable when the dual-client need is explicit.
constructor(
  private readonly client: SupabaseClient<Database>,
  private readonly adminClient: SupabaseClient<Database>,
) {}
```

**Services don't import `getSupabase*Client` directly.** That import is a signal you broke the contract. The only places that import the client constructors are call sites that decide which client to pass in.

Reference: [Makerkit services pattern](https://makerkit.dev/docs/next-supabase-turbo/data-fetching/services)
