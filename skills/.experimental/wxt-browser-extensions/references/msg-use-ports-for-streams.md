---
title: Use Ports for Streaming Communication
impact: HIGH
impactDescription: enables bidirectional streaming without per-message overhead
tags: msg, ports, streaming, long-lived, connection
---

## Use Ports for Streaming Communication

For long-lived connections or streaming data, use `runtime.connect` ports instead of repeated `sendMessage` calls. Ports maintain an open channel without reconnection overhead.

**Incorrect (repeated sendMessage for streaming):**

```typescript
// content.ts - polls for updates
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  main() {
    setInterval(async () => {
      // Creates new connection every 100ms
      const update = await browser.runtime.sendMessage({ type: 'GET_UPDATE' })
      applyUpdate(update)
    }, 100)
  }
})
```

**Correct (port for streaming updates):**

```typescript
// content.ts - maintains persistent connection
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  main(ctx) {
    const port = browser.runtime.connect({ name: 'updates' })

    port.onMessage.addListener((update) => {
      applyUpdate(update)
    })

    port.onDisconnect.addListener(() => {
      if (!ctx.isInvalidated) {
        // Reconnect if not due to extension update
        setTimeout(() => reconnect(), 1000)
      }
    })

    // Request to start streaming
    port.postMessage({ type: 'START_UPDATES' })
  }
})

// background.ts
export default defineBackground(() => {
  browser.runtime.onConnect.addListener((port) => {
    if (port.name === 'updates') {
      let intervalId: ReturnType<typeof setInterval>

      port.onMessage.addListener((message) => {
        if (message.type === 'START_UPDATES') {
          intervalId = setInterval(() => {
            const update = generateUpdate()
            port.postMessage(update)
          }, 100)
        }
      })

      port.onDisconnect.addListener(() => {
        clearInterval(intervalId)
      })
    }
  })
})
```

**When to use ports:**
- Streaming data (live updates, progress)
- Bidirectional communication
- Keep-alive connections for long operations

Reference: [Chrome Long-Lived Connections](https://developer.chrome.com/docs/extensions/develop/concepts/messaging#connect)
