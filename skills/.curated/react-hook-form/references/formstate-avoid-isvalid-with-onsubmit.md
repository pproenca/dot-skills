---
title: Avoid isValid with onSubmit Mode for Button State
impact: MEDIUM
impactDescription: prevents whole-form validation on every change under a deferred-validation mode
tags: formstate, isValid, onSubmit, validation-mode
---

## Avoid isValid with onSubmit Mode for Button State

Subscribing to `isValid` opts the form into continuous validation. RHF only computes it when something reads it — `_setValid()` is gated on `isValid` being subscribed — but once it is, RHF runs the **whole form's** validation (the entire resolver schema, not just the changed field) on mount and again on every change event. Choosing `mode: 'onSubmit'` to defer validation and then reading `isValid` to grey out the submit button cancels out the deferral you asked for.

(The cost is per change event, not per render: re-rendering the component without touching a field does not re-validate.)

**Incorrect (isValid re-validates the whole form on every change despite onSubmit mode):**

```typescript
function RegistrationForm() {
  const { register, handleSubmit, formState: { isValid } } = useForm<RegistrationData>({
    defaultValues: { email: '', password: '' },  // mode defaults to 'onSubmit'
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email', { required: true })} />
      <input {...register('password', { required: true })} />
      <button disabled={!isValid}>Register</button>  {/* Opts the form into validating on every change */}
    </form>
  )
}
```

**Correct (use isSubmitting or allow submit attempt):**

```typescript
function RegistrationForm() {
  const { register, handleSubmit, formState: { isSubmitting } } = useForm<RegistrationData>({
    defaultValues: { email: '', password: '' },
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email', { required: true })} />
      <input {...register('password', { required: true })} />
      <button disabled={isSubmitting}>
        {isSubmitting ? 'Registering...' : 'Register'}
      </button>
    </form>
  )
}
```

**Alternative:** if a live-disabled submit button really is the requirement, say so explicitly rather than leaving the two settings in tension — pair `isValid` with a mode that already validates continuously:

```typescript
function RegistrationForm() {
  const { register, formState: { isValid } } = useForm<RegistrationData>({
    mode: 'onChange',  // Deliberate: the button reflects validity as the user types
    defaultValues: { email: '', password: '' },
  })

  return <button disabled={!isValid}>Register</button>
}
```

Reference: [useForm - mode](https://react-hook-form.com/docs/useform)
