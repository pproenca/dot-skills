---
title: Combine `useSupabase()` with React Query for Client-Side Data
impact: MEDIUM-HIGH
impactDescription: prevents duplicate fetches across hooks
tags: client, supabase, react-query, dedup, hooks
---

## Combine `useSupabase()` with React Query for Client-Side Data

`useSupabase()` returns the memoized browser client (one instance per component tree). Wrapping queries in `useQuery` keys them by `[resource, ...params]` so two components asking for the same data trigger a single network call. React Query also handles loading/error states, refetch-on-focus, deduplication of in-flight requests, optimistic updates, and cache invalidation — features you would otherwise build by hand inside `useEffect`.

**Incorrect (raw `useEffect` + `useState` per consumer — every component fetches):**

```tsx
'use client';
import { useEffect, useState } from 'react';

export function NotificationBell() {
  const [count, setCount] = useState(0);
  const client = useSupabase();

  useEffect(() => {
    client
      .from('notifications')
      .select('id', { count: 'exact' })
      .eq('dismissed', false)
      .then((r) => setCount(r.count ?? 0));
  }, [client]);
  // Header bell fetches. Sidebar bell ALSO fetches. Dashboard counter ALSO fetches.

  return <Bell count={count} />;
}
```

**Correct (the shipped pattern — `useSupabase()` + `useQuery` with stable key):**

```tsx
// packages/features/notifications/src/hooks/use-fetch-notifications.ts
import { useQuery } from '@tanstack/react-query';
import { useSupabase } from '@kit/supabase/hooks/use-supabase';

function useFetchInitialNotifications(props: { accountIds: string[] }) {
  const client = useSupabase();
  const now = new Date().toISOString();

  return useQuery({
    queryKey: ['notifications', ...props.accountIds],     // Same key → single fetch.
    queryFn: async () => {
      const { data } = await client
        .from('notifications')
        .select(`id, body, dismissed, type, created_at, link`)
        .in('account_id', props.accountIds)
        .eq('dismissed', false)
        .gt('expires_at', now)
        .order('created_at', { ascending: false })
        .limit(10);
      return data;
    },
    refetchOnMount: false,
    refetchOnWindowFocus: false,
  });
}
```

```tsx
// Multiple consumers — all share one fetch.
function NotificationBell({ accountIds }: { accountIds: string[] }) {
  const { data } = useFetchInitialNotifications({ accountIds });
  return <Bell count={data?.length ?? 0} />;
}

function NotificationList({ accountIds }: { accountIds: string[] }) {
  const { data } = useFetchInitialNotifications({ accountIds });
  return <List items={data ?? []} />;
}
// Both consumers → React Query deduplicates to one underlying client.from('notifications').
```

**What you get for free:**

| Concern | Manual `useEffect` | `useQuery` |
|---------|--------------------|------------|
| Loading state | `useState(true)` + setLoading false in `.then` | `isPending` / `isLoading` |
| Error state | `try/catch` + `useState` | `isError`, `error` |
| Refetch on focus | `addEventListener('focus')` + cleanup | `refetchOnWindowFocus: true` (default) |
| Dedup across consumers | Lift state to a Context | Built-in by query key |
| Pagination | Manual offset state + array merge | `useInfiniteQuery` |
| Stale-while-revalidate | Two pieces of state (current + revalidating) | `data` + `isFetching` |
| Mutations + cache update | Manual `setQueryData` everywhere | `useMutation` + `onSuccess: invalidateQueries` |

**Mutation hook pattern (the kit's `use-update-account.ts`):**

```ts
import { useMutation } from '@tanstack/react-query';
import { useSupabase } from '@kit/supabase/hooks/use-supabase';

export function useUpdateAccountData(accountId: string) {
  const client = useSupabase();

  return useMutation({
    mutationKey: ['account:data', accountId],
    mutationFn: async (data: Database['public']['Tables']['accounts']['Update']) => {
      const response = await client.from('accounts').update(data).match({ id: accountId });
      if (response.error) throw response.error;
      return response.data;
    },
  });
}
```

**Stable query keys:** `['resource']` is too coarse — switching accounts shows the previous account's data. `['resource', accountId]` is keyed per account. For lists with multiple filters, include them all: `['projects', accountId, filter, sort]`.

**`useMemo` the client?** No — `useSupabase()` already returns a memoized client (`useMemo(() => getSupabaseBrowserClient(), [])`). Calling `useSupabase()` in every component is the right pattern; each call returns the same instance.

**Server actions for mutations, React Query for reads.** The action is the authoritative write path (auth, validation, logging, revalidatePath); React Query handles the read side and invalidation. Don't read via server actions; don't write via raw Supabase queries from the client.

Reference: [TanStack Query docs](https://tanstack.com/query/latest/docs/framework/react/overview)
