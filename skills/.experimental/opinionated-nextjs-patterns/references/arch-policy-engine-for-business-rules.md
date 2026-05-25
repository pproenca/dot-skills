---
title: Model Business Rules in a Policy Layer You Own — Not Inline Conditionals
impact: MEDIUM-HIGH
impactDescription: prevents business-rule scatter across actions, forms, and services
tags: arch, policies, authorization, business-rules, registry
---

## Model Business Rules in a Policy Layer You Own — Not Inline Conditionals

Build a small policy layer in `@app/authz` for business rules that need to be configurable, staged, composable, and surfaceable to the UI with actionable error messages. Instead of scattering `if (!subscription.active) return { error: 'upgrade' }` across forms, actions, and services, `definePolicy` once, register it in a feature-scoped registry, and evaluate via `createPoliciesEvaluator()` at the right stage (preliminary check before form submit; final check inside the action). The denied state carries a structured `{ code, message, remediation }` so the UI knows what to say *and* what to suggest. This is the same idea as an ability/policy evaluator like CASL — a layer of declarative rules the rest of the app asks instead of re-deriving conditions everywhere.

**Incorrect (inline conditionals scattered through the codebase):**

```ts
// In the form component:
if (!subscription?.active) return <UpgradePrompt />;

// In the loader:
if (subscription?.provider === 'paddle' && subscription.status === 'trialing') {
  const hasPerSeat = subscription.items.some((item) => item.type === 'per_seat');
  if (hasPerSeat) redirect('/upgrade');
}

// In the server action:
'use server';
export const inviteMemberAction = authActionClient.action(async () => {
  // Duplicate the same checks. Drift between form and action. Each location
  // has its own error message. Adding a new constraint = editing 3+ places.
});
```

**Correct (declarative policies + registry + evaluator):**

```ts
// packages/features/team-accounts/src/server/policies/invitation-policies.ts
import { allow, definePolicy, deny, createPolicyRegistry } from '@app/authz';
import { FeaturePolicyInvitationContext } from './feature-policy-invitation-context';

// 1. Define each policy as a pure function of context.
export const subscriptionRequiredInvitationsPolicy =
  definePolicy<FeaturePolicyInvitationContext>({
    id: 'subscription-required',
    stages: ['preliminary', 'submission'],   // Runs at both UI-load AND submit.
    evaluate: async ({ subscription }) => {
      if (!subscription?.active) {
        return deny({
          code: 'SUBSCRIPTION_REQUIRED',
          message: 'teams.policyErrors.subscriptionRequired',
          remediation: 'teams.policyRemediation.subscriptionRequired',
        });
      }
      return allow();
    },
  });

export const paddleBillingInvitationsPolicy =
  definePolicy<FeaturePolicyInvitationContext>({
    id: 'paddle-billing',
    stages: ['preliminary', 'submission'],
    evaluate: async ({ subscription }) => {
      if (!subscription) return allow();
      if (subscription.provider === 'paddle' && subscription.status === 'trialing') {
        const hasPerSeatItems = subscription.items.some((item) => item.type === 'per_seat');
        if (hasPerSeatItems) {
          return deny({
            code: 'PADDLE_TRIAL_RESTRICTION',
            message: 'teams.policyErrors.paddleTrialRestriction',
            remediation: 'teams.policyRemediation.paddleTrialRestriction',
          });
        }
      }
      return allow();
    },
  });

// 2. Register them in a feature-scoped registry.
export const invitationPolicyRegistry = createPolicyRegistry();
invitationPolicyRegistry.register(subscriptionRequiredInvitationsPolicy);
invitationPolicyRegistry.register(paddleBillingInvitationsPolicy);
```

```ts
// packages/features/team-accounts/src/server/policies/create-invitations-policy-evaluator.ts
import { createPoliciesEvaluator } from '@app/authz';

export function createInvitationsPolicyEvaluator() {
  const evaluator = createPoliciesEvaluator<FeaturePolicyInvitationContext>();
  return {
    hasPoliciesForStage(stage: 'preliminary' | 'submission') {
      return evaluator.hasPoliciesForStage(invitationPolicyRegistry, stage);
    },
    canInvite(context: FeaturePolicyInvitationContext, stage: 'preliminary' | 'submission') {
      return evaluator.evaluate(invitationPolicyRegistry, context, 'ALL', stage);
    },
  };
}
```

