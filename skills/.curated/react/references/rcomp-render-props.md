---
title: Use Render Props for Inversion of Control
impact: LOW-MEDIUM
impactDescription: flexible rendering, shared logic
tags: comp, render-props, inversion-of-control, pattern
---

## Use Render Props for Inversion of Control

Render props let parent components control how data is rendered while child components manage state and logic.

**Incorrect (fixed rendering in reusable component):**

```typescript
function DataFetcher({ url }: { url: string }) {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch(url).then(res => res.json()).then(setData).finally(() => setLoading(false))
  }, [url])

  if (loading) return <Spinner />
  return <pre>{JSON.stringify(data)}</pre>  // Fixed rendering
}
// Can't customize how data is displayed
```

**Correct (render prop for flexible rendering):**

```typescript
function DataFetcher<T>({
  url,
  render,
  fallback
}: {
  url: string
  render: (data: T) => ReactNode
  fallback?: ReactNode
}) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch(url).then(res => res.json()).then(setData).finally(() => setLoading(false))
  }, [url])

  if (loading) return fallback ?? <Spinner />
  if (!data) return null
  return <>{render(data)}</>
}

// Usage - caller controls rendering
<DataFetcher
  url="/api/users"
  render={(users) => (
    <UserList users={users} />
  )}
  fallback={<UserListSkeleton />}
/>
```

**Alternative (children as function):**

```typescript
<DataFetcher url="/api/users">
  {(users) => <UserList users={users} />}
</DataFetcher>
```
