---
title: Use document_idle for Content Script Injection
impact: CRITICAL
impactDescription: eliminates page load blocking, faster initial render
tags: content, run_at, injection, timing, performance
---

## Use document_idle for Content Script Injection

The default `document_idle` timing injects scripts after the DOM is ready but before all resources load. Using `document_start` blocks the page while your script runs. Only use earlier injection when absolutely necessary.

**Incorrect (blocks page rendering):**

```json
{
  "content_scripts": [{
    "matches": ["https://example.com/*"],
    "js": ["content.js"],
    "run_at": "document_start"
  }]
}
```

```javascript
// content.js - Heavy initialization at document_start
const config = loadExtensionConfig();  // Synchronous
setupMutationObservers();
initializeFeatures();
// All this runs before page renders anything
```

**Correct (non-blocking injection):**

```json
{
  "content_scripts": [{
    "matches": ["https://example.com/*"],
    "js": ["content.js"],
    "run_at": "document_idle"
  }]
}
```

```javascript
// content.js - Runs after DOM is ready
async function initialize() {
  const config = await chrome.storage.local.get(['config']);
  setupMutationObservers();
  initializeFeatures();
}

initialize();
```

**When document_start IS appropriate:**
- Injecting CSS to prevent flash of unstyled content
- Intercepting/modifying page scripts before they run
- Observing very early DOM mutations

**Injection timing reference:**
- `document_start` - Before DOM construction begins
- `document_end` - After DOM ready, before subresources
- `document_idle` - After DOM ready, during/after subresource load (default)

Reference: [Content Scripts](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts)
