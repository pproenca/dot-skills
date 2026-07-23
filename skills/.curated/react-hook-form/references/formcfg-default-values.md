---
title: Always Provide defaultValues for Form Initialization
impact: CRITICAL
impactDescription: prevents uncontrolled-to-controlled input warnings and a reset() with nothing to restore
tags: formcfg, default-values, initialization, useForm
---

## Always Provide defaultValues for Form Initialization

`useForm<T>()` with no `defaultValues` starts every field as `undefined`. Three things break at once: any controlled input flips from uncontrolled to controlled on first keystroke (React logs a warning and can lose the value), `reset()` with no arguments has no baseline to restore to, and `isDirty`/`dirtyFields` compare against nothing so the form reads as dirty the moment anything is touched. Provide the full shape up front, using empty strings rather than `undefined`.

**Incorrect (no defaultValues — reset() has no baseline, inputs start uncontrolled):**

```typescript
function ProfileForm({ user }: { user: User }) {
  const { register, reset, handleSubmit } = useForm<ProfileFormValues>()

  useEffect(() => {
    reset(user)
  }, [user, reset])

  return (
    <form onSubmit={handleSubmit(saveProfile)}>
      <input {...register('firstName')} />
      <input {...register('lastName')} />
      <button type="button" onClick={() => reset()}>Discard changes</button>
    </form>
  )
}
```

**Correct (explicit defaults — reset() restores them, isDirty is meaningful):**

```typescript
function ProfileForm({ user }: { user: User }) {
  const { register, reset, handleSubmit } = useForm<ProfileFormValues>({
    defaultValues: { firstName: '', lastName: '' },
  })

  useEffect(() => {
    reset(user)
  }, [user, reset])

  return (
    <form onSubmit={handleSubmit(saveProfile)}>
      <input {...register('firstName')} />
      <input {...register('lastName')} />
      <button type="button" onClick={() => reset()}>Discard changes</button>
    </form>
  )
}
```

When the defaults come from the server, pass them directly rather than defaulting-then-resetting — see `formcfg-async-default-values`. After a successful save, move the baseline with `resetDefaultValues` rather than `reset` (see `formstate-reset-default-values`).

**Note:** Avoid custom objects with prototype methods (Moment, Luxon) as defaultValues — RHF deep-clones them. Use plain objects or primitives.

Reference: [useForm - defaultValues](https://react-hook-form.com/docs/useform)
