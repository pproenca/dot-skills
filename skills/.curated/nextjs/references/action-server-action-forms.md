---
title: Mutations from forms run through Server Actions — not custom API routes + client `fetch`
impact: MEDIUM-HIGH
impactDescription: removes the API-route + JSON.stringify + manual fetch ceremony; mutations become type-safe, progressively enhanced, and integrate with cache invalidation
tags: action, server-action, form-action, no-api-route-mutation
---

## Mutations from forms run through Server Actions — not custom API routes + client `fetch`

**Pattern intent:** in App Router, form-driven mutations belong in a Server Action bound to `<form action={...}>`. The old "POST to `/api/x`, parse JSON, manually invalidate cache" pattern is now boilerplate that delivers a worse UX (requires JS to submit).

### Shapes to recognize

- A `'use client'` page with `onSubmit={async (e) => { e.preventDefault(); fetch('/api/...', {...}) }}` — the classic anti-pattern.
- A `route.ts` POST handler that exists only to receive form submissions from one specific page — should be a Server Action.
- A custom hook (`useCreatePost`) that wraps `fetch` and `useState` to track submission — Server Action + `useActionState` does this declaratively.
- A page that mutates state via fetch, then manually calls `router.refresh()` to reload data — the action should call `revalidatePath` server-side instead.
- A workaround using TanStack Query / SWR mutations against a route handler — fine for some cases, but for *form-shaped* mutations the Server Action path is simpler and progressively enhanced.

The canonical resolution: declare `async function createX(formData: FormData) { 'use server'; ... }`. Bind via `<form action={createX}>`. Call `revalidatePath`/`revalidateTag` then `redirect` server-side.

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

---

### In disguise — route handler POST + client `fetch` doing the work of a Server Action

The grep-friendly anti-pattern is `onSubmit={(e) => { e.preventDefault(); fetch('/api/...') }}`. The disguise is more sophisticated: a `route.ts` POST handler that *exists only to receive form submissions*, paired with a Client Component that POSTs to it. This is "the Pages Router pattern, ported into App Router" and looks reasonable until you compare it to the Server Action equivalent.

**Incorrect — in disguise (route handler + client POST + manual revalidation):**

```typescript
// app/api/posts/route.ts
import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  const data = await request.json()
  const post = await db.posts.create({ data })
  // No cache invalidation here — the client has to trigger router.refresh() afterward
  return NextResponse.json(post)
}

// app/posts/new/page.tsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'

export default function NewPostPage() {
  const [submitting, setSubmitting] = useState(false)
  const router = useRouter()

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setSubmitting(true)
    const formData = new FormData(e.currentTarget)
    const res = await fetch('/api/posts', {
      method: 'POST',
      body: JSON.stringify({
        title: formData.get('title'),
        content: formData.get('content'),
      }),
      headers: { 'Content-Type': 'application/json' },
    })
    const post = await res.json()
    router.refresh() // hope this picks up the new post somehow
    router.push(`/posts/${post.id}`)
  }

  return (
    <form onSubmit={onSubmit}>
      <input name="title" required />
      <textarea name="content" />
      <button disabled={submitting}>{submitting ? 'Creating...' : 'Create'}</button>
    </form>
  )
}
```

What's wrong: not progressively enhanced (form fails without JS); manual `JSON.stringify` instead of `FormData`; manual submission state; client-driven `router.refresh()` instead of server-driven `revalidateTag`; doubled type definitions (request body type + DB schema type) that drift.

**Correct — Server Action handles everything in one path:**

```typescript
// app/posts/new/page.tsx (Server Component shell)
import { redirect } from 'next/navigation'
import { revalidateTag } from 'next/cache'

async function createPost(formData: FormData) {
  'use server'
  const title = formData.get('title') as string
  const content = formData.get('content') as string
  const post = await db.posts.create({ data: { title, content } })
  revalidateTag('posts', 'max')
  redirect(`/posts/${post.id}`)
}

export default function NewPostPage() {
  return (
    <form action={createPost}>
      <input name="title" required />
      <textarea name="content" />
      <SubmitButton />
    </form>
  )
}

// SubmitButton.tsx — small client island
'use client'
import { useFormStatus } from 'react-dom'
export function SubmitButton() {
  const { pending } = useFormStatus()
  return <button disabled={pending}>{pending ? 'Creating...' : 'Create'}</button>
}
```

Half the code, type-safe end-to-end, progressively enhanced, cache invalidation happens server-side. The route handler can be deleted (or kept only if external consumers need it).
