---
title: Use Skeleton Components for Loading States
impact: MEDIUM-HIGH
impactDescription: reduces perceived load time and prevents layout shift
tags: data, skeleton, loading, ux, suspense
---

## Use Skeleton Components for Loading States

Use shadcn/ui Skeleton components to show content placeholders during data loading. This prevents layout shifts and reduces perceived load time.

**Incorrect (spinner or empty state):**

```tsx
function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading } = useQuery(["user", userId], fetchUser)

  if (isLoading) {
    return (
      <div className="flex justify-center p-8">
        <Loader2 className="h-8 w-8 animate-spin" />
        {/* Content jumps when data loads - layout shift */}
      </div>
    )
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-4">
          <Avatar className="h-16 w-16">
            <AvatarImage src={user.avatar} />
          </Avatar>
          <div>
            <CardTitle>{user.name}</CardTitle>
            <p className="text-muted-foreground">{user.email}</p>
          </div>
        </div>
      </CardHeader>
    </Card>
  )
}
```

**Correct (skeleton matching final layout):**

```tsx
import { Skeleton } from "@/components/ui/skeleton"

function UserProfileSkeleton() {
  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-4">
          <Skeleton className="h-16 w-16 rounded-full" />
          <div className="space-y-2">
            <Skeleton className="h-5 w-32" />
            <Skeleton className="h-4 w-48" />
          </div>
        </div>
      </CardHeader>
    </Card>
  )
}

function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading } = useQuery(["user", userId], fetchUser)

  if (isLoading) {
    return <UserProfileSkeleton />
    // Same dimensions as loaded content - no layout shift
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center gap-4">
          <Avatar className="h-16 w-16">
            <AvatarImage src={user.avatar} />
          </Avatar>
          <div>
            <CardTitle>{user.name}</CardTitle>
            <p className="text-muted-foreground">{user.email}</p>
          </div>
        </div>
      </CardHeader>
    </Card>
  )
}
```

**Skeleton best practices:**
- Match skeleton dimensions to final content exactly
- Use `animate-pulse` (default) for subtle loading indication
- Group related skeletons to show content hierarchy
- Create reusable skeleton components for repeated patterns

Reference: [shadcn/ui Skeleton](https://ui.shadcn.com/docs/components/skeleton)
