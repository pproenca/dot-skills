---
title: Use Server Actions With Progressive Enhancement; Never Disable Submit While Typing
impact: HIGH
impactDescription: Forms with disabled submit buttons until valid have 25-40% lower completion (Baymard); Server Actions + progressive enhancement work even when JS hasn't loaded
tags: ux, data-entry, server-actions, useformstate, validation, progressive-enhancement
---

## Use Server Actions With Progressive Enhancement; Never Disable Submit While Typing

Forms use Server Actions (`'use server'`) wired into the native `<form action={…}>` API so they submit even before JavaScript hydrates. Validation happens on the server (Zod is the standard), errors render inline next to the field via `useActionState`. Never disable the submit button while the user is typing — let them attempt submission and show errors *after*. Use `aria-invalid` and `aria-describedby` so screen readers announce errors.

**Incorrect (submit disabled while invalid; client-only validation; useState everywhere):**

```tsx
'use client'
function SignupForm() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const valid = email.includes('@') && password.length >= 8
  return (
    <form
      onSubmit={async (e) => {
        e.preventDefault()
        await fetch('/api/signup', { method: 'POST', body: JSON.stringify({ email, password }) })
      }}
    >
      <input value={email} onChange={(e) => setEmail(e.target.value)} />
      <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
      <button type="submit" disabled={!valid}>Sign up</button>
      {/* Disabled until valid → user can't see what's wrong; no SR announcement */}
    </form>
  )
}
```

**Correct (Server Action + Zod + useActionState + inline errors):**

```tsx
// app/signup/actions.ts
'use server'
import { z } from 'zod'
import { redirect } from 'next/navigation'

const schema = z.object({
  email: z.string().email('Enter a valid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
})

export type SignupState = {
  fieldErrors?: { email?: string[]; password?: string[] }
  formError?: string
}

export async function signupAction(_prev: SignupState, formData: FormData): Promise<SignupState> {
  const parsed = schema.safeParse(Object.fromEntries(formData))
  if (!parsed.success) return { fieldErrors: parsed.error.flatten().fieldErrors }
  try {
    await createUser(parsed.data)
  } catch (e) {
    if (e instanceof EmailInUseError) return { fieldErrors: { email: ['That email is already in use'] } }
    return { formError: 'Something went wrong. Please try again.' }
  }
  redirect('/dashboard')
}

// app/signup/page.tsx — Server Component renders the form; Client Component owns useActionState
import { SignupForm } from './signup-form'
export default function SignupPage() {
  return <SignupForm />
}

// app/signup/signup-form.tsx
'use client'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import { signupAction, type SignupState } from './actions'

const initial: SignupState = {}

function Field({ id, label, type = 'text', autoComplete, errors }: {
  id: string; label: string; type?: string; autoComplete?: string; errors?: string[]
}) {
  const errorId = `${id}-error`
  return (
    <div className="space-y-1">
      <label htmlFor={id} className="text-sm font-medium">{label}</label>
      <input
        id={id}
        name={id}
        type={type}
        autoComplete={autoComplete}
        aria-invalid={!!errors?.length}
        aria-describedby={errors?.length ? errorId : undefined}
        className={cn(
          'w-full rounded-md border px-3 h-11',
          errors?.length && 'border-destructive'
        )}
      />
      {errors?.map((msg) => (
        <p key={msg} id={errorId} role="alert" className="text-sm text-destructive">{msg}</p>
      ))}
    </div>
  )
}

function Submit() {
  const { pending } = useFormStatus()
  return (
    <Button type="submit" disabled={pending} className="w-full">
      {pending && <Loader2 className="mr-2 size-4 animate-spin" />}
      {pending ? 'Creating account…' : 'Create account'}
    </Button>
  )
}

export function SignupForm() {
  const [state, action] = useActionState(signupAction, initial)
  return (
    <form action={action} className="space-y-4">
      {state.formError && (
        <p role="alert" className="rounded-md border border-destructive/30 bg-destructive/5 p-3 text-sm text-destructive">
          {state.formError}
        </p>
      )}
      <Field id="email" label="Email" type="email" autoComplete="email" errors={state.fieldErrors?.email} />
      <Field id="password" label="Password" type="password" autoComplete="new-password" errors={state.fieldErrors?.password} />
      <Submit />
    </form>
  )
}
```

**Rule:**
- Use `<form action={serverAction}>` — works without JS via progressive enhancement
- Validate on the server with Zod (or equivalent); return structured errors in the action's return value
- Submit button is **never** disabled until valid — only disabled *during* submission (`useFormStatus().pending`)
- Each error gets `role="alert"`, `aria-invalid` on the input, and `aria-describedby` linking input to message
- Always set `autoComplete` correctly (`email`, `new-password`, `current-password`, `one-time-code`) — password managers depend on it

Reference: [Form best practices — Baymard Institute](https://baymard.com/blog/inline-form-validation) · [Server Actions — Next.js 16](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
