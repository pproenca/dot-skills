---
title: Pass Only Serializable Props to Client Components
impact: HIGH
impactDescription: Functions and class instances can't cross the server-client boundary; attempting causes runtime errors or silent failures
tags: server, serialization, props, boundaries
---

## Pass Only Serializable Props to Client Components

Server Components can pass props to Client Components, but only serializable data crosses the boundary. Functions, Date objects, Maps, Sets, and class instances must be converted to plain objects, strings, or numbers.

**Incorrect (non-serializable props):**

```typescript
// Server Component
export default async function Page() {
  const user = await getUser()

  return (
    <UserProfile
      user={user}
      // ❌ Functions can't be serialized
      onUpdate={async (data) => {
        'use server'
        await updateUser(data)
      }}
      // ❌ Date objects serialize as strings unexpectedly
      lastLogin={user.lastLogin}  // Date object
      // ❌ Class instances lose their methods
      permissions={user.permissions}  // PermissionSet instance
    />
  )
}
```

**Correct (serializable props):**

```typescript
// Server Component
export default async function Page() {
  const user = await getUser()

  return (
    <UserProfile
      // Plain object with primitives
      user={{
        id: user.id,
        name: user.name,
        email: user.email,
      }}
      // Date converted to ISO string
      lastLogin={user.lastLogin.toISOString()}
      // Class instance converted to plain array
      permissions={Array.from(user.permissions)}
    />
  )
}
```

```typescript
// Client Component
'use client'

import { updateUser } from '@/actions/user'  // Server Action

export default function UserProfile({
  user,
  lastLogin,
  permissions,
}: {
  user: { id: string; name: string; email: string }
  lastLogin: string
  permissions: string[]
}) {
  // Convert string back to Date if needed
  const loginDate = new Date(lastLogin)

  // Use Server Action for mutations
  const handleUpdate = async (data: FormData) => {
    await updateUser(user.id, data)
  }

  return (
    <form action={handleUpdate}>
      {/* ... */}
    </form>
  )
}
```

**Serializable types:**
- Primitives: string, number, boolean, null, undefined
- Plain objects with serializable values
- Arrays of serializable values
- Server Actions (special case - can be passed)

**Non-serializable types:**
- Functions (except Server Actions)
- Date, Map, Set, RegExp
- Class instances
- Symbols
- Circular references

**When NOT to use this pattern:**
- When using Server Actions for function-like behavior
- When data can remain in Server Components

Reference: [Next.js Composition Patterns](https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns)
