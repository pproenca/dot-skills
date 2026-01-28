---
title: Define Type-Safe Message Protocols
impact: HIGH
impactDescription: prevents runtime failures from typos and schema mismatches
tags: msg, typescript, types, protocol, type-safe
---

## Define Type-Safe Message Protocols

Define explicit message types to catch protocol mismatches at build time instead of runtime. This prevents silent failures from typos or schema changes.

**Incorrect (untyped messages):**

```typescript
// background.ts
browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'GET_USER') {
    // No type safety - easy to typo 'user' vs 'userId'
    getUser(message.userId).then(sendResponse)
    return true
  }
})

// content.ts
// Typo: 'user' instead of 'userId' - fails silently
browser.runtime.sendMessage({ type: 'GET_USER', user: 123 })
```

**Correct (typed message protocol):**

```typescript
// types/messages.ts
export type Message =
  | { type: 'GET_USER'; userId: number }
  | { type: 'UPDATE_SETTINGS'; settings: Settings }
  | { type: 'PING' }

export type MessageResponse<T extends Message> =
  T extends { type: 'GET_USER' } ? User | null :
  T extends { type: 'UPDATE_SETTINGS' } ? { success: boolean } :
  T extends { type: 'PING' } ? 'pong' :
  never

// utils/messaging.ts
export async function sendTypedMessage<T extends Message>(
  message: T
): Promise<MessageResponse<T>> {
  return browser.runtime.sendMessage(message)
}

// background.ts
browser.runtime.onMessage.addListener((message: Message, sender, sendResponse) => {
  switch (message.type) {
    case 'GET_USER':
      getUser(message.userId).then(sendResponse) // TypeScript knows userId exists
      return true
    case 'UPDATE_SETTINGS':
      updateSettings(message.settings).then(sendResponse)
      return true
    case 'PING':
      sendResponse('pong')
      return false
  }
})

// content.ts
const user = await sendTypedMessage({ type: 'GET_USER', userId: 123 })
// TypeScript error: Property 'user' does not exist, did you mean 'userId'?
```

Reference: [WXT Messaging Utilities](https://wxt.dev/guide/essentials/messaging)
