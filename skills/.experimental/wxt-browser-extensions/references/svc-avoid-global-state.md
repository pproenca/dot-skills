---
title: Avoid In-Memory Global State
impact: CRITICAL
impactDescription: prevents data loss on service worker termination
tags: svc, state, service-worker, persistence
---

## Avoid In-Memory Global State

Service workers can terminate after 30 seconds of inactivity. Any in-memory state is lost when this happens. Use persistent storage for all state that must survive restarts.

**Incorrect (state lost on termination):**

```typescript
let tabCounts: Record<number, number> = {}

export default defineBackground(() => {
  browser.tabs.onUpdated.addListener((tabId) => {
    tabCounts[tabId] = (tabCounts[tabId] || 0) + 1
    // State lost when service worker terminates
  })
})
```

**Correct (state persisted to storage):**

```typescript
const tabCounts = storage.defineItem<Record<number, number>>(
  'session:tabCounts',
  { fallback: {} }
)

export default defineBackground(() => {
  browser.tabs.onUpdated.addListener(async (tabId) => {
    const counts = await tabCounts.getValue()
    await tabCounts.setValue({
      ...counts,
      [tabId]: (counts[tabId] || 0) + 1
    })
  })
})
```

**Note:** Use `session:` storage area for ephemeral state that should clear on browser restart, `local:` for persistent state.

Reference: [WXT Storage](https://wxt.dev/storage)
