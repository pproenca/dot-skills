---
title: Pass the Third useForm Generic When the Resolver Transforms Values
impact: CRITICAL
impactDescription: makes handleSubmit receive the schema's output type instead of its input type
tags: formcfg, generics, resolver, zod, transform, typescript
---

## Pass the Third useForm Generic When the Resolver Transforms Values

`useForm` takes three generics: `useForm<TFieldValues, TContext, TTransformedValues>`. The first is what lives in the form (what inputs produce, before validation); the third is what `handleSubmit` hands your success callback. They are the same type only when the schema does no transformation.

The moment a schema uses `z.coerce`, `.transform()`, or a `.default()`, input and output diverge — the form holds a string, the schema yields a `Date` or a `number`. Omit the third generic and TypeScript pins the output to the input type, which the resolver then contradicts. With `@hookform/resolvers` v5 the error lands on the `resolver:` property and reads like this:

```text
Type 'Resolver<{ arrivesOn: string; … }, any, { arrivesOn: Date; … }>' is not assignable to
type 'Resolver<{ arrivesOn: string; … }, any, { arrivesOn: string; … }>'.
  Types of property 'arrivesOn' are incompatible.
    Type 'Date' is not assignable to type 'string'.
```

Nothing in that message mentions a missing generic, so the usual reactions are to cast the resolver, widen the schema until the transform is gone, or drop the resolver's type entirely — all of which trade a correct error for silently wrong types. This is the most common typing failure in RHF + Zod and the fix is one type argument.

**Incorrect (one generic — the resolver's output type contradicts the form's, and handleSubmit is typed with the pre-validation input):**

```typescript
const bookingSchema = z.object({
  guests: z.coerce.number().int().min(1),
  arrivesOn: z.iso.date().transform((value) => new Date(value)),
})

type BookingInput = z.input<typeof bookingSchema>

function BookingForm() {
  const { register, handleSubmit } = useForm<BookingInput>({
    resolver: zodResolver(bookingSchema),
    defaultValues: { guests: '1', arrivesOn: '' },
  })

  // The resolver above fails to typecheck; values.arrivesOn is string, but is a Date at runtime
  return <form onSubmit={handleSubmit((values) => createBooking(values))} />
}
```

**Correct (three generics — the callback is typed with the schema's output):**

```typescript
const bookingSchema = z.object({
  guests: z.coerce.number().int().min(1),
  arrivesOn: z.iso.date().transform((value) => new Date(value)),
})

type BookingInput = z.input<typeof bookingSchema>
type BookingOutput = z.output<typeof bookingSchema>

function BookingForm() {
  const { register, handleSubmit } = useForm<BookingInput, unknown, BookingOutput>({
    resolver: zodResolver(bookingSchema),
    defaultValues: { guests: '1', arrivesOn: '' },
  })

  // values.arrivesOn is Date, values.guests is number — matching runtime
  return <form onSubmit={handleSubmit((values) => createBooking(values))} />
}
```

The middle generic is the resolver context; pass `unknown` when you don't use one. Derive both types from the schema (`z.input` / `z.output`) rather than hand-writing them, so they can't drift.

If `handleSubmit` is fighting you about a field type, check this generic before reaching for `as`.

Reference: [useForm](https://react-hook-form.com/docs/useform) · [React Hook Form Resolvers](https://github.com/react-hook-form/resolvers)
