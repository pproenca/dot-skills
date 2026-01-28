---
title: Configure Cross-Browser Compatibility
impact: MEDIUM
impactDescription: enables single codebase for Chrome, Firefox, Safari, Edge
tags: manifest, cross-browser, firefox, safari, mv2, mv3
---

## Configure Cross-Browser Compatibility

WXT can build for multiple browsers from single codebase. Use browser-specific configuration and conditional code for compatibility.

**Incorrect (Chrome-only assumptions):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    // MV3-only features that Firefox doesn't support
    side_panel: {
      default_path: 'sidepanel.html'
    }
  }
})

// background.ts
export default defineBackground(() => {
  // Chrome-only API
  chrome.sidePanel.open({ windowId: 1 })
})
```

**Correct (cross-browser configuration):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: ({ browser, manifestVersion }) => ({
    // Shared configuration
    permissions: ['storage'],

    // Browser-specific sidepanel (Chrome/Edge only)
    ...(browser === 'chrome' && {
      side_panel: { default_path: 'sidepanel.html' }
    }),

    // Firefox uses sidebar_action instead
    ...(browser === 'firefox' && {
      sidebar_action: {
        default_panel: 'sidebar.html',
        default_title: 'My Extension'
      }
    })
  })
})

// background.ts
export default defineBackground(() => {
  // Check API availability before use
  if ('sidePanel' in browser) {
    browser.sidePanel.open({ windowId: 1 })
  } else if ('sidebarAction' in browser) {
    browser.sidebarAction.open()
  }
})
```

**Browser targeting in entrypoints:**

```typescript
// entrypoints/chrome-only.content.ts
export default defineContentScript({
  matches: ['*://*/*'],
  include: ['chrome'], // Only included in Chrome builds
  main() {
    // Chrome-specific functionality
  }
})

// entrypoints/firefox-only.content.ts
export default defineContentScript({
  matches: ['*://*/*'],
  include: ['firefox'], // Only included in Firefox builds
  main() {
    // Firefox-specific functionality
  }
})
```

Reference: [WXT Browser Targets](https://wxt.dev/guide/essentials/config/browser)
