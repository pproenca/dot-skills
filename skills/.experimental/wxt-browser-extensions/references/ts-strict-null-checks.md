---
title: Enable Strict Null Checks
impact: LOW-MEDIUM
impactDescription: prevents null reference errors from optional API returns
tags: ts, strict, null-checks, safety
---

## Enable Strict Null Checks

Enable strict null checks in TypeScript to catch potential null reference errors. Extension APIs frequently return null for missing data.

**Incorrect (null errors at runtime):**

```typescript
// tsconfig.json without strict null checks
{
  "compilerOptions": {
    "strict": false
  }
}

// background.ts
export default defineBackground(() => {
  browser.tabs.query({ active: true }, async (tabs) => {
    const tab = tabs[0]
    // Runtime error if no active tab
    await browser.tabs.sendMessage(tab.id, { type: 'PING' })
  })
})
```

**Correct (null safety enforced):**

```typescript
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "strictNullChecks": true
  }
}

// background.ts
export default defineBackground(() => {
  browser.action.onClicked.addListener(async () => {
    const [tab] = await browser.tabs.query({ active: true, currentWindow: true })

    // TypeScript requires null checks
    if (!tab?.id) {
      console.warn('No active tab found')
      return
    }

    // tab.id is now guaranteed to be number
    await browser.tabs.sendMessage(tab.id, { type: 'PING' })
  })
})
```

**Common extension API null cases to handle:**
- `browser.tabs.query()` returns empty array
- `tab.id` is undefined for some special tabs
- `tab.url` is undefined without tabs permission
- `sender.tab` is undefined for messages from popup/background
- `storage.getItem()` returns null for missing keys

Reference: [TypeScript Strict Mode](https://www.typescriptlang.org/tsconfig#strict)
