---
title: Augment Browser Types for Missing APIs
impact: LOW-MEDIUM
impactDescription: enables type safety for experimental and browser-specific APIs
tags: ts, types, augmentation, experimental
---

## Augment Browser Types for Missing APIs

Some browser APIs aren't in the default type definitions. Augment the types instead of using `any` or `@ts-ignore`.

**Incorrect (bypassing type system):**

```typescript
export default defineBackground(() => {
  // @ts-ignore - sidePanel types missing
  browser.sidePanel.open({ windowId: 1 })

  // Using 'any' loses all type safety
  ;(browser as any).sidePanel.setOptions({
    path: 'sidepanel.html',
    enabled: true
  })
})
```

**Correct (type augmentation):**

```typescript
// types/browser.d.ts
declare module 'wxt/browser' {
  interface BrowserSidePanel {
    open(options: { windowId?: number; tabId?: number }): Promise<void>
    setOptions(options: {
      path?: string
      enabled?: boolean
      tabId?: number
    }): Promise<void>
    getOptions(options: { tabId?: number }): Promise<{ path: string; enabled: boolean }>
  }

  interface Browser {
    sidePanel: BrowserSidePanel
  }
}

// background.ts - now fully typed
export default defineBackground(() => {
  browser.sidePanel.open({ windowId: 1 }) // Typed!
  browser.sidePanel.setOptions({
    path: 'sidepanel.html',
    enabled: true
  })
})
```

**For experimental APIs with documentation:**

```typescript
// types/chrome-experimental.d.ts
declare module 'wxt/browser' {
  interface BrowserReadingList {
    addEntry(options: { url: string; title: string; hasBeenRead?: boolean }): Promise<void>
    removeEntry(options: { url: string }): Promise<void>
    query(options: { url?: string; hasBeenRead?: boolean }): Promise<ReadingListEntry[]>
  }

  interface Browser {
    readingList: BrowserReadingList
  }
}
```

Reference: [TypeScript Module Augmentation](https://www.typescriptlang.org/docs/handbook/declaration-merging.html)
