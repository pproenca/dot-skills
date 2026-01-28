---
title: Use watch() for Reactive Storage Updates
impact: HIGH
impactDescription: eliminates polling and ensures UI consistency
tags: store, watch, reactive, sync, onChanged
---

## Use watch() for Reactive Storage Updates

Use `watch()` to react to storage changes instead of polling or manual refresh. This ensures all contexts (popup, content scripts, options) stay synchronized.

**Incorrect (polling for changes):**

```typescript
// popup.ts - polls for settings changes
let currentSettings: Settings

async function init() {
  currentSettings = await settings.getValue()
  renderUI(currentSettings)

  // Wasteful polling every second
  setInterval(async () => {
    const newSettings = await settings.getValue()
    if (JSON.stringify(newSettings) !== JSON.stringify(currentSettings)) {
      currentSettings = newSettings
      renderUI(currentSettings)
    }
  }, 1000)
}
```

**Correct (reactive watch):**

```typescript
// popup.ts - reacts to changes
async function init() {
  const currentSettings = await settings.getValue()
  renderUI(currentSettings)

  // Automatically updates when storage changes
  settings.watch((newSettings) => {
    renderUI(newSettings)
  })
}
```

**With cleanup for content scripts:**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    const unwatch = settings.watch((newSettings) => {
      applySettingsToPage(newSettings)
    })

    // Clean up when content script invalidated
    ctx.onInvalidated(() => {
      unwatch()
    })
  }
})
```

**Note:** `watch()` uses `browser.storage.onChanged` internally, which fires across all extension contexts automatically.

Reference: [WXT Storage Watch](https://wxt.dev/storage)
