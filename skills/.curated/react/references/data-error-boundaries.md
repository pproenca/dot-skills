---
title: Each Suspense boundary needs an Error Boundary wrapping it — failures must be containable
impact: MEDIUM
impactDescription: isolates async-component failures to their own region, prevents one bad fetch from taking down the whole page
tags: data, error-isolation, suspense-pair, error-boundary
---

## Each Suspense boundary needs an Error Boundary wrapping it — failures must be containable

**Pattern intent:** the same boundary structure that controls *loading* should control *error* — every async subtree is loadable, suspendable, and failable as one unit. A Suspense boundary without an Error Boundary leaves "what if this throws" to bubble up and crash the whole tree.

### Shapes to recognize

- A `<Suspense fallback={...}>` with no enclosing `<ErrorBoundary>` — any async failure unwinds past it.
- A `try/catch` inside an async Server Component returning a fallback JSX — works but defeats the boundary-based composition (loses retry semantics, conflates loading vs error).
- A single page-level `<ErrorBoundary>` wrapping multiple `<Suspense>` regions — one failure now affects all the others; should be per-region.
- A `class ErrorBoundary` written from scratch in this repo — fine, but check it implements `getDerivedStateFromError` and `componentDidCatch` correctly; `react-error-boundary` is the canonical choice.
- An async component that silently `return null` on caught error — failure becomes invisible; no retry, no logging, no signal to the user.

The canonical resolution: wrap each Suspense region in its own `<ErrorBoundary FallbackComponent={...}>`; provide `onReset` to clear state that caused the error; use `react-error-boundary` unless there's a strong reason to roll your own.

**Incorrect (unhandled errors crash page):**

```typescript
function Dashboard() {
  return (
    <Suspense fallback={<Spinner />}>
      <Analytics />  {/* If this throws, entire page crashes */}
      <Orders />
    </Suspense>
  )
}
```

**Correct (Error Boundary isolates failures):**

```typescript
import { ErrorBoundary } from 'react-error-boundary'

function Dashboard() {
  return (
    <div>
      <ErrorBoundary fallback={<AnalyticsError />}>
        <Suspense fallback={<AnalyticsSkeleton />}>
          <Analytics />
        </Suspense>
      </ErrorBoundary>

      <ErrorBoundary fallback={<OrdersError />}>
        <Suspense fallback={<OrdersSkeleton />}>
          <Orders />
        </Suspense>
      </ErrorBoundary>
    </div>
  )
}
// Analytics failure doesn't affect Orders
```

**With retry capability:**

```typescript
function ErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div className="error-panel">
      <p>Something went wrong: {error.message}</p>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  )
}

function Dashboard() {
  return (
    <ErrorBoundary
      FallbackComponent={ErrorFallback}
      onReset={() => {
        // Reset any state that might have caused the error
      }}
    >
      <Suspense fallback={<DashboardSkeleton />}>
        <DashboardContent />
      </Suspense>
    </ErrorBoundary>
  )
}
```
