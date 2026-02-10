---
title: "Use #imports Virtual Module"
impact: HIGH
impactDescription: eliminates scattered import paths and enables auto-imports
tags: ts, imports, virtual-module, auto-imports, wxt-prepare
---

## Use #imports Virtual Module

WXT v0.20+ provides `#imports` as a unified virtual module for all WXT APIs. This replaces scattered imports from `wxt/storage`, `wxt/sandbox`, `wxt/client`, etc. WXT also auto-imports common utilities, so explicit imports are often unnecessary.

**Incorrect (scattered old import paths):**

```typescript
import { storage } from 'wxt/storage'
import { defineContentScript } from 'wxt/sandbox'
import { ContentScriptContext } from 'wxt/client'
import { createShadowRootUi } from 'wxt/utils/content-script-ui/shadow-root'

export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx: ContentScriptContext) {
    const settings = await storage.getItem('local:settings')
  }
})
```

**Correct (unified #imports or auto-imports):**

```typescript
// Option 1: Explicit imports from #imports
import { storage, createShadowRootUi } from '#imports'

// Option 2: Auto-imports (preferred) - no import needed
// WXT auto-imports: defineBackground, defineContentScript, browser, storage,
// createShadowRootUi, createIntegratedUi, createIframeUi, etc.

export default defineContentScript({
  matches: ['*://*/*'],
  main(ctx) {
    // storage, browser, and ctx type are all auto-imported
    const settings = await storage.getItem('local:settings')
  }
})
```

**Setup: Run `wxt prepare` to generate type declarations:**

```bash
# Generate .wxt/ directory with type declarations for #imports
wxt prepare

# Add to package.json scripts for new contributors
"scripts": {
  "prepare": "wxt prepare"
}
```

**Testing caveat:** `vi.mock()` must use actual import paths, not `#imports`:

```typescript
// Incorrect
vi.mock('#imports', () => ({ storage: mockStorage }))

// Correct - mock the actual module path
vi.mock('wxt/storage', () => ({ storage: mockStorage }))
```

**Note:** Auto-imports extend to files in `components/`, `composables/`, `hooks/`, and `utils/` directories. Configure via `imports` in `wxt.config.ts`. Set `imports: false` to disable.

Reference: [WXT Auto-Imports](https://wxt.dev/guide/essentials/config/auto-imports)
