---
title: Use Keep-Alive Patterns for Long Operations
impact: CRITICAL
impactDescription: prevents premature termination of 30+ second operations
tags: svc, keep-alive, service-worker, long-running
---

## Use Keep-Alive Patterns for Long Operations

Service workers terminate after approximately 30 seconds of inactivity. For operations that take longer, use keep-alive patterns like periodic alarms or port connections.

**Incorrect (terminates mid-operation):**

```typescript
export default defineBackground(() => {
  browser.runtime.onMessage.addListener(async (message) => {
    if (message.type === 'PROCESS_LARGE_FILE') {
      // Service worker may terminate during this 2-minute operation
      const result = await processLargeFile(message.data)
      return result
    }
  })
})
```

**Correct (keep-alive with port connection):**

```typescript
export default defineBackground(() => {
  browser.runtime.onConnect.addListener((port) => {
    if (port.name === 'keepAlive') {
      // Port connection keeps service worker alive
      port.onDisconnect.addListener(() => {
        // Reconnect if needed
      })
    }
  })

  browser.runtime.onMessage.addListener(async (message, sender, sendResponse) => {
    if (message.type === 'PROCESS_LARGE_FILE') {
      // Create keep-alive port from content script before long operation
      const result = await processLargeFile(message.data)
      sendResponse(result)
    }
    return true
  })
})
```

**Alternative (alarm-based keep-alive):**

```typescript
const KEEP_ALIVE_ALARM = 'keepAlive'

export default defineBackground(() => {
  browser.alarms.onAlarm.addListener((alarm) => {
    if (alarm.name === KEEP_ALIVE_ALARM) {
      // Alarm callback resets 30s termination timer
    }
  })

  async function startLongOperation() {
    await browser.alarms.create(KEEP_ALIVE_ALARM, { periodInMinutes: 0.4 })
    try {
      await processLargeFile()
    } finally {
      await browser.alarms.clear(KEEP_ALIVE_ALARM)
    }
  }
})
```

Reference: [Chrome MV3 Service Worker Lifecycle](https://developer.chrome.com/docs/extensions/develop/concepts/service-workers/lifecycle)
