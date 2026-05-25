---
title: Pair a Memoized Browser Data Client with TanStack Query for Client-Side Reads
impact: MEDIUM-HIGH
impactDescription: prevents duplicate fetches across hooks
tags: client, react-query, dedup, hooks, supabase
---

## Pair a Memoized Browser Data Client with TanStack Query for Client-Side Reads

Expose one memoized browser data client per tree (so every component shares a single instance) and wrap every read in `useQuery`, keyed by `[resource, ...params]`. The shared client avoids re-instantiating the SDK; the query key lets two components asking for the same data trigger a single network call. TanStack Query then gives you loading/error states, refetch-on-focus, in-flight deduplication, optimistic updates, and cache invalidation — everything you would otherwise hand-roll inside `useEffect`.

**Incorrect (raw `useEffect` + `useState` per consumer — every component fetches):**

```tsx
'use client';
import { useEffect, useState } from 'react';
import { useClient } from '@app/supabase/client';

export function NotificationBell() {
  const [count, setCount] = useState(0);
  const client = useClient();

  useEffect(() => {
    client
      .from('notifications')
      .select('id', { count: 'exact' })
      .eq('dismissed', false)
      .then((response) => setCount(response.count ?? 0));
  }, [client]);
  // Header bell fetches. Sidebar bell ALSO fetches. Dashboard counter ALSO fetches.

  return <Bell count={count} />;
}
```

**Correct (memoized client + `useQuery` with a stable key):**

```tsx
// packages/features/notifications/src/hooks/use-fetch-notifications.ts
import { useQuery } from '@tanstack/react-query';
import { useClient } from '@app/supabase/client';

export function useFetchNotifications(props: { accountIds: string[] }) {
  const client = useClient();
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
      return data ?? [];
    },
    refetchOnMount: false,
    refetchOnWindowFocus: false,
  });
}
```

```tsx
// Multiple consumers — all share one fetch.
function NotificationBell({ accountIds }: { accountIds: string[] }) {
  const { data } = useFetchNotifications({ accountIds });
  return <Bell count={data?.length ?? 0} />;
}

function NotificationList({ accountIds }: { accountIds: string[] }) {
  const { data } = useFetchNotifications({ accountIds });
  return <List items={data ?? []} />;
}
// Both consumers → TanStack Query deduplicates to one underlying client.from('notifications').
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

**Mutation hook pattern (same memoized client, `useMutation`):**

```ts
import { useMutation } from '@tanstack/react-query';
import { useClient } from '@app/supabase/client';
import type { Database } from '@app/supabase/types';

export function useUpdateAccountData(accountId: string) {
  const client = useClient();

  return useMutation({
    mutationKey: ['account:data', accountId],
    mutationFn: async (changes: Database['public']['Tables']['accounts']['Update']) => {
      const response = await client.from('accounts').update(changes).match({ id: accountId });
      if (response.error) throw response.error; // Surface the failure to onError.
      return response.data;
    },
  });
}
```

**The browser client is a thin hook you own** (`@app/supabase/client.ts`) — built on the `@supabase/ssr` browser client and memoized so every call returns the same instance:

```ts
import { useMemo } from 'react';
import { createBrowserClient } from '@supabase/ssr';
import type { Database } from '@app/supabase/types';

export function useClient() {
  // One instance per tree: re-creating the SDK each render would re-open connections.
  return useMemo(
    () =>
      createBrowserClient<Database>(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      ),
    [],
  );
}
```

**Stable query keys:** `['notifications']` is too coarse — switching accounts shows the previous account's data. `['notifications', accountId]` is keyed per account. For lists with multiple filters, include them all: `['projects', accountId, filter, sort]`.

**Don't `useMemo` the client at the call site.** `useClient()` already returns a memoized instance; calling it in every component is correct — each call returns the same object.

**Server actions for mutations, TanStack Query for reads.** The action is the authoritative write path (auth, validation, logging, `revalidatePath`); TanStack Query handles the read side and invalidation. Don't read via server actions; don't write via raw client queries from the browser.

*Transferable:* the pattern is "one memoized browser client + a typed-key query cache." The Supabase browser client is the concrete example; with Drizzle/Prisma over a `fetch`-based API route, the `queryFn` calls your endpoint instead — the dedup, caching, and key hierarchy are identical.

Reference: [TanStack Query docs](https://tanstack.com/query/latest/docs/framework/react/overview)
