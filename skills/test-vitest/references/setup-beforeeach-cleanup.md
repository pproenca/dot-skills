---
title: Clean Up State in afterEach Hooks
impact: CRITICAL
impactDescription: Prevents test pollution where one test's side effects cause subsequent tests to fail
tags: setup, afterEach, cleanup, isolation, state-pollution
---

## Clean Up State in afterEach Hooks

Tests that modify global state, DOM, or shared resources must clean up after themselves. Without cleanup, tests become order-dependent - they pass in isolation but fail when run together, or vice versa.

**Incorrect (no cleanup):**

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'

describe('ThemeService', () => {
  beforeEach(() => {
    // Sets global state
    window.localStorage.setItem('theme', 'dark')
  })

  it('should read theme from storage', () => {
    expect(ThemeService.getTheme()).toBe('dark')
  })

  // Other tests may fail because localStorage still has 'dark'
})
```

**Correct (proper cleanup):**

```typescript
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'

describe('ThemeService', () => {
  beforeEach(() => {
    window.localStorage.setItem('theme', 'dark')
  })

  afterEach(() => {
    // Clean up after each test
    window.localStorage.clear()
  })

  it('should read theme from storage', () => {
    expect(ThemeService.getTheme()).toBe('dark')
  })
})
```

**Common cleanup patterns:**

```typescript
import { describe, afterEach, vi } from 'vitest'

describe('Integration tests', () => {
  afterEach(() => {
    // Restore all mocks
    vi.restoreAllMocks()

    // Clear all timers
    vi.useRealTimers()

    // Clean DOM
    document.body.innerHTML = ''

    // Clear storage
    localStorage.clear()
    sessionStorage.clear()

    // Reset modules
    vi.resetModules()
  })
})
```

**Benefits:**
- Tests are independent of execution order
- No mysterious failures when running full suite
- Easier debugging - each test starts clean

Reference: [Vitest Setup and Teardown](https://vitest.dev/api/#setup-and-teardown)
