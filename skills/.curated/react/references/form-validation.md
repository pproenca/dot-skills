---
title: Treat validation as a server-action concern; client checks are an enhancement, never the only gate
impact: MEDIUM
impactDescription: prevents client-only validation bypass (security), gives one source of truth for error messages, supports progressive enhancement
tags: form, server-validation, validation-source-of-truth, structured-errors
---

## Treat validation as a server-action concern; client checks are an enhancement, never the only gate

**Pattern intent:** the server action is the only piece of code that genuinely receives untrusted input. Validation logic must live there. Client-side checks exist for instant feedback and reducing round trips — never as the only barrier.

### Shapes to recognize

- An `onSubmit` that runs Zod/Yup/joi on the form values and then calls a server function with no further validation server-side.
- A trust-the-client API where the server function reads `formData.get('email')` and inserts it directly into a database call.
- A `confirm()` / `alert()` in the client that's treated as a "validation step" — a curl bypasses it in seconds.
- HTML-only validation (`required`, `pattern=...`) treated as sufficient — DevTools removes those in two clicks.
- Validation duplicated in two places (client + server) with the schemas drifting — one source of truth missing, drift bug waiting to happen. Prefer a shared schema imported into both, with the server check authoritative.

The canonical resolution: define the schema once in a server-importable module; the server action validates and returns `{ errors }` shape; the form renders errors from the `useActionState` state; the client may opt into echoing the same schema for instant feedback, but the server's `errors` shape is the source of truth.

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
