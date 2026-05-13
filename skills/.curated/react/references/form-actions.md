---
title: Wire form submission through the `action` prop, not a JS-only `onSubmit` handler
impact: HIGH
impactDescription: forms work without JS loaded (progressive enhancement), removes `e.preventDefault()` and manual FormData wiring
tags: form, action-prop, progressive-enhancement, submit
---

## Wire form submission through the `action` prop, not a JS-only `onSubmit` handler

**Pattern intent:** a form's submission semantics belong in the platform — the browser submits, the server receives. React 19's `action` prop on `<form>` integrates with this so the form works whether or not JS has loaded, and removes the `preventDefault()` + manual FormData ceremony.

### Shapes to recognize

- `<form onSubmit={async (e) => { e.preventDefault(); ... }}>` — the most common shape; the form is JS-only.
- An `onSubmit` handler that reads inputs from `e.currentTarget` or controlled-state instead of `FormData`.
- A submit button with `onClick` handler that calls `formRef.current.requestSubmit()` or fetches manually — an entire side-channel that bypasses the form.
- Workaround: a "non-JS fallback" message ("This form requires JavaScript") instead of using `action` for progressive enhancement.
- `onSubmit` that just calls `router.push(...)` after gathering input — uses the form as a UI shell, not as a form.

The canonical resolution: pass a function to `<form action={...}>`. For server mutations, use a Server Action (`'use server'` export). For client-side navigation/derived behavior, the function may live in a Client Component but the wiring stays through `action`.

**Incorrect (onSubmit requires JavaScript):**

```typescript
'use client'

function ContactForm() {
  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const formData = new FormData(e.currentTarget)
    await sendMessage(formData)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="email" type="email" />
      <textarea name="message" />
      <button type="submit">Send</button>
    </form>
  )
}
// Doesn't work if JS fails to load
```

**Correct (form action):**

```typescript
// With Server Action
import { sendMessage } from './actions'

function ContactForm() {
  return (
    <form action={sendMessage}>
      <input name="email" type="email" required />
      <textarea name="message" required />
      <button type="submit">Send</button>
    </form>
  )
}
// Works without JS - progressive enhancement

// actions.ts
'use server'

export async function sendMessage(formData: FormData) {
  const email = formData.get('email') as string
  const message = formData.get('message') as string

  await db.messages.create({ data: { email, message } })
  redirect('/thank-you')
}
```

**With client-side action:**

```typescript
'use client'

function SearchForm() {
  async function search(formData: FormData) {
    const query = formData.get('query') as string
    // Client-side handling
    router.push(`/search?q=${query}`)
  }

  return (
    <form action={search}>
      <input name="query" />
      <button>Search</button>
    </form>
  )
}
```
