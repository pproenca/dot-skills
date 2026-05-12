---
title: Use useFormStatus for Submit Button State
impact: MEDIUM-HIGH
impactDescription: proper loading indicators, prevents double submission
tags: form, useFormStatus, pending, button
---

## Use useFormStatus for Submit Button State

`useFormStatus` reads the pending state of the parent form. Use it for submit buttons to show loading state and prevent double submission.

**Incorrect (no pending state):**

```typescript
function ContactForm() {
  return (
    <form action={sendMessage}>
      <input name="email" />
      <button type="submit">Send</button>
      {/* No feedback during submission */}
    </form>
  )
}
```

**Correct (useFormStatus in child component):**

```typescript
import { useFormStatus } from 'react-dom'

function SubmitButton({ children }: { children: React.ReactNode }) {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Sending...' : children}
    </button>
  )
}

function ContactForm() {
  return (
    <form action={sendMessage}>
      <input name="email" required />
      <textarea name="message" required />
      <SubmitButton>Send Message</SubmitButton>
    </form>
  )
}
```

**Important:** `useFormStatus` must be called from a component that is a child of the `<form>`. It won't work in the same component as the form.

**With more status info:**

```typescript
function FormStatus() {
  // data: FormData | null, method: 'get' | 'post', action: string | ((formData: FormData) => void | Promise<void>) | null
  const { pending, data, method } = useFormStatus()

  if (!pending) return null

  const email = data?.get('email')?.toString() ?? ''

  return (
    <div className="status">
      Submitting {email} via {method}...
    </div>
  )
}
```
