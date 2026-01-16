---
title: Use Server Actions for Mutations
impact: CRITICAL
impactDescription: zero client-side mutation code, automatic revalidation, smaller bundles
tags: action, server-actions, use-server, mutations
---

## Use Server Actions for Mutations

Server Actions move mutation logic to the server, eliminating client-side API calls and reducing bundle size. They integrate directly with form actions and handle revalidation automatically.

**Incorrect (client-side API calls):**

```tsx
// app/actions.ts - runs on client
async function updateUser(formData: FormData) {
  const response = await fetch('/api/users', {
    method: 'POST',
    body: formData,
  })
  if (!response.ok) throw new Error('Failed to update')
  return response.json()
}

// app/profile/page.tsx
'use client'
function ProfilePage() {
  const handleSubmit = async (formData: FormData) => {
    await updateUser(formData)  // Client fetches API
    router.refresh()  // Manual revalidation
  }

  return <form action={handleSubmit}>...</form>
}
```

**Correct (server-side mutation):**

```tsx
// app/actions.ts - runs on server only
'use server'

import { revalidatePath } from 'next/cache'
import { db } from '@/lib/db'

export async function updateUser(formData: FormData) {
  const name = formData.get('name') as string
  await db.user.update({ where: { id: userId }, data: { name } })
  revalidatePath('/profile')  // Automatic revalidation
}

// app/profile/page.tsx - can be Server Component
import { updateUser } from './actions'

function ProfilePage() {
  return (
    <form action={updateUser}>  {/* Direct server call */}
      <input name="name" />
      <button>Save</button>
    </form>
  )
}
```

**Benefits:**
- No API route boilerplate
- Direct database access from actions
- Automatic cache revalidation
- Credentials stay server-side
- Smaller client bundles

Reference: [Server Actions](https://react.dev/reference/rsc/server-actions)
