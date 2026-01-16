---
title: Use useFormStatus for Nested Form Components
impact: CRITICAL
impactDescription: eliminates prop drilling for form state, enables reusable submit buttons
tags: action, useFormStatus, forms, composition
---

## Use useFormStatus for Nested Form Components

The `useFormStatus` hook provides form pending state to any component inside a form without prop drilling. This enables truly reusable form components.

**Incorrect (prop drilling pending state):**

```tsx
function SubmitButton({ isPending }: { isPending: boolean }) {
  return <button disabled={isPending}>{isPending ? 'Saving...' : 'Save'}</button>
}

function ContactForm() {
  const [state, action, isPending] = useActionState(submitContact, null)

  return (
    <form action={action}>
      <input name="email" />
      <SubmitButton isPending={isPending} />  {/* Must pass prop */}
    </form>
  )
}

function ProfileForm() {
  const [state, action, isPending] = useActionState(updateProfile, null)

  return (
    <form action={action}>
      <input name="name" />
      <SubmitButton isPending={isPending} />  {/* Must pass prop again */}
    </form>
  )
}
```

**Correct (automatic form state access):**

```tsx
function SubmitButton({ children }: { children: React.ReactNode }) {
  const { pending } = useFormStatus()  // Reads from nearest parent form
  return <button disabled={pending}>{pending ? 'Saving...' : children}</button>
}

function ContactForm() {
  const [state, action] = useActionState(submitContact, null)

  return (
    <form action={action}>
      <input name="email" />
      <SubmitButton>Send</SubmitButton>  {/* No props needed */}
    </form>
  )
}

function ProfileForm() {
  const [state, action] = useActionState(updateProfile, null)

  return (
    <form action={action}>
      <input name="name" />
      <SubmitButton>Save</SubmitButton>  {/* Same component, no props */}
    </form>
  )
}
```

**Note:** `useFormStatus` must be called from a component rendered inside a `<form>`. It cannot be called from the same component that renders the form.

Reference: [useFormStatus](https://react.dev/reference/react-dom/hooks/useFormStatus)
