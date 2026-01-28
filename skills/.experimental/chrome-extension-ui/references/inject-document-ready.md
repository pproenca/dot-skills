---
title: Inject UI After DOM Ready
impact: MEDIUM-HIGH
impactDescription: prevents null reference errors and race conditions
tags: inject, dom-ready, timing, content-script, initialization
---

## Inject UI After DOM Ready

Wait for the DOM to be ready before injecting UI elements. Injecting too early causes errors when target elements don't exist yet.

**Incorrect (injects before DOM ready):**

```typescript
// content.js - Runs immediately at document_start
const targetElement = document.querySelector('.page-header')
targetElement.appendChild(myToolbar)
// Error: Cannot read properties of null (targetElement is null)
```

**Correct (waits for DOM ready):**

```typescript
// content.js - Proper initialization timing
function initExtension() {
  const targetElement = document.querySelector('.page-header')
  if (targetElement) {
    injectToolbar(targetElement)
  }
}

// Option 1: Use document_idle in manifest (default, recommended)
// manifest.json: "run_at": "document_idle"
initExtension()

// Option 2: Check DOM state explicitly
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initExtension)
} else {
  initExtension()
}

// Option 3: For dynamically loaded content, use MutationObserver
function waitForElement(selector) {
  return new Promise((resolve) => {
    const element = document.querySelector(selector)
    if (element) {
      resolve(element)
      return
    }

    const observer = new MutationObserver((mutations, obs) => {
      const element = document.querySelector(selector)
      if (element) {
        obs.disconnect()
        resolve(element)
      }
    })

    observer.observe(document.body, {
      childList: true,
      subtree: true
    })
  })
}

// Usage for SPAs and dynamic content
async function initForDynamicSite() {
  const header = await waitForElement('.page-header')
  injectToolbar(header)
}
```

**Manifest timing options:**

```json
{
  "content_scripts": [{
    "matches": ["*://*.example.com/*"],
    "js": ["content.js"],
    "run_at": "document_idle"
  }]
}
```

| run_at | When it runs | Use case |
|--------|--------------|----------|
| `document_start` | Before DOM exists | Inject early styles, intercept requests |
| `document_end` | DOM ready, resources loading | Most UI injection |
| `document_idle` | DOM ready, page loaded (default) | Non-critical UI, safest option |

Reference: [Content Scripts run_at](https://developer.chrome.com/docs/extensions/reference/manifest/content-scripts)
