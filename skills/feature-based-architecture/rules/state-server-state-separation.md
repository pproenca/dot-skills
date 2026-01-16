---
title: Separate Server State from Client State
impact: MEDIUM
impactDescription: Eliminates manual cache sync; leverages query library optimizations
tags: state, server-state, client-state, tanstack-query
---

## Separate Server State from Client State

Server state (data from API) and client state (UI state, form state) have different characteristics. Server state should be managed by a query library; client state by local state or stores. Mixing them leads to stale data and sync bugs.

**Incorrect (server state in client store):**

```typescript
// src/stores/userStore.ts
export const useUserStore = create((set) => ({
  users: [],
  isLoading: false,

  // Manual fetching logic
  fetchUsers: async () => {
    set({ isLoading: true });
    const users = await api.getUsers();
    set({ users, isLoading: false });
  },

  // Manual cache invalidation
  invalidate: () => {
    // How do we know when to refetch?
    // What about stale data?
    // What about deduplication?
  },
}));
```

**Correct (server state in query library):**

```typescript
// src/features/user/hooks/useUsers.ts
// Server state - managed by TanStack Query
export function useUsers(filters: UserFilters) {
  return useQuery({
    queryKey: userKeys.list(filters),
    queryFn: () => getUsers(filters),
    staleTime: 60_000,  // Built-in cache management
  });
}

// src/features/user/stores/userUIStore.ts
// Client state - UI-only concerns
export const useUserUIStore = create((set) => ({
  selectedUserId: null,
  filterPanelOpen: false,
  sortOrder: 'asc' as const,

  selectUser: (id) => set({ selectedUserId: id }),
  toggleFilterPanel: () => set(s => ({ filterPanelOpen: !s.filterPanelOpen })),
  setSortOrder: (order) => set({ sortOrder: order }),
}));
```

**Usage:**

```typescript
function UserListPage() {
  // Server state
  const { data: users, isLoading } = useUsers({ active: true });

  // Client state
  const { selectedUserId, selectUser, sortOrder } = useUserUIStore();

  const sortedUsers = useMemo(() =>
    [...(users ?? [])].sort((a, b) =>
      sortOrder === 'asc' ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name)
    ),
    [users, sortOrder]
  );

  return <UserList users={sortedUsers} selected={selectedUserId} onSelect={selectUser} />;
}
```

**Server state characteristics:**
- Fetched from external source
- Can become stale
- Needs refetching, deduplication, caching

**Client state characteristics:**
- Created locally
- Never stale (source of truth is client)
- No network concerns

Reference: [TanStack Query - Overview](https://tanstack.com/query/latest/docs/framework/react/overview)
