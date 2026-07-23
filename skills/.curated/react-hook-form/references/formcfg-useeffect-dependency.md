---
title: Depend on formState Slices, Not on formState Itself
impact: HIGH
impactDescription: prevents effects that re-run on every keystroke
tags: formcfg, useEffect, dependencies, formState
---

## Depend on formState Slices, Not on formState Itself

The `useForm()` return object is **stable**. `useForm` keeps it in a `useRef` and returns the same object on every render, mutating `formState` onto it — so `useEffect(fn, [form])` runs once, and `register`, `reset`, `control`, `setValue` and friends are all safe dependencies. (Widely repeated advice says the form object is a fresh reference each render and loops; that is not true of any v7 release.)

The `formState` **proxy** is the part that changes. It is rebuilt via `useMemo` keyed on the underlying state, so it gets a new identity on every form-state update — every keystroke, in `onChange` mode. Depending on it re-runs the effect that often. Depend on the specific boolean you care about.

**Incorrect (effect re-runs on every form-state update, not just on success):**

```typescript
function ContactForm({ onSaved }: { onSaved: () => void }) {
  const { register, handleSubmit, reset, formState } = useForm({
    defaultValues: { email: '' },
  })

  useEffect(() => {
    if (formState.isSubmitSuccessful) {
      reset()
      onSaved()
    }
  }, [formState, reset, onSaved])  // New proxy identity on every keystroke

  return (
    <form onSubmit={handleSubmit(saveContact)}>
      <input {...register('email')} />
    </form>
  )
}
```

**Correct (depend on the slice that actually gates the effect):**

```typescript
function ContactForm({ onSaved }: { onSaved: () => void }) {
  const { register, handleSubmit, reset, formState: { isSubmitSuccessful } } = useForm({
    defaultValues: { email: '' },
  })

  useEffect(() => {
    if (isSubmitSuccessful) {
      reset()
      onSaved()
    }
  }, [isSubmitSuccessful, reset, onSaved])  // Only flips once per successful submit

  return (
    <form onSubmit={handleSubmit(saveContact)}>
      <input {...register('email')} />
    </form>
  )
}
```

Destructuring also matters for a second reason: reading `formState.isSubmitSuccessful` is what registers the Proxy subscription in the first place — see `formstate-destructure-formstate`.

Reference: [useForm](https://react-hook-form.com/docs/useform) · [formState](https://react-hook-form.com/docs/useform/formstate)
