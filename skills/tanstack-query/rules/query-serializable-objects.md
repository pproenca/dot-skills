---
title: Use Serializable Objects in Query Keys
impact: HIGH
impactDescription: deterministic hashing, prevents cache misses
tags: query, keys, objects, serialization, filters
---

## Use Serializable Objects in Query Keys

Query keys are hashed deterministically—object property order doesn't matter, but non-serializable values (functions, Dates, class instances) cause unpredictable cache behavior.

**Incorrect (non-serializable values):**

```typescript
// Functions in keys - never match
const { data } = useQuery({
  queryKey: ['users', { filter: (u: User) => u.active }], // Function!
  queryFn: fetchUsers,
})

// Date objects - reference comparison fails
const { data: events } = useQuery({
  queryKey: ['events', { date: new Date() }], // New Date each render!
  queryFn: fetchEvents,
})

// Class instances - unpredictable serialization
const { data: search } = useQuery({
  queryKey: ['search', new SearchParams({ q: 'test' })], // Class instance
  queryFn: performSearch,
})
```

**Correct (serializable primitives and plain objects):**

```typescript
// Plain objects with primitive values
const { data } = useQuery({
  queryKey: ['users', { status: 'active', role: 'admin' }],
  queryFn: () => fetchUsers({ status: 'active', role: 'admin' }),
})

// ISO string for dates
const { data: events } = useQuery({
  queryKey: ['events', { date: selectedDate.toISOString() }],
  queryFn: () => fetchEvents(selectedDate),
})

// Extract serializable properties
const { data: search } = useQuery({
  queryKey: ['search', { q: searchParams.query, page: searchParams.page }],
  queryFn: () => performSearch(searchParams),
})
```

**Safe types for query keys:**
- Strings, numbers, booleans, null
- Arrays of the above
- Plain objects with primitive values
- ISO date strings (not Date objects)
