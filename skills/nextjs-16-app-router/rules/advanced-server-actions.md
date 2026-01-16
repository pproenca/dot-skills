---
title: Use Server Actions with Proper Error Handling
impact: LOW
impactDescription: Enables type-safe mutations with automatic form state management
tags: advanced, server-actions, mutations, forms, error-handling
---

## Use Server Actions with Proper Error Handling

Server Actions that throw errors or return inconsistent responses make client-side error handling difficult. Using a consistent return pattern with success/error states enables proper form validation feedback and prevents unhandled promise rejections from crashing the UI.

**Incorrect (throws errors without structured response):**

```tsx
// app/actions/user.ts
'use server'

export async function updateUserProfile(formData: FormData) {
  const name = formData.get('name') as string

  if (!name || name.length < 2) {
    throw new Error('Name must be at least 2 characters')
    // Throwing causes unhandled rejection on client
  }

  await db.users.update({ where: { id: userId }, data: { name } })
  // No return value - client cannot confirm success
}
```

**Correct (structured response with error handling):**

```tsx
// app/actions/user.ts
'use server'

import { revalidatePath } from 'next/cache'

type ActionResult = {
  success: boolean
  message: string
  errors?: Record<string, string[]>
}

export async function updateUserProfile(
  prevState: ActionResult,
  formData: FormData
): Promise<ActionResult> {
  const name = formData.get('name') as string

  if (!name || name.length < 2) {
    return {
      success: false,
      message: 'Validation failed',
      errors: { name: ['Name must be at least 2 characters'] },
    }
  }

  try {
    await db.users.update({ where: { id: userId }, data: { name } })
    revalidatePath('/profile')
    return { success: true, message: 'Profile updated successfully' }
  } catch (error) {
    return { success: false, message: 'Failed to update profile' }
  }
}
```

```tsx
// app/profile/edit/page.tsx
'use client'

import { useActionState } from 'react'
import { updateUserProfile } from '@/app/actions/user'

export default function EditProfileForm() {
  const [state, formAction, isPending] = useActionState(updateUserProfile, {
    success: false,
    message: '',
  })

  return (
    <form action={formAction}>
      <input name="name" aria-describedby="name-error" />
      {state.errors?.name && (
        <p id="name-error" className="error">{state.errors.name[0]}</p>
      )}
      <button type="submit" disabled={isPending}>
        {isPending ? 'Saving...' : 'Save'}
      </button>
      {state.message && (
        <p className={state.success ? 'success' : 'error'}>{state.message}</p>
      )}
    </form>
  )
}
```

**Benefits:**
- Type-safe form state with predictable structure
- Field-level validation errors for better UX
- Automatic pending state with `useActionState`
- No unhandled promise rejections

Reference: [Server Actions and Mutations](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
