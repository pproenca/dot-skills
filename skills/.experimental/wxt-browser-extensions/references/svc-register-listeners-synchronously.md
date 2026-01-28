---
title: Register Event Listeners Synchronously
impact: CRITICAL
impactDescription: prevents missed events on service worker restart
tags: svc, event-listeners, service-worker, mv3
---

## Register Event Listeners Synchronously

Service workers can terminate at any time and restart when events occur. Event listeners must be registered synchronously at the top level of the service worker to ensure they are active before any events fire.

**Incorrect (async listener registration):**

```typescript
export default defineBackground(async () => {
  const config = await loadConfig()

  // Listener registered after async operation - may miss events
  browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    handleMessage(message, config).then(sendResponse)
    return true
  })
})
```

**Correct (synchronous registration, async handling):**

```typescript
export default defineBackground(() => {
  // Listener registered synchronously - catches all events
  browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    loadConfig().then((config) => {
      handleMessage(message, config).then(sendResponse)
    })
    return true
  })
})
```

**When NOT to use this pattern:**
- Event listeners that are intentionally conditional based on user settings
- Listeners that should only be active after explicit user action

Reference: [WXT Background Entrypoints](https://wxt.dev/guide/essentials/entrypoints)
