---
title: Update Only Changed Regions
impact: CRITICAL
impactDescription: reduces bandwidth by 80-95%
tags: render, partial, optimization, diff, performance
---

## Update Only Changed Regions

Update only the terminal regions that changed rather than redrawing the entire screen. Full redraws waste bandwidth and increase flicker risk.

**Incorrect (full redraw on every change):**

```typescript
function updateUI(state: AppState) {
  console.clear()  // Clears everything
  console.log(renderHeader(state))
  console.log(renderContent(state))
  console.log(renderFooter(state))
  // Redraws 100% of screen even if only footer changed
}
```

**Correct (targeted region updates):**

```typescript
interface Region {
  row: number
  content: string
}

function updateRegion({ row, content }: Region) {
  // Move cursor to specific row, clear line, write new content
  process.stdout.write(`\x1b[${row};1H\x1b[K${content}`)
}

function updateUI(state: AppState, prevState: AppState) {
  if (state.header !== prevState.header) {
    updateRegion({ row: 1, content: renderHeader(state) })
  }
  if (state.footer !== prevState.footer) {
    updateRegion({ row: 24, content: renderFooter(state) })
  }
  // Only changed regions are updated
}
```

**With Ink (automatic diffing):**

```tsx
function Dashboard({ data }: { data: DashboardData }) {
  // Ink's React reconciler automatically diffs and updates only changed components
  return (
    <Box flexDirection="column">
      <Header title={data.title} />
      <Content items={data.items} />
      <Footer status={data.status} />
    </Box>
  )
}
```

**Note:** Ink handles this automatically through React's reconciliation. When building custom renderers, track previous state to compute minimal diffs.

Reference: [Textualize Blog - Algorithms for High Performance Terminal Apps](https://textual.textualize.io/blog/2024/12/12/algorithms-for-high-performance-terminal-apps/)
