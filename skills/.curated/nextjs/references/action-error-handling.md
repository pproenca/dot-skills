---
title: Server Actions return a typed error/state result — never throw silently or rely on the client to know what failed
impact: MEDIUM-HIGH
impactDescription: makes validation/business-rule failures visible at the form; `useActionState` consumes the typed result for declarative error rendering
tags: action, action-result, useActionState, typed-errors
---

## Server Actions return a typed error/state result — never throw silently or rely on the client to know what failed

**Pattern intent:** validation and business-rule failures inside a Server Action should return a typed state object (`{ error: string }` or `{ errors: { field: string[] } }`), not throw. The client form pairs the action with `useActionState`, which surfaces the returned state directly.

### Shapes to recognize

- A `'use server'` action that throws on validation failure — the error bubbles to `error.tsx` instead of being displayed inline at the form.
- An action that calls `console.error('Invalid input')` and `return undefined` — silent failure; user has no idea why nothing happened.
- An action with a `try/catch` that swallows errors and returns `null` — silently drops user input.
- An action that returns `{ error: e.message }` but the caller doesn't render `state.error` anywhere — the typed result exists but isn't surfaced.
- An action that uses `redirect` *as* the error path (`if (!ok) redirect('/error')`) — loses field-level error context; user can't fix the form.

The canonical resolution: define a typed state (`{ error?, success?, errors? }`); validate first, return `{ error }` on failure; on success do the mutation, `revalidatePath`/`revalidateTag`, and either `redirect` or `return { success: true }`. The form uses `useActionState(action, {})`.

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
