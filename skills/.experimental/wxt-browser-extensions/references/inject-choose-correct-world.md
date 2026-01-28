---
title: Choose the Correct Execution World
impact: CRITICAL
impactDescription: prevents undefined errors from wrong world selection
tags: inject, world, isolated, main, security
---

## Choose the Correct Execution World

Content scripts can run in ISOLATED (default) or MAIN world. ISOLATED has extension API access but cannot see page variables. MAIN can see page variables but loses extension API access.

**Incorrect (wrong world for use case):**

```typescript
// Trying to access page variables from ISOLATED world
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  main() {
    // undefined - page variables not visible in ISOLATED world
    const pageData = window.appState
    browser.runtime.sendMessage({ data: pageData })
  }
})
```

**Correct (use MAIN world for page access):**

```typescript
// entrypoints/page-reader.content.ts - ISOLATED world parent
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  async main() {
    // Inject into MAIN world to access page variables
    await injectScript('/page-reader-main.js', { keepInDom: true })

    // Receive data via custom events
    window.addEventListener('PAGE_DATA', ((event: CustomEvent) => {
      browser.runtime.sendMessage({ data: event.detail })
    }) as EventListener)
  }
})

// entrypoints/page-reader-main.ts - MAIN world script
export default defineUnlistedScript(() => {
  // Can access page variables
  const pageData = (window as any).appState
  window.dispatchEvent(new CustomEvent('PAGE_DATA', { detail: pageData }))
})
```

**When to use each world:**
- ISOLATED: DOM manipulation, extension API access, secure operations
- MAIN: Reading page JavaScript variables, intercepting XHR/fetch, modifying prototypes

Reference: [WXT Content Scripts - Isolated vs Main World](https://wxt.dev/guide/essentials/content-scripts)
