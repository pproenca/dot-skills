---
title: Rebase Defaults with resetDefaultValues After a Successful Save
impact: HIGH
impactDescription: clears isDirty without discarding edits made during the in-flight request
tags: formstate, resetDefaultValues, isDirty, dirtyFields, save
---

## Rebase Defaults with resetDefaultValues After a Successful Save

For a form that stays mounted after saving (settings pages, inline editors), the goal after a successful `PATCH` is to make `isDirty` false again — the saved values are the new baseline. The reflex is `reset(savedValues)`, but `reset` writes **both** `defaultValues` and the live form values. Any keystroke the user made while the request was in flight is silently thrown away, and controlled inputs re-mount.

`resetDefaultValues(savedValues)` (RHF 7.77+, also exposed on `useFormContext` since 7.82) replaces `defaultValues` and recomputes `dirtyFields`/`isDirty` against the values already in the form, without touching them. Edits made during the save stay put and are correctly reported as dirty.

**Incorrect (reset discards edits made while the save was in flight):**

```typescript
function NotificationSettingsForm({ settings }: { settings: NotificationSettings }) {
  const { register, handleSubmit, reset, formState: { isDirty, isSubmitting } } =
    useForm({ defaultValues: settings })

  const onSubmit = async (values: NotificationSettings) => {
    try {
      const saved = await updateNotificationSettings(values)
      reset(saved)  // Overwrites live values — anything typed during the request is lost
    } catch {
      setError('root.serverError', { message: 'Could not save settings' })
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('digestEmail')} />
      <button type="submit" disabled={!isDirty || isSubmitting}>Save</button>
    </form>
  )
}
```

**Correct (rebase the baseline, keep the user's in-flight edits):**

```typescript
function NotificationSettingsForm({ settings }: { settings: NotificationSettings }) {
  const { register, handleSubmit, resetDefaultValues, setError, formState: { isDirty, isSubmitting } } =
    useForm({ defaultValues: settings })

  const onSubmit = async (values: NotificationSettings) => {
    try {
      const saved = await updateNotificationSettings(values)
      resetDefaultValues(saved)  // New baseline; live values untouched, isDirty recomputed against them
    } catch {
      setError('root.serverError', { message: 'Could not save settings' })
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('digestEmail')} />
      <button type="submit" disabled={!isDirty || isSubmitting}>Save</button>
    </form>
  )
}
```

**Which to reach for:**
- `resetDefaultValues(saved)` — form stays mounted and the user keeps editing; you only want the dirty baseline moved
- `reset(saved)` — you genuinely want to discard the current values too (form closes, or you are loading a different record)

`resetDefaultValues` accepts `{ keepDirty }` and `{ keepIsValid }` if you need to suppress either recomputation.

Reference: [useForm - resetDefaultValues](https://react-hook-form.com/docs/useform/resetdefaultvalues)
