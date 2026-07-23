---
title: Build the Validation Schema Once, Outside the Render Path
impact: HIGH
impactDescription: stops rebuilding the whole schema object on every keystroke
tags: valid, resolver, schema, zod, useMemo
---

## Build the Validation Schema Once, Outside the Render Path

There is no resolver cache in React Hook Form — `useForm` reassigns `control._options = props` on every render, and whatever resolver you passed is used as-is. The cost of an inline schema is the **construction**: `z.object({ … })` allocates a fresh validator tree every render, and under `mode: 'onChange'` that is once per keystroke, on top of the validation itself. Hoisting the schema to module scope makes it a one-time cost at import.

**Incorrect (a new schema object built on every render):**

```typescript
function InviteMemberForm() {
  const { register, handleSubmit } = useForm<InviteFormValues>({
    resolver: zodResolver(
      z.object({
        email: z.email('Enter a valid email address'),
        role: z.enum(['admin', 'editor', 'viewer']),
      }),
    ),
    defaultValues: { email: '', role: 'viewer' },
  })

  return (
    <form onSubmit={handleSubmit(sendInvite)}>
      <input {...register('email')} />
    </form>
  )
}
```

**Correct (built once at module load):**

```typescript
const inviteSchema = z.object({
  email: z.email('Enter a valid email address'),
  role: z.enum(['admin', 'editor', 'viewer']),
})

function InviteMemberForm() {
  const { register, handleSubmit } = useForm<InviteFormValues>({
    resolver: zodResolver(inviteSchema),
    defaultValues: { email: '', role: 'viewer' },
  })

  return (
    <form onSubmit={handleSubmit(sendInvite)}>
      <input {...register('email')} />
    </form>
  )
}
```

**When the schema genuinely depends on props or context**, hoist a factory instead of the schema and memoize the call — so it rebuilds when the input changes, not when the component renders:

```typescript
const createSeatSchema = (maxSeats: number) =>
  z.object({
    seats: z.number().int().max(maxSeats, `Your plan allows ${maxSeats} seats`),
  })

function SeatAllocationForm({ maxSeats }: { maxSeats: number }) {
  const schema = useMemo(() => createSeatSchema(maxSeats), [maxSeats])

  const { register, handleSubmit } = useForm<SeatFormValues>({
    resolver: zodResolver(schema),
    defaultValues: { seats: 1 },
  })

  return (
    <form onSubmit={handleSubmit(updateSeats)}>
      <input type="number" {...register('seats', { valueAsNumber: true })} />
    </form>
  )
}
```

Prefer a schema-level `.refine()` over a factory when the rule depends on *other fields* rather than on props — cross-field rules don't need the schema rebuilt.

Reference: [React Hook Form Resolvers](https://github.com/react-hook-form/resolvers)
