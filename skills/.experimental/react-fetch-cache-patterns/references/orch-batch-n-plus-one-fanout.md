---
title: Batch N+1 Fan-Out with DataLoader Pattern
impact: CRITICAL
impactDescription: reduces N requests to 1
tags: orch, batching, dataloader, n-plus-one, fanout
---

## Batch N+1 Fan-Out with DataLoader Pattern

When a list renders N cards and each card independently fetches `/users/:id`, you've created an N+1 storm — one request per card, each ~300ms, all hitting the backend in the same animation frame. Batch them: collect IDs requested within a microtask tick and fire one `/users?ids=...` request. The DataLoader pattern (from Facebook's Relay infrastructure) is the standard implementation.

**Incorrect (N+1 fan-out, every card fetches independently):**

```tsx
function CommentList({ comments }: { comments: Comment[] }) {
  return comments.map(c => <CommentRow key={c.id} comment={c} />);
}

function CommentRow({ comment }: { comment: Comment }) {
  // Each row fires GET /users/:id — 200 comments = 200 requests
  const { data: author } = useQuery({
    queryKey: ['user', comment.authorId],
    queryFn: () => fetchUser(comment.authorId),
  });
  return <div>{author?.name}: {comment.text}</div>;
}
```

**Correct (DataLoader batches per-tick into one bulk call):**

```tsx
import DataLoader from 'dataloader';

const userLoader = new DataLoader<string, User>(async (ids) => {
  // All IDs requested in this tick arrive together
  const users = await fetchUsersBulk([...ids]); // GET /users?ids=a,b,c
  const byId = new Map(users.map(u => [u.id, u]));
  return ids.map(id => byId.get(id) ?? new Error(`user ${id} not found`));
});

function CommentRow({ comment }: { comment: Comment }) {
  const { data: author } = useQuery({
    queryKey: ['user', comment.authorId],
    queryFn: () => userLoader.load(comment.authorId), // batched
  });
  return <div>{author?.name}: {comment.text}</div>;
}
```

**Alternative (normalized cache fed by a single bulk fetch):**

Fetch `users` once at the parent and read by ID from a normalized cache (see [[cache-normalize-shared-entities]]).

**Benefits:**
- 200 requests → 1 request
- Backend can index-scan once instead of paginate-by-key 200 times
- Same wall-clock latency as a single call

Reference: [graphql/dataloader](https://github.com/graphql/dataloader)
