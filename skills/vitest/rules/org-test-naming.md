---
title: Write Descriptive Test Names
impact: LOW
impactDescription: Improves test documentation and failure debugging
tags: org, naming, conventions, readability
---

## Write Descriptive Test Names

Test names are documentation. Vague names like "works" or "handles input" don't explain what the test verifies. Write names that describe the behavior being tested.

**Incorrect (vague names):**

```typescript
import { describe, it, expect } from 'vitest'

describe('Calculator', () => {
  it('works', () => {
    expect(calc.add(1, 2)).toBe(3)
  })

  it('handles edge case', () => {
    expect(calc.divide(10, 0)).toBe(Infinity)
  })

  it('test', () => {
    expect(calc.multiply(-1, 5)).toBe(-5)
  })
})
```

**Correct (descriptive names):**

```typescript
import { describe, it, expect } from 'vitest'

describe('Calculator', () => {
  describe('add', () => {
    it('should return sum of two positive numbers', () => {
      expect(calc.add(1, 2)).toBe(3)
    })

    it('should handle negative numbers', () => {
      expect(calc.add(-1, 2)).toBe(1)
    })
  })

  describe('divide', () => {
    it('should return Infinity when dividing by zero', () => {
      expect(calc.divide(10, 0)).toBe(Infinity)
    })
  })

  describe('multiply', () => {
    it('should return negative when multiplying positive by negative', () => {
      expect(calc.multiply(-1, 5)).toBe(-5)
    })
  })
})
```

**Naming patterns:**

| Pattern | Example |
|---------|---------|
| `should [verb] [outcome]` | "should return sum of two numbers" |
| `when [condition]` | "when input is empty" |
| `given [context]` | "given user is logged in" |
| `[action] [result]` | "creates user with hashed password" |

**Test name from failure:**

```
FAIL  Calculator > divide > should return Infinity when dividing by zero
      Expected: Infinity
      Received: NaN
```

Clear failure message tells you exactly what broke.

**Benefits:**
- Tests serve as documentation
- Failures are self-explanatory
- Easy to understand test coverage

Reference: [Vitest Test Naming](https://vitest.dev/api/)
