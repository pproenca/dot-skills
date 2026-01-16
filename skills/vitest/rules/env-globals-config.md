---
title: Configure Globals Consistently
impact: LOW
impactDescription: Determines whether imports are required for test APIs
tags: env, globals, configuration, imports, describe, it, expect
---

## Configure Globals Consistently

Vitest can inject test APIs (`describe`, `it`, `expect`) globally or require explicit imports. Both approaches work, but mixing them causes confusion. Choose one and apply consistently.

**Option 1: Explicit imports (default, recommended):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    globals: false, // Default
  },
})
```

```typescript
// Tests require imports - explicit dependencies
import { describe, it, expect, vi } from 'vitest'

describe('Calculator', () => {
  it('should add numbers', () => {
    expect(add(1, 2)).toBe(3)
  })
})
```

**Option 2: Global injection:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    globals: true,
  },
})
```

```typescript
// vitest.d.ts (for TypeScript)
/// <reference types="vitest/globals" />
```

```typescript
// Tests use globals - no imports needed
describe('Calculator', () => {
  it('should add numbers', () => {
    expect(add(1, 2)).toBe(3)
  })
})
```

**Pros and cons:**

| Approach | Pros | Cons |
|----------|------|------|
| Explicit imports | Clear dependencies, better IDE support, tree-shakeable | More boilerplate |
| Globals | Less boilerplate, Jest-like | Implicit dependencies, needs type reference |

**ESLint configuration for globals:**

```javascript
// .eslintrc.js
module.exports = {
  env: {
    'vitest-globals/env': true,
  },
  plugins: ['vitest-globals'],
}
```

**Benefits:**
- Consistent codebase
- No confusion about where APIs come from
- Proper TypeScript support either way

Reference: [Vitest Globals](https://vitest.dev/config/#globals)
