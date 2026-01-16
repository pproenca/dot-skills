---
title: Choose vi.spyOn vs vi.mock Appropriately
impact: HIGH
impactDescription: Prevents over-mocking and ensures tests exercise real code paths
tags: mock, vi.spyOn, vi.mock, partial-mocking, testing-strategy
---

## Choose vi.spyOn vs vi.mock Appropriately

`vi.mock` replaces entire modules, while `vi.spyOn` wraps individual functions. Using `vi.mock` when you only need to mock one function leads to over-mocking - your tests stop exercising real code.

**Incorrect (over-mocking with vi.mock):**

```typescript
import { describe, it, expect, vi } from 'vitest'
import { formatDate, parseDate, validateDate } from './dateUtils'

// Mocks ALL exports - tests won't use real formatDate or parseDate
vi.mock('./dateUtils', () => ({
  formatDate: vi.fn(),
  parseDate: vi.fn(),
  validateDate: vi.fn().mockReturnValue(true),
}))

describe('DatePicker', () => {
  it('should validate selected date', () => {
    // Only testing that validateDate is called, not that it works
    expect(validateDate('2024-01-01')).toBe(true)
  })
})
```

**Correct (targeted mocking with vi.spyOn):**

```typescript
import { describe, it, expect, vi, afterEach } from 'vitest'
import * as dateUtils from './dateUtils'

describe('DatePicker', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('should format valid dates', () => {
    // Uses real formatDate implementation
    expect(dateUtils.formatDate(new Date('2024-01-01'))).toBe('Jan 1, 2024')
  })

  it('should handle validation errors gracefully', () => {
    // Only mock validateDate for this specific test
    vi.spyOn(dateUtils, 'validateDate').mockReturnValue(false)

    const result = dateUtils.validateDate('invalid')
    expect(result).toBe(false)
  })
})
```

**When to use each:**

| Approach | Use When |
|----------|----------|
| `vi.mock` | Mocking external dependencies (APIs, databases), entire modules |
| `vi.spyOn` | Mocking specific functions, preserving other behavior |
| `vi.spyOn` with `mockImplementation` | Temporarily changing behavior for one test |

**Partial mocking pattern:**

```typescript
vi.mock('./api', async () => {
  const actual = await vi.importActual('./api')
  return {
    ...actual,
    // Only mock fetchUser, keep other exports real
    fetchUser: vi.fn(),
  }
})
```

**Benefits:**
- Tests exercise more real code
- Easier to identify what's actually being tested
- Less brittle when module internals change

Reference: [Vitest Mocking](https://vitest.dev/guide/mocking)
