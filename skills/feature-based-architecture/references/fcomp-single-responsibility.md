---
title: Apply Single Responsibility to Components
impact: MEDIUM-HIGH
impactDescription: Enables parallel development and isolated testing; reduces component complexity
tags: comp, single-responsibility, separation, focused
---

## Apply Single Responsibility to Components

Each component should do one thing well. When a component handles multiple concerns (rendering, data fetching, business logic), it becomes hard to test, reuse, and maintain. Split into focused components.

**Incorrect (multiple responsibilities):**

```typescript
// src/features/post/components/Post.tsx
export function Post({ postId }: { postId: string }) {
  // Data fetching
  const [post, setPost] = useState<Post | null>(null);
  const [comments, setComments] = useState<Comment[]>([]);

  useEffect(() => {
    fetchPost(postId).then(setPost);
    fetchComments(postId).then(setComments);
  }, [postId]);

  // Business logic
  const handleLike = async () => { ... };
  const handleComment = async () => { ... };

  // Rendering post AND comments AND forms
  return (
    <div>
      <h1>{post?.title}</h1>
      <p>{post?.content}</p>
      <button onClick={handleLike}>Like</button>
      <ul>
        {comments.map(c => <li key={c.id}>{c.text}</li>)}
      </ul>
      <CommentForm onSubmit={handleComment} />
    </div>
  );
}
```

**Correct (single responsibility each):**

```typescript
// src/features/post/components/PostContent.tsx
interface PostContentProps {
  post: Post;
  onLike: () => void;
}

export function PostContent({ post, onLike }: PostContentProps) {
  return (
    <article>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
      <LikeButton count={post.likes} onClick={onLike} />
    </article>
  );
}

// src/features/comment/components/CommentList.tsx
interface CommentListProps {
  comments: Comment[];
}

export function CommentList({ comments }: CommentListProps) {
  return (
    <ul>
      {comments.map(c => <CommentItem key={c.id} comment={c} />)}
    </ul>
  );
}

// src/app/posts/[id]/page.tsx (composition at app layer)
export async function PostPage({ postId }: { postId: string }) {
  const [post, comments] = await Promise.all([
    getPost(postId),
    getComments(postId),
  ]);

  return (
    <>
      <PostContent post={post} onLike={() => likePost(postId)} />
      <CommentList comments={comments} />
      <CommentForm postId={postId} />
    </>
  );
}
```

**Benefits:**
- PostContent can be tested without comments
- CommentList can be reused elsewhere
- Each component is ~20-50 lines, easy to understand

Reference: [Robin Wieruch - React Feature Architecture](https://www.robinwieruch.de/react-feature-architecture/)
