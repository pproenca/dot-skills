---
title: Use Positioned Iframe for Complex UI
impact: MEDIUM
impactDescription: enables full framework UI without performance cost
tags: ui, iframe, content-script, isolation, performance
---

## Use Positioned Iframe for Complex UI

For complex UIs injected into pages, use a positioned iframe instead of rendering directly. This provides complete isolation and allows using full frameworks without affecting page performance.

**Incorrect (heavy UI in content script):**

```typescript
export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    // Full React app in content script - bloats every page
    const ui = createShadowRootUi(ctx, {
      name: 'complex-ui',
      onMount: (container) => {
        const root = ReactDOM.createRoot(container)
        root.render(
          <QueryClientProvider client={queryClient}>
            <ComplexDashboard /> {/* 200KB+ of components */}
          </QueryClientProvider>
        )
      }
    })
    ui.mount()
  }
})
```

**Correct (iframe for complex UI):**

```typescript
// entrypoints/content.ts - lightweight injector
export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    const ui = createIframeUi(ctx, {
      page: '/dashboard.html', // Full page in extension context
      position: 'inline',
      anchor: 'body',
      onMount: (wrapper, iframe) => {
        // Style the iframe container
        Object.assign(iframe.style, {
          position: 'fixed',
          bottom: '20px',
          right: '20px',
          width: '400px',
          height: '500px',
          border: 'none',
          borderRadius: '8px',
          boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
          zIndex: '2147483647'
        })
      }
    })

    browser.runtime.onMessage.addListener((message) => {
      if (message.type === 'TOGGLE_DASHBOARD') {
        ui.mounted ? ui.remove() : ui.mount()
      }
    })
  }
})

// entrypoints/dashboard.html - full app runs in iframe
// Can use any framework, isolated from page
```

**Benefits of iframe approach:**
- Complete CSS isolation (no Shadow DOM complexity)
- Content script stays tiny (just injection logic)
- Full extension API access in iframe
- Page performance unaffected by heavy UI

Reference: [WXT Iframe UI](https://wxt.dev/guide/essentials/content-script-ui#iframe-ui)
