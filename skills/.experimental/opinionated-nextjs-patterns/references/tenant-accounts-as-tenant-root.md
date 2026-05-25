---
title: Anchor Every Tenant on One Root Table That Personal and Team Workspaces Both Reference
impact: CRITICAL
impactDescription: prevents fragmented authorization models
tags: tenant, multi-tenancy, schema
---

## Anchor Every Tenant on One Root Table That Personal and Team Workspaces Both Reference

Unify personal and team workspaces under a single tenant-root table and make every scoped row FK back to it. A personal account and a team account are both rows in that one table, so one authorization function, one URL convention, and one data-access factory serve both. Build a parallel "teams" table beside a "users" table and you double the auth surface: every policy is duplicated, every helper needs two versions, and the UI has to know whether it's in "personal mode" or "team mode."

**Incorrect (parallel personal/team models — two authz surfaces):**

```sql
-- A separate teams table forces every product table to choose a parent
-- and every policy to handle both cases.
create table public.user_settings (
  user_id uuid references auth.users(id) on delete cascade not null,
  theme text not null default 'system'
);

create table public.teams (
  id uuid primary key default gen_random_uuid(),
  name text not null
);

create table public.team_settings (
  team_id uuid references public.teams(id) on delete cascade not null,
  theme text not null default 'system'
);

-- Now every policy is duplicated, every helper needs two versions,
-- and the UI has to branch on "personal mode" vs "team mode".
```

**Correct (one tenant root, polymorphic via `is_personal_account`):**

```sql
create table public.accounts (
  id uuid primary key default gen_random_uuid(),
  primary_owner_user_id uuid references auth.users on delete cascade
    not null default auth.uid(),
  name text not null,
  slug text unique,                          -- null for personal, set for team
  is_personal_account boolean not null default false
);

-- Personal account row: id = auth.users.id, is_personal_account = true
-- Team account row:     id = gen_random_uuid(), is_personal_account = false,
--                       slug = 'acme', plus rows in accounts_memberships

create table public.accounts_memberships (
  user_id uuid references auth.users on delete cascade not null,
  account_id uuid references public.accounts on delete cascade not null,
  account_role text not null,
  primary key (user_id, account_id)
);

-- Product tables only ever know about account_id — never which "kind" of tenant:
create table public.projects (
  id uuid primary key default gen_random_uuid(),
  account_id uuid references public.accounts(id) on delete cascade not null,
  name text not null
);
```

**What the single root buys you:**

- One authorization function (`has_role_on_account(account_id)`) works for both contexts — a personal account's owner is just the user themselves.
- One data-access factory in `@app/accounts` queries the same table for personal and team data; `is_personal_account` is the only branch.
- One URL convention: `/home` for personal, `/home/[account]` (slug) for team.
- Scoping a feature to "personal only" or "teams only" becomes a feature-flag concern, not a data-model fork.

**When NOT to use a single tenant root:** if your product truly has two non-overlapping ownership models (a B2C consumer identity vs. a B2B enterprise with its own SSO), the merge cost can exceed the win. This model assumes the team workspace is an *upgrade* of the personal one, not a different product.

*Transferable:* the principle is "one tenant-root table that every scoped row points at." With Postgres that root is an `accounts` table referenced by FK; with another store, model the same root entity in one repository so every query resolves tenancy through a single place instead of two parallel hierarchies.

Reference: [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
