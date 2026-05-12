---
title: Use `loading.tsx` or `<Suspense>` With a Skeleton That Matches Final Layout
impact: HIGH
impactDescription: Skeleton screens that match final layout reduce perceived load time by 30-40% vs spinners (Facebook/Luke Wroblewski); generic spinners over server-rendered routes are an anti-pattern in App Router
tags: feed, loading-states, suspense, loading-tsx, skeleton, streaming
---

## Use `loading.tsx` or `<Suspense>` With a Skeleton That Matches Final Layout

Every route segment that fetches data has a `loading.tsx` that renders a skeleton matching the final layout's shape. For data fetched lower in the tree, wrap the slow component in `<Suspense>` with a tailored fallback so the rest of the page streams in immediately. Generic centered spinners are a fallback of last resort — they tell the user "something is happening" but nothing about what.

**Incorrect (whole-page spinner, no skeleton, no streaming):**

```tsx
// app/projects/[id]/page.tsx
'use client'
export default function ProjectPage({ params }: { params: { id: string } }) {
  const [project, setProject] = useState<Project | null>(null)
  useEffect(() => {
    fetch(`/api/projects/${params.id}`).then((r) => r.json()).then(setProject)
  }, [params.id])
  if (!project) return <Loader2 className="size-12 animate-spin mx-auto mt-32" />
  return <ProjectDetail project={project} />
}
```

**Correct (Server Component + loading.tsx + Suspense for nested slow data):**

```tsx
// app/projects/[id]/page.tsx — Server Component, awaits at the top
import { Suspense } from 'react'
import { getProject } from '@/lib/data'

export default async function ProjectPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const project = await getProject(id) // fast — main content
  return (
    <article>
      <ProjectHeader project={project} />
      <Suspense fallback={<ActivitySkeleton />}>
        <ProjectActivity projectId={id} /> {/* slow — streams in */}
      </Suspense>
    </article>
  )
}

// app/projects/[id]/loading.tsx — shape-matching skeleton, not a spinner
export default function Loading() {
  return (
    <article aria-busy="true" aria-label="Loading project">
      <header className="flex items-center gap-4 p-6">
        <div className="size-12 rounded-full bg-muted animate-pulse" />
        <div className="flex-1 space-y-2">
          <div className="h-5 w-48 rounded bg-muted animate-pulse" />
          <div className="h-4 w-32 rounded bg-muted animate-pulse" />
        </div>
      </header>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 p-6">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="h-32 rounded-md bg-muted animate-pulse" />
        ))}
      </div>
    </article>
  )
}

function ActivitySkeleton() {
  return (
    <div className="p-6 space-y-3" aria-label="Loading activity">
      {Array.from({ length: 5 }).map((_, i) => (
        <div key={i} className="h-12 rounded bg-muted animate-pulse" />
      ))}
    </div>
  )
}
```

**Suspense around any awaited Server Component you'd like to stream:**

```tsx
export default function Page() {
  return (
    <div className="grid grid-cols-2 gap-4">
      <Suspense fallback={<CardSkeleton />}>
        <SlowCardA /> {/* awaited inside the component */}
      </Suspense>
      <Suspense fallback={<CardSkeleton />}>
        <SlowCardB />
      </Suspense>
    </div>
  )
}
```

**Rule:**
- Every route segment that awaits data has a `loading.tsx` — Next.js auto-wraps the page in `<Suspense>`
- Skeletons match the shape of the final UI (cards, rows, headers) — not generic spinners
- Skeleton elements use `animate-pulse` and the `bg-muted` token (subtle, theme-aware)
- Add `aria-busy="true"` or `aria-label="Loading X"` on the skeleton container so screen readers announce loading
- Slow data nested below the page-level `loading.tsx` gets its own `<Suspense>` boundary

Reference: [Loading UI and Streaming — Next.js 16](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)
