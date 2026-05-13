---
title: Submit buttons read parent-form pending state from context, not from a prop drilled in
impact: MEDIUM-HIGH
impactDescription: proper loading indicators and double-submit prevention without threading `isPending` through every form's prop tree
tags: form, form-status-context, submit-button, pending
---

## Submit buttons read parent-form pending state from context, not from a prop drilled in

**Pattern intent:** a submit button (or pending indicator) should know whether *its* containing form is submitting — and that information should come from the platform/form context, not from a prop drilled down from wherever the form lives.

### Shapes to recognize

- A `<SubmitButton disabled={isPending}>` where `isPending` is a `useState` lifted to the form's parent and threaded through `<Form><SubmitButton isPending={isPending}/></Form>`.
- A submit button that imports a global "form context" the project built itself to share submit state — reinvented `useFormStatus`.
- A form with no submit-state feedback at all because plumbing the prop was inconvenient.
- A pending indicator placed *outside* the `<form>` boundary trying to read submit state — `useFormStatus` is intentionally scoped, the placement has to move.
- The submit button and the form are the same component, with `useFormStatus()` called there — it returns `pending: false` always, because the hook reads the *parent* form. The fix is to extract the button into a child component.

The canonical resolution: extract the submit button (or indicator) into its own component; place that component inside `<form>`; the component calls `useFormStatus()` and reads `{ pending, data, method }` from the surrounding form context.

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
