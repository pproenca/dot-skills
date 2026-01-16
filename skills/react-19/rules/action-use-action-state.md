---
title: Use useActionState for Form State Management
impact: CRITICAL
impactDescription: eliminates 3-4 useState calls per form, centralizes action lifecycle
tags: action, useActionState, forms, state-management
---

## Use useActionState for Form State Management

The `useActionState` hook consolidates pending state, error handling, and result management into a single API. Manual useState patterns are verbose and error-prone.

**Incorrect (multiple useState hooks, manual orchestration):**

```tsx
function UpdateProfile() {
  const [name, setName] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isPending, setIsPending] = useState(false)
  const [lastResult, setLastResult] = useState<Profile | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsPending(true)
    setError(null)
    try {
      const result = await updateProfile(name)
      setLastResult(result)
    } catch (err) {
      setError(err.message)
    } finally {
      setIsPending(false)
    }
  }

  return <form onSubmit={handleSubmit}>...</form>
}
```

**Correct (single hook manages entire lifecycle):**

```tsx
function UpdateProfile() {
  const [state, submitAction, isPending] = useActionState(
    async (prev: ActionState, formData: FormData) => {
      const name = formData.get('name') as string
      try {
        const profile = await updateProfile(name)
        return { profile, error: null }
      } catch (err) {
        return { profile: prev.profile, error: err.message }
      }
    },
    { profile: null, error: null }
  )

  return (
    <form action={submitAction}>
      <input name="name" defaultValue={state.profile?.name} />
      <button disabled={isPending}>Save</button>
      {state.error && <p className="error">{state.error}</p>}
    </form>
  )
}
```

**Benefits:**
- Single source of truth for action state
- Previous state accessible in action function
- Automatic pending state tracking
- Works with Server Actions directly

Reference: [useActionState](https://react.dev/reference/react/useActionState)
