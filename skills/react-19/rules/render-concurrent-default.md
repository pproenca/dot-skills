---
title: Leverage Concurrent Rendering by Default
impact: MEDIUM
impactDescription: prevents UI freezing during complex updates
tags: render, concurrent, performance, responsiveness
---

## Leverage Concurrent Rendering by Default

React 19 enables concurrent rendering by default. React can pause, interrupt, and resume rendering work. Write components that work with this model rather than against it.

**Incorrect (blocking synchronous pattern):**

```tsx
function DataTable({ data }: { data: Row[] }) {
  // Synchronous processing blocks the main thread
  const processedData = data.map(row => {
    return {
      ...row,
      computed: expensiveComputation(row),  // Blocks for each row
    }
  })

  return (
    <table>
      {processedData.map(row => <TableRow key={row.id} row={row} />)}
    </table>
  )
}
```

**Correct (works with concurrent rendering):**

```tsx
function DataTable({ data }: { data: Row[] }) {
  const deferredData = useDeferredValue(data)

  // Computation can be interrupted between renders
  const processedData = deferredData.map(row => ({
    ...row,
    computed: expensiveComputation(row),
  }))

  const isStale = data !== deferredData

  return (
    <div style={{ opacity: isStale ? 0.8 : 1 }}>
      <table>
        {processedData.map(row => <TableRow key={row.id} row={row} />)}
      </table>
    </div>
  )
}
```

**With virtualization for very large lists:**

```tsx
function VirtualizedDataTable({ data }: { data: Row[] }) {
  return (
    <VirtualizedList
      items={data}
      height={600}
      itemHeight={40}
      renderItem={(row) => <TableRow row={row} />}
    />
  )
}
// Only visible rows render, concurrent features work naturally
```

**Best practices:**
- Avoid synchronous loops that process thousands of items
- Use useDeferredValue for search/filter results
- Use virtualization for large lists
- Split expensive components with Suspense

Reference: [Concurrent React](https://react.dev/blog/2024/12/05/react-19#whats-new-in-react-19)
