---
title: Run Every Mutation Through a Typed Auth-Checked Action Client You Build on next-safe-action
impact: HIGH
impactDescription: prevents per-mutation auth/validation drift
tags: mutate, server-action, safe-action, authentication
---

## Run Every Mutation Through a Typed Auth-Checked Action Client You Build on next-safe-action

Define a small set of action clients once in `@app/next/safe-action` and route every mutation through the one that matches its auth posture. A bare `'use server'` function forces each action to re-implement authentication, input parsing, error envelopes, and the client-side fetch wiring — so they drift apart and one of them eventually forgets the auth check. A shared client gives you Zod validation, server-side error handling, a typed `useAction` binding, and a consistent return shape for free.

**Incorrect (bare `'use server'` — every action re-invents the wheel):**

```ts
'use server';

export async function createProjectAction(formData: FormData) {
  const client = getServerClient();
  const { data } = await client.auth.getClaims();
  if (!data?.claims) {
    throw new Error('Unauthenticated'); // Client sees a generic, unstructured error.
  }

  const name = formData.get('name') as string; // No validation.
  if (!name || name.length > 200) {
    throw new Error('Invalid name'); // Different error shape than other actions.
  }
  // ... insert ... no standard wiring to a client hook.
  return { ok: true };
}
```

**Correct (use the action client variant that matches the auth posture):**

```ts
// features/projects/server/create-project-action.ts
'use server';

import { authActionClient } from '@app/next/safe-action';
import { CreateProjectSchema } from './create-project.schema';
import { createCreateProjectService } from './services/create-project.service';
import { getServerClient } from '@app/supabase/server';

export const createProjectAction = authActionClient
  .inputSchema(CreateProjectSchema) // Zod-validated on the server.
  .action(async ({ parsedInput: { name }, ctx: { user } }) => {
    const service = createCreateProjectService(getServerClient());
    return service.createProject({ name, userId: user.id }); // user is already authenticated.
  });
```

**You own the action clients** (`@app/next/safe-action.ts`) — they are a thin layer on `next-safe-action`, not a vendored helper:

```ts
import 'server-only';
import { createSafeActionClient } from 'next-safe-action';
import { redirect } from 'next/navigation';
import { requireUser } from '@app/supabase/require-user';
import { getServerClient } from '@app/supabase/server';
import { verifyCaptchaToken } from '@app/captcha/server';

const baseClient = createSafeActionClient({
  handleServerError: (error) => error.message,
});

export const publicActionClient = baseClient;

export const authActionClient = baseClient.use(async ({ next }) => {
  const auth = await requireUser(getServerClient());
  if (!auth.data) redirect(auth.redirectTo); // Sign-in or MFA-verify route.
  return next({ ctx: { user: auth.data } }); // Inject the user into the handler ctx.
});

export const captchaActionClient = authActionClient.use(async ({ next, clientInput }) => {
  await verifyCaptchaToken((clientInput as { captchaToken?: string }).captchaToken ?? '');
  return next();
});
```

**Picking the variant:**

| Action client | When to use | Authentication | CAPTCHA |
|---------------|-------------|----------------|---------|
| `publicActionClient` | Marketing actions with no session (newsletter signup) | No | Consider captcha |
| `authActionClient` | Default for in-app mutations | Yes — `requireUser` runs first | No |
| `captchaActionClient` | Abuse-prone public actions (signup, contact) | Yes | Yes |
| `adminActionClient` | Super-admin-only mutations | Yes + super-admin check | No |

**The client side gets a typed `useAction` for free:**

```tsx
'use client';
import { useAction } from 'next-safe-action/hooks';
import { createProjectAction } from '@app/projects/server';

function NewProjectForm() {
  const { execute, isPending } = useAction(createProjectAction, {
    onSuccess: () => toast.success('Project created'),
    onError: ({ error }) => toast.error(error.serverError ?? 'Failed'),
  });
  // execute is typed by the Zod schema — calling it with the wrong shape fails to compile.
}
```

**Don't call an action with raw `fetch` from the client.** That bypasses the type binding, error wiring, and loading state — the whole reason to route mutations through these clients.

Reference: [next-safe-action documentation](https://next-safe-action.dev/)
