---
title: Integrate with React Query and SWR
impact: LOW
impactDescription: reduces store complexity by 80%
tags: adv, react-query, swr, server-state
---

## Integrate with React Query and SWR

Use Zustand for client state (UI, preferences, forms) and data-fetching libraries (React Query, SWR) for server state. Combine them via custom hooks when needed.

**Incorrect (mixing server and client state in Zustand):**

```typescript
// Anti-pattern: Zustand managing server data
const useUserStore = create<UserState>((set) => ({
  users: [],
  isLoading: false,
  error: null,

  fetchUsers: async () => {
    set({ isLoading: true })
    try {
      const users = await api.getUsers()
      set({ users, isLoading: false })
    } catch (error) {
      set({ error, isLoading: false })
    }
  },

  // Manual cache invalidation, no background refresh
  // No deduplication, no retry logic
}))
```

**Correct (Zustand for client state, React Query for server state):**

```typescript
// Zustand: client/UI state only
const useUIStore = create<UIState>((set) => ({
  selectedUserId: null,
  filterText: '',
  sortOrder: 'asc',
  setSelectedUser: (id) => set({ selectedUserId: id }),
  setFilter: (text) => set({ filterText: text }),
  setSortOrder: (order) => set({ sortOrder: order }),
}))

// React Query: server state
function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: api.getUsers,
    staleTime: 5 * 60 * 1000,
  })
}

// Custom hook combining both
function useFilteredUsers() {
  const { data: users = [], isLoading } = useUsers()
  const filterText = useUIStore((s) => s.filterText)
  const sortOrder = useUIStore((s) => s.sortOrder)

  const filteredUsers = useMemo(() => {
    let result = users.filter((u) =>
      u.name.toLowerCase().includes(filterText.toLowerCase())
    )
    return sortOrder === 'asc'
      ? result.sort((a, b) => a.name.localeCompare(b.name))
      : result.sort((a, b) => b.name.localeCompare(a.name))
  }, [users, filterText, sortOrder])

  return { users: filteredUsers, isLoading }
}

// Component uses the combined hook
function UserList() {
  const { users, isLoading } = useFilteredUsers()
  const setSelectedUser = useUIStore((s) => s.setSelectedUser)

  if (isLoading) return <Spinner />

  return (
    <ul>
      {users.map((user) => (
        <li key={user.id} onClick={() => setSelectedUser(user.id)}>
          {user.name}
        </li>
      ))}
    </ul>
  )
}
```

**Benefits:**
- React Query handles caching, deduplication, background refresh
- Zustand handles UI state that doesn't belong in URL or server
- Clear separation of concerns
- Each tool does what it's best at

Reference: [Working with Zustand - TkDodo](https://tkdodo.eu/blog/working-with-zustand)
