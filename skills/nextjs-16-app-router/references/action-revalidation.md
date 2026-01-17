---
title: Revalidate Cache After Mutations
impact: MEDIUM
impactDescription: ensures fresh data after changes
tags: action, revalidation, cache, mutation
---

## Revalidate Cache After Mutations

Always invalidate relevant cached data after mutations. Use `revalidatePath` for routes and `revalidateTag` for tagged data.

**Incorrect (stale cache after mutation):**

```typescript
'use server'

export async function deletePost(postId: string) {
  await db.posts.delete({ where: { id: postId } })
  redirect('/posts')
  // Posts list still shows deleted post from cache!
}
```

**Correct (invalidating cache):**

```typescript
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'
import { redirect } from 'next/navigation'

export async function deletePost(postId: string) {
  await db.posts.delete({ where: { id: postId } })

  // Option 1: Revalidate specific path
  revalidatePath('/posts')

  // Option 2: Revalidate by tag (more granular)
  revalidateTag('posts')

  redirect('/posts')
}

export async function updatePost(postId: string, formData: FormData) {
  await db.posts.update({
    where: { id: postId },
    data: { title: formData.get('title') }
  })

  // Revalidate both the list and detail pages
  revalidatePath('/posts')
  revalidatePath(`/posts/${postId}`)
}
```

**Revalidation strategies:**

```typescript
// Specific route
revalidatePath('/posts')

// Dynamic route with specific ID
revalidatePath(`/posts/${postId}`)

// All routes using a layout
revalidatePath('/dashboard', 'layout')

// By cache tag
revalidateTag('posts')

// Multiple tags
revalidateTag('posts')
revalidateTag(`post-${postId}`)
```
