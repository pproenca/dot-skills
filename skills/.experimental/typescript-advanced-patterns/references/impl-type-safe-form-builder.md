---
title: Drive Form-Field Inference from a Single Schema Definition
impact: MEDIUM-HIGH
impactDescription: prevents 100% of field-name drift between forms, validators, and submission payloads
tags: impl, forms, schema, inference, react-hook-form, validation
---

## Drive Form-Field Inference from a Single Schema Definition

In most React form codebases, the field list lives in the JSX, the validation rules live in the validator config, and the submission shape lives in the API client — three sources of truth that drift independently. The advanced application of schema-first inference (`[[dsl-schema-first-inference]]`) to forms is to make the schema produce the field names, the validators, and the typed `onSubmit` handler in one declaration. React Hook Form, Conform, and TanStack Form all support this; the pattern is general.

**Incorrect (parallel sources — field renames break silently):**

```typescript
// FormFields.tsx
function CreateUserForm() {
  const { register, handleSubmit } = useForm()
  return (
    <form onSubmit={handleSubmit(submit)}>
      <input {...register('email', { required: true, pattern: /.+@.+/ })} />
      <input {...register('fullName', { required: true })} />  {/* renamed from "name" */}
      <button>Submit</button>
    </form>
  )
}

async function submit(data: { email: string; name: string }) {  // stale name
  await api.createUser(data)  // payload mismatch — server gets fullName, client thinks it's `name`
}
```

**Correct (schema drives field names, types, and validators):**

```typescript
import { z } from 'zod'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'

const createUserSchema = z.object({
  email: z.string().email(),
  fullName: z.string().min(1).max(120),
  marketingOptIn: z.boolean().default(false),
})

type CreateUserInput = z.input<typeof createUserSchema>

function CreateUserForm({ onSubmit }: { onSubmit: (input: CreateUserInput) => void }) {
  const { register, handleSubmit, formState } = useForm<CreateUserInput>({
    resolver: zodResolver(createUserSchema),
  })
  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {formState.errors.email && <p>{formState.errors.email.message}</p>}
      <input {...register('fullName')} />
      {formState.errors.fullName && <p>{formState.errors.fullName.message}</p>}
      <label><input type="checkbox" {...register('marketingOptIn')} /> Marketing</label>
      <input {...register('nonExistentField')} />  {/* Error: not a key of CreateUserInput */}
      <button disabled={!formState.isValid}>Submit</button>
    </form>
  )
}
```

Renaming `fullName` to `displayName` in the schema produces type errors at every `register('fullName')` call and at every consumer's `onSubmit`. No silent drift.

Compose this with `[[impl-schema-derived-api-client]]` and the same schema (or a transform of it) becomes the API payload, closing the loop from input field → validated state → request body → server side.

**When NOT to apply:**
- Highly dynamic forms where the field list changes at runtime (admin tools, configurable surveys). The static schema cannot represent variable shapes — use a registry pattern with `Record<string, FieldDef>` and accept that field-name safety is local rather than end-to-end.
- Forms with one or two fields where the schema overhead exceeds the benefit. `useState<string>` is fine for a search box.

**Scope delta:**
- Companion to `[[dsl-schema-first-inference]]`. The schema-first rule says "derive types from schemas"; this rule applies that discipline to forms, where the consequence is field-name autocomplete and end-to-end submit safety, not just type narrowing.

Reference: [React Hook Form — Zod Resolver](https://react-hook-form.com/get-started#SchemaValidation)
