---
title: Use Server Actions for Form Submissions
impact: MEDIUM-HIGH
impactDescription: eliminates API routes, type-safe mutations
tags: action, server-action, form, mutation
---

## Use Server Actions for Form Submissions

Server Actions handle form submissions directly without creating API routes. They're type-safe, progressively enhanced, and integrate with caching.

**Incorrect (API route for form handling):**

```typescript
// app/api/posts/route.ts
export async function POST(request: Request) {
  const data = await request.json()
  const post = await db.posts.create({ data })
  return Response.json(post)
}

// app/posts/new/page.tsx
'use client'

export default function NewPostPage() {
  const handleSubmit = async (e) => {
    e.preventDefault()
    const formData = new FormData(e.target)
    await fetch('/api/posts', {
      method: 'POST',
      body: JSON.stringify(Object.fromEntries(formData))
    })
  }
  // Requires client component, manual fetch, no type safety
}
```

**Correct (Server Action):**

```typescript
// app/posts/new/page.tsx
import { redirect } from 'next/navigation'
import { revalidatePath } from 'next/cache'

export default function NewPostPage() {
  async function createPost(formData: FormData) {
    'use server'

    const title = formData.get('title') as string
    const content = formData.get('content') as string

    const post = await db.posts.create({
      data: { title, content }
    })

    revalidatePath('/posts')
    redirect(`/posts/${post.id}`)
  }

  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" />
      <button type="submit">Create Post</button>
    </form>
  )
}
// Works without JS, type-safe, integrated caching
```

**Benefits:**
- Progressive enhancement (works without JavaScript)
- Type-safe with TypeScript
- Direct cache invalidation
- No API route boilerplate
