---
title: Pass Only Serializable Data to Client Components
impact: HIGH
impactDescription: prevents runtime errors and hydration mismatches
tags: server, client, serialization, props
---

## Pass Only Serializable Data to Client Components

Data passed from Server Components to Client Components must be JSON-serializable. Functions, classes, Dates, and symbols will cause runtime errors or silent failures.

**Incorrect (non-serializable props):**

```tsx
// Server Component
async function UserPage() {
  const user = await getUser()

  return (
    <UserCard
      user={user}
      createdAt={user.createdAt}  // Date object - not serializable
      onEdit={() => console.log('edit')}  // Function - not serializable
      settings={new Map(user.settings)}  // Map - not serializable
    />
  )
}

// Client Component
'use client'
function UserCard({ user, createdAt, onEdit, settings }) {
  // Runtime error: functions and Dates can't cross the server/client boundary
}
```

**Correct (serializable props only):**

```tsx
// Server Component
async function UserPage() {
  const user = await getUser()

  return (
    <UserCard
      user={{
        id: user.id,
        name: user.name,
        email: user.email,
      }}
      createdAt={user.createdAt.toISOString()}  // String is serializable
      settings={Object.fromEntries(user.settings)}  // Plain object
    />
  )
}

// Client Component
'use client'
function UserCard({ user, createdAt, settings }) {
  const date = new Date(createdAt)  // Reconstruct on client

  const handleEdit = () => {
    // Define handlers in Client Component
  }

  return (
    <div>
      <h2>{user.name}</h2>
      <time>{date.toLocaleDateString()}</time>
      <button onClick={handleEdit}>Edit</button>
    </div>
  )
}
```

**Serializable types:**
- Primitives (string, number, boolean, null, undefined)
- Plain objects and arrays
- Server Actions (special case - serialized as references)

Reference: [Serializable Props](https://react.dev/reference/rsc/use-client#serializable-types)
