---
title: Keep the Action Thin — Put Business Logic in a Service
impact: MEDIUM-HIGH
impactDescription: enables reuse across actions, route handlers, jobs, and tests
tags: mutate, service, separation-of-concerns, reuse
---

## Keep the Action Thin — Put Business Logic in a Service

The action's job is orchestration: validate the input, check policies, call the service, log the result, revalidate the cache, redirect. The service's job is the actual workflow: multiple writes, external provider calls, transactional coordination. Putting the workflow inside the action handler means it is only callable from that one action — not from a route handler, not from a background job, not from a test. Extracting it to a service makes the same workflow reachable from every entry point that needs it.

**Incorrect (the whole workflow stuffed into the action handler):**

```ts
'use server';
export const createTeamAccountAction = authActionClient
  .inputSchema(CreateTeamSchema)
  .action(async ({ parsedInput: { name, slug }, ctx: { user } }) => {
    const client = getServerClient();
    const adminClient = getServiceRoleClient();

    // Check policies (inline).
    const evaluator = createAccountCreationPolicyEvaluator();
    if (await evaluator.hasPoliciesForStage('submission')) { /* 30 lines */ }

    // Create the account row (inline).
    const { data, error } = await adminClient.from('accounts').insert({ name, slug });
    if (error?.code === '23505') return { error: 'duplicate_slug' };

    // Create the membership (inline).
    await adminClient.from('accounts_memberships').insert({ accountId: data.id, userId: user.id });

    // Provision default settings (inline).
    await adminClient.from('account_settings').insert({ accountId: data.id });

    // Initialise billing (inline).
    const billing = await getBillingGatewayProvider(client);
    await billing.createCustomer({ accountId: data.id });

    // Send the welcome email (inline).
    const mailer = await getMailer();
    await mailer.send({ to: user.email, template: 'welcome' });

    revalidatePath('/home');
    redirect(`/home/${slug}`);

    // Want the same thing from a webhook? Copy-paste this whole block.
  });
```

**Correct (the action orchestrates, the service owns the workflow):**

```ts
// packages/features/team-accounts/src/server/create-team-account-action.ts
'use server';
import { authActionClient } from '@app/next/safe-action';
import { getLogger } from '@app/observability/logger';
import { CreateTeamSchema } from '@app/team-accounts/schema';
import { createCreateTeamAccountService } from './services/create-team-account.service';

export const createTeamAccountAction = authActionClient
  .inputSchema(CreateTeamSchema)
  .action(async ({ parsedInput: { name, slug }, ctx: { user } }) => {
    const logger = await getLogger();
    const ctx = { name: 'team-accounts.create', userId: user.id, accountName: name };

    logger.info(ctx, 'Creating team account...');

    // The action handles the auth-time policy gate (allow/deny envelope).
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
    const { data, error } = await service.createOrganizationAccount({ name, slug, userId: user.id });

    if (error === 'duplicate_slug') {
      return { error: true, message: 'teams.duplicateSlugError' }; // i18n key the form resolves.
    }

    logger.info(ctx, 'Team account created');
    redirect(`/home/${data.slug}`);
  });
```

```ts
// packages/features/team-accounts/src/server/services/create-team-account.service.ts
class CreateTeamAccountService {
  async createOrganizationAccount(params: { name: string; slug: string; userId: string }) {
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
- A route handler (a provider webhook triggers team setup).
- A migration script (bulk-create test accounts).
- A background job (provisioning).
- A unit test (mock the client → assert the right writes).

**The boundary line:**

| Belongs in the action | Belongs in the service |
|-----------------------|------------------------|
| Input validation (Zod) | Multi-step workflow |
| Reading `ctx.user` | External provider calls |
| Policy gate (allow/deny envelope) | Data-store mutations |
| Structured logging of the request | Coordination between subsystems |
| `revalidatePath` / `redirect` | Business invariants |
| Translating service errors to user messages | Transactional rollback |

**What "thin" means in practice:** if the action handler runs past ~30 lines, the line you didn't extract to a service is the line that will block reuse later.

**Don't return service-internal errors raw.** Translate them at the action boundary into stable user-facing messages (`'teams.duplicateSlugError'` is an i18n key the form looks up). Service throws are for unexpected failures that should hit the error boundary; structured returns (`{ error: 'duplicate_slug' }`) are for expected business outcomes.

Reference: [Next.js Server Actions and Mutations](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
