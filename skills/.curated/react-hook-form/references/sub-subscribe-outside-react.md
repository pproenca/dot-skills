---
title: Use subscribe() to React to Form Changes Outside the React Lifecycle
impact: HIGH
impactDescription: eliminates re-renders for non-UI consumers like analytics, autosave, telemetry
tags: sub, subscribe, side-effects, analytics, autosave, useForm
---

## Use subscribe() to React to Form Changes Outside the React Lifecycle

Introduced in v7.55.0, `useForm().subscribe(...)` registers a callback that fires on form state or value changes **without causing any re-renders**. Use it when the consumer of the change is not a UI element — analytics, autosave to localStorage, debounced telemetry, sending drafts to a server. `useWatch` and `watch` are still right for things that paint to screen; `subscribe` is right for everything else.

**Incorrect (using useWatch to drive a non-UI side-effect — re-renders the form on every keystroke):**

```typescript
function ProfileForm() {
  const { register, handleSubmit, control } = useForm<ProfileFormData>()
  const values = useWatch({ control })  // Every keystroke re-renders ProfileForm

  useEffect(() => {
    analytics.track('profile_field_edited', { values })  // Fires on every render
  }, [values])

  return (
    <form onSubmit={handleSubmit(saveProfile)}>
      <input {...register('displayName')} />
      <input {...register('bio')} />
    </form>
  )
}
```

**Correct (subscribe() runs the side-effect with zero re-renders):**

```typescript
function ProfileForm() {
  const { register, handleSubmit, subscribe } = useForm<ProfileFormData>()

  useEffect(() => {
    const unsubscribe = subscribe({
      formState: { values: true },
      callback: ({ values, name }) => {
        analytics.track('profile_field_edited', { field: name, values })
      },
    })
    return unsubscribe
  }, [subscribe])

  return (
    <form onSubmit={handleSubmit(saveProfile)}>
      <input {...register('displayName')} />
      <input {...register('bio')} />
    </form>
  )
}
```

**Subscribing to specific fields with formState slices (e.g. dirty-aware autosave):**

```typescript
function DraftEditor() {
  const { register, subscribe } = useForm<DraftFormData>({
    defaultValues: loadDraft(),
  })

  useEffect(() => {
    const unsubscribe = subscribe({
      name: ['title', 'body'],
      formState: { values: true, isDirty: true },
      callback: ({ values, isDirty }) => {
        if (isDirty) debouncedSaveDraft(values)
      },
    })
    return unsubscribe
  }, [subscribe])

  return (
    <>
      <input {...register('title')} />
      <textarea {...register('body')} />
    </>
  )
}
```

**When to use which:**
- `useWatch` / `Controller` — the value drives a rendered element
- `subscribe` — the value drives a non-UI side-effect (analytics, autosave, localStorage sync, telemetry)
- `watch(callback)` — legacy callback form; prefer `subscribe` in new code (subscribe replaces the watch-callback pattern with explicit formState slicing and no implicit re-renders)

`subscribe` returns an unsubscribe function — always return it from the `useEffect` cleanup to avoid leaks across remounts.

Reference: [subscribe](https://react-hook-form.com/docs/useform/subscribe) · [Release notes v7.55.0](https://github.com/react-hook-form/react-hook-form/releases/tag/v7.55.0)
