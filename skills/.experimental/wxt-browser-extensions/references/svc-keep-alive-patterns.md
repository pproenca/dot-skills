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
  browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.type === 'PROCESS_LARGE_FILE') {
      // Service worker may terminate during this 2-minute operation
      processLargeFile(message.data).then(sendResponse)
      return true
    }
  })
})
```

**Correct (keep-alive with port connection):**

```typescript
// background.ts - receives keep-alive port
export default defineBackground(() => {
  browser.runtime.onConnect.addListener((port) => {
    if (port.name === 'keepAlive') {
      // Port connection keeps service worker alive while connected
      port.onDisconnect.addListener(() => {
        console.log('Keep-alive port disconnected')
      })
    }
  })

  browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.type === 'PROCESS_LARGE_FILE') {
      processLargeFile(message.data).then(sendResponse)
      return true
    }
  })
})
```

```typescript
// popup.ts or content.ts - establishes keep-alive port
async function processWithKeepAlive(data: FileData) {
  // Open port to keep service worker alive during long operation
  const port = browser.runtime.connect({ name: 'keepAlive' })

  try {
    const result = await browser.runtime.sendMessage({
      type: 'PROCESS_LARGE_FILE',
      data
    })
    return result
  } finally {
    port.disconnect() // Release keep-alive when done
  }
}
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

**When NOT to use this pattern:**
- Operations that complete within 30 seconds
- Consider using offscreen documents for heavy DOM-dependent work instead

Reference: [Chrome MV3 Service Worker Lifecycle](https://developer.chrome.com/docs/extensions/develop/concepts/service-workers/lifecycle)
