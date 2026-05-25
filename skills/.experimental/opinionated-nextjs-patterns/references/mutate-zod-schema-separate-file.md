---
title: Put Zod Schemas in Their Own `*.schema.ts` File Shared by Client and Server
impact: HIGH
impactDescription: enables schema reuse between server action and client form
tags: mutate, zod, schema, validation, share
---

## Put Zod Schemas in Their Own `*.schema.ts` File Shared by Client and Server

A Zod schema declared in the same file as a `'use server'` directive is server-only — Next.js refuses to import that file into a client component. Splitting the schema into `*.schema.ts` lets the server action AND the client-side form (`zodResolver` for React Hook Form) import the same definition. One source of truth, validated on both sides, with error messages that stay in sync.

**Incorrect (schema inside the action file — can't reuse on the client):**

```ts
// create-project.action.ts
'use server';
import * as z from 'zod';

const CreateProjectSchema = z.object({
  name: z.string().min(1).max(200),
  description: z.string().max(2000).optional(),
});

export const createProjectAction = authActionClient
  .inputSchema(CreateProjectSchema)
  .action(async ({ parsedInput }) => { /* ... */ });
```

```tsx
// create-project-form.tsx
'use client';
import { CreateProjectSchema } from './create-project.action'; // Won't import — file is server-only.
// You redefine the schema here. Now it's max(200) on the server but max(255) on the client.
// The form accepts names the server rejects → 400 from the action → bad UX.
```

**Correct (schema in its own file — both sides import it):**

```ts
// packages/features/projects/src/schema/create-project.schema.ts
import * as z from 'zod';

export const CreateProjectSchema = z.object({
  name: z.string().min(1, 'projects.errors.nameRequired').max(200),
  description: z.string().max(2000).optional(),
});

export type CreateProjectInput = z.output<typeof CreateProjectSchema>;
```

```ts
// packages/features/projects/src/server/create-project-action.ts
'use server';
import { authActionClient } from '@app/next/safe-action';
import { CreateProjectSchema } from '../schema/create-project.schema';

export const createProjectAction = authActionClient
  .inputSchema(CreateProjectSchema) // Server validation.
  .action(async ({ parsedInput, ctx: { user } }) => { /* ... */ });
```

```tsx
// packages/features/projects/src/components/create-project-form.tsx
'use client';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { useAction } from 'next-safe-action/hooks';

import { CreateProjectSchema } from '../schema/create-project.schema';
import { createProjectAction } from '../server/create-project-action';

export function CreateProjectForm() {
  const { execute } = useAction(createProjectAction);
  const form = useForm({
    resolver: zodResolver(CreateProjectSchema), // Same schema — client validation.
    defaultValues: { name: '', description: '' },
  });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit((values) => execute(values))}>
        {/* fields */}
      </form>
    </Form>
  );
}
```

**`import * as z from 'zod'`, not `import { z } from 'zod'`.** This is Zod v4's namespace-import style — it's what enables the tree-shaking story. `import { z } from 'zod'` defeats it (the bundler can't analyse usage through the proxy). Use the namespace import for every schema in the codebase; deviating breaks lint rules and unbalances bundle output.

**Naming convention:** `{action-name}.schema.ts`, colocated with the action under `packages/features/<feature>/src/schema/` or `apps/web/.../_lib/schema/`. The `.schema` suffix makes the file's role visible at a glance.

**Schemas with i18n error messages:** wrap the schema in a function that takes the translation-key resolver, so the same definition serves both sides while the message is translated by the caller:

```ts
// update-email.schema.ts
import * as z from 'zod';

export const UpdateEmailSchema = {
  withTranslation: (mismatchMessage: string) =>
    z
      .object({
        email: z.string().email(),
        repeatEmail: z.string().email(),
      })
      .refine((values) => values.email === values.repeatEmail, {
        path: ['repeatEmail'],
        message: mismatchMessage, // Translated by the caller.
      }),
};

// Usage on the client:
const t = useTranslations();
const resolver = zodResolver(
  UpdateEmailSchema.withTranslation(t('account.emailsMustMatch')),
);
```

**Use `z.output<typeof Schema>`, not `z.infer<typeof Schema>`.** They're identical when there are no transforms, but `z.output` is correct when the schema contains `.transform()` or `.default()`. Pick one and stay consistent.

**The schema is the contract.** Once you split it out, every change to what the action accepts goes through that file. Reviewers see the contract change in isolation, not buried inside a service refactor.

Reference: [Zod schema definitions](https://zod.dev/)
