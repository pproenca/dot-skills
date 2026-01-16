---
title: Apply use-server Directive for Server Actions Only
impact: MEDIUM
impactDescription: prevents confusion between Server Components and Server Actions
tags: component, directives, use-server, server-actions
---

## Apply use-server Directive for Server Actions Only

The 'use server' directive marks functions as Server Actions, not Server Components. Server Components are the default and need no directive.

**Incorrect (unnecessary use server):**

```tsx
// components/UserProfile.tsx
'use server'  // WRONG - this doesn't make it a Server Component

export async function UserProfile({ userId }: { userId: string }) {
  const user = await db.user.findUnique({ where: { id: userId } })
  return <div>{user.name}</div>
}
// This is incorrect usage - 'use server' is for Server Actions
```

**Correct (Server Component - no directive):**

```tsx
// components/UserProfile.tsx
// No directive needed - Server Components are default

export async function UserProfile({ userId }: { userId: string }) {
  const user = await db.user.findUnique({ where: { id: userId } })
  return <div>{user.name}</div>
}
```

**Correct (Server Action with use server):**

```tsx
// app/actions.ts
'use server'

export async function updateUserName(formData: FormData) {
  const name = formData.get('name') as string
  await db.user.update({ where: { id: userId }, data: { name } })
  revalidatePath('/profile')
}

// components/ProfileForm.tsx
import { updateUserName } from '@/app/actions'

export function ProfileForm() {
  return (
    <form action={updateUserName}>
      <input name="name" />
      <button>Save</button>
    </form>
  )
}
```

**Summary:**
- Server Components: No directive (default)
- Client Components: 'use client'
- Server Actions: 'use server' (functions, not components)

Reference: [use server](https://react.dev/reference/rsc/use-server)
