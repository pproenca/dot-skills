---
title: Handle the NaN valueAsNumber Produces for an Empty Input
impact: HIGH
impactDescription: prevents an optional number field that can never be left blank
tags: valid, valueAsNumber, setValueAs, NaN, optional-fields
---

## Handle the NaN valueAsNumber Produces for an Empty Input

`register('n', { valueAsNumber: true })` converts an empty string to **`NaN`**, not to `undefined` or `null`. This is deliberate — a fix that treated `NaN` as empty was reverted in 7.76.1 — so it is stable behaviour you have to design around rather than a bug to wait out.

It is invisible on a required field, where any complaint is the complaint you wanted. It breaks **optional** number fields: the user clears the box, the schema receives `NaN`, `z.number().optional()` rejects it, and the field can never be left blank. The error text ("expected number, received nan") points at the schema rather than at the conversion, so the cause is easy to miss.

**Incorrect (an optional field the user cannot clear):**

```typescript
const listingSchema = z.object({
  title: z.string().min(1),
  reservePrice: z.number().positive().optional(),
})

function ListingForm() {
  const { register, handleSubmit } = useForm<ListingFormValues>({
    resolver: zodResolver(listingSchema),
    defaultValues: { title: '', reservePrice: undefined },
  })

  return (
    <form onSubmit={handleSubmit(saveListing)}>
      {/* Clearing the input yields NaN, which fails .optional() */}
      <input type="number" {...register('reservePrice', { valueAsNumber: true })} />
    </form>
  )
}
```

**Correct (map empty to undefined with setValueAs):**

```typescript
const listingSchema = z.object({
  title: z.string().min(1),
  reservePrice: z.number().positive().optional(),
})

function ListingForm() {
  const { register, handleSubmit } = useForm<ListingFormValues>({
    resolver: zodResolver(listingSchema),
    defaultValues: { title: '', reservePrice: undefined },
  })

  return (
    <form onSubmit={handleSubmit(saveListing)}>
      <input
        type="number"
        {...register('reservePrice', {
          setValueAs: (value) => (value === '' ? undefined : Number(value)),
        })}
      />
    </form>
  )
}
```

`setValueAs` and `valueAsNumber` are mutually exclusive — supplying `setValueAs` replaces the built-in conversion, which is exactly what you want here.

For a **required** number, `valueAsNumber: true` is fine: `NaN` fails validation, which is the correct outcome. Reserve `setValueAs` for fields that are genuinely allowed to be empty, and prefer it over `z.coerce.number()`, which turns `''` into `0` and would silently record a reserve price of zero.

Reference: [register - valueAsNumber](https://react-hook-form.com/docs/useform/register)
