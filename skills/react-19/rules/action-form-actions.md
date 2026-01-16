---
title: Use Form Actions Instead of onSubmit Handlers
impact: CRITICAL
impactDescription: eliminates manual pending/error state management, automatic form reset
tags: action, forms, useActionState, progressive-enhancement
---

## Use Form Actions Instead of onSubmit Handlers

React 19 form actions handle pending states, errors, and form resets automatically. Manual onSubmit handlers require managing these states yourself and break progressive enhancement.

**Incorrect (manual state management, no progressive enhancement):**

```tsx
function ContactForm() {
  const [isPending, setIsPending] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()  // Breaks without JS
    setIsPending(true)
    setError(null)
    const formData = new FormData(e.target as HTMLFormElement)
    const result = await submitContact(formData)
    setIsPending(false)
    if (result.error) setError(result.error)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" />
      <button disabled={isPending}>Submit</button>
      {error && <p>{error}</p>}
    </form>
  )
}
```

**Correct (automatic state management, works without JS):**

```tsx
function ContactForm() {
  const [error, submitAction, isPending] = useActionState(
    async (prevState: string | null, formData: FormData) => {
      const result = await submitContact(formData)
      if (result.error) return result.error
      redirect('/success')
      return null
    },
    null
  )

  return (
    <form action={submitAction}>
      <input name="email" type="email" />
      <button disabled={isPending}>Submit</button>
      {error && <p>{error}</p>}
    </form>
  )
}
```

**Benefits:**
- Form works without JavaScript (progressive enhancement)
- Automatic pending state via `isPending`
- Automatic form reset on successful submission
- Cleaner error handling with previous state access

Reference: [React 19 Actions](https://react.dev/blog/2024/12/05/react-19#actions)
