---
title: Avoid useEffect Fetch Chains
impact: CRITICAL
impactDescription: prevents render-fetch-render-fetch waterfalls
tags: orch, useeffect, waterfalls, dependencies
---

## Avoid useEffect Fetch Chains

A common anti-pattern: `useEffect` fetches A; once A arrives, a *second* `useEffect` watches A and fetches B; a third watches B and fetches C. Each fetch waits for the previous render commit, so C only starts ~600ms after page entry even though all three could have run concurrently with the right key construction.

If you can compute B's key from props (not from A's response), B doesn't depend on A — start them together. Effect chains are only correct when there is a genuine data dependency.

**Incorrect (three-stage waterfall through effect chain):**

```tsx
function UserFeed({ userId }: { userId: string }) {
  const [user, setUser] = useState<User>();
  const [posts, setPosts] = useState<Post[]>();
  const [comments, setComments] = useState<Comment[]>();

  useEffect(() => { fetchUser(userId).then(setUser); }, [userId]);
  useEffect(() => { if (user) fetchPosts(user.id).then(setPosts); }, [user]);    // waits for user
  useEffect(() => { if (posts) fetchCommentsFor(posts.map(p => p.id)).then(setComments); }, [posts]); // waits for posts

  // user.id === userId — fetchPosts didn't actually need user, it needed userId!
  // Three sequential round-trips for what should be two.
}
```

**Correct (flatten the dependency graph — only true dependencies wait):**

```tsx
function UserFeed({ userId }: { userId: string }) {
  // user and posts both keyed on userId — they're independent
  const user = useQuery({ queryKey: ['user', userId], queryFn: () => fetchUser(userId) });
  const posts = useQuery({ queryKey: ['posts', userId], queryFn: () => fetchPosts(userId) });

  // comments genuinely depends on posts — keep that sequential
  const comments = useQuery({
    queryKey: ['comments', posts.data?.map(p => p.id)],
    queryFn: () => fetchCommentsFor(posts.data!.map(p => p.id)),
    enabled: !!posts.data,
  });
}
```

**The test for "is this really a dependency":** can the key for the next fetch be computed from props alone? If yes, it's not a dependency — flatten it.

Reference: [React — You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
