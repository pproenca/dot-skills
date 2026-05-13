---
title: Trust automatic batching — don't reach for flushSync or unstable_batchedUpdates
impact: HIGH
impactDescription: collapses multiple state updates into a single render in all contexts (events, promises, setTimeout, native events)
tags: conc, batching, flush-sync, manual-batching
---

## Trust automatic batching — don't reach for flushSync or unstable_batchedUpdates

**Pattern intent:** multiple state updates in the same logical operation should produce one render, not several. React already does this automatically (since 18) in event handlers, promises, setTimeout, and native event handlers. Manual batching APIs and synchronous-flush workarounds are almost always a leftover or a misdiagnosis.

### Shapes to recognize

- `flushSync` wrapping individual `setState` calls "for safety" or "to make sure they apply" — produces *more* renders, not fewer.
- Leftover `unstable_batchedUpdates` from a React 17 codebase that was never cleaned up.
- A chain like `setX(...); await Promise.resolve(); setY(...)` written to "force separate renders" or "let X commit before Y" — the opposite of what async setState boundaries used to do, and unnecessary now.
- A workaround like `setTimeout(() => setY(...), 0)` after a `setX` to "wait for the first render" — the real fix is to express the dependency in render or via an effect.

The canonical resolution: write the consecutive `setState` calls naturally; React batches them. Reach for `flushSync` only when you genuinely need a synchronous DOM measurement before next paint.

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
  // React batches even in async callbacks (since 18)
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

**Note:** If you have code using `unstable_batchedUpdates`, you can remove it — React batches everywhere automatically since 18.
