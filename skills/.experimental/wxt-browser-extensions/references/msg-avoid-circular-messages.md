---
title: Avoid Circular Message Loops
impact: HIGH
impactDescription: prevents infinite loops and stack overflows
tags: msg, circular, loop, debugging
---

## Avoid Circular Message Loops

Message handlers that send messages can create infinite loops. Use message type checks and sender validation to prevent circular message patterns.

**Incorrect (infinite message loop):**

```typescript
// background.ts
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'PROCESS_DATA') {
    const result = transformUserData(message.data)
    // Sends message that triggers same listener
    browser.runtime.sendMessage({ type: 'PROCESS_DATA', data: result })
    return true
  }
})
```

**Correct (use distinct message types):**

```typescript
// background.ts
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
  switch (message.type) {
    case 'PROCESS_DATA':
      transformUserData(message.data).then((result) => {
        // Different message type for result
        browser.runtime.sendMessage({ type: 'DATA_PROCESSED', result })
      })
      return true

    case 'DATA_PROCESSED':
      // Handle processed data - no further messages
      updateUI(message.result)
      return false
  }
})
```

**Alternative (track message origin):**

```typescript
interface TrackedMessage {
  type: string
  data: unknown
  _origin?: 'background' | 'content' | 'popup'
}

browser.runtime.onMessage.addListener((message: TrackedMessage, sender, sendResponse) => {
  // Ignore messages we sent
  if (message._origin === 'background') {
    return false
  }

  if (message.type === 'SYNC_STATE') {
    const newState = mergeState(message.data)
    // Mark origin to prevent loop
    browser.runtime.sendMessage({
      type: 'SYNC_STATE',
      data: newState,
      _origin: 'background'
    })
  }
})
```

**Note:** [`@webext-core/messaging`](msg-type-safe-messaging.md) with named message types reduces the risk of circular loops through explicit sender/receiver separation.

Reference: [Chrome Messaging Debugging](https://developer.chrome.com/docs/extensions/develop/concepts/messaging#debugging)
