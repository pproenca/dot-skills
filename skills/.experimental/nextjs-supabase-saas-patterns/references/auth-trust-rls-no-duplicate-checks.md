---
title: Trust RLS — Do Not Duplicate Authorization Checks in App Code
impact: CRITICAL
impactDescription: prevents drift between application-layer and database-layer authz
tags: auth, rls, drift, performance
---

## Trust RLS — Do Not Duplicate Authorization Checks in App Code

When the standard server client is used, the policy on the table is already filtering every row to ones the user can see. Re-checking ownership in TypeScript creates two authorization surfaces that have to stay in sync, pulls more rows than necessary to the application layer, and gives a false sense of safety — the policy is what enforces the boundary, and if it's wrong, the TypeScript check is racing it.

**Incorrect (fetch then filter in JS — drift + performance hit):**

```ts
const client = getSupabaseServerClient();
const { data } = await client.from('projects').select('*');

// Drift: if RLS already filters by membership, this is redundant.
// If RLS does NOT filter, this is a SECURITY HOLE because RLS is
// the source of truth and someone may have already pulled the full set.
const myProjects = data?.filter((p) => p.account_id === currentAccountId);
```

**Correct (trust RLS — the query already returns only accessible rows):**

```ts
const client = getSupabaseServerClient();

// Policy: SELECT allowed if has_role_on_account(projects.account_id)
// Returns only rows the user is a member of. No JS filter needed.
const { data: projects } = await client.from('projects').select('*');
```

**Correct (use `.eq()` to scope further, not to authorize):**

```ts
// Filtering to ONE specific account is fine — it's a query refinement,
// not an authorization check. RLS still gates whether the user can see
// rows for THAT account at all.
const { data: projects } = await client
  .from('projects')
  .select('*')
  .eq('account_id', selectedAccountId);
```

**When app-layer checks are correct:**

- **Before invoking the admin client.** RLS isn't filtering for the admin client, so a `has_permission`/`isSuperAdmin` check in code is the *only* line of defense.
- **Feature-flag gating** (not authorization): "can the user create more than N projects on their plan?" — that's a business rule, not a row-visibility rule.
- **Policy engine checks** (`createPoliciesEvaluator`) — declarative rules that return user-facing messages (`deny({ code, message, remediation })`) layer cleanly on top of RLS.

**Why this matters in practice:** the worst version of this anti-pattern is when someone, surprised that a query returned fewer rows than expected, switches to the admin client to "fix" it and then re-adds a JS filter as their authorization. They've just bypassed RLS entirely and replaced it with a check that misses the edge case the policy handled.

Reference: [Makerkit RLS guide](https://makerkit.dev/docs/next-supabase-turbo/data-fetching/row-level-security)
