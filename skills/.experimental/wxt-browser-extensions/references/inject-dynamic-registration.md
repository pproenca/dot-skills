---
title: Use Runtime Registration for Conditional Injection
impact: CRITICAL
impactDescription: enables permission-based content script injection
tags: inject, runtime, registration, permissions, dynamic
---

## Use Runtime Registration for Conditional Injection

Use runtime registration instead of manifest registration when content scripts should only inject after user grants optional permissions or based on user settings.

**Incorrect (always injected via manifest):**

```typescript
// Content script always runs on all sites
export default defineContentScript({
  matches: ['*://*/*'],
  main() {
    // Runs everywhere, even before user configures sites
    enhancePage()
  }
})
```

**Correct (runtime registration based on permissions):**

```typescript
// entrypoints/enhancer.content.ts
export default defineContentScript({
  matches: ['*://*/*'],
  registration: 'runtime', // Not in manifest, registered dynamically
  main() {
    enhancePage()
  }
})

// entrypoints/background.ts
export default defineBackground(() => {
  browser.permissions.onAdded.addListener(async (permissions) => {
    if (permissions.origins?.length) {
      // Register content script for newly permitted origins
      await browser.scripting.registerContentScripts([{
        id: 'enhancer',
        matches: permissions.origins,
        js: ['/content-scripts/enhancer.js']
      }])
    }
  })

  browser.permissions.onRemoved.addListener(async (permissions) => {
    if (permissions.origins?.length) {
      // Unregister when permissions revoked
      await browser.scripting.unregisterContentScripts({
        ids: ['enhancer']
      })
    }
  })
})
```

**When to use runtime registration:**
- Optional host permissions (user must grant per-site access)
- User-configurable site lists
- Enterprise deployments with site restrictions

Reference: [Chrome Scripting API](https://developer.chrome.com/docs/extensions/reference/api/scripting)
