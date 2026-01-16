---
title: Fetch at Server Component Level
impact: MEDIUM-HIGH
impactDescription: Eliminates client-server waterfalls; reduces bundle size by keeping fetch logic on server
tags: query, server-components, rsc, next.js
---

## Fetch at Server Component Level

In React Server Component architectures, fetch data in server components and pass to client components as props. This eliminates client-server waterfalls and keeps data fetching off the client bundle.

**Incorrect (client component fetching):**

```typescript
// src/features/post/components/PostPage.tsx
'use client';

export function PostPage({ postId }: { postId: string }) {
  const [post, setPost] = useState<Post | null>(null);

  useEffect(() => {
    fetch(`/api/posts/${postId}`)  // Client-server waterfall
      .then(res => res.json())
      .then(setPost);
  }, [postId]);

  if (!post) return <Loading />;
  return <PostContent post={post} />;
}
```

**Correct (server component fetching):**

```typescript
// src/features/post/components/PostPage.tsx (Server Component)
import { getPost } from '../api/get-post';
import { PostContent } from './PostContent';  // Client component

export async function PostPage({ postId }: { postId: string }) {
  const post = await getPost(postId);  // Fetches on server

  return <PostContent post={post} />;
}

// src/features/post/components/PostContent.tsx
'use client';

interface PostContentProps {
  post: Post;  // Receives data as props, no fetching
}

export function PostContent({ post }: PostContentProps) {
  const [likes, setLikes] = useState(post.likes);

  return (
    <article>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
      <LikeButton likes={likes} onLike={() => setLikes(l => l + 1)} />
    </article>
  );
}
```

**Composition pattern:**

```typescript
// src/app/posts/[id]/page.tsx (Server Component)
import { PostPage } from '@/features/post';
import { Comments } from '@/features/comment';

export default async function Page({ params }: { params: { id: string } }) {
  // Parallel fetch at app layer
  const [post, comments] = await Promise.all([
    getPost(params.id),
    getComments(params.id),
  ]);

  return (
    <>
      <PostPage post={post} />
      <Comments comments={comments} />
    </>
  );
}
```

Reference: [Next.js - Data Fetching](https://nextjs.org/docs/app/building-your-application/data-fetching)
