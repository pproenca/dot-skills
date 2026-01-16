---
title: Use Server Actions for Mutations
impact: LOW-MEDIUM
impactDescription: Progressive enhancement - forms work without JavaScript; eliminates API route boilerplate and reduces client bundle
tags: advanced, server-actions, mutations, forms
---

## Use Server Actions for Mutations

Server Actions are async functions that run on the server, callable from Client Components or forms. They eliminate the need for API routes for mutations and provide progressive enhancement (forms work without JS).

**Incorrect (client-side fetch to API route):**

```typescript
// app/api/posts/route.ts - ❌ Extra file
export async function POST(request: Request) {
  const data = await request.json()
  const post = await db.posts.create(data)
  return Response.json(post)
}
```

```typescript
// components/CreatePost.tsx - ❌ Requires client JS
'use client'

import { useState } from 'react'

export default function CreatePost() {
  const [title, setTitle] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    await fetch('/api/posts', {
      method: 'POST',
      body: JSON.stringify({ title }),
    })
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={title} onChange={e => setTitle(e.target.value)} />
      <button type="submit">Create</button>
    </form>
  )
}
```

**Correct (Server Action):**

```typescript
// actions/posts.ts
'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string

  // Validate
  if (!title || title.length < 3) {
    return { error: 'Title must be at least 3 characters' }
  }

  // Create post
  const post = await db.posts.create({ title })

  // Revalidate and redirect
  revalidatePath('/posts')
  redirect(`/posts/${post.id}`)
}
```

```typescript
// components/CreatePost.tsx - Works without JS!
import { createPost } from '@/actions/posts'

export default function CreatePost() {
  return (
    <form action={createPost}>
      <input name="title" required minLength={3} />
      <button type="submit">Create</button>
    </form>
  )
}
// Form works even if JS fails to load (progressive enhancement)
```

**With pending state (useActionState):**

```typescript
'use client'

import { useActionState } from 'react'
import { createPost } from '@/actions/posts'

export default function CreatePost() {
  const [state, action, pending] = useActionState(createPost, null)

  return (
    <form action={action}>
      <input name="title" disabled={pending} />
      <button type="submit" disabled={pending}>
        {pending ? 'Creating...' : 'Create'}
      </button>
      {state?.error && <p className="error">{state.error}</p>}
    </form>
  )
}
```

**Optimistic updates (useOptimistic):**

```typescript
'use client'

import { useOptimistic } from 'react'
import { likePost } from '@/actions/posts'

export default function LikeButton({ postId, likes }: { postId: string; likes: number }) {
  const [optimisticLikes, addOptimisticLike] = useOptimistic(
    likes,
    (current) => current + 1
  )

  async function handleLike() {
    addOptimisticLike(null)  // Immediately show +1
    await likePost(postId)   // Server action
  }

  return (
    <form action={handleLike}>
      <button type="submit">{optimisticLikes} likes</button>
    </form>
  )
}
```

**When NOT to use Server Actions:**
- GET requests (use Server Components)
- WebSocket/real-time communication
- Third-party API calls from client

Reference: [Next.js Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
