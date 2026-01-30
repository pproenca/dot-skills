---
title: Remove Manual cleanup Calls
impact: HIGH
impactDescription: eliminates 2-3 lines of boilerplate per test file
tags: anti, cleanup, afterEach, setup
---

## Remove Manual cleanup Calls

Testing Library automatically calls `cleanup` after each test when using modern test frameworks (Jest, Vitest, Mocha with globals). Manual calls are unnecessary.

**Incorrect (manual cleanup):**

```tsx
import { render, cleanup } from '@testing-library/react'

afterEach(() => {
  cleanup()
})

test('renders dashboard', () => {
  render(<Dashboard />)
  // ...
})
// cleanup() is called twice - once manually, once automatically
```

**Correct (rely on automatic cleanup):**

```tsx
import { render } from '@testing-library/react'

test('renders dashboard', () => {
  render(<Dashboard />)
  // ...
})
// cleanup() runs automatically after test
```

**When manual cleanup IS needed:**
- Using a test framework without global `afterEach` (like AVA)
- Custom test runners without RTL integration

```tsx
// Only for frameworks without automatic cleanup
import { cleanup } from '@testing-library/react'
test.afterEach(cleanup)
```

Reference: [Testing Library - Cleanup](https://testing-library.com/docs/react-testing-library/api#cleanup)
