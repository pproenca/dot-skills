---
title: Use Skeleton for Loading States
impact: LOW-MEDIUM
impactDescription: improves perceived performance with instant visual feedback
tags: perf, skeleton, loading, ux, suspense
---

## Use Skeleton for Loading States

Use Skeleton components instead of spinners for content loading. Skeletons show the expected layout immediately, reducing perceived load time.

**Incorrect (generic spinner):**

```tsx
function UserProfile({ userId }) {
  const { data: user, isLoading } = useQuery(["user", userId], fetchUser)

  if (isLoading) {
    return (
      <div className="flex justify-center p-8">
        <Spinner />  {/* User has no idea what's loading */}
      </div>
    )
  }

  return (
    <Card>
      <CardHeader>
        <Avatar src={user.avatar} />
        <CardTitle>{user.name}</CardTitle>
      </CardHeader>
    </Card>
  )
}
```

**Correct (skeleton matching layout):**

```tsx
import { Skeleton } from "@/components/ui/skeleton"

function UserProfileSkeleton() {
  return (
    <Card>
      <CardHeader>
        <Skeleton className="h-12 w-12 rounded-full" />
        <Skeleton className="h-4 w-[200px]" />
      </CardHeader>
      <CardContent>
        <Skeleton className="h-4 w-[300px]" />
        <Skeleton className="h-4 w-[250px] mt-2" />
      </CardContent>
    </Card>
  )
}

function UserProfile({ userId }) {
  const { data: user, isLoading } = useQuery(["user", userId], fetchUser)

  if (isLoading) {
    return <UserProfileSkeleton />
  }

  return (
    <Card>
      <CardHeader>
        <Avatar src={user.avatar} />
        <CardTitle>{user.name}</CardTitle>
      </CardHeader>
      <CardContent>
        <p>{user.bio}</p>
        <p>{user.location}</p>
      </CardContent>
    </Card>
  )
}
```

**With Suspense:**

```tsx
<Suspense fallback={<UserProfileSkeleton />}>
  <UserProfile userId={userId} />
</Suspense>
```

Reference: [shadcn/ui Skeleton](https://ui.shadcn.com/docs/components/skeleton)
