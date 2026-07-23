---
title: Use the values Prop to Keep a Form in Sync with Server Data
impact: HIGH
impactDescription: replaces a useEffect+reset that overwrites edits whenever the query refetches
tags: formcfg, values, resetOptions, react-query, server-state
---

## Use the values Prop to Keep a Form in Sync with Server Data

When the initial data arrives from a query, the reflex is `useEffect(() => reset(data), [data])`. That works until the query refetches — on window focus, on interval, after an unrelated mutation — and the effect fires again mid-edit, wiping whatever the user had typed.

`useForm({ values })` is the built-in answer. RHF re-syncs the form when the `values` reference changes, and `resetOptions: { keepDirtyValues: true }` tells it to leave fields the user has touched alone while updating the ones they haven't. `defaultValues` still supplies the shape before the first response lands.

**Incorrect (effect-driven reset — a background refetch discards in-progress edits):**

```typescript
function ProfileForm({ userId }: { userId: string }) {
  const { data: profile } = useQuery({ queryKey: ['profile', userId], queryFn: fetchProfile })
  const { register, reset, handleSubmit } = useForm<ProfileFormValues>({
    defaultValues: { displayName: '', bio: '' },
  })

  useEffect(() => {
    if (profile) reset(profile)  // Fires again on every refetch, mid-edit
  }, [profile, reset])

  return (
    <form onSubmit={handleSubmit(saveProfile)}>
      <input {...register('displayName')} />
    </form>
  )
}
```

**Correct (declarative sync that preserves what the user has touched):**

```typescript
function ProfileForm({ userId }: { userId: string }) {
  const { data: profile } = useQuery({ queryKey: ['profile', userId], queryFn: fetchProfile })
  const { register, handleSubmit } = useForm<ProfileFormValues>({
    defaultValues: { displayName: '', bio: '' },
    values: profile,
    resetOptions: { keepDirtyValues: true },
  })

  return (
    <form onSubmit={handleSubmit(saveProfile)}>
      <input {...register('displayName')} />
    </form>
  )
}
```

**Which initialiser to reach for:**
- `defaultValues` — the shape and the baseline; required regardless (see `formcfg-default-values`)
- `values` — the record is fetched and may change while the form is open
- async `defaultValues` — the record is fetched once and will not change under the form (see `formcfg-async-default-values`)

Drop `keepDirtyValues` only when a server change should win over the user's edit — a record another person may be editing concurrently, for instance.

Reference: [useForm - values](https://react-hook-form.com/docs/useform)
