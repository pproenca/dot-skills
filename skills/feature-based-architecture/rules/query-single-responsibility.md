---
title: Keep Query Functions Single-Purpose
impact: HIGH
impactDescription: Prevents query permutation explosion as features grow
tags: query, single-responsibility, data-fetching, api
---

## Keep Query Functions Single-Purpose

Each query function should fetch one type of data. Avoid creating variations that combine multiple concerns. When features need combined data, fetch separately and compose at the component level.

**Incorrect (query permutations):**

```typescript
// src/features/post/api/queries.ts

// Creates combinatorial explosion as requirements grow
export async function getPost(id: string) { ... }
export async function getPostWithComments(id: string) { ... }
export async function getPostWithAuthor(id: string) { ... }
export async function getPostWithCommentsAndAuthor(id: string) { ... }
export async function getPostWithCommentsAndAuthorAndLikes(id: string) { ... }
// N relations = 2^N possible combinations
```

**Correct (single-purpose queries):**

```typescript
// src/features/post/api/get-post.ts
export async function getPost(id: string) {
  return prisma.post.findUnique({ where: { id } });
}

// src/features/comment/api/get-comments.ts
export async function getComments(postId: string) {
  return prisma.comment.findMany({ where: { postId } });
}

// src/features/user/api/get-user.ts
export async function getUser(id: string) {
  return prisma.user.findUnique({ where: { id } });
}

// Component composes what it needs
export async function PostPage({ postId }: { postId: string }) {
  const [post, comments] = await Promise.all([
    getPost(postId),
    getComments(postId),
  ]);

  return (
    <article>
      <PostContent post={post} />
      <CommentList comments={comments} />
    </article>
  );
}
```

**Benefits:**
- Linear growth: N relations = N query functions
- Each query is independently cacheable
- Parallel fetching via Promise.all()
- Each feature owns its own data fetching

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
