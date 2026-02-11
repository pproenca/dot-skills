---
title: Eliminate Sequential Data Fetch Waterfalls
impact: HIGH
impactDescription: 2-5x faster page loads by parallelizing requests
tags: fetch, waterfalls, parallel, network, latency
---

## Eliminate Sequential Data Fetch Waterfalls

When a parent component fetches data and then renders children that start their own fetches, each request waits for the previous one to complete. Three sequential 200ms requests take 600ms total. Parallelizing them reduces total latency to the duration of the slowest single request.

**Incorrect (sequential fetch waterfall — 3 round trips):**

```tsx
function ProjectDashboard({ projectId }: { projectId: string }) {
  const { data: project } = useQuery({
    queryKey: ["project", projectId],
    queryFn: () => fetchProject(projectId),
  })

  if (!project) return <Skeleton />

  // waits for project to load before starting
  return (
    <div>
      <ProjectHeader project={project} />
      <ProjectMembers projectId={projectId} />
      <ProjectActivity projectId={projectId} />
    </div>
  )
}

function ProjectMembers({ projectId }: { projectId: string }) {
  const { data: members } = useQuery({
    queryKey: ["members", projectId],
    queryFn: () => fetchMembers(projectId), // starts after parent renders
  })

  if (!members) return <Skeleton />
  return <MemberList members={members} />
}

function ProjectActivity({ projectId }: { projectId: string }) {
  const { data: activity } = useQuery({
    queryKey: ["activity", projectId],
    queryFn: () => fetchActivity(projectId), // starts after parent renders
  })

  if (!activity) return <Skeleton />
  return <ActivityFeed activity={activity} />
}
```

**Correct (parallel fetching — all requests start simultaneously):**

```tsx
function ProjectDashboard({ projectId }: { projectId: string }) {
  const projectQuery = useQuery({
    queryKey: ["project", projectId],
    queryFn: () => fetchProject(projectId),
  })

  const membersQuery = useQuery({
    queryKey: ["members", projectId],
    queryFn: () => fetchMembers(projectId), // starts immediately, no dependency
  })

  const activityQuery = useQuery({
    queryKey: ["activity", projectId],
    queryFn: () => fetchActivity(projectId), // starts immediately, no dependency
  })

  if (projectQuery.isPending) return <Skeleton />

  return (
    <div>
      <ProjectHeader project={projectQuery.data} />
      {membersQuery.data ? <MemberList members={membersQuery.data} /> : <Skeleton />}
      {activityQuery.data ? <ActivityFeed activity={activityQuery.data} /> : <Skeleton />}
    </div>
  )
}
```

Reference: [TanStack Query — Parallel Queries](https://tanstack.com/query/latest/docs/framework/react/guides/parallel-queries)
