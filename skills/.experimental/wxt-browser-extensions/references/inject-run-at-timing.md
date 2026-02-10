---
title: Select Appropriate runAt Timing
impact: CRITICAL
impactDescription: prevents race conditions with page load
tags: inject, run-at, timing, dom, document-start
---

## Select Appropriate runAt Timing

The `runAt` option controls when content scripts execute. Wrong timing causes race conditions where scripts run before elements exist or after events have fired.

**Incorrect (default timing too late to intercept page scripts):**

```typescript
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  // Default runAt: 'document_idle' - runs after page scripts
  main() {
    // Too late - page's tracking script already initialized
    Object.defineProperty(window, 'trackingEnabled', {
      value: false,
      writable: false
    })
  }
})
```

**Correct (explicit timing for use case):**

```typescript
// For intercepting requests or modifying page before load
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  runAt: 'document_start',
  main() {
    // Runs before any page scripts
    Object.defineProperty(window, 'trackingEnabled', {
      value: false,
      writable: false
    })
  }
})

// For DOM manipulation after document ready
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  runAt: 'document_end',
  main() {
    // DOM is fully parsed but resources may still be loading
    const container = document.querySelector('.main-content')
    injectUI(container)
  }
})

// For non-critical enhancements (default, best performance)
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  runAt: 'document_idle',
  main() {
    // Runs when browser is idle, least impact on page load
    addEnhancementFeatures()
  }
})
```

**Timing reference:**
- `document_start`: Before any DOM exists, before page scripts
- `document_end`: After DOM parsed, before images/iframes loaded
- `document_idle`: After page fully loaded or browser idle

Reference: [Chrome Content Scripts runAt](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts#run_time)
