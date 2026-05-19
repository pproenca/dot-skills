---
title: Pass Server Data to Client Components as Props, Don't Refetch
impact: HIGH
impactDescription: prevents double round-trip for already-loaded data
tags: client, props, hydration, server-component, initial-data
---

## Pass Server Data to Client Components as Props, Don't Refetch

The server component already has the workspace/list/account from the loader. Passing it down as props means the client subtree renders immediately with the data — no loading spinner, no extra round-trip. Re-fetching the same data on the client via `useSupabase()` + `useQuery()` doubles the round-trips (server fetched once, browser fetches again from the user's network) and shows the user a stale window during the second fetch.

**Incorrect (server fetches, client throws it away and refetches):**

```tsx
// page.tsx (server)
export default async function Page() {
  const client = getSupabaseServerClient();
  const { data: projects } = await client.from('projects').select('*');
  // Server has the data, but...
  return <ProjectsClient />;  // Doesn't pass it down.
}
```

```tsx
// projects-client.tsx
'use client';
import { useQuery } from '@tanstack/react-query';
import { useSupabase } from '@kit/supabase/hooks/use-supabase';

export function ProjectsClient() {
  const client = useSupabase();
  const { data: projects, isLoading } = useQuery({
    queryKey: ['projects'],
    queryFn: () => client.from('projects').select('*').then(r => r.data),
  });
  // Same query the server just ran — round-tripped again from the user's network.

  if (isLoading) return <Spinner />;  // User sees a flash of loading.
  return <ProjectList projects={projects ?? []} />;
}
```

**Correct (server passes data, client uses it as initialData):**

```tsx
// page.tsx (server)
export default async function Page() {
  const client = getSupabaseServerClient();
  const { data: projects } = await client.from('projects').select('*');
  return <ProjectsClient initialProjects={projects ?? []} />;
}
```

```tsx
// projects-client.tsx
'use client';
import { useQuery } from '@tanstack/react-query';

export function ProjectsClient({ initialProjects }: { initialProjects: Project[] }) {
  // For static-after-mount data: just use the prop.
  return <ProjectList projects={initialProjects} />;
}
```

**Correct (initial render uses server data, then real-time / refetch takes over):**

```tsx
'use client';
import { useQuery } from '@tanstack/react-query';
import { useSupabase } from '@kit/supabase/hooks/use-supabase';

export function NotificationsClient({
  initialNotifications,
  accountIds,
}: {
  initialNotifications: Notification[];
  accountIds: string[];
}) {
  const client = useSupabase();

  const { data: notifications } = useQuery({
    queryKey: ['notifications', ...accountIds],
    queryFn: async () => {
      const { data } = await client
        .from('notifications')
        .select('*')
        .in('account_id', accountIds)
        .order('created_at', { ascending: false })
        .limit(10);
      return data ?? [];
    },
    initialData: initialNotifications,    // No loading on first render.
    refetchOnMount: false,                // Server already gave us fresh data.
    refetchOnWindowFocus: true,           // Refetch when user returns to tab.
  });

  // Real-time subscription updates the cache on new events.
  useNotificationsStream({
    accountIds,
    enabled: true,
    onNotifications: (newOnes) => {
      queryClient.setQueryData(['notifications', ...accountIds], (old: any) => [
        ...newOnes,
        ...(old ?? []),
      ]);
    },
  });

  return <NotificationList items={notifications ?? []} />;
}
```

**When this matters most:** above-the-fold data (the user sees a spinner if you refetch), workspace/account context that every component needs, lists that the user is about to interact with. The server already did the work — let it count.

**`refetchOnMount: false` is the typical pairing.** When `initialData` is provided, React Query considers it fresh by default (`staleTime: 0` reloads it on mount; bumping `staleTime` or setting `refetchOnMount: false` keeps the server-rendered data).

**Pass primitives or stable references.** Passing a new `useMemo` object every render makes the query key unstable. For lists, pass the array; React Query handles equality.

**Server data is the source of truth for the first render.** Updates after that come from mutations + revalidation, or real-time subscriptions, or refocus refetches — but not from "let's re-ask for the same data the page already had."

Reference: [TanStack Query initialData](https://tanstack.com/query/latest/docs/framework/react/guides/initial-query-data)
