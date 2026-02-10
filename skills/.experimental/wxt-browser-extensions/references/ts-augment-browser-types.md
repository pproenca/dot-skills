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
declare namespace chrome {
  export namespace readingList {
    interface ReadingListEntry {
      url: string
      title: string
      hasBeenRead: boolean
      creationTime: number
    }

    export function addEntry(options: {
      url: string
      title: string
      hasBeenRead?: boolean
    }): Promise<void>

    export function removeEntry(options: { url: string }): Promise<void>

    export function query(options: {
      url?: string
      hasBeenRead?: boolean
    }): Promise<ReadingListEntry[]>
  }
}

// background.ts - now fully typed
export default defineBackground(() => {
  browser.readingList.addEntry({
    url: 'https://example.com',
    title: 'Example',
    hasBeenRead: false
  })
})
```

**WXT v0.20+ type system:** WXT now uses `@types/chrome`-based types instead of `@types/webextension-polyfill`. This means:
- Most Chrome APIs (including `sidePanel`) are already typed
- Augment the `chrome` namespace directly, not `wxt/browser`
- Use optional chaining for APIs not available on all browsers: `browser.sidePanel?.open()`

**When to augment:**
- Experimental Chrome APIs not yet in `@types/chrome`
- Browser-specific APIs (Firefox-only, Safari-only)
- APIs behind flags (Chrome Origin Trials, etc.)

Reference: [TypeScript Module Augmentation](https://www.typescriptlang.org/docs/handbook/declaration-merging.html)
