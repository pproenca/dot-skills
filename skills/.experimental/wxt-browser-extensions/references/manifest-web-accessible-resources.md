---
title: Scope Web Accessible Resources Narrowly
impact: MEDIUM
impactDescription: prevents fingerprinting and resource theft
tags: manifest, web-accessible-resources, security, fingerprinting
---

## Scope Web Accessible Resources Narrowly

Web accessible resources can be accessed by any web page. Limit them to specific domains to prevent extension fingerprinting and unauthorized resource access.

**Incorrect (resources accessible everywhere):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    web_accessible_resources: [{
      resources: ['images/*', 'scripts/*', 'styles/*'],
      matches: ['<all_urls>'] // Any site can access these
    }]
  }
})
// Sites can detect your extension by probing for these resources
```

**Correct (scoped to necessary domains):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    web_accessible_resources: [
      {
        // Main world scripts - needed on specific sites
        resources: ['injected-scripts/*.js'],
        matches: ['https://*.example.com/*']
      },
      {
        // Extension ID used for cross-origin requests
        resources: ['fonts/*.woff2'],
        matches: ['https://*.myservice.com/*'],
        use_dynamic_url: true // Randomize URL to prevent fingerprinting
      }
    ]
  }
})
```

**Alternative (inject content via content script instead):**

```typescript
// Instead of web accessible CSS
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  css: ['styles/injected.css'], // Injected directly, not web accessible
  main() {
    // Content script code
  }
})
```

**Note:** Use `use_dynamic_url: true` in MV3 to generate randomized URLs that change per session, making fingerprinting harder.

Reference: [Chrome Web Accessible Resources](https://developer.chrome.com/docs/extensions/reference/manifest/web-accessible-resources)
