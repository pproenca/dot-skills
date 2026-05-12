---
title: Use forceAllowId During Bulk Migration to Preserve Existing User IDs
impact: MEDIUM
impactDescription: prevents foreign keys in your business tables from pointing at obsolete user IDs
tags: migrate, bulk-import, ids, foreign-keys
---

## Use forceAllowId During Bulk Migration to Preserve Existing User IDs

Better Auth's adapters generate new IDs by default on insert — safe for production traffic, dangerous during migration. Your existing data already has foreign keys (`invoice.userId`, `audit_log.actor_id`, `team_member.user_id`) pointing at the legacy IDs. If the migration script lets Better Auth assign new IDs, every business table now points at non-existent users. The `forceAllowId: true` flag tells the adapter to honor the `id` you provide in the data payload, preserving referential integrity.

**Incorrect (default insert assigns new IDs, foreign keys break):**

```typescript
// Migration script
for (const legacyUser of legacyUsers) {
  await ctx.adapter.create({
    model: "user",
    data: {
      id: legacyUser.id, // ← ignored; adapter generates fresh ID
      email: legacyUser.email,
      // ...
    },
  });
}
// Now user has id="new-uuid-1", but invoice.userId still says "legacy-id-1" → orphaned
```

**Correct (forceAllowId preserves legacy IDs):**

```typescript
// Migration script
for (const legacyUser of legacyUsers) {
  await ctx.adapter.create({
    model: "user",
    data: {
      id: legacyUser.id, // honored because forceAllowId
      email: legacyUser.email,
      name: legacyUser.name,
      emailVerified: legacyUser.email_verified,
      createdAt: new Date(legacyUser.created_at),
      updatedAt: new Date(legacyUser.updated_at),
    },
    forceAllowId: true, // ← preserve ID exactly as given
  });
}
// invoice.userId references match new user.id → all foreign keys intact
```

**Implementation (verify IDs survived the round trip):**

```typescript
async function verifyMigration(sample: LegacyUser[]) {
  const orphans: string[] = [];
  for (const u of sample) {
    const migrated = await db.query.user.findFirst({ where: eq(user.id, u.id) });
    if (!migrated) orphans.push(u.id);
  }
  if (orphans.length > 0) throw new Error(`${orphans.length} users lost their IDs`);
}
```

**When NOT to use forceAllowId:**
- For normal application code paths (sign-up, social link). Reserve it for one-shot migration scripts where you've audited the input.
- If your legacy IDs collide with Better Auth's ID format expectations (e.g., legacy uses integers, Better Auth uses UUIDs and you have a UUID column type), normalize the format first rather than forcing a mismatch.

Reference: [Better Auth — Auth0 Migration: Adapter create with forceAllowId](https://www.better-auth.com/docs/guides/auth0-migration-guide)
