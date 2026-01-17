---
title: Use revalidatePath for Route-Level Cache Invalidation
impact: HIGH
impactDescription: invalidates all cached data for a route
tags: cache, revalidate-path, invalidation, server-actions
---

## Use revalidatePath for Route-Level Cache Invalidation

Use `revalidatePath` to invalidate all cached data associated with a specific route. Prefer `revalidateTag` for granular control.

**Incorrect (forgetting to revalidate after mutation):**

```typescript
'use server'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  const content = formData.get('content') as string

  await db.posts.create({ data: { title, content } })

  // User doesn't see new post until cache expires!
}
```

**Correct (revalidating after mutation):**

```typescript
'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  const content = formData.get('content') as string

  const post = await db.posts.create({ data: { title, content } })

  revalidatePath('/posts')  // Invalidate posts list
  redirect(`/posts/${post.id}`)  // Navigate to new post
}
```

**Path patterns:**

```typescript
// Specific route
revalidatePath('/posts')

// Dynamic route
revalidatePath('/posts/[slug]', 'page')

// Layout and all child routes
revalidatePath('/dashboard', 'layout')

// Entire app (use sparingly)
revalidatePath('/', 'layout')
```

**Note:** `redirect` must be called after `revalidatePath` as it throws internally.
