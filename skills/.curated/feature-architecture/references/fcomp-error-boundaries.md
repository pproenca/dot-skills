---
title: Use Feature-Level Error Boundaries
impact: MEDIUM
impactDescription: Isolates failures to single features; prevents full-page crashes
tags: comp, error-boundary, resilience, isolation
---

## Use Feature-Level Error Boundaries

Wrap each feature's root component in an error boundary. When a feature fails, only that feature shows an error state while the rest of the page remains functional.

**Incorrect (single app-level boundary):**

```typescript
// Single error boundary - any feature crash takes down entire app
function App() {
  return (
    <ErrorBoundary fallback={<FullPageError />}>
      <Dashboard />
    </ErrorBoundary>
  );
}

function Dashboard() {
  return (
    <div>
      <UserProfile />     {/* Crash here = full page error */}
      <RecentOrders />
      <Notifications />
    </div>
  );
}
```

**Correct (feature-level boundaries):**

```typescript
// src/shared/components/FeatureErrorBoundary.tsx
interface FeatureErrorBoundaryProps {
  feature: string;
  children: ReactNode;
  fallback?: ReactNode;
}

export function FeatureErrorBoundary({
  feature,
  children,
  fallback,
}: FeatureErrorBoundaryProps) {
  return (
    <ErrorBoundary
      fallback={fallback ?? <FeatureErrorFallback feature={feature} />}
      onError={(error) => logError(error, { feature })}
    >
      {children}
    </ErrorBoundary>
  );
}

// src/app/pages/DashboardPage.tsx
function Dashboard() {
  return (
    <div>
      <FeatureErrorBoundary feature="user-profile">
        <UserProfile />  {/* Crash here = only this section shows error */}
      </FeatureErrorBoundary>

      <FeatureErrorBoundary feature="recent-orders">
        <RecentOrders />  {/* Still works even if UserProfile crashed */}
      </FeatureErrorBoundary>

      <FeatureErrorBoundary feature="notifications">
        <Notifications />  {/* Still works */}
      </FeatureErrorBoundary>
    </div>
  );
}
```

**Graceful fallback UI:**

```typescript
function FeatureErrorFallback({ feature }: { feature: string }) {
  return (
    <div className="rounded border border-red-200 bg-red-50 p-4">
      <p className="text-red-800">
        Unable to load {feature}. <button onClick={retry}>Try again</button>
      </p>
    </div>
  );
}
```

**Benefits:**
- One feature failing doesn't crash the page
- Errors are attributed to specific features
- Users can continue using working features

Reference: [React Error Boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)
