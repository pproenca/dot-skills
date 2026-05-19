---
title: Use select to Subscribe to a Subset of Cache Data
impact: CRITICAL
impactDescription: 5-20x reduction in re-render rate
tags: cache, select, subscription, re-renders, performance
---

## Use select to Subscribe to a Subset of Cache Data

A component subscribed to `useQuery({ queryKey: ['user', id] })` re-renders any time *any* field of the user object changes — even if it only displays `user.name`. In a feed where each row subscribes to a chunky user object, an unrelated update to `user.lastSeenAt` re-renders every row. `select` transforms the cache value and the component re-renders only when the *selected* slice changes.

Same pattern in Zustand, Redux's `useSelector`, Jotai's atoms. The principle: subscribe to the minimum slice you render.

**Incorrect (subscribe to whole user, re-render on any field change):**

```tsx
function CommentAvatar({ authorId }: { authorId: string }) {
  // Re-renders any time *anything* on the user changes — name, bio, lastSeenAt, isOnline...
  const { data: user } = useQuery({
    queryKey: ['user', authorId],
    queryFn: () => fetchUser(authorId),
  });
  return <Avatar src={user?.avatarUrl} />; // we only need avatarUrl!
}
```

**Correct (select narrows the subscription to the rendered field):**

```tsx
function CommentAvatar({ authorId }: { authorId: string }) {
  const { data: avatarUrl } = useQuery({
    queryKey: ['user', authorId],
    queryFn: () => fetchUser(authorId),
    select: user => user.avatarUrl, // re-render only when avatarUrl changes
  });
  return <Avatar src={avatarUrl} />;
}
```

**Multiple consumers of the same query, each selecting different fields:**

```tsx
function useUserAvatar(id: string) {
  return useQuery({ queryKey: ['user', id], queryFn: () => fetchUser(id), select: u => u.avatarUrl });
}
function useUserName(id: string) {
  return useQuery({ queryKey: ['user', id], queryFn: () => fetchUser(id), select: u => u.name });
}
// One fetch, two narrow subscriptions — name update doesn't re-render avatar consumers.
```

**Implementation note:** `select` must produce a stable reference for the same input. Returning `{ a, b }` on every call creates a new object each time and defeats memoization — return primitives, or wrap the projector in `useCallback` and produce equal results.

Reference: [TanStack Query — Render Optimizations](https://tanstack.com/query/latest/docs/framework/react/guides/render-optimizations)
