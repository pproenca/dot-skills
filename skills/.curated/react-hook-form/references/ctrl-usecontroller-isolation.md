---
title: Isolate Controlled Inputs in Dedicated Child Components
impact: HIGH
impactDescription: reduces re-renders from O(n) to O(1) per field change
tags: ctrl, useController, Controller, controlled-components, re-renders
---

## Isolate Controlled Inputs in Dedicated Child Components

`Controller` and `useController` are equivalent — `Controller` is a thin component wrapper around `useController`. Re-render isolation does **not** come from picking one over the other. It comes from putting the subscription in a **child component**, so that when the field value changes, only the child re-renders. Inlining `Controller` (or `useController`) in the parent form makes every parent re-render flow through every controlled input.

**Incorrect (Controllers inlined in parent — every parent re-render re-renders all controlled inputs):**

```typescript
function PaymentForm() {
  const { control, handleSubmit } = useForm<PaymentFormData>()

  return (
    <form onSubmit={handleSubmit(submitPayment)}>
      <Controller
        name="amount"
        control={control}
        render={({ field }) => <CurrencyInput {...field} />}
      />
      <Controller
        name="currency"
        control={control}
        render={({ field }) => <CurrencySelect {...field} />}
      />
    </form>
  )
}
```

**Correct (subscription moved into dedicated child components, isolating re-renders to the changed field):**

```typescript
function PaymentForm() {
  const { control, handleSubmit } = useForm<PaymentFormData>()

  return (
    <form onSubmit={handleSubmit(submitPayment)}>
      <AmountInput control={control} />
      <CurrencySelectField control={control} />
    </form>
  )
}

function AmountInput({ control }: { control: Control<PaymentFormData> }) {
  const { field } = useController({ name: 'amount', control })
  return <CurrencyInput {...field} />
}

function CurrencySelectField({ control }: { control: Control<PaymentFormData> }) {
  const { field } = useController({ name: 'currency', control })
  return <CurrencySelect {...field} />
}
```

**Equivalent with `Controller` (also correct — same isolation):**

```typescript
function AmountField({ control }: { control: Control<PaymentFormData> }) {
  return (
    <Controller
      name="amount"
      control={control}
      render={({ field }) => <CurrencyInput {...field} />}
    />
  )
}
```

**When to prefer one API over the other:**
- `useController` — when you also need `fieldState`/`formState` in the same component, or want to compose with custom logic
- `Controller` — when you want a single JSX-only declaration and don't need to read state in the surrounding component

Both achieve the same re-render isolation when placed in a child component.

Reference: [useController](https://react-hook-form.com/docs/usecontroller) · [Controller](https://react-hook-form.com/docs/usecontroller/controller)
