---
title: Wrap Mutations with `authActionClient` / `publicActionClient` / `captchaActionClient`
impact: HIGH
impactDescription: prevents per-mutation auth/validation drift
tags: mutate, server-action, safe-action, authentication
---

## Wrap Mutations with `authActionClient` / `publicActionClient` / `captchaActionClient`

The kit ships three action clients from `@kit/next/safe-action`: `publicActionClient` (no auth), `authActionClient` (requires user — injects `ctx.user`), and `captchaActionClient` (verifies a CAPTCHA token + auth). Wrapping every mutation in one of them gives you Zod input validation, server-side error handling, structured client ergonomics (`useAction`), and consistent return shapes for free. Bare `'use server'` functions force every action to re-implement auth, parsing, error envelopes, and the client-side fetch wiring.

**Incorrect (bare `'use server'` — every action re-invents the wheel):**

```ts
'use server';

export async function createProjectAction(formData: FormData) {
  const client = getSupabaseServerClient();
  const { data } = await client.auth.getClaims();
  if (!data?.claims) {
    throw new Error('Unauthenticated');  // Client sees a generic error.
  }

  // Manual extraction, no validation.
  const name = formData.get('name') as string;
  if (!name || name.length > 200) {
    throw new Error('Invalid name');     // Different error shape than other actions.
  }

  // ... insert ...

  // No standard wiring to useAction on the client side.
  return { ok: true };
}
```

**Correct (use the action client variant that matches the auth posture):**

```ts
// packages/features/projects/src/server/create-project-action.ts
'use server';

import { authActionClient } from '@kit/next/safe-action';
import { CreateProjectSchema } from './create-project.schema';
import { createCreateProjectService } from './services/create-project.service';

export const createProjectAction = authActionClient
  .inputSchema(CreateProjectSchema)                      // Zod-validated on server.
  .action(async ({ parsedInput: { name }, ctx: { user } }) => {
    // user is typed JWTUserData, already authenticated by the middleware.
    const service = createCreateProjectService(getSupabaseServerClient());
    return await service.createProject({ name, userId: user.id });
  });
```

**Picking the variant:**

| Action client | When to use | Authentication | CAPTCHA |
|---------------|-------------|----------------|---------|
| `publicActionClient` | Marketing-page actions (newsletter signup, contact form without auth) | No | No (but consider captcha) |
| `authActionClient` | Default for in-app mutations | Yes — `requireUser` runs first | No |
| `captchaActionClient` | Public actions that abuse-risk (signup, contact form) | Yes (after captcha) | Yes |
| `adminActionClient` | Super-admin-only mutations | Yes + `isSuperAdmin` check | No |

**What each wrapper does behind the scenes:**

```ts
// From packages/next/src/actions/safe-action-client.ts
const baseClient = createSafeActionClient({
  handleServerError: (error) => error.message,
});

export const publicActionClient = baseClient;

export const authActionClient = baseClient.use(async ({ next }) => {
  const auth = await requireUser(getSupabaseServerClient());
  if (!auth.data) redirect(auth.redirectTo);          // Sign-in or MFA verify.
  return next({ ctx: { user: auth.data } });          // Inject user into handler ctx.
});

export const captchaActionClient = baseClient.use(async ({ next, clientInput }) => {
  const token = (clientInput as any)?.captchaToken ?? '';
  await verifyCaptchaToken(token);                    // Throws if invalid.
  const auth = await requireUser(getSupabaseServerClient());
  if (!auth.data) redirect(auth.redirectTo);
  return next({ ctx: { user: auth.data } });
});
```

**Client side gets `useAction` for free:**

```tsx
'use client';
import { useAction } from 'next-safe-action/hooks';
import { createProjectAction } from '@kit/projects/server/actions';

function NewProjectForm() {
  const { execute, isPending, result } = useAction(createProjectAction, {
    onSuccess: () => toast.success('Project created'),
    onError: ({ error }) => toast.error(error.serverError ?? 'Failed'),
  });
  // execute is typed by the Zod schema — calling it with wrong shape fails to compile.
  // isPending tracks the mutation; result holds success/error.
}
```

**Don't reach for raw `fetch` from the client to call an action.** That bypasses every guarantee — type safety, error wiring, loading state. The whole point of safe-action is the typed binding between server action and client hook.

Reference: [next-safe-action docs](https://next-safe-action.dev/)
