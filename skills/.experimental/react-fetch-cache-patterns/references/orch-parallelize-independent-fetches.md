---
title: Parallelize Independent Fetches
impact: CRITICAL
impactDescription: eliminates N-1 sequential round-trips
tags: orch, parallel, promise-all, waterfalls, network
---

## Parallelize Independent Fetches

Two `await` statements in a row are serialized — the second request can't start until the first response arrives. If neither depends on the other, you've paid for two round-trips when you could pay for one. In a page that loads user, settings, and notifications this turns a 300ms page into a 900ms page for no reason.

**Incorrect (sequential awaits, three round-trips):**

```tsx
async function loadDashboard(userId: string) {
  const user = await fetchUser(userId);            // wait 300ms
  const settings = await fetchSettings(userId);    // wait another 300ms (independent of user)
  const notifications = await fetchNotifications(userId); // wait another 300ms
  return { user, settings, notifications };        // total: ~900ms
}
```

**Correct (parallel, one round-trip time):**

```tsx
async function loadDashboard(userId: string) {
  const [user, settings, notifications] = await Promise.all([
    fetchUser(userId),
    fetchSettings(userId),
    fetchNotifications(userId),
  ]); // total: ~300ms — bound by the slowest call
  return { user, settings, notifications };
}
```

**With TanStack Query (parallel queries declare independence):**

```tsx
function Dashboard({ userId }: { userId: string }) {
  const user = useQuery({ queryKey: ['user', userId], queryFn: () => fetchUser(userId) });
  const settings = useQuery({ queryKey: ['settings', userId], queryFn: () => fetchSettings(userId) });
  const notifs = useQuery({ queryKey: ['notifs', userId], queryFn: () => fetchNotifications(userId) });
  // All three fire on mount in parallel — no orchestration code needed
}
```

**When NOT to parallelize:** when the second request genuinely depends on the first's result (e.g. fetching items by IDs returned from a search). Use `Promise.all` only on independent calls.

Reference: [MDN — Promise.all](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all)