**Consumed in the loader (preliminary stage) and in the action (submission stage):**

```ts
// Loader: tell the UI whether the form should even render in active state.
const invitationEvaluator = createInvitationsPolicyEvaluator();
if (await invitationEvaluator.hasPoliciesForStage('preliminary')) {
  const result = await invitationEvaluator.canInvite(invitationContext, 'preliminary');
  if (!result.allowed) {
    return { canInvite: false, reason: result.reasons[0] };
    // UI renders the form disabled with the remediation suggestion.
  }
}
```

```ts
// Action: re-check at submit (the context may have changed since page load).
'use server';
export const inviteMemberAction = authActionClient
  .inputSchema(InviteMemberSchema)
  .action(async ({ parsedInput, ctx: { user } }) => {
    const invitationEvaluator = createInvitationsPolicyEvaluator();
    if (await invitationEvaluator.hasPoliciesForStage('submission')) {
      const result = await invitationEvaluator.canInvite(invitationContext, 'submission');
      if (!result.allowed) {
        return { error: true, message: result.reasons[0]?.message };
      }
    }
    // ... actual invitation work
  });
```

**The two-stage pattern is the killer feature.** `preliminary` runs when the page loads (so the form can be disabled with a helpful message); `submission` runs when the action fires (in case state changed in between — subscription expired, plan downgraded). Same policies, two evaluation points, one source of truth.

**`allow()` vs `deny({ code, message, remediation })`:**

| Returned | When | What the UI does |
|----------|------|------------------|
| `allow()` | Policy passes | Form is enabled, action proceeds |
| `deny({ code, message })` | Policy fails, no recommended fix | Block the action, show `<Trans i18nKey={message} />` |
| `deny({ code, message, remediation })` | Policy fails AND there's a fix | Block + show remediation as a CTA link |

**`'ALL'` operator:** every policy in the registry must `allow()` for the result to be `allowed`. The first `deny()` short-circuits the rest (or all run, depending on evaluator settings) and the reasons are aggregated.

**Where this complements data-layer authorization, not replaces it:**

| Concern | Where it lives |
|---------|----------------|
| "Can user X read row Y?" (row visibility) | Data-layer scoping (Postgres RLS here; a repository elsewhere) |
| "Can this account use feature Z given their plan?" (business rule) | `@app/authz` |
| "Has the user authenticated?" (session) | `requireUser` in the action/proxy |

The data layer answers visibility; policies answer business eligibility. A user with an expired subscription can still *see* their accounts (the data layer allows it) but the policy denies inviting new members.

*Transferable:* `@app/authz` is just declarative rules + an evaluator — the same shape whether you back it with hand-written `definePolicy` functions or a CASL-style ability builder. Keep row-visibility in the data layer and reserve this layer for business eligibility.

**When NOT to use the policy layer:**

- **Trivial single-condition checks.** `if (!user.isPro) return;` doesn't need a registry.
- **One-off prerequisite checks inside a service.** If the condition is genuinely local and never displayed to the UI, an inline check is simpler.
- **Pure row-visibility checks** the data layer already handles. Don't re-implement "can this user see this row."

**Where this fits in a feature package:**

- `packages/features/team-accounts/src/server/policies/invitation-policies.ts` — invitation policies (subscription required, paddle trial restriction).
- `packages/features/team-accounts/src/server/policies/create-account-policy-evaluator.ts` — account creation gating.
- Wired into the workspace loader (`apps/web/app/[locale]/home/(user)/_lib/server/load-user-workspace.ts`) so the personal home page knows whether to render the "Create team" button enabled or with an upgrade prompt.

Reference: [CASL: defining abilities](https://casl.js.org/v6/en/guide/define-rules)
