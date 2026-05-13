---
title: Every Server Action that mutates data must invalidate the routes/tags that surface it — the failure mode is silent staleness
impact: HIGH
impactDescription: invalidates the cached data the mutation just changed; without it, users see their own writes only after the next natural cache expiry
tags: cache, revalidate-path, mutation-invalidate, server-action-followup
---

## Every Server Action that mutates data must invalidate the routes/tags that surface it — the failure mode is silent staleness

**Pattern intent:** mutations and their cache invalidations form a transaction in the user's mental model. A Server Action that writes but doesn't invalidate the relevant cache leaves the user staring at their pre-write state with no error to debug. `revalidatePath` for whole routes; `revalidateTag` for granular slices.

### Shapes to recognize

- A `'use server'` action with `await db.x.create(...)` and no `revalidatePath`/`revalidateTag` call — the canonical anti-pattern.
- A bug report "data doesn't appear until I refresh twice" — almost always a missing invalidation call after the action.
- An action that calls `revalidatePath('/x')` but the data also appears on `/y` (e.g., a global sidebar count) — under-invalidation.
- An action that calls `revalidatePath('/', 'layout')` for any mutation — over-invalidation; nukes everyone's cache for a small change.
- A `redirect(...)` *before* `revalidatePath(...)` — `redirect` throws internally, so the invalidation never runs. Order matters.
- A custom "cache buster" approach (router.refresh() in the client after the action returns) — works for client-rendered subtrees but loses the server-driven invalidation guarantee.

The canonical resolution: call `revalidatePath(specificRoute)` or `revalidateTag(...)` after the mutation succeeds and *before* the `redirect()`. Prefer `revalidateTag` when multiple routes show the same data; `revalidatePath` is the coarser hammer.

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
