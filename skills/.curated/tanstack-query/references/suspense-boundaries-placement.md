---
title: Place Suspense Boundaries Strategically
impact: MEDIUM
impactDescription: controls loading granularity, prevents layout shift
tags: suspense, boundaries, loading, ux
---

## Place Suspense Boundaries Strategically

Suspense boundary placement determines loading granularity. Too high = entire page loading. Too low = many spinners. Place boundaries at meaningful content sections.

**Too high (entire page loads together):**

```typescript
function App() {
  return (
    <Suspense fallback={<FullPageSpinner />}>
      <Header />      {/* Fast static content waits for... */}
      <Sidebar />     {/* ...slow API call in... */}
      <MainContent /> {/* ...this component */}
      <Footer />
    </Suspense>
  )
}
// User sees blank page until slowest query completes
```

**Too low (spinner chaos):**

```typescript
function Dashboard() {
  return (
    <div>
      <Suspense fallback={<Spinner />}>
        <UserName />
      </Suspense>
      <Suspense fallback={<Spinner />}>
        <UserAvatar />
      </Suspense>
      <Suspense fallback={<Spinner />}>
        <UserStats />
      </Suspense>
      {/* Multiple spinners everywhere, jarring UX */}
    </div>
  )
}
```

**Correct (meaningful sections):**

```typescript
function Dashboard() {
  return (
    <div>
      {/* Static header loads immediately */}
      <Header />

      {/* User section loads together */}
      <ErrorBoundary fallback={<UserError />}>
        <Suspense fallback={<UserSkeleton />}>
          <UserSection />
        </Suspense>
      </ErrorBoundary>

      {/* Stats section loads independently */}
      <ErrorBoundary fallback={<StatsError />}>
        <Suspense fallback={<StatsSkeleton />}>
          <StatsSection />
        </Suspense>
      </ErrorBoundary>

      {/* Static footer loads immediately */}
      <Footer />
    </div>
  )
}
```

**Nested boundaries for progressive loading:**

```typescript
function ProjectPage() {
  return (
    <Suspense fallback={<ProjectSkeleton />}>
      <ProjectHeader /> {/* Loads first */}

      <Suspense fallback={<TasksSkeleton />}>
        <TasksList /> {/* Can load after header */}
      </Suspense>

      <Suspense fallback={<CommentsSkeleton />}>
        <Comments /> {/* Can load last */}
      </Suspense>
    </Suspense>
  )
}
```
