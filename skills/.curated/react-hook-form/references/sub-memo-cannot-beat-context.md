---
title: React.memo Cannot Stop Context-Driven Re-renders Under FormProvider
impact: MEDIUM
impactDescription: replaces a memo pass that has no effect with isolation that does
tags: sub, FormProvider, memo, useFormContext, isolation
---

## React.memo Cannot Stop Context-Driven Re-renders Under FormProvider

The instinct when a `FormProvider` tree re-renders too much is to wrap the heavy children in `React.memo`. It does nothing here. `React.memo` compares props; a component that calls `useFormContext()` is a context consumer, and a context value change re-renders it regardless of whether its props were equal. `FormProvider` already memoizes its own value, but `formState` is one of that memo's dependencies, so the value's identity does change on every form-state update — and every `useFormContext()` consumer under it re-renders.

Wrapping in `memo` therefore buys nothing for the components you were worried about, and costs a comparison on every render for the ones you weren't.

**Incorrect (memo on a context consumer — still re-renders on every form-state update):**

```typescript
const AddressSection = React.memo(function AddressSection() {
  const { register, control } = useFormContext<CheckoutForm>()
  const { errors } = useFormState<CheckoutForm>({ control })  // Consumes context; memo is bypassed

  return (
    <fieldset>
      <input {...register('street')} />
      {errors.street && <span>{errors.street.message}</span>}
    </fieldset>
  )
})
```

**Correct (subscribe to the narrowest slice, so the re-render is cheap and local):**

```typescript
function AddressSection() {
  const { register, control } = useFormContext<CheckoutForm>()

  return (
    <fieldset>
      <input {...register('street')} />
      <FormStateSubscribe
        control={control}
        name="street"
        render={({ errors }) => (errors.street ? <span>{errors.street.message}</span> : null)}
      />
    </fieldset>
  )
}
```

`React.memo` is still worth reaching for on a genuinely expensive child that takes plain props and does **not** read form context — a chart, a map, a large static list rendered as a sibling of the form. The distinction is whether the component consumes context at all.

Reference: [FormProvider](https://react-hook-form.com/docs/formprovider) · [useFormState](https://react-hook-form.com/docs/useformstate)
