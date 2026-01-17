---
title: Enable Suspense Mode for Streaming UX
impact: MEDIUM-HIGH
impactDescription: enables React Suspense integration for better loading states
tags: oquery, react-query, suspense, streaming
---

## Enable Suspense Mode for Streaming UX

Enable suspense query generation when using React Suspense boundaries. This provides cleaner loading state management and enables streaming SSR.

**Incorrect (manual loading states):**

```typescript
function UserProfile({ userId }: { userId: string }) {
  const { data, isLoading, error } = useGetUser(userId);

  if (isLoading) return <Skeleton />;
  if (error) return <ErrorDisplay error={error} />;

  return <Profile user={data} />;  // data could still be undefined
}
```

**Correct (suspense mode):**

```typescript
// orval.config.ts
export default defineConfig({
  api: {
    output: {
      client: 'react-query',
      override: {
        query: {
          useSuspenseQuery: true,
        },
      },
    },
  },
});
```

**Clean component with Suspense:**
```typescript
import { Suspense } from 'react';
import { ErrorBoundary } from 'react-error-boundary';

// Parent component handles loading/error
function UserPage({ userId }: { userId: string }) {
  return (
    <ErrorBoundary fallback={<ErrorDisplay />}>
      <Suspense fallback={<Skeleton />}>
        <UserProfile userId={userId} />
      </Suspense>
    </ErrorBoundary>
  );
}

// Child component is simple - data is guaranteed
function UserProfile({ userId }: { userId: string }) {
  const { data } = useGetUserSuspense(userId);

  return <Profile user={data} />;  // data is never undefined
}
```

**Benefits:**
- `data` is always defined (no undefined checks)
- Loading states handled declaratively
- Works with React 18 streaming SSR
- Cleaner component code

**When NOT to use this pattern:**
- Need granular loading states within a component
- Can't use error boundaries
- Supporting React <18

Reference: [TanStack Suspense](https://tanstack.com/query/latest/docs/framework/react/guides/suspense)
