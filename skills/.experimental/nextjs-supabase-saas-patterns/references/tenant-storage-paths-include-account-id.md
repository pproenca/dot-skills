---
title: Embed `account_id` in Supabase Storage Paths
impact: HIGH
impactDescription: enables per-tenant storage RLS + cleanup on account delete
tags: tenant, storage, rls, account-id
---

## Embed `account_id` in Supabase Storage Paths

Supabase Storage policies parse the object name to decide access — they have no way to check "does this user own this file" unless the tenant ownership is encoded in the filename or path. The kit's convention: name the object after the `account_id` (e.g., `{account_id}.png` or `{account_id}/avatar.png`), then the policy extracts the UUID with a helper and calls `has_role_on_account` on it. Random filenames give every authenticated user access to every file in the bucket.

**Incorrect (random filename — no tenant marker, no per-tenant RLS possible):**

```ts
// Random filename means the bucket policy can't know who owns the file.
const fileName = crypto.randomUUID() + '.png';
await client.storage
  .from('account_image')
  .upload(fileName, file);
```

```sql
-- The only policy you can write is "any authenticated user can read",
-- which means any user can read every other user's avatars.
create policy account_image_select on storage.objects
  for select to authenticated
  using (bucket_id = 'account_image');
```

**Correct (filename is the account UUID — RLS extracts it):**

```ts
// File named after the account so the policy can extract and check it.
const fileExtension = file.name.split('.').pop();
const fileName = `${accountId}.${fileExtension}`;

await client.storage
  .from('account_image')
  .upload(fileName, file, { upsert: true });
```

```sql
-- A helper to pull the UUID back out of the filename.
create or replace function kit.get_storage_filename_as_uuid(name text)
  returns uuid set search_path = '' as $$
begin
  return replace(storage.filename(name),
                 concat('.', storage.extension(name)),
                 '')::uuid;
end;
$$ language plpgsql;

-- Policy: allow the operation only if the caller has a role on the account
-- whose UUID is encoded in the filename.
create policy account_image on storage.objects for all
  using (
    bucket_id = 'account_image' and (
      kit.get_storage_filename_as_uuid(name) = auth.uid()                 -- personal
      or public.has_role_on_account(kit.get_storage_filename_as_uuid(name)) -- team
    )
  )
  with check (
    bucket_id = 'account_image' and (
      kit.get_storage_filename_as_uuid(name) = auth.uid()
      or public.has_permission(
        auth.uid(),
        kit.get_storage_filename_as_uuid(name),
        'settings.manage'
      )
    )
  );
```

**Alternative for multi-file-per-tenant buckets (`{account_id}/{filename}`):**

```sql
-- (storage.foldername(name))[1] returns the first path segment.
create policy documents_select on storage.objects for select
  using (
    bucket_id = 'documents'
    and public.has_role_on_account(((storage.foldername(name))[1])::uuid)
  );
```

```ts
// Upload preserves the tenant prefix.
await client.storage
  .from('documents')
  .upload(`${accountId}/${file.name}`, file);
```

**Cascade on account delete:** Postgres `on delete cascade` on `accounts` doesn't reach Storage objects (they live in `storage.objects`, not your schema). Pair this convention with a `delete-account` service that explicitly removes objects under the deleted account's prefix, or a scheduled cleanup of orphaned `account_id` prefixes.

**Why this isn't just "use a bucket per tenant":** buckets are configuration-level objects — creating one per tenant requires admin API calls and doesn't scale past a few hundred tenants. Path-based isolation in a shared bucket with RLS is the durable pattern.

Reference: [Supabase Storage access control](https://supabase.com/docs/guides/storage/security/access-control)
