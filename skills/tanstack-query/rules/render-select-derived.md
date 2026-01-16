---
title: Use Select to Derive Data and Reduce Re-renders
impact: MEDIUM
impactDescription: component only re-renders when derived value changes
tags: render, select, derived, transformation
---

## Use Select to Derive Data and Reduce Re-renders

Components re-render when query data changes. Use `select` to derive only the values you need—the component only re-renders when the selected value changes.

**Incorrect (re-renders on any user field change):**

```typescript
function UserStatus({ userId }: { userId: string }) {
  const { data: user } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  // Component re-renders when ANY user field changes
  // (name, email, avatar, preferences, etc.)
  return <span>{user?.isOnline ? '🟢' : '⚪'}</span>
}
```

**Correct (re-renders only when isOnline changes):**

```typescript
function UserStatus({ userId }: { userId: string }) {
  const { data: isOnline } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    select: (user) => user.isOnline, // Only track this field
  })

  // Component only re-renders when isOnline value changes
  return <span>{isOnline ? '🟢' : '⚪'}</span>
}
```

**Select for computed values:**

```typescript
function TodoStats() {
  const { data: stats } = useQuery({
    queryKey: ['todos'],
    queryFn: fetchTodos,
    select: (todos) => ({
      total: todos.length,
      completed: todos.filter(t => t.completed).length,
      pending: todos.filter(t => !t.completed).length,
    }),
  })

  return (
    <div>
      <span>{stats?.completed}/{stats?.total} completed</span>
    </div>
  )
}
```

**Multiple components, same query, different selections:**

```typescript
// Both use same cached data, but render independently
function UserName({ userId }: { userId: string }) {
  const { data: name } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    select: (user) => user.name,
  })
  return <h1>{name}</h1>
}

function UserAvatar({ userId }: { userId: string }) {
  const { data: avatarUrl } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    select: (user) => user.avatarUrl,
  })
  return <img src={avatarUrl} />
}
// Changing name doesn't re-render UserAvatar!
```
