---
title: Render Loading, Empty, and Error States
impact: MEDIUM-HIGH
impactDescription: prevents a blank frame during async work
tags: design, states, loading, error
---

## Render Loading, Empty, and Error States

Tool calls and in-widget refreshes take time and sometimes fail. Without explicit loading, empty, and error states the user stares at a blank iframe and assumes the app is broken. Render a skeleton while data loads, a clear message when a query returns nothing, and a retry affordance on failure — every state the component can be in should look intentional.

**Incorrect (renders nothing until data exists; failures look like a frozen app):**

```tsx
return <ul>{flights?.map((f) => <FlightRow key={f.id} flight={f} />)}</ul>;
```

**Correct (every state is visible and recoverable):**

```tsx
if (status === "loading") return <SkeletonList rows={5} />;
if (status === "error") return <ErrorPanel message="Couldn't load flights." onRetry={refetch} />;
if (flights.length === 0) return <EmptyState message="No flights match these dates." />;
return <ul>{flights.map((f) => <FlightRow key={f.id} flight={f} />)}</ul>;
```

Reference: [Design components – Apps SDK](https://developers.openai.com/apps-sdk/plan/components)
