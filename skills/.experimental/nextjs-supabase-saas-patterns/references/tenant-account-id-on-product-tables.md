---
title: Every Product Table Needs `account_id` + RLS + FK Index
impact: CRITICAL
impactDescription: prevents tenant isolation gaps and slow queries
tags: tenant, account-id, rls, index, schema
---

## Every Product Table Needs `account_id` + RLS + FK Index

Three things must hold for every new tenant-scoped table or the multi-tenancy model breaks: (1) an `account_id` column referencing `accounts(id) on delete cascade not null` so RLS has something to filter on and orphaned rows are cleaned up automatically; (2) `enable row level security` plus at least one policy referencing `has_role_on_account` or `has_permission` so unauthenticated traffic can't read; (3) `create index on (account_id)` so tenant-scoped queries hit the index instead of a sequential scan once the table grows.

**Incorrect (table missing RLS, FK, and index):**

```sql
-- Looks fine in dev. In production: any authenticated user can read
-- every project across every tenant, queries get slower with every
-- new row, and deleting an account leaves orphaned projects forever.
create table public.projects (
  id uuid primary key default extensions.uuid_generate_v4(),
  name text not null,
  account_id uuid,                    -- nullable, no FK
  created_at timestamptz default now()
);
-- No "alter table ... enable row level security".
-- No policies.
-- No index on account_id.
```

**Correct (the shipped contract for tenant-owned tables):**

```sql
create table public.projects (
  id uuid primary key default extensions.uuid_generate_v4(),
  account_id uuid references public.accounts(id) on delete cascade not null,
  name text not null,
  created_at timestamptz default now() not null,
  created_by uuid references auth.users(id)
);

-- 1. Enable RLS — without this, every policy below is dead code.
alter table public.projects enable row level security;

-- 2. Grant the standard role what it needs (RLS still filters).
grant select, insert, update, delete on public.projects to authenticated;

-- 3. Policies use the helper functions, not inline subqueries.
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

-- 4. Index on the FK — without this, every "where account_id = ?" is a seq scan.
create index projects_account_id_idx on public.projects (account_id);
```

**Why each piece matters individually:**

- **No `on delete cascade`:** deleting an account leaves orphan rows that violate the FK only on re-insert, become invisible to `has_role_on_account` (no membership), and accumulate forever.
- **No `not null` on `account_id`:** any insert without an `account_id` is invisible to every policy and becomes a "free for all" row.
- **No RLS:** authenticated users see and modify every tenant's data.
- **No index on `account_id`:** Postgres won't use a sequential scan plan for small tables, so this is fine in dev. The first slow page in production will be a tenant-scoped query on a multi-million-row table.

**Run `pnpm supabase:web:typegen` after the migration** so `Tables<'projects'>` reflects the new columns. Run `pnpm supabase:web:test` to verify the policies allow/deny the expected accounts (the kit ships pgTAP tests).

Reference: [Makerkit data model guide](https://makerkit.dev/docs/next-supabase-turbo/data-fetching/database-schema)
