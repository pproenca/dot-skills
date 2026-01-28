---
title: Avoid any Type in Message Handlers
impact: LOW-MEDIUM
impactDescription: prevents silent runtime failures from typos
tags: ts, any, types, messages, safety
---

## Avoid any Type in Message Handlers

Message handlers using `any` miss type errors that cause silent runtime failures. Define explicit message types for compile-time safety.

**Incorrect (any loses type safety):**

```typescript
export default defineBackground(() => {
  browser.runtime.onMessage.addListener((message: any, sender, sendResponse) => {
    if (message.type === 'FETCH_DATA') {
      // No type checking - typos compile fine
      fetchData(message.endpont).then(sendResponse) // 'endpont' typo not caught
      return true
    }
  })
})
```

**Correct (discriminated union types):**

```typescript
// types/messages.ts
type FetchDataMessage = {
  type: 'FETCH_DATA'
  endpoint: string
  params?: Record<string, string>
}

type UpdateSettingsMessage = {
  type: 'UPDATE_SETTINGS'
  settings: Partial<Settings>
}

type PingMessage = {
  type: 'PING'
}

type ExtensionMessage = FetchDataMessage | UpdateSettingsMessage | PingMessage

// background.ts
export default defineBackground(() => {
  browser.runtime.onMessage.addListener((
    message: ExtensionMessage,
    sender,
    sendResponse
  ) => {
    switch (message.type) {
      case 'FETCH_DATA':
        // TypeScript knows message.endpoint exists
        fetchData(message.endpoint, message.params).then(sendResponse)
        return true

      case 'UPDATE_SETTINGS':
        // TypeScript knows message.settings exists
        updateSettings(message.settings).then(sendResponse)
        return true

      case 'PING':
        sendResponse({ pong: true })
        return false
    }
  })
})
```

**Note:** The discriminated union pattern with `switch` statements enables TypeScript's exhaustiveness checking - add a new message type and TypeScript shows everywhere it needs handling.

Reference: [TypeScript Discriminated Unions](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#discriminated-unions)
