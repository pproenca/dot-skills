---
title: Return true for Async Message Handlers
impact: HIGH
impactDescription: prevents dropped responses from async handlers
tags: msg, async, sendMessage, onMessage, response
---

## Return true for Async Message Handlers

When handling messages asynchronously with the raw `browser.runtime.onMessage` API, you must return `true` synchronously to keep the message channel open. Without this, `sendResponse` is called before your async work completes.

**Important (WXT v0.20+):** WXT removed `webextension-polyfill`, so returning a Promise from `addListener` no longer works. You must use `sendResponse` + `return true`. Consider using [`@webext-core/messaging`](msg-type-safe-messaging.md) which handles this automatically.

**Incorrect (channel closes before async completes):**

```typescript
export default defineBackground(() => {
  browser.runtime.onMessage.addListener(async (message) => {
    if (message.type === 'FETCH_DATA') {
      const data = await fetchData(message.url)
      return data // Never reaches sender - channel already closed
    }
  })
})
```

**Correct (keep channel open with return true):**

```typescript
export default defineBackground(() => {
  browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.type === 'FETCH_DATA') {
      fetchData(message.url).then((data) => {
        sendResponse(data)
      })
      return true // Keep message channel open
    }
  })
})
```

**Alternative (wrap in promise handler):**

```typescript
export default defineBackground(() => {
  browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.type === 'FETCH_DATA') {
      handleFetchMessage(message)
        .then(sendResponse)
        .catch((error) => sendResponse({ error: error.message }))
      return true
    }
  })
})

async function handleFetchMessage(message: FetchMessage): Promise<FetchResponse> {
  const data = await fetchData(message.url)
  return { success: true, data }
}
```

Reference: [Chrome Runtime Messaging](https://developer.chrome.com/docs/extensions/develop/concepts/messaging)
