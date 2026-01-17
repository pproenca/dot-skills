---
title: Test Edge Cases and Boundaries
impact: MEDIUM
impactDescription: Catches bugs that happy-path-only tests miss
tags: assert, edge-cases, boundaries, null, empty, error-handling
---

## Test Edge Cases and Boundaries

Tests that only cover the happy path miss bugs that occur with edge cases. Empty arrays, null values, zero, negative numbers, and boundary conditions are where most bugs hide.

**Incorrect (happy path only):**

```typescript
import { describe, it, expect } from 'vitest'

describe('calculateDiscount', () => {
  it('should apply discount', () => {
    expect(calculateDiscount(100, 10)).toBe(90)
  })
})
// What about 0% discount? 100% discount? Negative prices? Null input?
```

**Correct (edge cases covered):**

```typescript
import { describe, it, expect } from 'vitest'

describe('calculateDiscount', () => {
  // Happy path
  it('should apply 10% discount to $100', () => {
    expect(calculateDiscount(100, 10)).toBe(90)
  })

  // Zero boundary
  it('should handle 0% discount', () => {
    expect(calculateDiscount(100, 0)).toBe(100)
  })

  // Upper boundary
  it('should handle 100% discount', () => {
    expect(calculateDiscount(100, 100)).toBe(0)
  })

  // Zero price
  it('should handle $0 price', () => {
    expect(calculateDiscount(0, 50)).toBe(0)
  })

  // Error cases
  it('should throw for negative discount', () => {
    expect(() => calculateDiscount(100, -10)).toThrow('Discount cannot be negative')
  })

  it('should throw for discount over 100%', () => {
    expect(() => calculateDiscount(100, 150)).toThrow('Discount cannot exceed 100%')
  })

  // Null/undefined
  it('should throw for null price', () => {
    expect(() => calculateDiscount(null, 10)).toThrow()
  })
})
```

**Common edge cases checklist:**

| Category | Cases to Test |
|----------|---------------|
| Numbers | 0, 1, -1, MAX_SAFE_INTEGER, NaN, Infinity |
| Strings | "", " ", very long strings, special characters |
| Arrays | [], [single item], [many items] |
| Objects | {}, null, missing properties |
| Dates | past, future, now, invalid dates |
| Async | timeout, network error, empty response |

**Benefits:**
- Catches bugs before production
- Documents expected behavior at boundaries
- Improves code robustness

Reference: [Vitest Test Patterns](https://vitest.dev/api/)
