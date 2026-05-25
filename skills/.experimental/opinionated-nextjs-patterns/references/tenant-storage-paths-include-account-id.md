---
title: Namespace Object-Storage Paths by Tenant ID So Access Rules Can Match on the Path
impact: HIGH
impactDescription: enables per-tenant storage RLS + cleanup on account delete
tags: tenant, storage, rls, supabase
---

## Namespace Object-Storage Paths by Tenant ID So Access Rules Can Match on the Path

Object-storage access rules can only authorize what they can see in the request — the bucket and the object path. They have no join to your tenant tables, so the only way a rule can answer "may this caller touch this file" is if the tenant id is encoded in the path. Name objects after the `account_id` (`{account_id}.png`, or `{account_id}/{filename}` for multi-file tenants), then the policy parses the id out of the path and runs the same `has_role_on_account` check used everywhere else. Random filenames leave you with one possible rule — "any authenticated user can read" — which exposes every tenant's files.

**Incorrect (random filename — no tenant marker, no per-tenant rule possible):**

```ts
// A random filename means the bucket policy can't tell who owns the file.
const objectName = crypto.randomUUID() + '.png';
await client.storage
  .from('account_image')
  .upload(objectName, avatarFile);
```

```sql
-- The only policy you can write is "any authenticated user can read",
-- which means any user can read every other tenant's avatars.
create policy account_image_select on storage.objects
  for select to authenticated
  using (bucket_id = 'account_image');
```

**Correct (path carries the account UUID — the policy extracts and checks it):**

```ts
// Name the object after the tenant so the policy can extract and authorize it.
const fileExtension = avatarFile.name.split('.').pop();
const objectName = `${accountId}.${fileExtension}`;

await client.storage
  .from('account_image')
  .upload(objectName, avatarFile, { upsert: true });
```

```sql
-- Helper: pull the tenant UUID back out of the object name.
create or replace function public.storage_filename_as_uuid(name text)
  returns uuid set search_path = '' as $$
begin
  return replace(storage.filename(name),
                 concat('.', storage.extension(name)),
                 '')::uuid;
end;
$$ language plpgsql;

-- Policy: allow the operation only if the caller has a role on the account
-- whose UUID is encoded in the object name.
create policy account_image on storage.objects for all
  using (
    bucket_id = 'account_image' and (
      public.storage_filename_as_uuid(name) = auth.uid()                    -- personal
      or public.has_role_on_account(public.storage_filename_as_uuid(name))  -- team
    )
  )
  with check (
    bucket_id = 'account_image' and (
      public.storage_filename_as_uuid(name) = auth.uid()
      or public.has_permission(
        auth.uid(),
        public.storage_filename_as_uuid(name),
        'settings.manage'
      )
    )
  );
```

**For multi-file-per-tenant buckets, prefix with the tenant id (`{account_id}/{filename}`):**

```sql
-- (storage.foldername(name))[1] returns the first path segment.
create policy documents_select on storage.objects for select
  using (
    bucket_id = 'documents'
    and public.has_role_on_account(((storage.foldername(name))[1])::uuid)
  );
```

```ts
// Upload preserves the tenant prefix so the policy above matches.
await client.storage
  .from('documents')
  .upload(`${accountId}/${documentFile.name}`, documentFile);
```

**Cascade on account delete doesn't reach storage:** objects live in `storage.objects`, not your schema, so a Postgres `on delete cascade` on `accounts` won't remove them. Pair this convention with a `delete-account` service that explicitly deletes everything under the tenant's prefix, or a scheduled sweep of orphaned prefixes.

**Why not a bucket per tenant:** buckets are configuration-level objects — one per tenant needs admin API calls and stops scaling past a few hundred tenants. Path-based isolation in one shared bucket is the durable pattern.

*Transferable:* the principle is "encode the tenant id in the object path so the access rule can match on it." With Supabase Storage that's an RLS policy parsing `storage.filename` / `storage.foldername`; with S3 or GCS, prefix keys by tenant (`tenants/{account_id}/...`) and constrain each tenant's credentials to that prefix via an IAM/bucket policy condition.

Reference: [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
