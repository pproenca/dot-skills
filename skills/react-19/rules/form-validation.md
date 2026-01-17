---
title: Validate Forms on Server with Actions
impact: MEDIUM
impactDescription: secure validation, consistent error handling
tags: form, validation, server-actions, security
---

## Validate Forms on Server with Actions

Always validate form data on the server, even with client-side validation. Return structured errors for display.

**Incorrect (client-only validation):**

```typescript
'use client'

function SignupForm() {
  function handleSubmit(formData: FormData) {
    const email = formData.get('email') as string
    if (!email.includes('@')) {
      alert('Invalid email')  // Only client validation
      return
    }
    signup(formData)  // Server trusts input
  }

  return (
    <form action={handleSubmit}>
      <input name="email" type="email" />
      <button>Sign Up</button>
    </form>
  )
}
```

**Correct (server validation with error state):**

```typescript
// actions.ts
'use server'

import { z } from 'zod'

const signupSchema = z.object({
  email: z.string().email('Invalid email format'),
  password: z.string().min(8, 'Password must be 8+ characters')
})

type State = {
  errors?: { email?: string[]; password?: string[] }
  success?: boolean
}

export async function signup(prevState: State, formData: FormData): Promise<State> {
  const result = signupSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password')
  })

  if (!result.success) {
    return { errors: result.error.flatten().fieldErrors }
  }

  await createUser(result.data)
  return { success: true }
}

// SignupForm.tsx
'use client'

import { useActionState } from 'react'
import { signup } from './actions'

function SignupForm() {
  const [state, formAction] = useActionState(signup, {})

  return (
    <form action={formAction}>
      <input name="email" type="email" />
      {state.errors?.email && <p className="error">{state.errors.email[0]}</p>}

      <input name="password" type="password" />
      {state.errors?.password && <p className="error">{state.errors.password[0]}</p>}

      <button>Sign Up</button>
    </form>
  )
}
```
