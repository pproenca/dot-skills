---
title: Place All Runtime Code Inside main()
impact: CRITICAL
impactDescription: prevents build errors and undefined API access
tags: inject, content-script, main, entrypoint
---

## Place All Runtime Code Inside main()

WXT imports entrypoint files in a Node.js build environment where browser APIs don't exist. All code using `browser.*` APIs must be inside the `main()` function.

**Incorrect (API usage at module level):**

```typescript
// entrypoints/content.ts
browser.runtime.onMessage.addListener((message) => {
  // Error: browser is not defined during build
  handleMessage(message)
})

export default defineContentScript({
  matches: ['*://*.example.com/*'],
  main() {
    console.log('Content script loaded')
  }
})
```

**Correct (API usage inside main):**

```typescript
// entrypoints/content.ts
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  main() {
    browser.runtime.onMessage.addListener((message) => {
      handleMessage(message)
    })
    console.log('Content script loaded')
  }
})
```

**Note:** Pure utility functions without browser API usage can remain at module level for sharing between files.

Reference: [WXT Extension APIs](https://wxt.dev/guide/essentials/extension-apis)
