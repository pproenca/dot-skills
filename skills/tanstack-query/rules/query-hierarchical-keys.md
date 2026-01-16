---
title: Structure Keys from Generic to Specific
impact: CRITICAL
impactDescription: enables granular cache invalidation at any level
tags: query, keys, hierarchy, invalidation, structure
---

## Structure Keys from Generic to Specific

Flat query keys prevent granular invalidation. Hierarchical keys from generic to specific enable invalidating at any level—all queries, all lists, or specific items.

**Incorrect (flat keys, no hierarchy):**

```typescript
// Flat keys - can only invalidate exact matches
const { data: todos } = useQuery({
  queryKey: ['todos-list-active'],
  queryFn: fetchActiveTodos,
})

const { data: todo } = useQuery({
  queryKey: ['todo-detail-123'],
  queryFn: () => fetchTodo('123'),
})

// Cannot invalidate all todo queries at once
queryClient.invalidateQueries({ queryKey: ['todo'] }) // Matches nothing!
```

**Correct (hierarchical keys):**

```typescript
// Hierarchical: ['todos'] → ['todos', 'list'] → ['todos', 'list', { status }]
const { data: todos } = useQuery({
  queryKey: ['todos', 'list', { status: 'active' }],
  queryFn: fetchActiveTodos,
})

const { data: todo } = useQuery({
  queryKey: ['todos', 'detail', '123'],
  queryFn: () => fetchTodo('123'),
})

// Invalidate ALL todo queries (lists + details)
queryClient.invalidateQueries({ queryKey: ['todos'] })

// Invalidate only todo lists, keep details cached
queryClient.invalidateQueries({ queryKey: ['todos', 'list'] })

// Invalidate specific filtered list
queryClient.invalidateQueries({ queryKey: ['todos', 'list', { status: 'active' }] })
```

**Common hierarchy patterns:**
- `['entity']` - all queries for entity
- `['entity', 'list']` - all list queries
- `['entity', 'list', filters]` - specific filtered list
- `['entity', 'detail']` - all detail queries
- `['entity', 'detail', id]` - specific detail

Reference: [TanStack Query - Query Keys](https://tanstack.com/query/v5/docs/react/guides/query-keys)
