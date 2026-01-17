---
title: Show Pending States with useFormStatus
impact: MEDIUM-HIGH
impactDescription: better UX during form submission
tags: action, useFormStatus, pending, loading
---

## Show Pending States with useFormStatus

Use `useFormStatus` to show loading indicators and disable buttons during form submission. This provides immediate feedback to users.

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
