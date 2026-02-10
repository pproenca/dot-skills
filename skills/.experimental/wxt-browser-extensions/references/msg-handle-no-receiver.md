---
title: Handle Missing Message Receivers
impact: HIGH
impactDescription: prevents uncaught errors when receivers unavailable
tags: msg, error-handling, sendMessage, receiver
---

## Handle Missing Message Receivers

`sendMessage` throws an error if no listener is registered. Always handle this case, especially when content scripts may not be injected on all pages.

**Incorrect (unhandled rejection):**

```typescript
// popup.ts
async function sendToContentScript() {
  // Throws if content script not injected
  const response = await browser.tabs.sendMessage(tabId, { type: 'GET_DATA' })
  displayData(response)
}
```

**Correct (handle no receiver case):**

```typescript
// popup.ts
async function sendToContentScript(tabId: number) {
  try {
    const response = await browser.tabs.sendMessage(tabId, { type: 'GET_DATA' })
    displayData(response)
  } catch (error) {
    if (isNoReceiverError(error)) {
      // Content script not injected - inject it first
      await browser.scripting.executeScript({
        target: { tabId },
        files: ['/content-scripts/content.js']
      })
      // Retry after injection
      const response = await browser.tabs.sendMessage(tabId, { type: 'GET_DATA' })
      displayData(response)
    } else {
      throw error
    }
  }
}

function isNoReceiverError(error: unknown): boolean {
  return error instanceof Error && (
    error.message.includes('Receiving end does not exist') ||
    error.message.includes('Could not establish connection')
  )
}
```

**Alternative (check before sending):**

```typescript
async function sendIfContentScriptReady(tabId: number, message: Message) {
  const tab = await browser.tabs.get(tabId)

  // Check if URL matches content script patterns
  if (!tab.url?.startsWith('http')) {
    console.log('Content script cannot run on this page')
    return null
  }

  try {
    return await browser.tabs.sendMessage(tabId, message)
  } catch {
    return null
  }
}
```

**Note:** [`@webext-core/messaging`](msg-type-safe-messaging.md) handles receiver errors automatically, reducing the need for manual error handling.

Reference: [Chrome Messaging Best Practices](https://developer.chrome.com/docs/extensions/develop/concepts/messaging)
