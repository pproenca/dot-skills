---
title: Flatten API to Reduce Waterfalls
impact: CRITICAL
impactDescription: eliminates dependent query chains entirely
tags: prefetch, api-design, waterfalls, architecture
---

## Flatten API to Reduce Waterfalls

When queries depend on each other (`fetchUser` → `fetchUserProjects`), consider restructuring your API to combine them. This is often the best solution for unavoidable waterfalls.

**Incorrect (chained queries):**

```typescript
function UserProjects({ email }: { email: string }) {
  // First: get user by email to get their ID
  const { data: user } = useQuery({
    queryKey: ['user', email],
    queryFn: () => getUserByEmail(email),
  })

  // Second: get projects using user ID (depends on first)
  const { data: projects } = useQuery({
    queryKey: ['projects', user?.id],
    queryFn: () => getProjectsByUser(user!.id),
    enabled: !!user?.id, // Must wait for user
  })

  // Total time: getUserByEmail (100ms) + getProjectsByUser (100ms) = 200ms
}
```

**Correct (flattened API):**

```typescript
// API: GET /api/projects?userEmail=xxx
// Backend joins user + projects in one query

function UserProjects({ email }: { email: string }) {
  const { data: projects } = useQuery({
    queryKey: ['projects', { userEmail: email }],
    queryFn: () => getProjectsByUserEmail(email), // Single request!
  })

  // Total time: getProjectsByUserEmail (100ms) = 100ms
}
```

**When flattening isn't possible, move waterfall to server:**

```typescript
// Server Action or API route handles the chain
async function getProjectsForEmail(email: string) {
  const user = await getUserByEmail(email)
  const projects = await getProjectsByUser(user.id)
  return { user, projects }
}

// Client makes single request
function UserProjects({ email }: { email: string }) {
  const { data } = useQuery({
    queryKey: ['userProjects', email],
    queryFn: () => getProjectsForEmail(email),
  })
}
```

Server-to-server latency is typically 1-10ms vs 50-200ms for client-to-server.

Reference: [Request Waterfalls](https://tanstack.com/query/v5/docs/react/guides/request-waterfalls)
