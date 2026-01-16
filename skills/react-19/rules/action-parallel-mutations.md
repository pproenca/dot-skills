---
title: Avoid Sequential Action Calls
impact: CRITICAL
impactDescription: 2-5× improvement for independent mutations
tags: action, parallelization, promises, waterfalls
---

## Avoid Sequential Action Calls

When multiple actions have no dependencies, execute them concurrently. Sequential awaits add full round-trip latency for each operation.

**Incorrect (sequential execution, 3 round trips):**

```tsx
async function handleBulkUpdate(items: Item[]) {
  const updatedItems: Item[] = []

  for (const item of items) {
    const result = await updateItem(item)  // Waits for each one
    updatedItems.push(result)
  }

  return updatedItems
}
```

**Correct (parallel execution, 1 round trip):**

```tsx
async function handleBulkUpdate(items: Item[]) {
  const results = await Promise.all(
    items.map(item => updateItem(item))  // All requests fire simultaneously
  )

  return results
}
```

**Alternative (with error isolation):**

```tsx
async function handleBulkUpdate(items: Item[]) {
  const results = await Promise.allSettled(
    items.map(item => updateItem(item))
  )

  const succeeded = results
    .filter((r): r is PromiseFulfilledResult<Item> => r.status === 'fulfilled')
    .map(r => r.value)

  return succeeded
}
```

**When NOT to use this pattern:**
- Actions depend on results from previous actions
- Server has rate limiting that requires sequential requests
- Order of operations matters for data consistency

Reference: [React 19 Actions](https://react.dev/blog/2024/12/05/react-19#actions)
