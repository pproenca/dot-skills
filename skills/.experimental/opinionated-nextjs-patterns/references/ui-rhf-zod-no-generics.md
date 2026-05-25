---
title: Let `zodResolver` Infer Form Types — Don't Add `useForm` Generics
impact: MEDIUM
impactDescription: prevents type/schema drift in forms
tags: ui, react-hook-form, zod, types, inference
---

## Let `zodResolver` Infer Form Types — Don't Add `useForm` Generics

`useForm({ resolver: zodResolver(Schema), defaultValues: {...} })` infers the form's TypeScript type from the schema. Adding `useForm<MyType>()` decouples the form view from the schema: when the schema changes, the form types don't, and the form silently accepts (or rejects) the wrong shape. Let the resolver be the source of truth.

**Incorrect (manual generic — duplicates the schema):**

```tsx
'use client';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

type CreateProjectFormValues = {
  name: string;
  description?: string;
  // Person who wrote this forgot to add `archived` after the schema gained it.
};

const form = useForm<CreateProjectFormValues>({
  resolver: zodResolver(CreateProjectSchema),  // Schema has `archived`; type doesn't.
  defaultValues: { name: '', description: '' },
});

// register('archived')  → type error, even though the schema allows it.
// Or worse: register('archived' as any) — silently works but type-unsafe.
```

**Correct (let inference do its job):**

```tsx
'use client';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

import { CreateProjectSchema } from '../schema/create-project.schema';

// No generic. RHF infers the form type from the resolver's schema.
const form = useForm({
  resolver: zodResolver(CreateProjectSchema),
  defaultValues: { name: '', description: '' },
});

// form.register('name'), form.register('description'), form.register('archived')
// — all type-checked against the schema's shape.
```

**Why this matters more in larger forms:** with 15 fields, the temptation to hand-type the form is highest, and the cost of drift is highest. The schema is already the spec — re-typing it in TypeScript and keeping the two in sync is busywork the compiler can do.

**`useWatch`, not `watch()`:**

```tsx
// Incorrect — watch() causes the entire form to re-render on any field change.
const name = form.watch('name');

// Correct — useWatch subscribes to a specific field, re-renders only on its change.
import { useWatch } from 'react-hook-form';
const name = useWatch({ control: form.control, name: 'name' });
```

**`defaultValues`** *should* match the schema's input type. If you set `defaultValues: { name: '' }` for a schema with `name: z.string().min(1)`, the form is in an invalid state on first render — that's fine because submit is gated, but error messages flash on touch.

**Avoid `as` casts on `defaultValues`:**

```tsx
// Smell: defaultValues being cast means TypeScript caught a real mismatch.
useForm({
  resolver: zodResolver(Schema),
  defaultValues: { name: undefined } as z.input<typeof Schema>,  // ❌
});

// Fix the defaults to match the schema's input shape instead.
useForm({
  resolver: zodResolver(Schema),
  defaultValues: { name: '', email: '' },
});
```

**The schema is the contract.** Once it's defined, the form, the server action (`.inputSchema(Schema)`), and the route handler (which validates the body against the same `Schema`) all derive their types from it. Three derivations, one source.

**One escape valve:** schemas with `.transform()` produce different input and output types. Use `z.input<typeof Schema>` for `defaultValues` and `z.output<typeof Schema>` for what your handler receives. RHF's resolver handles this correctly without you specifying the generic.

Reference: [React Hook Form](https://react-hook-form.com/)
