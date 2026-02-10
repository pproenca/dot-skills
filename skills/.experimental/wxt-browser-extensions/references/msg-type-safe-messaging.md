---
title: Define Type-Safe Message Protocols
impact: HIGH
impactDescription: prevents runtime failures from typos and schema mismatches
tags: msg, typescript, types, protocol, type-safe, webext-core
---

## Define Type-Safe Message Protocols

Use `@webext-core/messaging` for type-safe messaging between extension contexts. WXT's [messaging guide](https://wxt.dev/guide/essentials/messaging) recommends this library over raw `browser.runtime.onMessage` because it handles `return true`, type safety, and error handling automatically.

**Incorrect (untyped raw messages):**

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

**Correct (@webext-core/messaging with ProtocolMap):**

```typescript
// utils/messaging.ts
import { defineExtensionMessaging } from '@webext-core/messaging'

interface ProtocolMap {
  getUser(data: { userId: number }): User | null
  updateSettings(data: { settings: Settings }): { success: boolean }
  ping(): 'pong'
}

export const { sendMessage, onMessage } = defineExtensionMessaging<ProtocolMap>()
```

```typescript
// background.ts
export default defineBackground(() => {
  onMessage('getUser', ({ data }) => {
    return getUser(data.userId) // TypeScript knows userId exists
  })

  onMessage('updateSettings', ({ data }) => {
    return updateSettings(data.settings) // Return type checked
  })

  onMessage('ping', () => 'pong')
})
```

```typescript
// content.ts or popup.ts
const user = await sendMessage('getUser', { userId: 123 })
// TypeScript error if you typo: sendMessage('getUser', { user: 123 })
// TypeScript knows user is User | null
```

**Alternative (raw API when you cannot add dependencies):**

```typescript
// types/messages.ts
export type Message =
  | { type: 'GET_USER'; userId: number }
  | { type: 'UPDATE_SETTINGS'; settings: Settings }

// background.ts - must manually return true for async
browser.runtime.onMessage.addListener((message: Message, sender, sendResponse) => {
  switch (message.type) {
    case 'GET_USER':
      getUser(message.userId).then(sendResponse)
      return true
  }
})
```

**Install:** `npm install @webext-core/messaging`

Reference: [WXT Messaging Guide](https://wxt.dev/guide/essentials/messaging)
