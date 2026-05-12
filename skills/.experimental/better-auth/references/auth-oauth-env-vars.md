---
title: Load OAuth Credentials From Environment, Never Inline in Source
impact: HIGH
impactDescription: prevents committed secret keys from leaking to repo history and CI logs
tags: auth, oauth, secrets, environment
---

## Load OAuth Credentials From Environment, Never Inline in Source

OAuth `clientSecret` values are bearer credentials — anyone holding one can impersonate your application to the provider and harvest user tokens. Inlining them in `lib/auth.ts` for "convenience" exposes them in: repository history (even after `git rm`), CI logs that print configs, the bundled JS if `auth.ts` is ever imported by a client component, error stack traces, and any logging middleware that dumps `auth.options`. The 1-line cost of `process.env.GOOGLE_CLIENT_SECRET!` is non-negotiable.

**Incorrect (hardcoded secret):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  socialProviders: {
    google: {
      clientId: "987654321-abcdef.apps.googleusercontent.com",
      clientSecret: "GOCSPX-aBcDeFgHiJkLmNoPqRsTuVwXyZ", // ← committed to git
    },
  },
});
```

**Correct (env-loaded with explicit non-null assertion):**

```typescript
import { betterAuth } from "better-auth";

export const auth = betterAuth({
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
    github: {
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    },
  },
});
```

```env
# .env.local (gitignored)
GOOGLE_CLIENT_ID=987654321-abcdef.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-aBcDeFgHiJkLmNoPqRsTuVwXyZ
GITHUB_CLIENT_ID=Iv1.abc123
GITHUB_CLIENT_SECRET=ghp_xxxxxxxxxxxx
```

**Implementation (with runtime validation):**

```typescript
import { z } from "zod";

const env = z.object({
  GOOGLE_CLIENT_ID: z.string().min(1),
  GOOGLE_CLIENT_SECRET: z.string().min(1),
  GITHUB_CLIENT_ID: z.string().min(1),
  GITHUB_CLIENT_SECRET: z.string().min(1),
  BETTER_AUTH_SECRET: z.string().min(32),
  BETTER_AUTH_URL: z.string().url(),
}).parse(process.env);

export const auth = betterAuth({
  baseURL: env.BETTER_AUTH_URL,
  socialProviders: {
    google: { clientId: env.GOOGLE_CLIENT_ID, clientSecret: env.GOOGLE_CLIENT_SECRET },
    github: { clientId: env.GITHUB_CLIENT_ID, clientSecret: env.GITHUB_CLIENT_SECRET },
  },
});
```

**Warning:** If a secret has been committed, rotate it immediately — `git rm` and force-push do not remove it from forks, CI caches, or git hosting backups.

Reference: [Better Auth — Social Providers Setup](https://www.better-auth.com/docs/authentication/google)
