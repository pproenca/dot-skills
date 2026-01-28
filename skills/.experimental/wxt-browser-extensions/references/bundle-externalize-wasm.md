---
title: Load WASM and Heavy Assets Dynamically
impact: MEDIUM-HIGH
impactDescription: reduces initial bundle by moving large assets to lazy loading
tags: bundle, wasm, assets, dynamic-import
---

## Load WASM and Heavy Assets Dynamically

WebAssembly modules and large assets should be loaded on-demand, not bundled into entry files. This keeps initial load fast for users who don't need heavy features.

**Incorrect (WASM bundled with content script):**

```typescript
// content.ts - WASM loaded even on pages that don't need it
import init, { processImage } from 'image-processor-wasm'

export default defineContentScript({
  matches: ['*://*/*'],
  async main() {
    await init()
    // Most pages won't use this feature
  }
})
```

**Correct (WASM loaded on demand):**

```typescript
// content.ts
export default defineContentScript({
  matches: ['*://*/*'],
  main() {
    browser.runtime.onMessage.addListener(async (message, sender, sendResponse) => {
      if (message.type === 'PROCESS_IMAGE') {
        // Load WASM only when needed
        const { init, processImage } = await import('image-processor-wasm')
        await init()
        const result = await processImage(message.imageData)
        sendResponse(result)
      }
      return true
    })
  }
})
```

**For public assets (load from extension URL):**

```typescript
// wxt.config.ts
export default defineConfig({
  manifest: {
    web_accessible_resources: [{
      resources: ['wasm/*.wasm'],
      matches: ['<all_urls>']
    }]
  }
})

// content.ts
async function loadWasm() {
  const wasmUrl = browser.runtime.getURL('wasm/processor.wasm')
  const response = await fetch(wasmUrl)
  const buffer = await response.arrayBuffer()
  const module = await WebAssembly.instantiate(buffer)
  return module.instance.exports
}
```

Reference: [WXT Public Assets](https://wxt.dev/guide/essentials/assets)
