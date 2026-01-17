---
title: Use skip and only Appropriately
impact: LOW
impactDescription: Prevents accidentally committing focused or skipped tests
tags: org, skip, only, debugging, ci
---

## Use skip and only Appropriately

`test.only` and `test.skip` are useful during development but dangerous when committed. CI should catch these to prevent accidentally running incomplete test suites.

**During development (acceptable):**

```typescript
import { describe, it, expect } from 'vitest'

describe('FeatureUnderDevelopment', () => {
  // Focus on the test you're writing
  it.only('should handle the new case', () => {
    expect(newFeature()).toBe(true)
  })

  it('other test that would slow you down', () => {
    // This won't run while you focus on the above
  })
})
```

**In committed code (problematic):**

```typescript
// DON'T commit this!
it.only('should work', () => {}) // Only this test runs, all others skipped

// Also problematic
it.skip('broken test we ignore', () => {}) // Technical debt accumulating
```

**CI protection with eslint:**

```javascript
// .eslintrc.js
module.exports = {
  rules: {
    'vitest/no-focused-tests': 'error',  // Fails on .only
    'vitest/no-disabled-tests': 'warn',  // Warns on .skip
  },
}
```

**Vitest CLI protection:**

```bash
# Fail if .only tests are found
vitest run --allowOnly=false
```

**Proper skip usage with reason:**

```typescript
// If you must skip, document why
it.skip('should integrate with legacy API', () => {
  // TODO: Re-enable when legacy API migration complete (JIRA-1234)
})

// Or use todo for planned tests
it.todo('should handle rate limiting')
```

**Benefits:**
- Full test suite always runs in CI
- Skipped tests don't accumulate silently
- Clear tracking of incomplete tests

Reference: [Vitest Only and Skip](https://vitest.dev/api/#test-only)
