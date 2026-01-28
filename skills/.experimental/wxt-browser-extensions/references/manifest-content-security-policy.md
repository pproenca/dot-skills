---
title: Configure Content Security Policy Correctly
impact: MEDIUM
impactDescription: prevents CSP build errors in MV3 extensions
tags: manifest, csp, security, content-security-policy
---

## Configure Content Security Policy Correctly

MV3 enforces strict CSP for extension pages. Configure CSP to allow necessary functionality while maintaining security.

**Incorrect (trying to bypass CSP):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    content_security_policy: {
      extension_pages: "script-src 'self' 'unsafe-inline' 'unsafe-eval';"
      // Error: MV3 blocks unsafe-inline and unsafe-eval
    }
  }
})
```

**Correct (MV3-compliant CSP):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    content_security_policy: {
      extension_pages: "script-src 'self' 'wasm-unsafe-eval'; object-src 'self'"
    }
  }
})
```

**For WASM support:**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    content_security_policy: {
      // Allow WASM compilation
      extension_pages: "script-src 'self' 'wasm-unsafe-eval'; object-src 'self'"
    }
  }
})
```

**For sandbox pages (less restricted):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    sandbox: {
      pages: ['sandbox.html']
    },
    content_security_policy: {
      // Sandbox pages can have eval for templating engines
      sandbox: "sandbox allow-scripts; script-src 'self' 'unsafe-eval'"
    }
  }
})
```

**Note:** Sandbox pages cannot use extension APIs but can run less-restricted JavaScript. Use postMessage to communicate between sandbox and extension pages.

Reference: [Chrome Extension CSP](https://developer.chrome.com/docs/extensions/develop/migrate/improve-security)
