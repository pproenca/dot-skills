---
title: Keep Actions Thin — Put Business Logic in a Service
impact: MEDIUM-HIGH
impactDescription: enables reuse across actions, route handlers, jobs, and tests
tags: mutate, service, separation-of-concerns, reuse
---

## Keep Actions Thin — Put Business Logic in a Service

The action's job is orchestration: validate the input, check policies, call the service, log the result, revalidate the cache, redirect. The service's job is the actual workflow: multiple Supabase writes, external provider calls, transactional coordination. Putting business logic inside the action handler means that workflow is only callable from that one action — not from a webhook, not from a background job, not from a test. Extracting it to a service makes the same workflow reachable from every entry point that needs it.

**Incorrect (200 lines of business logic stuffed into the action handler):**

```ts
'use server';
export const createTeamAccountAction = authActionClient
  .inputSchema(CreateTeamSchema)
  .action(async ({ parsedInput: { name, slug }, ctx: { user } }) => {
    const client = getSupabaseServerClient();
    const adminClient = getSupabaseServerAdminClient();

    // Check policies (inline).
    const evaluator = createAccountCreationPolicyEvaluator();
    if (await evaluator.hasPoliciesForStage('submission')) { /* 30 lines */ }

    // Create account row (inline).
    const { data, error } = await adminClient.from('accounts').insert({...});
    if (error?.code === '23505') return { error: 'duplicate_slug' };

    // Create membership (inline).
    await adminClient.from('accounts_memberships').insert({...});

    // Provision default settings (inline).
    await adminClient.from('account_settings').insert({...});

    // Initialize billing (inline).
    const billing = await getBillingGatewayProvider(client);
    await billing.createCustomer({...});

    // Send welcome email (inline).
    const mailer = await getMailer();
    await mailer.send({...});

    revalidatePath('/home');
    redirect(`/home/${slug}`);

    // Want to do the same thing from a webhook? Copy-paste this whole block.
  });
```

**Correct (action orchestrates, service owns the workflow):**

```ts
'use server';
// packages/features/team-accounts/src/server/actions/create-team-account-server-actions.ts
export const createTeamAccountAction = authActionClient
  .inputSchema(CreateTeamSchema)
  .action(async ({ parsedInput: { name, slug }, ctx: { user } }) => {
    const logger = await getLogger();
    const ctx = { name: 'team-accounts.create', userId: user.id, accountName: name };

    logger.info(ctx, `Creating team account...`);

    // Action handles auth-time policy check (preliminary stage already ran in the loader).
    const evaluator = createAccountCreationPolicyEvaluator();
    if (await evaluator.hasPoliciesForStage('submission')) {
      const result = await evaluator.canCreateAccount(
        { timestamp: new Date().toISOString(), userId: user.id, accountName: name },
        'submission',
      );
      if (!result.allowed) {
        return { error: true, message: result.reasons[0] ?? 'Policy denied' };
      }
    }

    // Delegate the actual workflow.
    const service = createCreateTeamAccountService();
    const { data, error } = await service.createNewOrganizationAccount({
      name,
      userId: user.id,
      slug,
    });

    if (error === 'duplicate_slug') {
      return { error: true, message: 'teams.duplicateSlugError' };
    }

    logger.info(ctx, `Team account created`);
    redirect(`/home/${data.slug}`);
  });
```

```ts
// packages/features/team-accounts/src/server/services/create-team-account.service.ts
class CreateTeamAccountService {
  async createNewOrganizationAccount(params: { name: string; userId: string; slug: string }) {
    // ALL the workflow: account row, membership, settings, billing, email.
    // Reusable from anywhere that has the params.
  }
}

export function createCreateTeamAccountService() {
  return new CreateTeamAccountService();
}
```

**Now the same workflow is reachable from:**

- The web action (above).
- A webhook (Stripe `customer.subscription.created` triggers team setup).
- A migration script (bulk-create test accounts).
- A background job (provisioning).
- A unit test (mock client → assert the right writes).

**The boundary line:**

| Belongs in the action | Belongs in the service |
|----------------------|------------------------|
| Input validation (Zod) | Multi-step workflow |
| Reading `ctx.user` | External provider calls |
| Policy gate (allow/deny envelope) | Database mutations |
| Structured logging of the request | Coordination between subsystems |
| `revalidatePath` / `redirect` | Business invariants |
| Translating service errors to user messages | Transactional rollback |

**What "thin" means quantitatively:** if the action handler is over ~30 lines, the line you didn't extract to a service is the line that will block reuse later.

**Don't return service-internal errors raw.** Translate them at the action boundary into stable user-facing messages (`'teams.duplicateSlugError'` is an i18n key the form can look up). Service throws are for unexpected failures that should hit the error boundary; structured returns (`{ error: 'duplicate_slug' }`) are for expected business outcomes.

Reference: [Makerkit services and actions](https://makerkit.dev/docs/next-supabase-turbo/data-fetching/server-actions)
