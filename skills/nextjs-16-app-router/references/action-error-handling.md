---
title: Handle Server Action Errors Gracefully
impact: MEDIUM-HIGH
impactDescription: prevents silent failures, better error UX
tags: action, error-handling, validation, useActionState
---

## Handle Server Action Errors Gracefully

Return error states from Server Actions instead of throwing. Use `useActionState` to manage form state and display errors.

**Incorrect (unhandled errors):**

```typescript
async function createPost(formData: FormData) {
  'use server'

  const title = formData.get('title') as string
  await db.posts.create({ data: { title } })
  // If validation fails or DB errors, user sees nothing
}
```

**Correct (returning error state):**

```typescript
// actions.ts
'use server'

type ActionState = {
  error?: string
  success?: boolean
}

export async function createPost(
  prevState: ActionState,
  formData: FormData
): Promise<ActionState> {
  const title = formData.get('title') as string

  if (!title || title.length < 3) {
    return { error: 'Title must be at least 3 characters' }
  }

  try {
    await db.posts.create({ data: { title } })
    revalidatePath('/posts')
    return { success: true }
  } catch (e) {
    return { error: 'Failed to create post. Please try again.' }
  }
}

// page.tsx
'use client'

import { useActionState } from 'react'
import { createPost } from './actions'

export default function NewPostForm() {
  const [state, formAction, isPending] = useActionState(createPost, {})

  return (
    <form action={formAction}>
      <input name="title" />
      {state.error && <p className="error">{state.error}</p>}
      <button disabled={isPending}>
        {isPending ? 'Creating...' : 'Create'}
      </button>
    </form>
  )
}
```

Reference: [useActionState](https://react.dev/reference/react/useActionState)
