---
title: Submit buttons read parent-form pending state from `useFormStatus` — not from a prop drilled in
impact: MEDIUM-HIGH
impactDescription: proper "Saving..." indicators and double-submit prevention without threading `isPending` through every form's prop tree
tags: action, form-status-context, submit-button, pending-state
---

## Submit buttons read parent-form pending state from `useFormStatus` — not from a prop drilled in

**Pattern intent:** the submit button knows whether *its* containing form is submitting via `useFormStatus` from `react-dom`. That information comes from the form context, not from a `useState` cell lifted to the parent.

### Shapes to recognize

- A submit button with `disabled={isPending}` where `isPending` is a `useState` lifted from the page-level component and threaded through `<Form><Button isPending={isPending}/></Form>`.
- A form with no pending feedback at all — user clicks "Create" three times because nothing happens visibly.
- `useFormStatus()` called in the *same component* as the `<form>` — returns `pending: false` always, because the hook reads the parent form's status. The fix is to extract the button to a child component.
- A "form context" hand-rolled by the team to share submit state — reinvented `useFormStatus`.
- A workaround calling `useTransition` in the consumer to track submission — works for non-form mutations, but for form actions `useFormStatus` is the right primitive.

The canonical resolution: extract submit button into a separate Client Component; that component calls `useFormStatus()` and reads `{ pending, data, method }` from the surrounding form context.

**Incorrect (no feedback during submission):**

```typescript
// app/posts/new/page.tsx
export default function NewPostPage() {
  async function createPost(formData: FormData) {
    'use server'
    await db.posts.create({ data: { title: formData.get('title') } })
  }

  return (
    <form action={createPost}>
      <input name="title" />
      <button type="submit">Create Post</button>
      {/* User clicks multiple times, no feedback */}
    </form>
  )
}
```

**Correct (pending state with useFormStatus):**

```typescript
// app/posts/new/page.tsx
import { SubmitButton } from './submit-button'

export default function NewPostPage() {
  async function createPost(formData: FormData) {
    'use server'
    await db.posts.create({ data: { title: formData.get('title') } })
  }

  return (
    <form action={createPost}>
      <input name="title" />
      <SubmitButton />
    </form>
  )
}

// submit-button.tsx
'use client'

import { useFormStatus } from 'react-dom'

export function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Creating...' : 'Create Post'}
    </button>
  )
}
```

**Note:** `useFormStatus` must be used in a child component of the form, not in the same component as the form element.
