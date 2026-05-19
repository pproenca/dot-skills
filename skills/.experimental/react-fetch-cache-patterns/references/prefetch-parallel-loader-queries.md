---
title: Run Route Loader Queries in Parallel
impact: HIGH
impactDescription: reduces N sequential awaits to 1 round-trip
tags: prefetch, route-loader, parallel, tanstack-router, remix
---

## Run Route Loader Queries in Parallel

A loader that `await`s the user, then `await`s settings, then `await`s notifications is just a server-side waterfall — three round-trips, same as the client version. Loaders unlock real parallelism: fire all independent queries together and `await Promise.all` the dependencies. The loader is *the* place to do this because the route framework guarantees the loader completes before the component renders.

For dependent data (you need step A's result to compute step B's key), use `defer` to stream partial data without blocking the full render.

**Incorrect (sequential awaits inside the loader):**

```tsx
// TanStack Router
export const Route = createFileRoute('/dashboard')({
  loader: async ({ context: { queryClient } }) => {
    const user = await queryClient.ensureQueryData({
      queryKey: ['user'], queryFn: fetchUser
    });
    const settings = await queryClient.ensureQueryData({
      queryKey: ['settings'], queryFn: fetchSettings  // waits for user — but doesn't need it!
    });
    const notifs = await queryClient.ensureQueryData({
      queryKey: ['notifs'], queryFn: fetchNotifications
    });
    return { user, settings, notifs };
  },
});
// ~900ms before the route renders
```

**Correct (parallel via Promise.all):**

```tsx
export const Route = createFileRoute('/dashboard')({
  loader: async ({ context: { queryClient } }) => {
    const [user, settings, notifs] = await Promise.all([
      queryClient.ensureQueryData({ queryKey: ['user'], queryFn: fetchUser }),
      queryClient.ensureQueryData({ queryKey: ['settings'], queryFn: fetchSettings }),
      queryClient.ensureQueryData({ queryKey: ['notifs'], queryFn: fetchNotifications }),
    ]);
    return { user, settings, notifs };
  },
});
// ~300ms before the route renders
```

**Defer slow queries (don't block the route on a slow non-critical fetch):**

```tsx
// Remix-style defer / TanStack Router defer
export const Route = createFileRoute('/dashboard')({
  loader: async ({ context: { queryClient } }) => {
    // Fast critical data — await
    const user = await queryClient.ensureQueryData({ queryKey: ['user'], queryFn: fetchUser });
    // Slow non-critical data — defer (stream in after first paint)
    const activityPromise = queryClient.prefetchQuery({
      queryKey: ['activity'], queryFn: fetchActivity, // takes 2s
    });
    return { user, activityPromise }; // route renders with user; activity streams in
  },
});
```

**Pattern for dependent queries:**

```tsx
loader: async ({ context: { queryClient }, params }) => {
  // Critical: get the project (need its members list to fetch related users)
  const project = await queryClient.ensureQueryData({
    queryKey: ['project', params.id], queryFn: () => fetchProject(params.id),
  });

  // Now parallelize the dependent fetches
  const [members, tasks, activity] = await Promise.all([
    queryClient.ensureQueryData({
      queryKey: ['members', project.id],
      queryFn: () => fetchMembers(project.members),
    }),
    queryClient.ensureQueryData({
      queryKey: ['tasks', project.id], queryFn: () => fetchTasks(project.id),
    }),
    queryClient.ensureQueryData({
      queryKey: ['activity', project.id], queryFn: () => fetchActivity(project.id),
    }),
  ]);
  return { project, members, tasks, activity };
};
```

Reference: [TanStack Router — Parallel Routes](https://tanstack.com/router/latest/docs/framework/react/guide/data-loading)
