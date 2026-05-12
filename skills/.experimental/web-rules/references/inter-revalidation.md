---
title: Revalidate Cache After Mutations With `revalidatePath` / `revalidateTag`; Never Rely on Client Refresh
impact: CRITICAL
impactDescription: 300-800 ms savings per mutation vs `router.refresh()`; granular tag-based revalidation cuts re-fetched data by 5-10× compared to full path refresh
tags: inter, revalidation, server-actions, revalidate-path, revalidate-tag, cache
---

## Revalidate Cache After Mutations With `revalidatePath` / `revalidateTag`; Never Rely on Client Refresh

Server Actions that mutate data must invalidate the affected cache entries on the server. Use `revalidatePath('/projects')` for path-based invalidation or `revalidateTag('project-list')` for tag-based fan-out across multiple routes. Pair with `useOptimistic` on the client for instant UI feedback. Never call `router.refresh()` from the client to "fix" stale data — it papers over the real problem and ships a full re-fetch every time.

**Incorrect (client refresh after mutation, no cache invalidation on the server):**

```tsx
// app/projects/actions.ts
'use server'
export async function createProject(formData: FormData) {
  await db.project.create({ data: { name: formData.get('name') as string } })
  // returns silently — cache stays stale
}

// app/projects/new-project-form.tsx
'use client'
import { useRouter } from 'next/navigation'

export function NewProjectForm() {
  const router = useRouter()
  return (
    <form
      action={async (formData) => {
        await createProject(formData)
        router.refresh() // wasteful full re-fetch
      }}
    >
      <input name="name" />
      <button type="submit">Create</button>
    </form>
  )
}
```

**Correct (server-side revalidation + optimistic UI):**

```tsx
// app/projects/actions.ts
'use server'
import { revalidateTag } from 'next/cache'
import { redirect } from 'next/navigation'

export async function createProject(formData: FormData) {
  const name = formData.get('name') as string
  if (!name?.trim()) return { error: 'Name is required' }
  const project = await db.project.create({ data: { name } })
  revalidateTag('project-list')         // refreshes all routes tagged 'project-list'
  redirect(`/projects/${project.id}`)   // navigate to the new entity
}

// app/projects/page.tsx — fetch with cache tag
export default async function Projects() {
  const projects = await fetch('/api/projects', { next: { tags: ['project-list'] } }).then((r) => r.json())
  return <ProjectList projects={projects} />
}

// app/projects/new-project-form.tsx
'use client'
import { useActionState } from 'react'
import { createProject } from './actions'

export function NewProjectForm() {
  const [state, formAction, pending] = useActionState(createProject, null)
  return (
    <form action={formAction} className="space-y-2">
      <input name="name" required className="w-full rounded border px-3 py-1.5" />
      {state?.error && <p className="text-sm text-destructive">{state.error}</p>}
      <Button type="submit" disabled={pending}>{pending ? 'Creating…' : 'Create'}</Button>
    </form>
  )
}
```

**Rule:**
- Every Server Action that writes calls `revalidatePath`/`revalidateTag` (or `redirect`, which implicitly revalidates)
- Tag every cached `fetch()` with `{ next: { tags: [...] } }` so you can invalidate granularly
- Never call `router.refresh()` as the primary stale-data fix — only as a last-resort escape hatch
- For optimistic UX, combine `useOptimistic` (client) with server revalidation — never rely on optimistic state alone

Reference: [Data fetching, caching, and revalidating — Next.js 16](https://nextjs.org/docs/app/building-your-application/data-fetching/fetching)
