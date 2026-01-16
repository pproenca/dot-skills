---
title: Use happy-dom Over jsdom When Possible
impact: HIGH
impactDescription: 2-3× faster DOM operations compared to jsdom
tags: perf, happy-dom, jsdom, environment, dom-testing
---

## Use happy-dom Over jsdom When Possible

happy-dom is significantly faster than jsdom for most DOM testing scenarios. While jsdom has broader compatibility, happy-dom handles the majority of use cases with better performance.

**Slower (jsdom):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    environment: 'jsdom',
  },
})
```

**Faster (happy-dom):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    environment: 'happy-dom',
  },
})
```

**Per-file environment override:**

```typescript
// tests/complex-dom.test.ts
/**
 * @vitest-environment jsdom
 */

// This file uses jsdom for better compatibility
import { describe, it, expect } from 'vitest'

describe('Complex DOM interactions', () => {
  it('should handle edge case that happy-dom misses', () => {
    // Test code that requires jsdom
  })
})
```

**When to prefer jsdom:**
- Tests rely on specific DOM features not implemented in happy-dom
- Third-party libraries require jsdom
- You need `MutationObserver` edge cases
- Legacy code with complex DOM manipulation

**When happy-dom works well:**
- React/Vue/Svelte component testing
- Basic DOM queries and manipulation
- Testing Library based tests
- Most application testing scenarios

**Mixed configuration:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Default to happy-dom for speed
    environment: 'happy-dom',

    // Override for specific files
    environmentMatchGlobs: [
      ['**/jsdom-required/**', 'jsdom'],
      ['**/node-only/**', 'node'],
    ],
  },
})
```

**Benefits:**
- Faster test execution
- Lower memory usage
- Same API as jsdom for most operations

Reference: [happy-dom GitHub](https://github.com/capricorn86/happy-dom)
