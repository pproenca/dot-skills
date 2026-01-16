---
title: Understand Structural Sharing
impact: LOW
impactDescription: automatic reference stability for unchanged data
tags: render, structural-sharing, reference, stability
---

## Understand Structural Sharing

TanStack Query preserves object references when data hasn't changed through "structural sharing." This enables React's bailout optimization and prevents unnecessary re-renders.

**How it works:**

```typescript
// First fetch returns: { user: { id: 1, name: 'Alice' }, settings: { theme: 'dark' } }
// Second fetch returns: { user: { id: 1, name: 'Alice' }, settings: { theme: 'light' } }

// After structural sharing:
// - Top-level object: NEW reference (something changed)
// - user object: SAME reference (unchanged)
// - settings object: NEW reference (theme changed)
```

**Benefits for React:**

```typescript
const UserProfile = memo(function UserProfile({ user }: { user: User }) {
  return <div>{user.name}</div>
})

function Dashboard() {
  const { data } = useQuery({
    queryKey: ['dashboard'],
    queryFn: fetchDashboard,
  })

  return (
    <>
      {/* Doesn't re-render when settings change, only when user changes */}
      <UserProfile user={data?.user} />
      <Settings settings={data?.settings} />
    </>
  )
}
```

**When structural sharing fails:**

```typescript
// Dates are compared by reference, not value
// Different Date objects are always "new"
const { data } = useQuery({
  queryKey: ['events'],
  queryFn: async () => {
    const events = await fetchEvents()
    return events.map(e => ({
      ...e,
      date: new Date(e.dateString), // New Date each time!
    }))
  },
})
// Every refetch = new references for all events
```

**Solution: transform in select, not queryFn:**

```typescript
const { data } = useQuery({
  queryKey: ['events'],
  queryFn: fetchEvents, // Returns raw data with date strings
  select: (events) => events.map(e => ({
    ...e,
    date: new Date(e.dateString),
  })),
  // select's result also gets structural sharing
  // but Dates still break it - consider keeping as strings
})
```

**Disable structural sharing if needed:**

```typescript
useQuery({
  queryKey: ['data'],
  queryFn: fetchData,
  structuralSharing: false, // Always returns new references
})
```
