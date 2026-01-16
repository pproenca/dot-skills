---
title: Colocate Query Keys with Features
impact: MEDIUM
impactDescription: improves maintainability, enables feature isolation
tags: query, keys, colocation, organization, architecture
---

## Colocate Query Keys with Features

Centralizing all query keys in a single file creates a maintenance bottleneck. Colocate keys with their feature modules for better encapsulation and easier refactoring.

**Incorrect (global keys file):**

```typescript
// queries/keys.ts - becomes massive, unrelated keys mixed together
export const queryKeys = {
  users: ['users'],
  userDetail: (id: string) => ['users', id],
  todos: ['todos'],
  todoDetail: (id: string) => ['todos', id],
  projects: ['projects'],
  // ... 50 more keys from different features
}
```

**Correct (colocated with features):**

```typescript
// features/users/queries.ts
export const userKeys = {
  all: ['users'] as const,
  detail: (id: string) => [...userKeys.all, 'detail', id] as const,
  list: (filters: UserFilters) => [...userKeys.all, 'list', filters] as const,
}

export const userQueries = {
  detail: (id: string) =>
    queryOptions({
      queryKey: userKeys.detail(id),
      queryFn: () => fetchUser(id),
    }),
}

// features/todos/queries.ts
export const todoKeys = {
  all: ['todos'] as const,
  detail: (id: string) => [...todoKeys.all, 'detail', id] as const,
  list: (filters: TodoFilters) => [...todoKeys.all, 'list', filters] as const,
}

export const todoQueries = {
  detail: (id: string) =>
    queryOptions({
      queryKey: todoKeys.detail(id),
      queryFn: () => fetchTodo(id),
    }),
}
```

**Benefits:**
- Feature teams own their query keys
- Deleting a feature removes all related keys
- No merge conflicts in a shared keys file
- Keys evolve with their feature

Reference: [Effective React Query Keys](https://tkdodo.eu/blog/effective-react-query-keys)
