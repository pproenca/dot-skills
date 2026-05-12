---
title: Set a Strong BETTER_AUTH_SECRET in Every Environment
impact: CRITICAL
impactDescription: prevents session forgery and silent session invalidation
tags: setup, secret, environment, security
---

## Set a Strong BETTER_AUTH_SECRET in Every Environment

Better Auth uses `BETTER_AUTH_SECRET` (or `AUTH_SECRET`) to sign session cookies, JWTs, and verification tokens. In development, Better Auth falls back to a built-in secret if none is set — but production explicitly throws. Reusing the same secret across environments, or rotating it without a migration plan, invalidates every active session for every user simultaneously.

**Incorrect (no secret, reused secret, or weak value):**

```env
# .env.production
# (BETTER_AUTH_SECRET unset — production throws on startup)
BETTER_AUTH_URL=https://app.example.com
```

```env
# .env.production
BETTER_AUTH_SECRET=development-secret # reused from local — leaks via dev tools / accidental commit
```

**Correct (per-environment 32-byte random secret):**

```bash
# generate once per environment, store in your secrets manager
openssl rand -base64 32
```

```env
# .env.production
BETTER_AUTH_SECRET=YkV3...32-bytes-base64
BETTER_AUTH_URL=https://app.example.com
```

**When NOT to rotate the secret without a migration plan:**
- A rotation invalidates all session cookies signed with the old secret. Coordinate with a forced-logout deployment, or honor both secrets during a window.

Reference: [Better Auth — Options: secret](https://www.better-auth.com/docs/reference/options#secret)
