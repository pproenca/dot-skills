---
title: Use import.meta for Environment and Build Info
impact: LOW-MEDIUM
impactDescription: prevents hardcoded values and fragile runtime detection
tags: ts, import-meta, env, build, vite
---

## Use import.meta for Environment and Build Info

WXT exposes build information through `import.meta`. Use these instead of hardcoding values or relying on runtime detection.

**Incorrect (runtime detection and hardcoding):**

```typescript
export default defineBackground(() => {
  // Hardcoded, needs manual update
  const version = '1.2.3'

  // Fragile runtime detection
  const isDev = window.location.protocol === 'chrome-extension:'
    && !window.location.href.includes('production')

  // Manual browser sniffing
  const browser = navigator.userAgent.includes('Firefox') ? 'firefox' : 'chrome'
})
```

**Correct (import.meta.env):**

```typescript
export default defineBackground(() => {
  // Version from package.json (auto-updated)
  const version = browser.runtime.getManifest().version

  // Build mode from Vite
  const isDev = import.meta.env.DEV
  const isProd = import.meta.env.PROD
  const mode = import.meta.env.MODE // 'development' | 'production'

  // Target browser from WXT
  const targetBrowser = import.meta.env.BROWSER // 'chrome' | 'firefox' | 'edge' | 'safari'
  const manifestVersion = import.meta.env.MANIFEST_VERSION // 2 | 3

  if (isDev) {
    console.log(`Running ${targetBrowser} dev build (MV${manifestVersion})`)
  }
})
```

**Type declarations for custom env vars:**

```typescript
// types/env.d.ts
interface ImportMetaEnv {
  readonly VITE_API_URL: string
  readonly VITE_ANALYTICS_ID: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

// Usage
const apiUrl = import.meta.env.VITE_API_URL
```

**Conditional code by browser:**

```typescript
if (import.meta.env.BROWSER === 'firefox') {
  // Firefox-specific code
} else if (import.meta.env.BROWSER === 'chrome') {
  // Chrome-specific code
}
```

Reference: [WXT Environment Variables](https://wxt.dev/guide/essentials/config/environment)
