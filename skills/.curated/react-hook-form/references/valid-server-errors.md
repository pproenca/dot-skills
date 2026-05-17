---
title: Surface Server Errors via setError('root.serverError', ...)
impact: HIGH
impactDescription: prevents lost server-side validation errors and unrecoverable form state
tags: valid, server-errors, setError, async, error-handling
---

## Surface Server Errors via setError('root.serverError', ...)

`handleSubmit` does not catch errors thrown inside async submit handlers — it logs them and silently leaves the form unrecoverable (`isSubmitting` stays `true` if you `throw`). The canonical pattern is to `try/catch` inside the submit handler and route API failures into `setError`. Use field-level `setError(name, ...)` when the server tells you which field is wrong; use `setError('root.serverError', ...)` for general failures (network error, 500, "Account is locked").

**Incorrect (server error is thrown, swallowed, and form is now stuck):**

```typescript
function LoginForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<LoginFormData>()

  const onSubmit = async (data: LoginFormData) => {
    const res = await fetch('/api/login', { method: 'POST', body: JSON.stringify(data) })
    if (!res.ok) throw new Error('Login failed')  // Lost: no UI feedback, isSubmitting stuck
    redirect('/dashboard')
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      <input type="password" {...register('password')} />
      <button disabled={isSubmitting}>Sign in</button>
    </form>
  )
}
```

**Correct (server errors surfaced via setError, form stays recoverable):**

```typescript
function LoginForm() {
  const {
    register,
    handleSubmit,
    setError,
    clearErrors,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormData>()

  const onSubmit = async (data: LoginFormData) => {
    clearErrors('root.serverError')
    try {
      const res = await fetch('/api/login', { method: 'POST', body: JSON.stringify(data) })
      if (!res.ok) {
        const body = await res.json()
        if (body.field === 'password') {
          setError('password', { type: 'server', message: body.message })
        } else {
          setError('root.serverError', { type: 'server', message: body.message ?? 'Sign in failed' })
        }
        return
      }
      redirect('/dashboard')
    } catch {
      setError('root.serverError', { type: 'network', message: 'Network error — please retry' })
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      {errors.root?.serverError && (
        <div role="alert">{errors.root.serverError.message}</div>
      )}
      <input {...register('email')} />
      {errors.email && <span>{errors.email.message}</span>}
      <input type="password" {...register('password')} />
      {errors.password && <span>{errors.password.message}</span>}
      <button disabled={isSubmitting}>Sign in</button>
    </form>
  )
}
```

**Key details:**
- Root-level errors live under `errors.root.{key}` — pick any key (`serverError`, `network`, `rateLimit`) and read it back the same way
- Root errors **persist across submissions** until you call `clearErrors('root.serverError')` — clear at the start of each submit, or rely on the next resolver pass to overwrite
- Always `try/catch` async submit handlers. `handleSubmit` will not surface thrown errors, and `isSubmitting` only resets when the handler returns (resolves), not when it throws — see also `formstate-async-submit-lifecycle`

Reference: [setError](https://react-hook-form.com/docs/useform/seterror) · [Discussion #9691 — Handle global/server errors](https://github.com/orgs/react-hook-form/discussions/9691)
