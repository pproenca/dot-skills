---
title: Type Entrypoint Options Explicitly
impact: LOW-MEDIUM
impactDescription: prevents runtime failures from config typos
tags: ts, entrypoint, types, configuration
---

## Type Entrypoint Options Explicitly

Use explicit types for entrypoint configuration to catch typos and invalid options at build time instead of runtime.

**Incorrect (untyped configuration):**

```typescript
export default defineContentScript({
  matches: ['*://*.example.com/*'],
  runAt: 'documet_start', // Typo not caught
  allframes: true, // Wrong casing not caught
  main() {}
})
```

**Correct (typed configuration):**

```typescript
import type { ContentScriptDefinition } from 'wxt/sandbox'

const config: ContentScriptDefinition = {
  matches: ['*://*.example.com/*'],
  runAt: 'document_start', // TypeScript autocomplete helps
  allFrames: true, // Correct casing enforced
}

export default defineContentScript({
  ...config,
  main(ctx) {
    // ctx is properly typed as ContentScriptContext
  }
})
```

**Background script with type safety:**

```typescript
import type { BackgroundDefinition } from 'wxt/sandbox'

export default defineBackground({
  persistent: false, // TypeScript shows this is MV2-only
  type: 'module',
  main() {
    // Properly typed context
  }
} satisfies BackgroundDefinition)
```

**Note:** The `satisfies` keyword (TypeScript 4.9+) provides type checking while preserving the specific literal types.

Reference: [WXT TypeScript Support](https://wxt.dev/guide/essentials/entrypoints)
