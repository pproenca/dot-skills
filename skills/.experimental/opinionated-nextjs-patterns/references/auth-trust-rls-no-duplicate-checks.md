---
title: Authorize Once at the Data Layer — Don't Re-Check the Same Rule in App Code
impact: CRITICAL
impactDescription: prevents drift between application-layer and database-layer authz
tags: auth, rls, drift, supabase
---

## Authorize Once at the Data Layer — Don't Re-Check the Same Rule in App Code

When you read through the request-scoped client, the policy on the table is already filtering every row to ones the user may see. Re-checking the same ownership rule in TypeScript creates two authorization surfaces that have to stay in sync, pulls more rows than necessary up to the application layer, and gives a false sense of safety — the policy is the boundary, and if it's wrong, the TypeScript check is racing it rather than backing it up.

**Incorrect (fetch then filter in JS — drift + performance hit):**

```ts
const client = getServerClient();
const { data: projects } = await client.from('projects').select('*');

// Drift: if RLS already filters by membership, this is redundant.
// If RLS does NOT filter, this is a SECURITY HOLE — the database is
// the source of truth and the full set may already be over the wire.
const visibleProjects = projects?.filter((p) => p.account_id === currentAccountId);
```

**Correct (trust the data layer — the query already returns only accessible rows):**

```ts
const client = getServerClient();

// Policy: SELECT allowed if has_role_on_account(projects.account_id).
// Returns only rows the user is a member of — no JS filter needed.
const { data: projects } = await client.from('projects').select('*');
```

**Correct (use `.eq()` to scope further, not to authorize):**

```ts
// Filtering to ONE specific account is a query refinement, not an
// authorization check. RLS still gates whether the user can see rows
// for THAT account at all.
const { data: projects } = await client
  .from('projects')
  .select('*')
  .eq('account_id', selectedAccountId);
```

**When an app-layer check is genuinely correct:**

- **Before invoking the privileged client.** RLS isn't filtering for the service-role client, so an `isSuperAdmin`/`hasPermission` check in code is the *only* line of defense.
- **Business-rule gating** (not authorization): "can the user create more than N projects on their plan?" — a quota rule, not a row-visibility rule.
- **Policy-engine messages** (`definePolicy` in `@app/authz`) — declarative rules that return user-facing copy (`deny({ code, message, remediation })`) layer cleanly on top of the data-layer check.

**The worst version of this anti-pattern:** someone, surprised that a query returned fewer rows than expected, switches to the privileged client to "fix" it and re-adds a JS filter as their authorization. They have just bypassed RLS entirely and replaced it with a check that misses the very edge case the policy handled.

*Transferable:* the principle is "authorize at the data layer, then trust it." With Postgres that boundary is RLS; with Drizzle or Prisma, enforce the same scoping in a repository or query helper every read passes through — and never re-implement that rule in a component as a second, drifting copy.

Reference: [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
