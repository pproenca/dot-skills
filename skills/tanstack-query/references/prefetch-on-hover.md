---
title: Prefetch on Hover for Perceived Speed
impact: HIGH
impactDescription: 200-400ms head start before navigation
tags: prefetch, hover, intent, perceived-performance
---

## Prefetch on Hover for Perceived Speed

Users hover before clicking—use this 200-400ms window to prefetch data. The next page loads instantly from cache.

**Without prefetch:**

```typescript
function ProjectLink({ projectId }: { projectId: string }) {
  return (
    <Link href={`/projects/${projectId}`}>
      View Project
    </Link>
  )
  // User clicks → navigate → fetch starts → loading spinner → content
}
```

**With hover prefetch:**

```typescript
function ProjectLink({ projectId }: { projectId: string }) {
  const queryClient = useQueryClient()

  const prefetch = () => {
    queryClient.prefetchQuery({
      queryKey: ['project', projectId],
      queryFn: () => fetchProject(projectId),
      staleTime: 60_000, // Don't refetch if we have recent data
    })
  }

  return (
    <Link
      href={`/projects/${projectId}`}
      onMouseEnter={prefetch}
      onFocus={prefetch} // Keyboard accessibility
    >
      View Project
    </Link>
  )
  // User hovers → prefetch starts → user clicks → instant content
}
```

**Prefetch multiple related queries:**

```typescript
const prefetch = () => {
  queryClient.prefetchQuery(projectQueries.detail(projectId))
  queryClient.prefetchQuery(projectQueries.members(projectId))
  queryClient.prefetchQuery(projectQueries.activity(projectId))
}
```

**With queryOptions for type safety:**

```typescript
const projectQueries = {
  detail: (id: string) =>
    queryOptions({
      queryKey: ['project', id],
      queryFn: () => fetchProject(id),
      staleTime: 60_000,
    }),
}

function ProjectLink({ projectId }: { projectId: string }) {
  const queryClient = useQueryClient()

  return (
    <Link
      href={`/projects/${projectId}`}
      onMouseEnter={() =>
        queryClient.prefetchQuery(projectQueries.detail(projectId))
      }
    >
      View Project
    </Link>
  )
}
```
