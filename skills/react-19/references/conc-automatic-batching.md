---
title: Leverage Automatic Batching for Fewer Renders
impact: HIGH
impactDescription: 32% fewer renders in heavy updates
tags: conc, batching, automatic, performance
---

## Leverage Automatic Batching for Fewer Renders

React 19 automatically batches state updates in all contexts: event handlers, promises, setTimeout, and native events. Understand this to avoid unnecessary workarounds.

**Incorrect (forcing synchronous updates):**

```typescript
import { flushSync } from 'react-dom'

function handleClick() {
  // Don't do this - breaks automatic batching
  flushSync(() => {
    setCount(c => c + 1)
  })
  flushSync(() => {
    setFlag(f => !f)
  })
}
// Two renders instead of one
```

**Correct (letting React batch automatically):**

```typescript
function handleClick() {
  // React batches these - single render
  setCount(c => c + 1)
  setFlag(f => !f)
}

async function handleSubmit() {
  const data = await fetchData()
  // React 19 batches even in async callbacks
  setData(data)
  setLoading(false)
  setError(null)
}
// Single render for all three updates
```

**When flushSync is appropriate:**

```typescript
function handleInput(e: React.ChangeEvent<HTMLInputElement>) {
  const value = e.target.value
  setQuery(value)

  // Rare: need DOM measurement before next paint
  flushSync(() => {
    setResults(search(value))
  })
  // Now can measure DOM synchronously
  scrollToTop()
}
```

**Note:** If you have code using `unstable_batchedUpdates`, you can remove it - React 19 batches everywhere automatically.
