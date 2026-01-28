---
title: Minimize Content Script Size
impact: MEDIUM-HIGH
impactDescription: reduces page load impact by 50-200ms per page
tags: bundle, content-script, minification, performance
---

## Minimize Content Script Size

Content scripts run on every matching page. Large content scripts slow down page loads across all affected sites. Keep them minimal.

**Incorrect (heavy content script):**

```typescript
// content.ts - includes full UI framework and utilities
import React from 'react'
import ReactDOM from 'react-dom/client'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { FullFeaturedUI } from '@/components/FullFeaturedUI'

export default defineContentScript({
  matches: ['*://*/*'],
  main() {
    // 200KB+ content script on every page
    const root = ReactDOM.createRoot(container)
    root.render(
      <QueryClientProvider client={new QueryClient()}>
        <FullFeaturedUI />
      </QueryClientProvider>
    )
  }
})
```

**Correct (minimal content script, heavy UI in popup/iframe):**

```typescript
// content.ts - lightweight detection and injection only
export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    // Only inject UI when needed (~5KB)
    browser.runtime.onMessage.addListener((message) => {
      if (message.type === 'SHOW_UI') {
        injectMinimalUI(ctx)
      }
    })
  }
})

function injectMinimalUI(ctx: ContentScriptContext) {
  // Use WXT's createShadowRootUi for isolated styling
  const ui = createShadowRootUi(ctx, {
    name: 'my-extension-ui',
    position: 'inline',
    onMount: (container) => {
      // Minimal vanilla JS UI, or lazy-load framework
      container.innerHTML = `<button id="open-popup">Open</button>`
      container.querySelector('#open-popup')?.addEventListener('click', () => {
        browser.runtime.sendMessage({ type: 'OPEN_POPUP' })
      })
    }
  })
  ui.mount()
}
```

**Content script size targets:**
- Detection/injection only: < 10KB
- With minimal UI: < 30KB
- Maximum recommended: < 50KB

Reference: [WXT Content Script UI](https://wxt.dev/guide/essentials/content-script-ui)
