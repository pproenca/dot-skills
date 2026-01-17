# TanStack Query v5

**Version 1.0.0**  
community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for TanStack Query v5 applications, designed for AI agents and LLMs. Contains 40+ rules across 8 categories, prioritized by impact from critical (query key structure, caching configuration) to incremental (render optimization). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Query Key Structure](#1-query-key-structure) — **CRITICAL**
   - 1.1 [Always Use Array Query Keys](#11-always-use-array-query-keys)
   - 1.2 [Colocate Query Keys with Features](#12-colocate-query-keys-with-features)
   - 1.3 [Structure Keys from Generic to Specific](#13-structure-keys-from-generic-to-specific)
   - 1.4 [Use Query Key Factories](#14-use-query-key-factories)
   - 1.5 [Use queryOptions for Type-Safe Sharing](#15-use-queryoptions-for-type-safe-sharing)
   - 1.6 [Use Serializable Objects in Query Keys](#16-use-serializable-objects-in-query-keys)
2. [Caching Configuration](#2-caching-configuration) — **CRITICAL**
   - 2.1 [Configure Global Defaults Appropriately](#21-configure-global-defaults-appropriately)
   - 2.2 [Control Automatic Refetch Triggers](#22-control-automatic-refetch-triggers)
   - 2.3 [Invalidate with Precision](#23-invalidate-with-precision)
   - 2.4 [Understand staleTime vs gcTime](#24-understand-staletime-vs-gctime)
   - 2.5 [Use enabled for Conditional Queries](#25-use-enabled-for-conditional-queries)
   - 2.6 [Use placeholderData vs initialData Correctly](#26-use-placeholderdata-vs-initialdata-correctly)
3. [Mutation Patterns](#3-mutation-patterns) — **HIGH**
   - 3.1 [Avoid Parallel Mutations on Same Data](#31-avoid-parallel-mutations-on-same-data)
   - 3.2 [Cancel Queries Before Optimistic Updates](#32-cancel-queries-before-optimistic-updates)
   - 3.3 [Implement Optimistic Updates with Rollback](#33-implement-optimistic-updates-with-rollback)
   - 3.4 [Invalidate in onSettled, Not onSuccess](#34-invalidate-in-onsettled-not-onsuccess)
   - 3.5 [Use setQueryData for Immediate Cache Updates](#35-use-setquerydata-for-immediate-cache-updates)
4. [Prefetching & Waterfalls](#4-prefetching-waterfalls) — **HIGH**
   - 4.1 [Avoid Request Waterfalls](#41-avoid-request-waterfalls)
   - 4.2 [Flatten API to Reduce Waterfalls](#42-flatten-api-to-reduce-waterfalls)
   - 4.3 [Prefetch Dependent Data in queryFn](#43-prefetch-dependent-data-in-queryfn)
   - 4.4 [Prefetch in Server Components](#44-prefetch-in-server-components)
   - 4.5 [Prefetch on Hover for Perceived Speed](#45-prefetch-on-hover-for-perceived-speed)
5. [Infinite Queries](#5-infinite-queries) — **MEDIUM**
   - 5.1 [Flatten Pages for Rendering](#51-flatten-pages-for-rendering)
   - 5.2 [Handle Infinite Query Loading States Correctly](#52-handle-infinite-query-loading-states-correctly)
   - 5.3 [Limit Infinite Query Pages with maxPages](#53-limit-infinite-query-pages-with-maxpages)
   - 5.4 [Understand Infinite Query Refetch Behavior](#54-understand-infinite-query-refetch-behavior)
6. [Suspense Integration](#6-suspense-integration) — **MEDIUM**
   - 6.1 [Always Pair Suspense with Error Boundaries](#61-always-pair-suspense-with-error-boundaries)
   - 6.2 [Combine Suspense Queries with useSuspenseQueries](#62-combine-suspense-queries-with-usesuspensequeries)
   - 6.3 [Place Suspense Boundaries Strategically](#63-place-suspense-boundaries-strategically)
   - 6.4 [Use Suspense Hooks for Simpler Loading States](#64-use-suspense-hooks-for-simpler-loading-states)
7. [Error & Retry Handling](#7-error-retry-handling) — **MEDIUM**
   - 7.1 [Configure Retry with Exponential Backoff](#71-configure-retry-with-exponential-backoff)
   - 7.2 [Display Errors Appropriately](#72-display-errors-appropriately)
   - 7.3 [Use Conditional Retry Based on Error Type](#73-use-conditional-retry-based-on-error-type)
   - 7.4 [Use Global Error Handler for Common Errors](#74-use-global-error-handler-for-common-errors)
   - 7.5 [Use throwOnError with Error Boundaries](#75-use-throwonerror-with-error-boundaries)
8. [Render Optimization](#8-render-optimization) — **LOW-MEDIUM**
   - 8.1 [Avoid Destructuring All Properties](#81-avoid-destructuring-all-properties)
   - 8.2 [Memoize Select Functions](#82-memoize-select-functions)
   - 8.3 [Understand Structural Sharing](#83-understand-structural-sharing)
   - 8.4 [Use notifyOnChangeProps to Limit Re-renders](#84-use-notifyonchangeprops-to-limit-re-renders)
   - 8.5 [Use Select to Derive Data and Reduce Re-renders](#85-use-select-to-derive-data-and-reduce-re-renders)

---

## 1. Query Key Structure

**Impact: CRITICAL**

Query key structure cascades through cache lookups, invalidation patterns, and request deduplication—wrong structure means broken cache management.

### 1.1 Always Use Array Query Keys

**Impact: HIGH (consistent structure, prevents string/array mismatch bugs)**

String query keys get converted to arrays internally, causing confusion when mixing formats. Always use arrays for consistency and to enable the hierarchical key pattern.

**Incorrect (mixed string and array keys):**

```typescript
// String key
const { data: user } = useQuery({
  queryKey: 'currentUser', // Internally becomes ['currentUser']
  queryFn: fetchCurrentUser,
})

// Array key elsewhere
const { data: settings } = useQuery({
  queryKey: ['currentUser', 'settings'],
  queryFn: fetchUserSettings,
})

// Invalidation confusion - does this match the string key?
queryClient.invalidateQueries({ queryKey: ['currentUser'] }) // Yes, but not obvious
```

**Correct (always arrays):**

```typescript
// Always arrays, even for single elements
const { data: user } = useQuery({
  queryKey: ['currentUser'],
  queryFn: fetchCurrentUser,
})

const { data: settings } = useQuery({
  queryKey: ['currentUser', 'settings'],
  queryFn: fetchUserSettings,
})

// Clear invalidation hierarchy
queryClient.invalidateQueries({ queryKey: ['currentUser'] }) // Matches both
```

**Note:** TanStack Query v5 TypeScript types enforce arrays, but runtime still accepts strings for backwards compatibility.

### 1.2 Colocate Query Keys with Features

**Impact: MEDIUM (improves maintainability, enables feature isolation)**

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

### 1.3 Structure Keys from Generic to Specific

**Impact: CRITICAL (enables granular cache invalidation at any level)**

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

### 1.4 Use Query Key Factories

**Impact: CRITICAL (eliminates key duplication, enables type-safe invalidation)**

Query keys scattered across components lead to typos, inconsistent structure, and broken cache invalidation. A query key factory centralizes key generation for type safety and maintainability.

**Incorrect (scattered keys, easy to break):**

```typescript
// In UserProfile.tsx
const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})

// In UserSettings.tsx - typo breaks invalidation
const { data } = useQuery({
  queryKey: ['users', userId], // 'users' vs 'user' - different cache!
  queryFn: () => fetchUser(userId),
})

// In mutation - invalidation misses the typo
queryClient.invalidateQueries({ queryKey: ['user'] })
```

**Correct (centralized factory):**

```typescript
// queries/users.ts
export const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (filters: UserFilters) => [...userKeys.lists(), filters] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
}

// In UserProfile.tsx
const { data } = useQuery({
  queryKey: userKeys.detail(userId),
  queryFn: () => fetchUser(userId),
})

// In mutation - invalidates all user queries
queryClient.invalidateQueries({ queryKey: userKeys.all })
```

**Benefits:**
- TypeScript autocompletion prevents typos
- Hierarchical structure enables granular invalidation
- Single source of truth for all user-related keys

Reference: [Effective React Query Keys](https://tkdodo.eu/blog/effective-react-query-keys)

### 1.5 Use queryOptions for Type-Safe Sharing

**Impact: HIGH (type-safe prefetching and cache access)**

When sharing query configuration between `useQuery`, `prefetchQuery`, and `getQueryData`, inline objects lose type inference. The `queryOptions` helper preserves types across all usage sites.

**Incorrect (repeated configuration, lost types):**

```typescript
// In component
const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})

// In prefetch - duplicated, no type link
await queryClient.prefetchQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
})

// getQueryData returns unknown
const user = queryClient.getQueryData(['user', userId])
// user is unknown, need manual cast
```

**Correct (queryOptions shares types):**

```typescript
// Define once with queryOptions
const userQueryOptions = (userId: string) =>
  queryOptions({
    queryKey: ['user', userId] as const,
    queryFn: () => fetchUser(userId),
  })

// In component - fully typed
const { data } = useQuery(userQueryOptions(userId))

// In prefetch - same options, same types
await queryClient.prefetchQuery(userQueryOptions(userId))

// getQueryData is now typed!
const user = queryClient.getQueryData(userQueryOptions(userId).queryKey)
// user is User | undefined, not unknown
```

**Combine with query key factories:**

```typescript
export const userQueries = {
  detail: (userId: string) =>
    queryOptions({
      queryKey: userKeys.detail(userId),
      queryFn: () => fetchUser(userId),
    }),
  list: (filters: UserFilters) =>
    queryOptions({
      queryKey: userKeys.list(filters),
      queryFn: () => fetchUsers(filters),
    }),
}

// Usage
const { data } = useQuery(userQueries.detail(userId))
await queryClient.prefetchQuery(userQueries.list({ role: 'admin' }))
```

Reference: [TanStack Query - TypeScript](https://tanstack.com/query/v5/docs/react/typescript)

### 1.6 Use Serializable Objects in Query Keys

**Impact: HIGH (deterministic hashing, prevents cache misses)**

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

---

## 2. Caching Configuration

**Impact: CRITICAL**

Misconfigured staleTime/gcTime causes unnecessary refetches (waterfalls) or stale data display—the most common TanStack Query mistakes.

### 2.1 Configure Global Defaults Appropriately

**Impact: CRITICAL (prevents per-query repetition, establishes sensible baselines)**

TanStack Query's defaults prioritize freshness over performance—`staleTime: 0` refetches on every mount. Configure global defaults to match your app's data patterns, then override per-query.

**Incorrect (accepting aggressive defaults):**

```typescript
// Default QueryClient - every query refetches on mount/focus
const queryClient = new QueryClient()

// Every query across the app repeats these overrides
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  staleTime: 5 * 60 * 1000,
  retry: 2,
})
```

**Correct (sensible global defaults):**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 60 * 1000,           // 1 minute default freshness
      gcTime: 5 * 60 * 1000,          // 5 minute cache retention
      retry: 1,                        // Retry once on failure
      refetchOnWindowFocus: 'always', // Refetch stale on focus
      refetchOnReconnect: 'always',   // Refetch stale on reconnect
    },
    mutations: {
      retry: 0, // Don't retry mutations by default
    },
  },
})

// Queries now inherit sensible defaults
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  // Inherits staleTime: 60_000, retry: 1, etc.
})

// Override only when needed
const { data: config } = useQuery({
  queryKey: ['appConfig'],
  queryFn: fetchConfig,
  staleTime: Infinity, // Static data, override default
})
```

**Environment-specific defaults:**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: process.env.NODE_ENV === 'development'
        ? 0              // Fresh data in dev for debugging
        : 60 * 1000,     // 1 minute in production
      retry: process.env.NODE_ENV === 'test' ? 0 : 1,
    },
  },
})
```

### 2.2 Control Automatic Refetch Triggers

**Impact: MEDIUM (prevents unexpected refetches, saves bandwidth)**

TanStack Query refetches stale queries on window focus, reconnect, and component mount. These defaults are aggressive—disable them when inappropriate.

**Default behavior (often surprising):**

```typescript
// With defaults, this query refetches when:
// 1. Window regains focus (user switches tabs back)
// 2. Network reconnects
// 3. Component mounts (if data is stale)
const { data } = useQuery({
  queryKey: ['heavyReport'],
  queryFn: fetchHeavyReport, // Takes 10 seconds, 5MB response
})
```

**Controlled refetching:**

```typescript
// Expensive query - don't refetch on focus/reconnect
const { data: report } = useQuery({
  queryKey: ['heavyReport'],
  queryFn: fetchHeavyReport,
  refetchOnWindowFocus: false, // Don't refetch when tab focuses
  refetchOnReconnect: false,   // Don't refetch on network restore
  refetchOnMount: false,       // Don't refetch if we have cached data
  staleTime: 30 * 60 * 1000,   // Consider fresh for 30 minutes
})

// Real-time data - aggressive refetching appropriate
const { data: notifications } = useQuery({
  queryKey: ['notifications'],
  queryFn: fetchNotifications,
  refetchOnWindowFocus: 'always', // Refetch even if fresh
  refetchInterval: 30_000,         // Poll every 30 seconds
})

// User-specific data - refetch on focus if stale
const { data: user } = useQuery({
  queryKey: ['currentUser'],
  queryFn: fetchCurrentUser,
  refetchOnWindowFocus: true, // Default - refetch if stale
  staleTime: 60_000,          // Fresh for 1 minute
})
```

**Conditional refetching:**

```typescript
const { data } = useQuery({
  queryKey: ['dashboard'],
  queryFn: fetchDashboard,
  // Only refetch on focus if tab was away > 5 minutes
  refetchOnWindowFocus: (query) => {
    const fiveMinutes = 5 * 60 * 1000
    const lastUpdated = query.state.dataUpdatedAt
    return Date.now() - lastUpdated > fiveMinutes
  },
})
```

### 2.3 Invalidate with Precision

**Impact: HIGH (prevents over-invalidation cascade, improves performance)**

Broad invalidation (`queryClient.invalidateQueries()` with no filter) refetches everything, causing unnecessary network traffic. Use hierarchical keys to invalidate only affected queries.

**Incorrect (nuclear invalidation):**

```typescript
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: () => {
    // Invalidates EVERY query in the cache!
    queryClient.invalidateQueries()
  },
})

// Also bad - too broad for a single user update
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: () => {
    // Refetches all user lists, all user details - wasteful
    queryClient.invalidateQueries({ queryKey: ['users'] })
  },
})
```

**Correct (surgical invalidation):**

```typescript
const mutation = useMutation({
  mutationFn: (data: { userId: string; updates: UserUpdate }) =>
    updateUser(data.userId, data.updates),
  onSuccess: (_, variables) => {
    // Only invalidate the specific user detail
    queryClient.invalidateQueries({
      queryKey: ['users', 'detail', variables.userId],
    })
    // And user lists (they contain this user's summary)
    queryClient.invalidateQueries({
      queryKey: ['users', 'list'],
    })
  },
})
```

**Even better - update cache directly when possible:**

```typescript
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: (updatedUser) => {
    // Update detail cache directly - no refetch needed
    queryClient.setQueryData(
      ['users', 'detail', updatedUser.id],
      updatedUser
    )
    // Only invalidate lists (need refetch for sorting/filtering)
    queryClient.invalidateQueries({ queryKey: ['users', 'list'] })
  },
})
```

**Use exact match when needed:**

```typescript
// Invalidate ONLY ['users', 'list', { status: 'active' }]
// Not ['users', 'list'] or ['users', 'list', { status: 'inactive' }]
queryClient.invalidateQueries({
  queryKey: ['users', 'list', { status: 'active' }],
  exact: true,
})
```

### 2.4 Understand staleTime vs gcTime

**Impact: CRITICAL (prevents unnecessary refetches and memory issues)**

`staleTime` and `gcTime` are the most misunderstood TanStack Query options. Confusing them causes excessive refetching or stale data. `gcTime` was renamed from `cacheTime` in v5 because of this confusion.

**staleTime**: How long data stays "fresh." Fresh data won't trigger background refetches.

**gcTime**: How long *unused* queries stay in memory before garbage collection.

**Incorrect (default staleTime causes refetch storms):**

```typescript
// staleTime defaults to 0 - data is immediately stale
const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  // staleTime: 0 (default) - every component mount triggers refetch
})

// User navigates away and back - unnecessary refetch!
// Another component mounts with same key - another refetch!
```

**Correct (appropriate staleTime for use case):**

```typescript
// Static data - rarely changes
const { data: config } = useQuery({
  queryKey: ['appConfig'],
  queryFn: fetchConfig,
  staleTime: Infinity, // Never refetch unless manually invalidated
  gcTime: Infinity,    // Keep in cache forever
})

// User data - may change, but not every second
const { data: user } = useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  staleTime: 5 * 60 * 1000, // Fresh for 5 minutes
})

// Real-time data - always fresh from server
const { data: notifications } = useQuery({
  queryKey: ['notifications'],
  queryFn: fetchNotifications,
  staleTime: 0, // Always refetch on focus/mount (default)
  refetchInterval: 30_000, // Also poll every 30s
})
```

**Common mistake - gcTime less than staleTime:**

```typescript
// Problematic: data expires from cache before it goes stale
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  staleTime: 10 * 60 * 1000, // 10 minutes
  gcTime: 5 * 60 * 1000,     // 5 minutes - cache gone before stale!
})
```

**Rule of thumb:** `gcTime >= staleTime` to ensure cached data is available when needed.

Reference: [Important Defaults](https://tanstack.com/query/v5/docs/react/guides/important-defaults)

### 2.5 Use enabled for Conditional Queries

**Impact: HIGH (prevents invalid requests, enables dependent queries)**

Queries run immediately by default. Use `enabled` to defer queries until dependencies are available—essential for dependent queries and conditional fetching.

**Incorrect (query runs with undefined parameter):**

```typescript
function UserProfile({ userId }: { userId?: string }) {
  // Runs immediately, even when userId is undefined!
  const { data } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId!), // Dangerous assertion
  })
  // API receives: GET /users/undefined
}
```

**Correct (enabled guards the query):**

```typescript
function UserProfile({ userId }: { userId?: string }) {
  const { data, isPending } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId!),
    enabled: !!userId, // Only run when userId exists
  })

  if (!userId) return <div>Select a user</div>
  if (isPending) return <Skeleton />
  return <div>{data.name}</div>
}
```

**Dependent queries (waterfall is intentional):**

```typescript
function UserProjects({ userId }: { userId: string }) {
  // First query: get user
  const { data: user } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  // Second query: depends on user's organizationId
  const { data: projects } = useQuery({
    queryKey: ['projects', user?.organizationId],
    queryFn: () => fetchProjects(user!.organizationId),
    enabled: !!user?.organizationId, // Wait for user data
  })
}
```

**Skip query based on feature flag:**

```typescript
const { data: experiments } = useQuery({
  queryKey: ['experiments'],
  queryFn: fetchExperiments,
  enabled: featureFlags.experimentsEnabled,
})
```

**Note:** When `enabled` is false:
- Query stays in `isPending` state
- No network request is made
- `data` remains undefined

### 2.6 Use placeholderData vs initialData Correctly

**Impact: HIGH (prevents stale data bugs and incorrect cache behavior)**

`placeholderData` and `initialData` both show data immediately, but they have different cache semantics. Wrong choice causes stale data or unexpected refetches.

**initialData**: Persisted to cache, affects staleTime, used as real data.
**placeholderData**: Not persisted, never affects staleTime, purely for UI.

**Incorrect (initialData for preview data):**

```typescript
// Using initialData for a preview - BAD!
const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  initialData: { name: 'Loading...', id: userId }, // Fake data in cache!
  staleTime: 5 * 60 * 1000,
})
// Problem: "Loading..." is now cached for 5 minutes!
// If user navigates away and back, they see "Loading..." as real data
```

**Correct (placeholderData for preview):**

```typescript
// placeholderData for UI preview - GOOD!
const { data, isPlaceholderData } = useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  placeholderData: { name: 'Loading...', id: userId },
  staleTime: 5 * 60 * 1000,
})

// isPlaceholderData tells you if showing placeholder
return (
  <div className={isPlaceholderData ? 'opacity-50' : ''}>
    {data.name}
  </div>
)
```

**When to use initialData:**

```typescript
// Cache-to-cache: use detail from list
const { data: user } = useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
  initialData: () => {
    // Get from cached list if available
    const users = queryClient.getQueryData<User[]>(['users'])
    return users?.find(u => u.id === userId)
  },
  initialDataUpdatedAt: () => {
    // Use list's updatedAt for staleTime calculation
    return queryClient.getQueryState(['users'])?.dataUpdatedAt
  },
})
```

**Summary:**
- `placeholderData`: Temporary UI, not cached, for skeletons/previews
- `initialData`: Real data, cached, for cache-to-cache or server-provided data

---

## 3. Mutation Patterns

**Impact: HIGH**

Mutation callbacks (onMutate, onError, onSettled) coordinate optimistic updates, rollback, and cache invalidation for responsive UX.

### 3.1 Avoid Parallel Mutations on Same Data

**Impact: MEDIUM (prevents race conditions and cache corruption)**

Multiple parallel mutations on the same resource cause race conditions—the last response wins regardless of which mutation was "correct." Disable UI or use mutation state to prevent this.

**Incorrect (allow parallel mutations):**

```typescript
function TodoItem({ todo }: { todo: Todo }) {
  const mutation = useMutation({
    mutationFn: updateTodo,
    onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
  })

  return (
    <div>
      <input
        value={todo.title}
        onChange={(e) => mutation.mutate({ ...todo, title: e.target.value })}
        // User types fast: "H" "He" "Hel" "Hell" "Hello"
        // 5 parallel mutations, responses arrive out of order
        // Final state might be "Hel" instead of "Hello"!
      />
    </div>
  )
}
```

**Correct (debounce or disable during mutation):**

```typescript
function TodoItem({ todo }: { todo: Todo }) {
  const [title, setTitle] = useState(todo.title)
  const mutation = useMutation({
    mutationFn: updateTodo,
    onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
  })

  // Debounce the mutation
  const debouncedSave = useDebouncedCallback((newTitle: string) => {
    mutation.mutate({ ...todo, title: newTitle })
  }, 500)

  return (
    <input
      value={title}
      onChange={(e) => {
        setTitle(e.target.value)
        debouncedSave(e.target.value)
      }}
    />
  )
}
```

**Alternative: disable during mutation:**

```typescript
function SaveButton({ todo }: { todo: Todo }) {
  const mutation = useMutation({ mutationFn: updateTodo })

  return (
    <button
      onClick={() => mutation.mutate(todo)}
      disabled={mutation.isPending} // Prevent double-click
    >
      {mutation.isPending ? 'Saving...' : 'Save'}
    </button>
  )
}
```

### 3.2 Cancel Queries Before Optimistic Updates

**Impact: HIGH (prevents race conditions, preserves optimistic state)**

In-flight refetches can overwrite optimistic updates with stale server data. Always cancel pending queries before updating the cache optimistically.

**Incorrect (race condition possible):**

```typescript
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // Optimistically update without canceling
    queryClient.setQueryData(['todos'], (old: Todo[]) =>
      old.map(t => t.id === newTodo.id ? newTodo : t)
    )
    // Meanwhile, a refetch completes and overwrites our optimistic update!
  },
})
```

**Timeline of the bug:**
```
t=0ms: User clicks save, mutation starts
t=0ms: Optimistic update shows new title
t=5ms: Background refetch (started earlier) completes
t=5ms: Old data overwrites optimistic update!
t=100ms: Mutation succeeds, but user saw flash of old data
```

**Correct (cancel before update):**

```typescript
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // Cancel any in-flight queries for this data
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    // Now safe to update optimistically
    const previous = queryClient.getQueryData(['todos'])
    queryClient.setQueryData(['todos'], (old: Todo[]) =>
      old.map(t => t.id === newTodo.id ? newTodo : t)
    )

    return { previous }
  },
  onError: (err, newTodo, context) => {
    queryClient.setQueryData(['todos'], context?.previous)
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

**Cancel specific queries for better precision:**

```typescript
onMutate: async (newTodo) => {
  // Only cancel the specific item's query, not all todos
  await queryClient.cancelQueries({
    queryKey: ['todos', 'detail', newTodo.id],
  })
  // ... rest of optimistic update
}
```

### 3.3 Implement Optimistic Updates with Rollback

**Impact: HIGH (instant UI feedback, proper error recovery)**

Optimistic updates show changes immediately while the server processes. Without proper rollback in `onError`, failed mutations leave the UI in an inconsistent state.

**Incorrect (no rollback on error):**

```typescript
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // Optimistically update
    queryClient.setQueryData(['todos'], (old: Todo[]) =>
      old.map(t => t.id === newTodo.id ? newTodo : t)
    )
  },
  onError: (error) => {
    // UI shows success, but server rejected it!
    toast.error('Failed to update')
    // User sees the "successful" update forever
  },
})
```

**Correct (full optimistic update pattern):**

```typescript
const mutation = useMutation({
  mutationFn: updateTodo,
  onMutate: async (newTodo) => {
    // 1. Cancel in-flight refetches (they'd overwrite our optimistic update)
    await queryClient.cancelQueries({ queryKey: ['todos'] })

    // 2. Snapshot current state for rollback
    const previousTodos = queryClient.getQueryData<Todo[]>(['todos'])

    // 3. Optimistically update cache
    queryClient.setQueryData(['todos'], (old: Todo[]) =>
      old.map(t => t.id === newTodo.id ? newTodo : t)
    )

    // 4. Return context for rollback
    return { previousTodos }
  },
  onError: (error, newTodo, context) => {
    // 5. Rollback on error
    if (context?.previousTodos) {
      queryClient.setQueryData(['todos'], context.previousTodos)
    }
    toast.error('Failed to update')
  },
  onSettled: () => {
    // 6. Always refetch to sync with server
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

**Simplified v5 pattern (using mutation state):**

```typescript
const mutation = useMutation({
  mutationFn: updateTodo,
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['todos'] }),
})

// Use mutation.variables for optimistic display
function TodoItem({ todo }: { todo: Todo }) {
  const optimisticTodo = mutation.isPending && mutation.variables?.id === todo.id
    ? mutation.variables
    : todo

  return <div>{optimisticTodo.title}</div>
}
```

### 3.4 Invalidate in onSettled, Not onSuccess

**Impact: HIGH (ensures cache sync after errors too)**

Invalidating only in `onSuccess` leaves the cache inconsistent after failed mutations. Use `onSettled` to ensure cache invalidation regardless of success or failure.

**Incorrect (invalidate in onSuccess only):**

```typescript
const mutation = useMutation({
  mutationFn: createTodo,
  onSuccess: () => {
    // Only runs on success
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})

// If mutation fails after optimistic update:
// 1. onError restores old state
// 2. But server might have partial state
// 3. onSuccess never runs, no refetch
// 4. Client and server are out of sync!
```

**Correct (invalidate in onSettled):**

```typescript
const mutation = useMutation({
  mutationFn: createTodo,
  onMutate: async (newTodo) => {
    await queryClient.cancelQueries({ queryKey: ['todos'] })
    const previous = queryClient.getQueryData(['todos'])
    queryClient.setQueryData(['todos'], (old: Todo[]) => [...old, newTodo])
    return { previous }
  },
  onError: (err, newTodo, context) => {
    queryClient.setQueryData(['todos'], context?.previous)
  },
  onSettled: () => {
    // Runs after BOTH success AND error
    // Ensures cache matches server state
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

**When to use onSuccess specifically:**

```typescript
const mutation = useMutation({
  mutationFn: createTodo,
  onSuccess: (data) => {
    // Use response data for something specific
    toast.success(`Created: ${data.title}`)
    router.push(`/todos/${data.id}`)
  },
  onError: (error) => {
    toast.error(error.message)
  },
  onSettled: () => {
    // Always invalidate here
    queryClient.invalidateQueries({ queryKey: ['todos'] })
  },
})
```

### 3.5 Use setQueryData for Immediate Cache Updates

**Impact: MEDIUM (instant UI updates without refetch roundtrip)**

When mutation responses contain the updated data, use `setQueryData` to update the cache directly instead of invalidating and refetching.

**Incorrect (always invalidate):**

```typescript
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: () => {
    // Triggers a refetch - extra roundtrip!
    queryClient.invalidateQueries({ queryKey: ['user', userId] })
  },
})
```

**Correct (use response data):**

```typescript
const mutation = useMutation({
  mutationFn: updateUser,
  onSuccess: (updatedUser) => {
    // Update cache directly with response
    queryClient.setQueryData(['user', updatedUser.id], updatedUser)

    // Only invalidate related queries that might be affected
    queryClient.invalidateQueries({ queryKey: ['users', 'list'] })
  },
})
```

**Update nested cache entries:**

```typescript
const mutation = useMutation({
  mutationFn: (data: { todoId: string; completed: boolean }) =>
    updateTodo(data.todoId, { completed: data.completed }),
  onSuccess: (updatedTodo) => {
    // Update the detail cache
    queryClient.setQueryData(['todos', 'detail', updatedTodo.id], updatedTodo)

    // Update the todo within list caches
    queryClient.setQueriesData(
      { queryKey: ['todos', 'list'] },
      (old: Todo[] | undefined) =>
        old?.map(t => t.id === updatedTodo.id ? updatedTodo : t)
    )
  },
})
```

**When to invalidate vs setQueryData:**

| Scenario | Use |
|----------|-----|
| API returns full updated entity | `setQueryData` |
| API returns partial data | `invalidateQueries` |
| Update affects list ordering/filtering | `invalidateQueries` |
| Delete operation | Both (remove + invalidate) |
| Create operation | Both (add + invalidate for sorting) |

---

## 4. Prefetching & Waterfalls

**Impact: HIGH**

Request waterfalls multiply latency—prefetching and query hoisting parallelize data fetching for faster page loads.

### 4.1 Avoid Request Waterfalls

**Impact: CRITICAL (2-10× latency reduction)**

Sequential await patterns create waterfalls where each request waits for the previous. Child component queries don't start until parent components render, multiplying latency.

**Incorrect (child waits for parent to render):**

```typescript
function Article({ id }: { id: string }) {
  const { data: article, isPending } = useQuery({
    queryKey: ['article', id],
    queryFn: () => fetchArticle(id),
  })

  if (isPending) return <Skeleton />

  // Comments query doesn't START until article loads AND renders
  return (
    <>
      <ArticleContent article={article} />
      <Comments articleId={id} /> {/* Waterfall! */}
    </>
  )
}

function Comments({ articleId }: { articleId: string }) {
  const { data } = useQuery({
    queryKey: ['comments', articleId],
    queryFn: () => fetchComments(articleId),
  })
  // This query started AFTER article loaded - wasted time
}
```

**Timeline:** Article (200ms) → then Comments (150ms) = 350ms total

**Correct (hoist queries to parent):**

```typescript
function Article({ id }: { id: string }) {
  // Both queries start immediately, in parallel
  const { data: article, isPending: articlePending } = useQuery({
    queryKey: ['article', id],
    queryFn: () => fetchArticle(id),
  })

  const { data: comments, isPending: commentsPending } = useQuery({
    queryKey: ['comments', id],
    queryFn: () => fetchComments(id),
  })

  if (articlePending) return <Skeleton />

  return (
    <>
      <ArticleContent article={article} />
      {commentsPending ? <CommentsSkeleton /> : <Comments comments={comments} />}
    </>
  )
}
```

**Timeline:** Article (200ms) + Comments (150ms) parallel = 200ms total

**Alternative (prefetch in parent):**

```typescript
function Article({ id }: { id: string }) {
  const { data: article, isPending } = useQuery({
    queryKey: ['article', id],
    queryFn: () => fetchArticle(id),
  })

  // Prefetch comments while article loads
  useQuery({
    queryKey: ['comments', id],
    queryFn: () => fetchComments(id),
    notifyOnChangeProps: [], // Don't re-render this component
  })

  if (isPending) return <Skeleton />

  return (
    <>
      <ArticleContent article={article} />
      <Comments articleId={id} /> {/* Cache already warm! */}
    </>
  )
}
```

Reference: [Request Waterfalls](https://tanstack.com/query/v5/docs/react/guides/request-waterfalls)

### 4.2 Flatten API to Reduce Waterfalls

**Impact: CRITICAL (eliminates dependent query chains entirely)**

When queries depend on each other (`fetchUser` → `fetchUserProjects`), consider restructuring your API to combine them. This is often the best solution for unavoidable waterfalls.

**Incorrect (chained queries):**

```typescript
function UserProjects({ email }: { email: string }) {
  // First: get user by email to get their ID
  const { data: user } = useQuery({
    queryKey: ['user', email],
    queryFn: () => getUserByEmail(email),
  })

  // Second: get projects using user ID (depends on first)
  const { data: projects } = useQuery({
    queryKey: ['projects', user?.id],
    queryFn: () => getProjectsByUser(user!.id),
    enabled: !!user?.id, // Must wait for user
  })

  // Total time: getUserByEmail (100ms) + getProjectsByUser (100ms) = 200ms
}
```

**Correct (flattened API):**

```typescript
// API: GET /api/projects?userEmail=xxx
// Backend joins user + projects in one query

function UserProjects({ email }: { email: string }) {
  const { data: projects } = useQuery({
    queryKey: ['projects', { userEmail: email }],
    queryFn: () => getProjectsByUserEmail(email), // Single request!
  })

  // Total time: getProjectsByUserEmail (100ms) = 100ms
}
```

**When flattening isn't possible, move waterfall to server:**

```typescript
// Server Action or API route handles the chain
async function getProjectsForEmail(email: string) {
  const user = await getUserByEmail(email)
  const projects = await getProjectsByUser(user.id)
  return { user, projects }
}

// Client makes single request
function UserProjects({ email }: { email: string }) {
  const { data } = useQuery({
    queryKey: ['userProjects', email],
    queryFn: () => getProjectsForEmail(email),
  })
}
```

Server-to-server latency is typically 1-10ms vs 50-200ms for client-to-server.

Reference: [Request Waterfalls](https://tanstack.com/query/v5/docs/react/guides/request-waterfalls)

### 4.3 Prefetch Dependent Data in queryFn

**Impact: HIGH (parallelizes dependent data fetching)**

When you know what data will be needed based on a response, start prefetching within the queryFn itself. This runs prefetches in parallel with the primary fetch.

**Incorrect (sequential dependent fetches):**

```typescript
function Feed() {
  const { data: feed } = useQuery({
    queryKey: ['feed'],
    queryFn: getFeed,
  })

  // Graph queries only start AFTER feed renders
  return (
    <div>
      {feed?.map(item =>
        item.type === 'GRAPH'
          ? <GraphWidget id={item.id} key={item.id} />
          : <TextWidget item={item} key={item.id} />
      )}
    </div>
  )
}

function GraphWidget({ id }: { id: string }) {
  const { data } = useQuery({
    queryKey: ['graph', id],
    queryFn: () => getGraphData(id),
  })
  // Started after feed loaded - waterfall!
}
```

**Correct (prefetch in queryFn):**

```typescript
function Feed() {
  const queryClient = useQueryClient()

  const { data: feed } = useQuery({
    queryKey: ['feed'],
    queryFn: async () => {
      const feed = await getFeed()

      // Prefetch graph data for all graph items in parallel
      feed
        .filter(item => item.type === 'GRAPH')
        .forEach(item => {
          queryClient.prefetchQuery({
            queryKey: ['graph', item.id],
            queryFn: () => getGraphData(item.id),
          })
        })

      return feed
    },
  })

  return (
    <div>
      {feed?.map(item =>
        item.type === 'GRAPH'
          ? <GraphWidget id={item.id} key={item.id} /> // Cache already warm!
          : <TextWidget item={item} key={item.id} />
      )}
    </div>
  )
}
```

**Timeline improvement:**
```
Before: Feed (100ms) → then Graph1 + Graph2 + Graph3 (150ms each) = 550ms
After:  Feed (100ms) + Graphs prefetching in parallel = 150ms total
```

### 4.4 Prefetch in Server Components

**Impact: HIGH (eliminates client-side waterfall, immediate data)**

In Next.js App Router, prefetch data in Server Components and pass the hydrated state to the client. This eliminates the client-side fetch waterfall entirely.

**Incorrect (client-side fetch after hydration):**

```typescript
// app/projects/[id]/page.tsx
'use client'

export default function ProjectPage({ params }: { params: { id: string } }) {
  const { data, isPending } = useQuery({
    queryKey: ['project', params.id],
    queryFn: () => fetchProject(params.id),
  })

  if (isPending) return <Skeleton /> // User sees loading spinner
  return <ProjectDetails project={data} />
}
```

**Correct (prefetch in Server Component):**

```typescript
// app/projects/[id]/page.tsx
import { dehydrate, HydrationBoundary, QueryClient } from '@tanstack/react-query'

export default async function ProjectPage({ params }: { params: { id: string } }) {
  const queryClient = new QueryClient()

  await queryClient.prefetchQuery({
    queryKey: ['project', params.id],
    queryFn: () => fetchProject(params.id),
  })

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <ProjectDetails projectId={params.id} />
    </HydrationBoundary>
  )
}

// components/ProjectDetails.tsx
'use client'

export function ProjectDetails({ projectId }: { projectId: string }) {
  const { data } = useQuery({
    queryKey: ['project', projectId],
    queryFn: () => fetchProject(projectId),
  })

  // Data is immediately available from hydrated cache!
  return <div>{data.name}</div>
}
```

**Prefetch multiple queries:**

```typescript
export default async function ProjectPage({ params }: { params: { id: string } }) {
  const queryClient = new QueryClient()

  // Parallel prefetching
  await Promise.all([
    queryClient.prefetchQuery(projectQueries.detail(params.id)),
    queryClient.prefetchQuery(projectQueries.members(params.id)),
    queryClient.prefetchQuery(projectQueries.tasks(params.id)),
  ])

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <ProjectDetails projectId={params.id} />
    </HydrationBoundary>
  )
}
```

### 4.5 Prefetch on Hover for Perceived Speed

**Impact: HIGH (200-400ms head start before navigation)**

Users hover before clicking—use this 200-400ms window to prefetch data. The next page loads instantly from cache.

**Without prefetch:**

```typescript
function ProjectLink({ projectId }: { projectId: string }) {
  return (
    <Link href={`/projects/${projectId}`}>
      View Project
    </Link>
  )
  // User clicks → navigate → fetch starts → loading spinner → content
}
```

**With hover prefetch:**

```typescript
function ProjectLink({ projectId }: { projectId: string }) {
  const queryClient = useQueryClient()

  const prefetch = () => {
    queryClient.prefetchQuery({
      queryKey: ['project', projectId],
      queryFn: () => fetchProject(projectId),
      staleTime: 60_000, // Don't refetch if we have recent data
    })
  }

  return (
    <Link
      href={`/projects/${projectId}`}
      onMouseEnter={prefetch}
      onFocus={prefetch} // Keyboard accessibility
    >
      View Project
    </Link>
  )
  // User hovers → prefetch starts → user clicks → instant content
}
```

**Prefetch multiple related queries:**

```typescript
const prefetch = () => {
  queryClient.prefetchQuery(projectQueries.detail(projectId))
  queryClient.prefetchQuery(projectQueries.members(projectId))
  queryClient.prefetchQuery(projectQueries.activity(projectId))
}
```

**With queryOptions for type safety:**

```typescript
const projectQueries = {
  detail: (id: string) =>
    queryOptions({
      queryKey: ['project', id],
      queryFn: () => fetchProject(id),
      staleTime: 60_000,
    }),
}

function ProjectLink({ projectId }: { projectId: string }) {
  const queryClient = useQueryClient()

  return (
    <Link
      href={`/projects/${projectId}`}
      onMouseEnter={() =>
        queryClient.prefetchQuery(projectQueries.detail(projectId))
      }
    >
      View Project
    </Link>
  )
}
```

---

## 5. Infinite Queries

**Impact: MEDIUM**

Infinite query memory grows unbounded without maxPages, and refetching all pages serially causes performance degradation.

### 5.1 Flatten Pages for Rendering

**Impact: MEDIUM (simplifies component logic, enables virtualization)**

`useInfiniteQuery` returns data as `{ pages: Page[], pageParams: unknown[] }`. Flatten to a single array for rendering and enable virtualization libraries.

**Incorrect (nested rendering):**

```typescript
function PostsList() {
  const { data } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    // ...
  })

  return (
    <div>
      {data?.pages.map((page, pageIndex) => (
        // Extra wrapper divs, harder to virtualize
        <div key={pageIndex}>
          {page.items.map(post => (
            <PostCard key={post.id} post={post} />
          ))}
        </div>
      ))}
    </div>
  )
}
```

**Correct (flattened array):**

```typescript
function PostsList() {
  const { data } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    // ...
  })

  // Flatten once, memoized
  const allPosts = useMemo(
    () => data?.pages.flatMap(page => page.items) ?? [],
    [data?.pages]
  )

  return (
    <div>
      {allPosts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  )
}
```

**With virtualization:**

```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

function VirtualizedPostsList() {
  const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    // ...
  })

  const allPosts = useMemo(
    () => data?.pages.flatMap(page => page.items) ?? [],
    [data?.pages]
  )

  const parentRef = useRef<HTMLDivElement>(null)
  const virtualizer = useVirtualizer({
    count: hasNextPage ? allPosts.length + 1 : allPosts.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 100,
  })

  useEffect(() => {
    const lastItem = virtualizer.getVirtualItems().at(-1)
    if (lastItem?.index >= allPosts.length - 1 && hasNextPage && !isFetchingNextPage) {
      fetchNextPage()
    }
  }, [virtualizer.getVirtualItems(), hasNextPage, isFetchingNextPage, fetchNextPage, allPosts.length])

  return (
    <div ref={parentRef} style={{ height: '500px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map(virtualRow => (
          <PostCard
            key={allPosts[virtualRow.index]?.id ?? 'loader'}
            post={allPosts[virtualRow.index]}
            style={{ transform: `translateY(${virtualRow.start}px)` }}
          />
        ))}
      </div>
    </div>
  )
}
```

### 5.2 Handle Infinite Query Loading States Correctly

**Impact: MEDIUM (prevents UI glitches, shows appropriate feedback)**

Infinite queries have multiple loading states: initial load, fetching next page, and background refetch. Using the wrong state causes spinners in wrong places.

**Incorrect (wrong loading indicator):**

```typescript
function PostsList() {
  const { data, isPending, fetchNextPage, hasNextPage } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    // ...
  })

  // isPending is true during initial load AND fetchNextPage!
  if (isPending) return <FullPageSpinner /> // Flashes on load more

  return (
    <div>
      {data.pages.flatMap(p => p.items).map(post => (
        <PostCard key={post.id} post={post} />
      ))}
      <button onClick={() => fetchNextPage()}>
        Load More
      </button>
    </div>
  )
}
```

**Correct (distinct loading states):**

```typescript
function PostsList() {
  const {
    data,
    isPending,           // True only during initial load
    isFetchingNextPage,  // True only during fetchNextPage
    isFetching,          // True during any fetch (including background)
    hasNextPage,
    fetchNextPage,
  } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    // ...
  })

  // Initial load
  if (isPending) return <FullPageSpinner />

  const allPosts = data.pages.flatMap(p => p.items)

  return (
    <div>
      {/* Background refetch indicator */}
      {isFetching && !isFetchingNextPage && (
        <div className="absolute top-0 right-0">
          <RefreshSpinner />
        </div>
      )}

      {allPosts.map(post => (
        <PostCard key={post.id} post={post} />
      ))}

      {/* Load more button with loading state */}
      {hasNextPage && (
        <button
          onClick={() => fetchNextPage()}
          disabled={isFetchingNextPage}
        >
          {isFetchingNextPage ? 'Loading...' : 'Load More'}
        </button>
      )}

      {/* End of list indicator */}
      {!hasNextPage && <div>No more posts</div>}
    </div>
  )
}
```

**Loading state summary:**

| State | Initial Load | Fetch Next | Background Refetch |
|-------|--------------|------------|-------------------|
| isPending | ✓ | ✗ | ✗ |
| isFetchingNextPage | ✗ | ✓ | ✗ |
| isFetching | ✓ | ✓ | ✓ |

### 5.3 Limit Infinite Query Pages with maxPages

**Impact: HIGH (90% memory reduction in long sessions)**

Without `maxPages`, infinite queries accumulate all pages in memory indefinitely. After 50+ pages, memory bloats and refetching all pages serially causes severe performance degradation.

**Incorrect (unbounded pages):**

```typescript
const { data, fetchNextPage } = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts(pageParam),
  initialPageParam: 0,
  getNextPageParam: (lastPage) => lastPage.nextCursor,
  // No maxPages - accumulates forever!
})

// User scrolls through 100 pages:
// - 100 pages in memory
// - Refetch takes 100 sequential requests
// - Memory grows unbounded
```

**Correct (bounded with maxPages):**

```typescript
const { data, fetchNextPage, fetchPreviousPage } = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts(pageParam),
  initialPageParam: 0,
  getNextPageParam: (lastPage) => lastPage.nextCursor,
  getPreviousPageParam: (firstPage) => firstPage.prevCursor,
  maxPages: 5, // Keep only 5 pages in memory
})

// User scrolls through 100 pages:
// - Only 5 pages in memory at any time
// - Refetch is 5 requests, not 100
// - Bidirectional scrolling works with getPreviousPageParam
```

**Choose maxPages based on UX:**

```typescript
// Chat: users scroll back frequently, keep more
maxPages: 10,

// Feed: users rarely scroll back, keep less
maxPages: 3,

// Dashboard tables: virtualized, keep minimal
maxPages: 2,
```

**Handle page eviction in UI:**

```typescript
function PostsList() {
  const { data, fetchPreviousPage, hasPreviousPage } = useInfiniteQuery({
    queryKey: ['posts'],
    // ...
    maxPages: 5,
    getPreviousPageParam: (firstPage) => firstPage.prevCursor,
  })

  return (
    <div>
      {hasPreviousPage && (
        <button onClick={() => fetchPreviousPage()}>
          Load earlier posts
        </button>
      )}
      {data.pages.flatMap(page => page.items).map(post => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  )
}
```

Reference: [Infinite Queries](https://tanstack.com/query/v5/docs/react/guides/infinite-queries)

### 5.4 Understand Infinite Query Refetch Behavior

**Impact: MEDIUM (prevents unexpected sequential refetches)**

When an infinite query refetches, it refetches ALL pages sequentially. This can be slow with many pages. Use `maxPages` to limit this, or consider manual cache updates.

**Default behavior (sequential refetch):**

```typescript
const { data, refetch } = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts(pageParam),
  initialPageParam: 0,
  getNextPageParam: (lastPage) => lastPage.nextCursor,
})

// User has loaded 20 pages, then window focus triggers refetch:
// Page 1 → Page 2 → Page 3 → ... → Page 20 (sequential!)
// 20 network requests, one after another
```

**Mitigation 1: Use maxPages:**

```typescript
useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
  maxPages: 5, // Only 5 sequential requests on refetch
  // ...
})
```

**Mitigation 2: Disable auto-refetch:**

```typescript
useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
  refetchOnWindowFocus: false, // Don't refetch all pages on focus
  refetchOnMount: false,       // Don't refetch on remount
  staleTime: 5 * 60 * 1000,    // Stay fresh for 5 minutes
  // ...
})
```

**Mitigation 3: Manual first-page refetch:**

```typescript
function PostsList() {
  const queryClient = useQueryClient()
  const { data } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
    refetchOnWindowFocus: false,
    // ...
  })

  // Manually refetch only the first page
  const refreshLatest = async () => {
    const firstPage = await fetchPosts({ pageParam: 0 })
    queryClient.setQueryData(['posts'], (old) => ({
      pages: [firstPage, ...(old?.pages.slice(1) ?? [])],
      pageParams: old?.pageParams ?? [0],
    }))
  }

  return (
    <div>
      <button onClick={refreshLatest}>Refresh</button>
      {/* ... */}
    </div>
  )
}
```

---

## 6. Suspense Integration

**Impact: MEDIUM**

Suspense hooks simplify loading states but require proper error boundaries and understanding of data availability guarantees.

### 6.1 Always Pair Suspense with Error Boundaries

**Impact: HIGH (prevents unhandled exceptions from crashing app)**

Suspense queries throw errors as exceptions. Without an Error Boundary, errors crash the app. Always wrap Suspense components with an Error Boundary.

**Incorrect (no error handling):**

```typescript
function App() {
  return (
    <Suspense fallback={<Skeleton />}>
      <UserProfile userId="123" />
      {/* If query fails, entire app crashes! */}
    </Suspense>
  )
}
```

**Correct (Error Boundary catches errors):**

```typescript
import { ErrorBoundary } from 'react-error-boundary'

function App() {
  return (
    <ErrorBoundary
      fallback={<ErrorDisplay />}
      onReset={() => {
        // Reset any state that caused the error
      }}
    >
      <Suspense fallback={<Skeleton />}>
        <UserProfile userId="123" />
      </Suspense>
    </ErrorBoundary>
  )
}
```

**With retry functionality:**

```typescript
function ErrorFallback({ error, resetErrorBoundary }: FallbackProps) {
  const queryClient = useQueryClient()

  return (
    <div>
      <p>Something went wrong: {error.message}</p>
      <button
        onClick={() => {
          // Clear failed queries before retrying
          queryClient.clear()
          resetErrorBoundary()
        }}
      >
        Try again
      </button>
    </div>
  )
}

function App() {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      <Suspense fallback={<Skeleton />}>
        <UserProfile userId="123" />
      </Suspense>
    </ErrorBoundary>
  )
}
```

**Granular error boundaries:**

```typescript
function Dashboard() {
  return (
    <div className="grid grid-cols-2 gap-4">
      <ErrorBoundary fallback={<WidgetError />}>
        <Suspense fallback={<WidgetSkeleton />}>
          <RevenueWidget />
        </Suspense>
      </ErrorBoundary>

      <ErrorBoundary fallback={<WidgetError />}>
        <Suspense fallback={<WidgetSkeleton />}>
          <UsersWidget />
        </Suspense>
      </ErrorBoundary>
      {/* One widget failing doesn't break the other */}
    </div>
  )
}
```

### 6.2 Combine Suspense Queries with useSuspenseQueries

**Impact: MEDIUM (prevents waterfall in suspense components)**

Multiple `useSuspenseQuery` calls in one component create waterfalls—each suspends sequentially. Use `useSuspenseQueries` to fetch in parallel.

**Incorrect (sequential suspension):**

```typescript
function Dashboard() {
  // First query suspends
  const { data: user } = useSuspenseQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
  })

  // Only starts AFTER user query resolves!
  const { data: stats } = useSuspenseQuery({
    queryKey: ['stats'],
    queryFn: fetchStats,
  })

  // Third waterfall
  const { data: notifications } = useSuspenseQuery({
    queryKey: ['notifications'],
    queryFn: fetchNotifications,
  })

  return <div>...</div>
}
// Total time: 100ms + 100ms + 100ms = 300ms
```

**Correct (parallel suspension):**

```typescript
function Dashboard() {
  const [
    { data: user },
    { data: stats },
    { data: notifications },
  ] = useSuspenseQueries({
    queries: [
      { queryKey: ['user'], queryFn: fetchUser },
      { queryKey: ['stats'], queryFn: fetchStats },
      { queryKey: ['notifications'], queryFn: fetchNotifications },
    ],
  })

  return <div>...</div>
}
// Total time: max(100ms, 100ms, 100ms) = 100ms
```

**With queryOptions for type safety:**

```typescript
const dashboardQueries = {
  user: queryOptions({
    queryKey: ['user'],
    queryFn: fetchUser,
  }),
  stats: queryOptions({
    queryKey: ['stats'],
    queryFn: fetchStats,
  }),
  notifications: queryOptions({
    queryKey: ['notifications'],
    queryFn: fetchNotifications,
  }),
}

function Dashboard() {
  const [
    { data: user },
    { data: stats },
    { data: notifications },
  ] = useSuspenseQueries({
    queries: [
      dashboardQueries.user,
      dashboardQueries.stats,
      dashboardQueries.notifications,
    ],
  })

  return <div>...</div>
}
```

### 6.3 Place Suspense Boundaries Strategically

**Impact: MEDIUM (controls loading granularity, prevents layout shift)**

Suspense boundary placement determines loading granularity. Too high = entire page loading. Too low = many spinners. Place boundaries at meaningful content sections.

**Too high (entire page loads together):**

```typescript
function App() {
  return (
    <Suspense fallback={<FullPageSpinner />}>
      <Header />      {/* Fast static content waits for... */}
      <Sidebar />     {/* ...slow API call in... */}
      <MainContent /> {/* ...this component */}
      <Footer />
    </Suspense>
  )
}
// User sees blank page until slowest query completes
```

**Too low (spinner chaos):**

```typescript
function Dashboard() {
  return (
    <div>
      <Suspense fallback={<Spinner />}>
        <UserName />
      </Suspense>
      <Suspense fallback={<Spinner />}>
        <UserAvatar />
      </Suspense>
      <Suspense fallback={<Spinner />}>
        <UserStats />
      </Suspense>
      {/* Multiple spinners everywhere, jarring UX */}
    </div>
  )
}
```

**Correct (meaningful sections):**

```typescript
function Dashboard() {
  return (
    <div>
      {/* Static header loads immediately */}
      <Header />

      {/* User section loads together */}
      <ErrorBoundary fallback={<UserError />}>
        <Suspense fallback={<UserSkeleton />}>
          <UserSection />
        </Suspense>
      </ErrorBoundary>

      {/* Stats section loads independently */}
      <ErrorBoundary fallback={<StatsError />}>
        <Suspense fallback={<StatsSkeleton />}>
          <StatsSection />
        </Suspense>
      </ErrorBoundary>

      {/* Static footer loads immediately */}
      <Footer />
    </div>
  )
}
```

**Nested boundaries for progressive loading:**

```typescript
function ProjectPage() {
  return (
    <Suspense fallback={<ProjectSkeleton />}>
      <ProjectHeader /> {/* Loads first */}

      <Suspense fallback={<TasksSkeleton />}>
        <TasksList /> {/* Can load after header */}
      </Suspense>

      <Suspense fallback={<CommentsSkeleton />}>
        <Comments /> {/* Can load last */}
      </Suspense>
    </Suspense>
  )
}
```

### 6.4 Use Suspense Hooks for Simpler Loading States

**Impact: MEDIUM (eliminates loading checks, cleaner component code)**

`useSuspenseQuery` suspends the component during loading, guaranteeing `data` is defined when the component renders. This eliminates loading state checks and simplifies component logic.

**Without Suspense (loading checks everywhere):**

```typescript
function UserProfile({ userId }: { userId: string }) {
  const { data: user, isPending, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  if (isPending) return <Skeleton />
  if (error) return <ErrorDisplay error={error} />

  // data might still be undefined if enabled was false
  return <div>{user?.name}</div>
}
```

**With Suspense (data always defined):**

```typescript
import { useSuspenseQuery } from '@tanstack/react-query'

function UserProfile({ userId }: { userId: string }) {
  const { data: user } = useSuspenseQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  // data is GUARANTEED to be defined here
  return <div>{user.name}</div>
}

// Parent handles loading via Suspense boundary
function UserProfilePage({ userId }: { userId: string }) {
  return (
    <ErrorBoundary fallback={<ErrorDisplay />}>
      <Suspense fallback={<Skeleton />}>
        <UserProfile userId={userId} />
      </Suspense>
    </ErrorBoundary>
  )
}
```

**Key differences from useQuery:**

| Feature | useQuery | useSuspenseQuery |
|---------|----------|------------------|
| `data` type | `T \| undefined` | `T` (guaranteed) |
| `isPending` | Can be `true` | Always `false` |
| `status` | `'pending' \| 'error' \| 'success'` | `'error' \| 'success'` |
| `enabled` option | Supported | Not supported |
| `placeholderData` | Supported | Not supported |

**Important:** `enabled: false` is not compatible with Suspense because the component would suspend forever waiting for data that will never come.

---

## 7. Error & Retry Handling

**Impact: MEDIUM**

Retry configuration determines user experience during transient failures—wrong defaults waste time or hide real errors.

### 7.1 Configure Retry with Exponential Backoff

**Impact: MEDIUM (balances recovery vs user wait time)**

Default retry (3 attempts with exponential backoff) is aggressive for some queries and insufficient for others. Configure retry based on operation importance and expected failure modes.

**Default behavior:**

```typescript
// Retries 3 times with exponential backoff (1s, 2s, 4s)
// Total: up to 7 seconds before error shows
useQuery({
  queryKey: ['data'],
  queryFn: fetchData,
  // retry: 3 (default)
  // retryDelay: attempt => Math.min(1000 * 2 ** attempt, 30000) (default)
})
```

**Fast-fail for user-initiated actions:**

```typescript
// User clicks search - don't make them wait
useQuery({
  queryKey: ['search', query],
  queryFn: () => search(query),
  retry: 1,              // One retry only
  retryDelay: 500,       // Quick retry
})
```

**Patient retry for background data:**

```typescript
// Dashboard widget - can wait for recovery
useQuery({
  queryKey: ['analytics'],
  queryFn: fetchAnalytics,
  retry: 5,
  retryDelay: (attempt) => Math.min(1000 * 2 ** attempt, 60000),
})
```

**Custom backoff strategies:**

```typescript
// Linear backoff: 1s, 2s, 3s, 4s
retryDelay: (attempt) => attempt * 1000,

// Fixed delay: always 2s
retryDelay: 2000,

// Jittered backoff (prevents thundering herd)
retryDelay: (attempt) => {
  const base = Math.min(1000 * 2 ** attempt, 30000)
  const jitter = Math.random() * 1000
  return base + jitter
},
```

**Global defaults:**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 2,
      retryDelay: (attempt) => Math.min(1000 * 2 ** attempt, 10000),
    },
    mutations: {
      retry: 0, // Don't retry mutations by default
    },
  },
})
```

### 7.2 Display Errors Appropriately

**Impact: MEDIUM (improves UX, prevents silent failures)**

Ignoring query errors leaves users confused. Display errors inline for recoverable issues, or redirect/toast for critical failures.

**Incorrect (error ignored):**

```typescript
function UserList() {
  const { data, isPending } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
    // Error not destructured or handled!
  })

  if (isPending) return <Skeleton />
  return <ul>{data?.map(user => <li key={user.id}>{user.name}</li>)}</ul>
  // If error occurs: shows nothing, user has no idea why
}
```

**Correct (error displayed):**

```typescript
function UserList() {
  const { data, isPending, isError, error, refetch } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  })

  if (isPending) return <Skeleton />

  if (isError) {
    return (
      <div className="error-state">
        <p>Failed to load users: {error.message}</p>
        <button onClick={() => refetch()}>Retry</button>
      </div>
    )
  }

  return <ul>{data.map(user => <li key={user.id}>{user.name}</li>)}</ul>
}
```

**Partial error with stale data:**

```typescript
function UserList() {
  const { data, isError, error, isFetching } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers,
  })

  return (
    <div>
      {/* Show stale data with error banner */}
      {isError && (
        <div className="bg-yellow-100 p-2">
          Failed to refresh: {error.message}
        </div>
      )}

      {/* Stale data still displayed */}
      {data && (
        <ul className={isFetching ? 'opacity-50' : ''}>
          {data.map(user => <li key={user.id}>{user.name}</li>)}
        </ul>
      )}
    </div>
  )
}
```

**Error-specific handling:**

```typescript
function UserProfile() {
  const { data, isError, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  })

  if (isError) {
    if (error instanceof ApiError) {
      if (error.status === 404) return <NotFound />
      if (error.status === 403) return <Forbidden />
    }
    return <GenericError error={error} />
  }

  return <Profile user={data} />
}
```

### 7.3 Use Conditional Retry Based on Error Type

**Impact: HIGH (prevents retrying unrecoverable errors)**

Retrying 4xx client errors is pointless—the server won't change its mind. Only retry transient errors (network issues, 5xx server errors, rate limits).

**Incorrect (retries everything):**

```typescript
useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
  retry: 3, // Retries even 404, 403, 401 errors
})
// User deleted? Retries 3 times before showing "not found"
// Unauthorized? Retries 3 times before redirect to login
```

**Correct (conditional retry):**

```typescript
useQuery({
  queryKey: ['user', userId],
  queryFn: () => fetchUser(userId),
  retry: (failureCount, error) => {
    // Don't retry client errors (4xx)
    if (error instanceof ApiError && error.status >= 400 && error.status < 500) {
      return false
    }
    // Retry server errors up to 3 times
    return failureCount < 3
  },
})
```

**Typed error handling:**

```typescript
class ApiError extends Error {
  constructor(
    public status: number,
    public code: string,
    message: string
  ) {
    super(message)
  }

  isRetryable(): boolean {
    // Retry 5xx, 429 (rate limit), network errors
    return (
      this.status >= 500 ||
      this.status === 429 ||
      this.code === 'NETWORK_ERROR'
    )
  }
}

useQuery({
  queryKey: ['data'],
  queryFn: fetchData,
  retry: (failureCount, error) => {
    if (error instanceof ApiError) {
      return error.isRetryable() && failureCount < 3
    }
    // Network errors: retry
    return failureCount < 3
  },
})
```

**Global retry configuration:**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: (failureCount, error) => {
        // Never retry 4xx
        if (error instanceof ApiError && error.status >= 400 && error.status < 500) {
          return false
        }
        // Retry others up to 2 times
        return failureCount < 2
      },
    },
  },
})
```

### 7.4 Use Global Error Handler for Common Errors

**Impact: MEDIUM (centralizes error handling, consistent UX)**

Handling authentication errors, network failures, and server errors in every component creates duplication. Use QueryClient's global error handler for common patterns.

**Incorrect (duplicated in every query):**

```typescript
function UserProfile() {
  const { data, error } = useQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
  })

  useEffect(() => {
    if (error?.status === 401) {
      router.push('/login')
    }
    if (error?.status >= 500) {
      toast.error('Server error, please try again')
    }
  }, [error])
}

// Repeated in every component that uses queries...
```

**Correct (global handler):**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: (failureCount, error) => {
        // Don't retry auth errors
        if (error instanceof ApiError && error.status === 401) {
          return false
        }
        return failureCount < 2
      },
    },
  },
  queryCache: new QueryCache({
    onError: (error, query) => {
      if (error instanceof ApiError) {
        // Redirect on auth errors
        if (error.status === 401) {
          window.location.href = '/login'
          return
        }

        // Toast for server errors (but only for user-facing queries)
        if (error.status >= 500 && !query.meta?.silent) {
          toast.error('Something went wrong. Please try again.')
        }
      }
    },
  }),
  mutationCache: new MutationCache({
    onError: (error, variables, context, mutation) => {
      if (error instanceof ApiError && error.status >= 500) {
        toast.error('Failed to save. Please try again.')
      }
    },
  }),
})
```

**Using query meta for control:**

```typescript
// Silent query - don't show global toast
useQuery({
  queryKey: ['background-sync'],
  queryFn: syncData,
  meta: { silent: true },
})

// User-facing query - show global toast on error
useQuery({
  queryKey: ['user'],
  queryFn: fetchUser,
  // No meta.silent - global handler will toast on error
})
```

### 7.5 Use throwOnError with Error Boundaries

**Impact: MEDIUM (bubbles errors to boundaries, enables catch-all handling)**

By default, query errors are returned in the `error` field. Use `throwOnError: true` to throw errors, which Error Boundaries can catch for consistent error UI.

**Default behavior (errors in state):**

```typescript
function UserProfile() {
  const { data, isError, error } = useQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
  })

  // Must handle error manually in this component
  if (isError) return <ErrorDisplay error={error} />
  return <div>{data.name}</div>
}
```

**With throwOnError (bubbles to boundary):**

```typescript
function UserProfile() {
  const { data } = useQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
    throwOnError: true, // Throws on error
  })

  // No error handling needed here - boundary catches it
  return <div>{data.name}</div>
}

// Parent handles all errors
function UserPage() {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      <UserProfile />
    </ErrorBoundary>
  )
}
```

**Conditional throwOnError:**

```typescript
useQuery({
  queryKey: ['user'],
  queryFn: fetchUser,
  // Only throw for server errors, handle 4xx locally
  throwOnError: (error) => error instanceof ApiError && error.status >= 500,
})
```

**Combining with Suspense:**

```typescript
// useSuspenseQuery always throws errors (no throwOnError option)
function UserProfile() {
  const { data } = useSuspenseQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
  })
  return <div>{data.name}</div>
}

// Must have both Suspense AND Error Boundary
function UserPage() {
  return (
    <ErrorBoundary FallbackComponent={ErrorFallback}>
      <Suspense fallback={<Skeleton />}>
        <UserProfile />
      </Suspense>
    </ErrorBoundary>
  )
}
```

**Global throwOnError:**

```typescript
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      throwOnError: (error) => error instanceof ApiError && error.status >= 500,
    },
  },
})
```

---

## 8. Render Optimization

**Impact: LOW-MEDIUM**

Select functions, notifyOnChangeProps, and structural sharing reduce unnecessary re-renders in high-frequency update scenarios.

### 8.1 Avoid Destructuring All Properties

**Impact: LOW (prevents subscribing to unused state changes)**

Destructuring query result properties you don't use still subscribes you to their changes. Only destructure what you need, or use `notifyOnChangeProps`.

**Incorrect (subscribed to unused properties):**

```typescript
function SimpleDisplay() {
  // Destructures everything, subscribed to all changes
  const {
    data,
    error,
    isLoading,
    isFetching,
    isError,
    isSuccess,
    status,
    fetchStatus,
    // ... and more
  } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
  })

  // But only uses data!
  return <div>{data?.value}</div>
}
```

**Correct (minimal destructuring):**

```typescript
function SimpleDisplay() {
  const { data } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
  })

  return <div>{data?.value}</div>
}
```

**Access properties only when needed:**

```typescript
function DataWithLoading() {
  const query = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
  })

  // Access isPending only in the conditional
  if (query.isPending) return <Skeleton />

  // Access error only if checking for it
  if (query.isError) return <Error message={query.error.message} />

  // Access data for rendering
  return <div>{query.data?.value}</div>
}
```

**Combine with notifyOnChangeProps for explicitness:**

```typescript
function DataOnly() {
  const { data } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
    notifyOnChangeProps: ['data'], // Explicit subscription
  })

  return <div>{data?.value}</div>
}
```

**Note:** React Query's tracked queries feature (when enabled) automatically detects which properties you access and optimizes subscriptions. However, explicit `notifyOnChangeProps` is clearer and doesn't rely on runtime detection.

### 8.2 Memoize Select Functions

**Impact: MEDIUM (prevents repeated computation on every render)**

The `select` function runs on every render if passed inline. Memoize with `useCallback` or extract outside the component for stable reference.

**Incorrect (runs on every render):**

```typescript
function TodoCount() {
  const { data: count } = useQuery({
    queryKey: ['todos'],
    queryFn: fetchTodos,
    // Inline arrow function - new reference every render
    select: (todos) => todos.length,
  })

  return <span>{count} todos</span>
}
// select runs on EVERY render, even if todos didn't change
```

**Correct (stable function reference):**

```typescript
// Option 1: Extract outside component
const selectTodoCount = (todos: Todo[]) => todos.length

function TodoCount() {
  const { data: count } = useQuery({
    queryKey: ['todos'],
    queryFn: fetchTodos,
    select: selectTodoCount, // Stable reference
  })

  return <span>{count} todos</span>
}

// Option 2: useCallback (when closing over props)
function FilteredTodoCount({ minPriority }: { minPriority: number }) {
  const selectFiltered = useCallback(
    (todos: Todo[]) => todos.filter(t => t.priority >= minPriority).length,
    [minPriority] // Only recreate when minPriority changes
  )

  const { data: count } = useQuery({
    queryKey: ['todos'],
    queryFn: fetchTodos,
    select: selectFiltered,
  })

  return <span>{count} high priority todos</span>
}
```

**When inline is acceptable:**

```typescript
// Static filtering with no dependencies - consider extracting
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  select: (users) => users.filter(u => u.active), // Runs every render
})

// But if data changes rarely and component doesn't render often,
// the overhead is negligible
```

Reference: [Render Optimizations](https://tanstack.com/query/v5/docs/react/guides/render-optimizations)

### 8.3 Understand Structural Sharing

**Impact: LOW (automatic reference stability for unchanged data)**

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

### 8.4 Use notifyOnChangeProps to Limit Re-renders

**Impact: LOW-MEDIUM (prevents re-renders for unused state changes)**

Components re-render when any query state changes (data, error, isLoading, isFetching, etc.). Use `notifyOnChangeProps` to subscribe only to specific properties.

**Default behavior (re-renders on any change):**

```typescript
function DataDisplay() {
  const { data } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
  })

  // Re-renders when:
  // - data changes ✓ (we use this)
  // - error changes ✗ (we don't use this)
  // - isFetching changes ✗ (we don't use this)
  // - isStale changes ✗ (we don't use this)

  return <div>{data?.value}</div>
}
```

**Optimized (only re-render for data changes):**

```typescript
function DataDisplay() {
  const { data } = useQuery({
    queryKey: ['data'],
    queryFn: fetchData,
    notifyOnChangeProps: ['data'], // Only re-render when data changes
  })

  return <div>{data?.value}</div>
}
```

**Common patterns:**

```typescript
// Only care about data and error
notifyOnChangeProps: ['data', 'error'],

// Show loading state
notifyOnChangeProps: ['data', 'isPending'],

// Track background fetching
notifyOnChangeProps: ['data', 'isFetching'],
```

**Prefetch without re-renders:**

```typescript
function Article({ id }: { id: string }) {
  // Main query - normal behavior
  const { data } = useQuery({
    queryKey: ['article', id],
    queryFn: () => fetchArticle(id),
  })

  // Prefetch comments - don't re-render this component at all
  useQuery({
    queryKey: ['comments', id],
    queryFn: () => fetchComments(id),
    notifyOnChangeProps: [], // Never causes re-render
  })

  return <ArticleContent article={data} />
}
```

**Auto-detection with tracked queries:**

```typescript
// TanStack Query can auto-track which props you access
// Enable via QueryClient config:
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      notifyOnChangeProps: 'all', // Or specific props
    },
  },
})
```

### 8.5 Use Select to Derive Data and Reduce Re-renders

**Impact: MEDIUM (component only re-renders when derived value changes)**

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

---

## References

1. [https://tanstack.com/query/v5/docs](https://tanstack.com/query/v5/docs)
2. [https://tkdodo.eu/blog](https://tkdodo.eu/blog)
3. [https://github.com/lukemorales/query-key-factory](https://github.com/lukemorales/query-key-factory)
4. [https://github.com/TanStack/query/discussions](https://github.com/TanStack/query/discussions)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |