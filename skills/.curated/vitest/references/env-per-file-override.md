---
title: Override Environment Per File When Needed
impact: MEDIUM
impactDescription: Allows mixing node and browser tests without separate config files
tags: env, environment, docblock, jsdom, happy-dom
---

## Override Environment Per File When Needed

Not all tests need a DOM environment. Running DOM tests in node mode fails, while running pure logic tests in jsdom wastes resources. Use per-file environment overrides to match test needs.

**Incorrect (same environment for all):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // All tests run in jsdom, even pure logic tests
    environment: 'jsdom',
  },
})
```

**Correct (per-file environment):**

```typescript
// src/utils/math.test.ts
// Pure logic - no DOM needed, runs faster in node
import { describe, it, expect } from 'vitest'

describe('math utils', () => {
  it('should add numbers', () => {
    expect(add(1, 2)).toBe(3)
  })
})
```

```typescript
// src/components/Button.test.tsx
/**
 * @vitest-environment happy-dom
 */
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'

describe('Button', () => {
  it('should render', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
  })
})
```

**Environment options:**

| Environment | Use For |
|-------------|---------|
| `node` (default) | Pure logic, Node.js APIs, utilities |
| `jsdom` | Full DOM compatibility, complex browser APIs |
| `happy-dom` | Fast DOM testing, most component tests |
| `edge-runtime` | Edge function testing |

**Configuration-based overrides:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Default to node for speed
    environment: 'node',

    // Pattern-based overrides
    environmentMatchGlobs: [
      ['src/components/**', 'happy-dom'],
      ['src/hooks/**', 'happy-dom'],
      ['tests/e2e/**', 'jsdom'],
    ],
  },
})
```

**Benefits:**
- Faster tests for pure logic
- Correct environment for DOM tests
- Flexible per-test-file control

Reference: [Vitest Test Environment](https://vitest.dev/guide/environment)
