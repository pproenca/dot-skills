---
title: Lift imperative pending/error/submit bookkeeping into a single declarative form-state hook
impact: HIGH
impactDescription: collapses manual `loading`/`error`/`success` `useState` triples plus an `onSubmit` handler into one declarative `useActionState` call with automatic pending state
tags: form, declarative-form-state, pending-tracking, action-state
---

## Lift imperative pending/error/submit bookkeeping into a single declarative form-state hook

**Pattern intent:** a form's mutation lifecycle (idle → submitting → success/error) is a single state machine. It should be modeled as such — not assembled by hand from three `useState` calls, a `try/catch/finally` block, and a manually managed `pending` flag.

### Shapes to recognize

- A Client Component with `useState` for `loading`, `useState` for `error`, and `useState` for the form values, plus an `async onSubmit` that orchestrates them.
- A custom hook returning `{ submit, isLoading, error, data }` that wraps `useState` + `fetch` — a hand-rolled `useActionState` that doesn't get progressive enhancement.
- A `useReducer` with actions `START`, `SUCCESS`, `FAILURE` driving the same idle-pending-result state machine.
- Use of a third-party form library (Formik, RHF) only for tracking submission state of a single-server-action form — the library is doing the job `useActionState` does for free.
- A `try/catch/finally` block in an `onSubmit` that calls `setLoading(true)` then `setLoading(false)` — the entire block is the antithesis of the rule.

The canonical resolution: `const [state, formAction, isPending] = useActionState(action, initial)`. The action receives `(prevState, formData)` and returns next state. The form binds `action={formAction}`. Pending and errors come for free.

**Incorrect (manual form state management):**

```typescript
'use client'

import { useState } from 'react'

function LoginForm() {
  const [email, setEmail] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      await login(email)
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={email} onChange={e => setEmail(e.target.value)} />
      {error && <p>{error}</p>}
      <button disabled={loading}>{loading ? 'Loading...' : 'Login'}</button>
    </form>
  )
}
```

**Correct (useActionState):**

```typescript
'use client'

import { useActionState } from 'react'
import { login } from './actions'

function LoginForm() {
  const [state, formAction, isPending] = useActionState(
    async (prevState: { error?: string }, formData: FormData) => {
      const email = formData.get('email') as string
      const result = await login(email)
      if (result.error) return { error: result.error }
      return {}
    },
    { error: undefined }
  )

  return (
    <form action={formAction}>
      <input name="email" type="email" required />
      {state.error && <p className="error">{state.error}</p>}
      <button disabled={isPending}>
        {isPending ? 'Logging in...' : 'Login'}
      </button>
    </form>
  )
}
// Works without JS, automatic pending state, error handling
```

**Incorrect — in disguise (custom hook hiding the manual state machine):**

The grep-friendly anti-pattern is `useState` + `onSubmit` + `e.preventDefault()` inside the component. But the same break also appears wrapped in a custom hook that *looks* like a reusable abstraction. The hook is doing exactly the job of `useActionState`, without the progressive-enhancement benefits.

```typescript
'use client'

// hooks/useSubmitForm.ts — looks like a clean reusable abstraction
function useSubmitForm<T>(onSubmit: (data: T) => Promise<{ error?: string } | void>) {
  const [error, setError] = useState<string | undefined>()
  const [isLoading, setIsLoading] = useState(false)

  async function handle(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setIsLoading(true)
    setError(undefined)
    const formData = new FormData(e.currentTarget)
    const result = await onSubmit(Object.fromEntries(formData) as T)
    if (result?.error) setError(result.error)
    setIsLoading(false)
  }

  return { error, isLoading, handle }
}

// LoginForm.tsx
function LoginForm() {
  const { error, isLoading, handle } = useSubmitForm(async (data) => {
    return login(data.email as string)
  })
  return (
    <form onSubmit={handle}>
      <input name="email" type="email" required />
      {error && <p className="error">{error}</p>}
      <button disabled={isLoading}>{isLoading ? 'Logging in...' : 'Login'}</button>
    </form>
  )
}
// Same anti-pattern — just hidden inside the hook. No progressive enhancement;
// the form requires JS; manual state cells still drift if the hook is forked.
```

**Correct — same shape, `useActionState`:**

```typescript
'use client'

import { useActionState } from 'react'
import { login } from './actions'

function LoginForm() {
  const [state, formAction, isPending] = useActionState(
    async (_prev: { error?: string }, formData: FormData) => {
      const result = await login(formData.get('email') as string)
      return result.error ? { error: result.error } : {}
    },
    {}
  )

  return (
    <form action={formAction}>
      <input name="email" type="email" required />
      {state.error && <p className="error">{state.error}</p>}
      <button disabled={isPending}>{isPending ? 'Logging in...' : 'Login'}</button>
    </form>
  )
}
```

Reference: [useActionState](https://react.dev/reference/react/useActionState)
