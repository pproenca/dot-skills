---
title: Use Stable, Hierarchical Query Keys
impact: MEDIUM
impactDescription: prevents cache collisions and unnecessary refetches
tags: client, react-query, query-key, dedup
---

## Use Stable, Hierarchical Query Keys

A React Query cache entry is keyed by a deep-equal comparison of its key array. `['notifications']` returns the same cached data regardless of which account is being viewed — switching tenants shows the previous tenant's notifications until the cache expires. `['notifications', ...accountIds]` keys per account. New objects created in component render cause every render to look like a different key — pass primitives, sorted arrays, or stable references.

**Incorrect (key too coarse — cache collisions across contexts):**

```tsx
function useNotifications({ accountIds }: { accountIds: string[] }) {
  const client = useClient();
  return useQuery({
    queryKey: ['notifications'],  // SAME key for every accountIds value.
    queryFn: () =>
      client.from('notifications').select('*').in('account_id', accountIds),
  });
}

// User switches from /home/acme to /home/beta:
// Same query key → React Query returns the cached acme data.
// User sees acme's notifications under beta's URL.
```

**Incorrect (key includes an unstable object — refetches on every render):**

```tsx
function useNotifications({ accountIds, filter }: Props) {
  const client = useClient();
  return useQuery({
    // New object every render → keys are never deep-equal → cache miss every time.
    queryKey: ['notifications', { accountIds, filter }],
    queryFn: () => /* ... */,
  });
}
// Every render triggers a refetch. Look-busy UI, wasted bandwidth.
```

**Correct (hierarchical key with primitives and stable values):**

```tsx
function useNotifications({ accountIds, filter }: Props) {
  const client = useClient();
  return useQuery({
    // Primitives in a flat array. Equal sub-arrays compare equal.
    // `accountIds` should already be a stable reference from a stable source
    // (e.g., workspace loader result), or sort it before passing.
    queryKey: ['notifications', filter, ...accountIds],
    queryFn: () => /* ... */,
  });
}
```

**Hierarchy convention (matches React Query's invalidation patterns):**

```ts
['accounts']                            // All account queries.
['accounts', accountId]                 // One account's queries.
['accounts', accountId, 'projects']     // That account's projects.
['accounts', accountId, 'projects', { archived: false }]  // Filtered.
```

This pays off at invalidation time:

```ts
queryClient.invalidateQueries({ queryKey: ['accounts', accountId] });
// Invalidates: ['accounts', accountId], ['accounts', accountId, 'projects'],
// ['accounts', accountId, 'projects', anything] — every key starting with this prefix.
```

**Sort spread arrays for stable equality.** `[...accountIds]` is order-sensitive. If two consumers might pass the same set in different orders, sort before spreading:

```ts
queryKey: ['notifications', filter, ...[...accountIds].sort()],
```

Or wrap the call in a single `useMemo` if the sort cost matters:

```ts
const sortedIds = useMemo(() => [...accountIds].sort(), [accountIds]);
queryKey: ['notifications', filter, ...sortedIds];
```

**Co-locate keys with the hook.** Don't sprinkle bare arrays through call sites — define a key factory next to the hook:

```ts
// keys.ts
export const notificationKeys = {
  all: () => ['notifications'] as const,
  byAccount: (accountId: string) => ['notifications', accountId] as const,
  byAccountFiltered: (accountId: string, filter: string) =>
    ['notifications', accountId, filter] as const,
};

// Use site:
useQuery({ queryKey: notificationKeys.byAccount(accountId), queryFn });

// Invalidation site (in a mutation onSuccess):
queryClient.invalidateQueries({ queryKey: notificationKeys.byAccount(accountId) });
```

**`enabled: !!accountId` for late-arriving deps.** If a dep is `undefined` on first render (e.g., loading from a parent context), passing it through to the key creates a `['notifications', undefined]` cache entry. Set `enabled` to gate execution:

```ts
useQuery({
  queryKey: ['notifications', accountId],
  queryFn: () => /* ... */,
  enabled: !!accountId,
});
```

**Default `staleTime` is 0 — refetches on every mount.** That's the cause of "why does my query refetch every time I navigate?" Set a `staleTime` (e.g., `5_000` for a few seconds, `Infinity` for "until invalidated") so data persists across navigations.

Reference: [TanStack Query: query keys](https://tanstack.com/query/latest/docs/framework/react/guides/query-keys)
