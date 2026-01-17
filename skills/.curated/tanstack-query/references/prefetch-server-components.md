---
title: Prefetch in Server Components
impact: HIGH
impactDescription: eliminates client-side waterfall, immediate data
tags: prefetch, server-components, ssr, next.js
---

## Prefetch in Server Components

In Next.js App Router, prefetch data in Server Components and pass the hydrated state to the client. This eliminates the client-side fetch waterfall entirely.

**Incorrect (client-side fetch after hydration):**

```typescript
// app/projects/[id]/page.tsx
'use client'

export default function ProjectPage({ params }: { params: { id: string } }) {
  const { data, isPending } = useQuery({
    queryKey: ['project', params.id],
    queryFn: () => fetchProject(params.id),
  })

  if (isPending) return <Skeleton /> // User sees loading spinner
  return <ProjectDetails project={data} />
}
```

**Correct (prefetch in Server Component):**

```typescript
// app/projects/[id]/page.tsx
import { dehydrate, HydrationBoundary, QueryClient } from '@tanstack/react-query'

export default async function ProjectPage({ params }: { params: { id: string } }) {
  const queryClient = new QueryClient()

  await queryClient.prefetchQuery({
    queryKey: ['project', params.id],
    queryFn: () => fetchProject(params.id),
  })

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <ProjectDetails projectId={params.id} />
    </HydrationBoundary>
  )
}

// components/ProjectDetails.tsx
'use client'

export function ProjectDetails({ projectId }: { projectId: string }) {
  const { data } = useQuery({
    queryKey: ['project', projectId],
    queryFn: () => fetchProject(projectId),
  })

  // Data is immediately available from hydrated cache!
  return <div>{data.name}</div>
}
```

**Prefetch multiple queries:**

```typescript
export default async function ProjectPage({ params }: { params: { id: string } }) {
  const queryClient = new QueryClient()

  // Parallel prefetching
  await Promise.all([
    queryClient.prefetchQuery(projectQueries.detail(params.id)),
    queryClient.prefetchQuery(projectQueries.members(params.id)),
    queryClient.prefetchQuery(projectQueries.tasks(params.id)),
  ])

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <ProjectDetails projectId={params.id} />
    </HydrationBoundary>
  )
}
```
