---
title: Use Form Actions Instead of onSubmit
impact: HIGH
impactDescription: progressive enhancement, simpler code
tags: form, actions, progressive-enhancement, mutation
---

## Use Form Actions Instead of onSubmit

React 19 supports the `action` prop on forms. This provides progressive enhancement - forms work even without JavaScript.

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
