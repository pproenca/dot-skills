---
title: Use useActionState for Form State Management
impact: HIGH
impactDescription: declarative form handling, automatic pending states
tags: form, useActionState, actions, mutation
---

## Use useActionState for Form State Management

`useActionState` provides declarative form handling with built-in pending state, error handling, and progressive enhancement.

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

Reference: [useActionState](https://react.dev/reference/react/useActionState)
