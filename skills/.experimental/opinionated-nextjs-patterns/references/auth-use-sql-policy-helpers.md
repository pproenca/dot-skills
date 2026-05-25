---
title: Use Reusable SQL Helper Functions Inside RLS Policies
impact: CRITICAL
impactDescription: prevents inconsistent authorization logic across tables
tags: auth, rls, postgres, supabase
---

## Use Reusable SQL Helper Functions Inside RLS Policies

Define `SECURITY DEFINER` helper functions once (`has_role_on_account`, `has_permission`, `is_account_owner`, `has_active_subscription`, `is_team_member`, `is_super_admin`) and call them from every RLS policy so each table reads the same source of truth. Inline subqueries that duplicate membership logic drift out of sync — a change to permission semantics has to be applied in every policy that copied the subquery, and the one you miss is a silent authorization hole.

**Incorrect (inline subquery duplicating membership logic):**

```sql
create policy projects_select on public.projects
for select to authenticated using (
  exists (
    select 1 from public.accounts_memberships m
    where m.user_id = (select auth.uid())
      and m.account_id = projects.account_id
      and m.account_role in ('owner', 'admin')
  )
);
-- Every other tenant-scoped table now needs the same subquery; change the
-- permission model and you must find them all, or leave a hole behind.
```

**Correct (delegate to the centralized helper):**

```sql
create policy projects_select on public.projects
for select to authenticated using (
  public.has_role_on_account(projects.account_id)
);

-- For a specific role:
create policy projects_delete on public.projects
for delete to authenticated using (
  public.has_role_on_account(projects.account_id, 'owner')
);

-- For permission-based access (preferred for fine-grained rules):
create policy projects_update on public.projects
for update to authenticated using (
  public.has_permission((select auth.uid()), projects.account_id, 'projects.manage')
);
```

**Helpers you define once and reuse (across `apps/web/supabase/schemas/*.sql`):**

| Helper | Defined in | Use when |
|--------|-----------|----------|
| `has_role_on_account(account_id, role?)` | `05-memberships.sql` | Membership check, optionally for a specific role |
| `has_permission(user_id, account_id, permission)` | `06-roles-permissions.sql` | Fine-grained permission check |
| `is_account_owner(account_id)` | `03-accounts.sql` | Owner-only operations |
| `has_active_subscription(account_id)` | `09-subscriptions.sql` | Feature gating by billing state |
| `is_team_member(account_id, user_id)` | `05-memberships.sql` | Membership check by explicit user |
| `is_super_admin()` | `13-mfa.sql` | Super-admin escape hatch |

**Why `SECURITY DEFINER`:** these functions run with the privileges of their definer (postgres), so they can read `accounts_memberships` even when the calling user's own RLS would forbid it. `set search_path = ''` prevents schema-injection via search-path manipulation.

*Transferable:* the principle is "centralize scoping predicates in one place, whatever the store." With Postgres that place is a set of `SECURITY DEFINER` SQL functions called from policies; with Drizzle or Prisma, put the same membership/permission predicate in one repository or policy module every query composes — so a permission change touches one definition, not dozens of copies.

Reference: [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
