---
title: Avoid Unnecessary Re-renders in Forms
impact: MEDIUM
impactDescription: prevents full form re-render on every keystroke
tags: perf, forms, re-renders, react-hook-form, isolation
---

## Avoid Unnecessary Re-renders in Forms

Isolate frequently updating form state to prevent entire form re-renders. Watch specific fields instead of the entire form state.

**Incorrect (watching entire form state):**

```tsx
function CheckoutForm() {
  const form = useForm<CheckoutFormValues>()
  const values = form.watch() // Re-renders entire form on ANY field change

  const total = calculateTotal(values.items, values.coupon)

  return (
    <Form {...form}>
      {/* All 20 form fields re-render on every keystroke */}
      <FormField name="name" control={form.control} render={...} />
      <FormField name="email" control={form.control} render={...} />
      <FormField name="address" control={form.control} render={...} />
      {/* ... 17 more fields */}
      <div>Total: ${total}</div>
    </Form>
  )
}
```

**Correct (isolated watch with useWatch):**

```tsx
function CheckoutForm() {
  const form = useForm<CheckoutFormValues>()

  return (
    <Form {...form}>
      <FormField name="name" control={form.control} render={...} />
      <FormField name="email" control={form.control} render={...} />
      <FormField name="address" control={form.control} render={...} />
      {/* Fields don't re-render when unrelated fields change */}

      {/* Isolated component for reactive total */}
      <OrderTotal control={form.control} />
    </Form>
  )
}

function OrderTotal({ control }: { control: Control<CheckoutFormValues> }) {
  // Only this component re-renders when items or coupon change
  const items = useWatch({ control, name: "items" })
  const coupon = useWatch({ control, name: "coupon" })

  const total = calculateTotal(items, coupon)

  return <div className="text-lg font-bold">Total: ${total}</div>
}
```

**Alternative (watch specific fields at form level):**

```tsx
function CheckoutForm() {
  const form = useForm<CheckoutFormValues>()

  // Only watch specific fields needed for calculations
  const [items, coupon] = form.watch(["items", "coupon"])
  // Still causes re-renders but only for these 2 fields

  return (
    <Form {...form}>
      {/* ... */}
    </Form>
  )
}
```

**Best practices:**
- Use `useWatch` in isolated child components
- Watch specific field names, not entire form
- Use `useFormState` for submission/validation state
- Use `useController` for complex controlled components

Reference: [React Hook Form useWatch](https://react-hook-form.com/docs/usewatch)
