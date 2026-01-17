---
title: Avoid N+1 Query Patterns
impact: HIGH
impactDescription: Prevents request count from scaling with data size; eliminates O(N) network calls
tags: query, n-plus-one, performance, batching
---

## Avoid N+1 Query Patterns

N+1 queries occur when you fetch a list and then individually fetch related data for each item. This creates N+1 requests instead of 2, causing performance to degrade with data growth.

**Incorrect (N+1 pattern):**

```typescript
// 1 request for posts + N requests for authors = N+1 total
export async function PostList() {
  const posts = await getPosts();  // 1 request

  // N additional requests!
  const postsWithAuthors = await Promise.all(
    posts.map(async (post) => ({
      ...post,
      author: await getUser(post.authorId),  // 1 request per post
    }))
  );

  return postsWithAuthors.map(post => <PostCard post={post} />);
}
```

**Correct (batched query):**

```typescript
// src/features/user/api/get-users-by-ids.ts
export async function getUsersByIds(ids: string[]) {
  return prisma.user.findMany({
    where: { id: { in: ids } },
  });
}

// 2 requests total regardless of post count
export async function PostList() {
  const posts = await getPosts();  // 1 request

  const authorIds = [...new Set(posts.map(p => p.authorId))];
  const authors = await getUsersByIds(authorIds);  // 1 request
  const authorsById = new Map(authors.map(a => [a.id, a]));

  const postsWithAuthors = posts.map(post => ({
    ...post,
    author: authorsById.get(post.authorId),
  }));

  return postsWithAuthors.map(post => <PostCard post={post} />);
}
```

**Alternative: Lazy load where appropriate:**

```typescript
// If authors are rarely viewed, lazy load on demand
export function PostCard({ post }: { post: Post }) {
  const [showAuthor, setShowAuthor] = useState(false);

  return (
    <article>
      <h2>{post.title}</h2>
      <button onClick={() => setShowAuthor(true)}>Show Author</button>
      {showAuthor && <AuthorInfo userId={post.authorId} />}
    </article>
  );
}
```

**When to accept N+1:**
- N is always small (< 5 items)
- Data is heavily cached and cache hits are near 100%
- Lazy loading is appropriate (user rarely views related data)

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
