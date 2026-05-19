---
title: Use `accounts` as the Single Tenant Root for Personal and Team Workspaces
impact: CRITICAL
impactDescription: prevents fragmented authorization models
tags: tenant, accounts, multi-tenancy, schema
---

## Use `accounts` as the Single Tenant Root for Personal and Team Workspaces

The kit unifies personal and team workspaces under one `accounts` table. Personal accounts satisfy `auth.users.id = accounts.id`; team accounts are separate `accounts` rows plus `accounts_memberships` with roles and permissions. Every product table joins on `accounts.id` via an `account_id` column, so RLS helpers (`has_role_on_account`, `has_permission`) and feature APIs (`createAccountsApi`, `createTeamAccountsApi`) work identically for both. Building a parallel "teams" table doubles the auth surface and breaks every helper.

**Incorrect (parallel personal/team models — two authz surfaces):**

```sql
-- A separate teams table forces every product table to choose a parent
-- and every policy to handle both cases.
create table users_settings (
  user_id uuid references auth.users(id),
  ...
);

create table teams (
  id uuid primary key,
  ...
);

create table teams_settings (
  team_id uuid references teams(id),
  ...
);

-- Now every policy is duplicated, every helper needs two versions,
-- and the UI has to know whether it's in "personal mode" or "team mode".
```

**Correct (one `accounts` root, polymorphic via `is_personal_account`):**

```sql
-- The shipped schema (simplified):
create table public.accounts (
  id uuid primary key default extensions.uuid_generate_v4(),
  primary_owner_user_id uuid references auth.users on delete cascade
    not null default auth.uid(),
  name varchar(255) not null,
  slug text unique,                          -- null for personal, set for team
  is_personal_account boolean default false not null,
  ...
);

-- Personal account row: id = auth.users.id, is_personal_account = true
-- Team account row:     id = uuid_generate_v4(), is_personal_account = false,
--                       slug = 'acme', plus rows in accounts_memberships

create table public.accounts_memberships (
  user_id uuid references auth.users on delete cascade,
  account_id uuid references public.accounts on delete cascade,
  account_role varchar(50) not null,
  ...
);

-- Product tables only ever know about account_id:
create table public.projects (
  id uuid primary key,
  account_id uuid references public.accounts(id) on delete cascade not null,
  ...
);
```

**What you get for free with this model:**

- `has_role_on_account(account_id)` works for both personal and team contexts (personal owner = the user themselves).
- `createAccountsApi(client)` for personal data; `createTeamAccountsApi(client)` for team data — both query the same underlying table.
- One URL convention: `/home` for personal, `/home/[account]` for team (slug).
- Adding a feature to "personal accounts only" or "teams only" is a feature-flag concern, not a data-model concern.

**When NOT to use a single tenant root:** if your product truly has two non-overlapping ownership models (e.g., one for B2C consumers, a completely different one for B2B enterprises with their own identity provider), the merge cost may exceed the win. The kit's model assumes the team workspace is an *upgrade* of the personal one, not a different product.

Reference: [Makerkit accounts model](https://makerkit.dev/docs/next-supabase-turbo/data-fetching/accounts)
