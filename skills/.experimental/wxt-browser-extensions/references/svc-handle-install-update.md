---
title: Handle Install and Update Events
impact: CRITICAL
impactDescription: prevents broken state after extension updates
tags: svc, install, update, lifecycle, migration
---

## Handle Install and Update Events

The `runtime.onInstalled` event fires on first install, extension update, and browser update. Use it to initialize storage, run migrations, and set up default state.

**Incorrect (no install/update handling):**

```typescript
export default defineBackground(() => {
  // Assumes storage is already initialized
  browser.action.onClicked.addListener(async () => {
    const settings = await storage.getItem('local:settings')
    // Crashes on first install when settings is null
    applyTheme(settings.theme)
  })
})
```

**Correct (proper lifecycle handling):**

```typescript
const settings = storage.defineItem('local:settings', {
  fallback: { theme: 'light', notifications: true }
})

export default defineBackground(() => {
  browser.runtime.onInstalled.addListener(async (details) => {
    if (details.reason === 'install') {
      // First install - initialize defaults
      await settings.setValue({ theme: 'light', notifications: true })
      await browser.tabs.create({ url: 'https://example.com/welcome' })
    } else if (details.reason === 'update') {
      // Extension updated - run migrations
      const currentSettings = await settings.getValue()
      if (!('notifications' in currentSettings)) {
        await settings.setValue({ ...currentSettings, notifications: true })
      }
    }
  })

  browser.action.onClicked.addListener(async () => {
    const currentSettings = await settings.getValue()
    applyTheme(currentSettings.theme)
  })
})
```

**Note:** Always use `storage.defineItem` with `fallback` to handle cases where storage hasn't been initialized.

Reference: [Chrome Runtime onInstalled](https://developer.chrome.com/docs/extensions/reference/api/runtime#event-onInstalled)
