---
title: Use React Performance Tracks for Render Analysis
impact: MEDIUM
impactDescription: reduces render bottleneck diagnosis from hours to minutes
tags: profile, react-devtools, profiler, render-analysis
---

## Use React Performance Tracks for Render Analysis

React's Performance Tracks integration in Chrome DevTools shows exactly which components re-rendered, how long each render took, and whether renders were triggered by state, props, or context changes. Without this data, developers resort to guessing which components cause slowdowns.

**Incorrect (guessing at re-render causes with console.log):**

```tsx
function InventoryDashboard({ warehouses }: { warehouses: Warehouse[] }) {
  console.log("InventoryDashboard rendered") // clutters console, no timing data

  return (
    <div>
      <WarehouseFilters />
      <WarehouseMap warehouses={warehouses} />
      <InventoryTable warehouses={warehouses} />
    </div>
  )
}

function WarehouseMap({ warehouses }: { warehouses: Warehouse[] }) {
  console.log("WarehouseMap rendered") // no information about render duration
  return <MapVisualization data={warehouses} />
}

function InventoryTable({ warehouses }: { warehouses: Warehouse[] }) {
  console.log("InventoryTable rendered") // cannot compare relative costs
  return <Table rows={warehouses.flatMap((w) => w.inventory)} />
}
```

**Correct (systematic profiling with React Performance Tracks):**

```tsx
// Step 1: Enable React Performance Tracks
//   Chrome DevTools → Performance → enable "React" track

// Step 2: Record a trace while interacting with the slow UI
//   Click record → perform the slow action → stop recording

// Step 3: Read the React track in the flame chart
//   - Each component render appears as a bar with duration
//   - Yellow/red bars indicate slow renders (>16ms)
//   - Gray bars indicate components that did not re-render

// Step 4: Apply targeted fix based on profiling data
// Profiler showed: InventoryTable takes 280ms (renders 5000 rows)
// Profiler showed: WarehouseMap takes 2ms (not a bottleneck)

function InventoryDashboard({ warehouses }: { warehouses: Warehouse[] }) {
  return (
    <div>
      <WarehouseFilters />
      <WarehouseMap warehouses={warehouses} />
      <Suspense fallback={<TableSkeleton />}>
        <VirtualizedInventoryTable warehouses={warehouses} />
      </Suspense>
    </div>
  )
}
```

Reference: [React Blog — React Performance Tracks](https://react.dev/blog/2025/04/25/react-conf-2025-recap)
