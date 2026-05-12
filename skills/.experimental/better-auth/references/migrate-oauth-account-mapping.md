---
title: Map Legacy OAuth Identities to Better Auth account Rows, Preserving Provider IDs
impact: MEDIUM
impactDescription: prevents OAuth users from being treated as new users on first sign-in after migration
tags: migrate, oauth, account, schema-mapping
---

## Map Legacy OAuth Identities to Better Auth account Rows, Preserving Provider IDs

Better Auth stores each OAuth identity as a row in the `account` table keyed on `(providerId, accountId)` — where `accountId` is the OAuth provider's user ID (Google's `sub`, GitHub's `id`, etc.). NextAuth/Auth.js calls these "accounts" too, Auth0 calls them "identities", Clerk calls them "external accounts" — schemas differ but the concept is the same. If your migration creates `user` rows but doesn't populate `account` rows, OAuth users land on the sign-in page, click "Sign in with Google," and get a NEW user — duplicated, separate from their old data.

**Incorrect (migrate users only, skip accounts):**

```typescript
// Migration script
for (const oldUser of legacyUsers) {
  await db.insert(user).values({
    id: oldUser.id,
    email: oldUser.email,
    name: oldUser.name,
  });
  // account rows not created → next Google sign-in creates duplicate user
}
```

**Correct (preserve OAuth identity → account mapping):**

```typescript
// Migration script — for an Auth0 export
for (const auth0User of legacyUsers) {
  // 1. Create the user row
  await db.insert(user).values({
    id: auth0User.user_id,
    email: auth0User.email,
    emailVerified: auth0User.email_verified ?? false,
    name: auth0User.name,
    image: auth0User.picture,
    createdAt: new Date(auth0User.created_at),
    updatedAt: new Date(auth0User.updated_at),
  });

  // 2. Create one account row per OAuth identity
  for (const identity of auth0User.identities ?? []) {
    const providerId = identity.provider === "auth0" ? "credential" : identity.provider;
    await db.insert(account).values({
      id: `${auth0User.user_id}|${providerId}|${identity.user_id}`,
      userId: auth0User.user_id,
      providerId,
      accountId: identity.user_id, // ← MUST match what the provider returns on next OAuth sign-in
      accessToken: identity.access_token,
      refreshToken: identity.refresh_token,
      scope: identity.scope,
      idToken: identity.id_token,
      // password is null for OAuth; populated only for credential provider
    });
  }

  // 3. Email/password identity → 'credential' account with hashed password
  if (auth0User.password_hash) {
    await db.insert(account).values({
      id: `${auth0User.user_id}|credential`,
      userId: auth0User.user_id,
      providerId: "credential",
      accountId: auth0User.email,
      password: auth0User.password_hash, // verify in custom verify() — see security-password-hash-interop
    });
  }
}
```

**Implementation (verification step):**

```typescript
// After migration, dry-run sign-in for a sample of users
const sample = legacyUsers.slice(0, 100);
for (const u of sample) {
  const account = await db.query.account.findFirst({
    where: and(eq(account.providerId, "google"), eq(account.accountId, u.google_sub)),
  });
  if (!account) console.error(`Missing OAuth account for ${u.email}`);
}
```

Reference: [Better Auth — Auth0 Migration Guide](https://www.better-auth.com/docs/guides/auth0-migration-guide)
