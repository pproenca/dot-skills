---
title: Give Every Tenant-Scoped Table the Tenant Key, an Index on It, and a Policy That Filters by It
impact: CRITICAL
impactDescription: prevents tenant isolation gaps and slow queries
tags: tenant, rls, index, schema, supabase
---

## Give Every Tenant-Scoped Table the Tenant Key, an Index on It, and a Policy That Filters by It

Three things must hold for every new tenant-scoped table or the isolation model breaks: (1) a tenant-key column — here `account_id` referencing `accounts(id) on delete cascade not null` — so the policy has something to filter on and orphaned rows are cleaned up automatically; (2) row-level security enabled plus at least one policy that scopes access to the caller's tenant, so unauthenticated or cross-tenant traffic can't read; (3) an index on the tenant key so scoped queries hit the index instead of a sequential scan once the table grows. Skip any one and you ship a leak, a dead policy, or a slow page.

**Incorrect (table missing RLS, FK, and index):**

```sql
-- Looks fine in dev. In production: any authenticated user can read
-- every project across every tenant, queries get slower with every
-- new row, and deleting an account leaves orphaned projects forever.
create table public.projects (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  account_id uuid,                    -- nullable, no FK
  created_at timestamptz not null default now()
);
-- No "alter table ... enable row level security".
-- No policies.
-- No index on account_id.
```

**Correct (the contract for every tenant-owned table):**

```sql
create table public.projects (
  id uuid primary key default gen_random_uuid(),
  account_id uuid references public.accounts(id) on delete cascade not null,
  name text not null,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id)
);

-- 1. Enable RLS — without this, every policy below is dead code.
alter table public.projects enable row level security;

-- 2. Grant the authenticated role what it needs (RLS still filters every row).
grant select, insert, update, delete on public.projects to authenticated;

-- 3. Policies scope to the caller's tenant via a reusable function.
create policy projects_select on public.projects
  for select to authenticated
  using (public.has_role_on_account(account_id));

create policy projects_insert on public.projects
  for insert to authenticated
  with check (public.has_role_on_account(account_id));

create policy projects_update on public.projects
  for update to authenticated
  using (public.has_permission((select auth.uid()), account_id, 'projects.manage'))
  with check (public.has_permission((select auth.uid()), account_id, 'projects.manage'));

create policy projects_delete on public.projects
  for delete to authenticated
  using (public.has_role_on_account(account_id, 'owner'));

-- 4. Index on the tenant key — without this, every "where account_id = ?" is a seq scan.
create index projects_account_id_idx on public.projects (account_id);
```

**Why each piece matters individually:**

- **No `on delete cascade`:** deleting an account leaves orphan rows that no membership can reach, so they're invisible to the policy and accumulate forever.
- **No `not null` on `account_id`:** an insert with no tenant key is invisible to every policy and becomes a "free for all" row.
- **No RLS:** authenticated users see and modify every tenant's data.
- **No index on `account_id`:** Postgres seq-scans small tables anyway, so this is invisible in dev. The first slow page in production will be a tenant-scoped query on a multi-million-row table.

*Transferable:* the principle is "carry the tenant key, index it, and authorize on it at the data layer." With Postgres that's a column plus an RLS policy plus a B-tree index; with another store, put the same tenant filter in the one repository every query passes through and make sure the tenant key is the leading index column.

Reference: [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
