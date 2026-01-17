---
title: Choose toBe vs toEqual Correctly
impact: LOW
impactDescription: Prevents false positives from reference vs value comparison
tags: assert, toBe, toEqual, reference-equality, value-equality
---

## Choose toBe vs toEqual Correctly

`toBe` uses `Object.is()` for strict reference equality. `toEqual` performs deep value comparison. Using the wrong one causes confusing failures or false positives.

**Incorrect (wrong equality type):**

```typescript
import { describe, it, expect } from 'vitest'

describe('Equality', () => {
  it('should compare objects', () => {
    const a = { name: 'Alice' }
    const b = { name: 'Alice' }

    // FAILS - different object references
    expect(a).toBe(b)
  })

  it('should compare arrays', () => {
    const arr = [1, 2, 3]

    // FAILS - different array references
    expect(arr).toBe([1, 2, 3])
  })
})
```

**Correct (appropriate equality):**

```typescript
import { describe, it, expect } from 'vitest'

describe('Equality', () => {
  it('should compare object values', () => {
    const a = { name: 'Alice' }
    const b = { name: 'Alice' }

    // PASSES - same values
    expect(a).toEqual(b)
  })

  it('should compare array values', () => {
    const arr = [1, 2, 3]

    // PASSES - same values
    expect(arr).toEqual([1, 2, 3])
  })

  it('should verify same reference', () => {
    const obj = { name: 'Alice' }
    const ref = obj

    // PASSES - same reference
    expect(ref).toBe(obj)
  })
})
```

**Matcher selection guide:**

| Scenario | Use |
|----------|-----|
| Primitives (string, number, boolean) | `toBe` |
| Same object reference | `toBe` |
| Object/array value comparison | `toEqual` |
| Object with subset of properties | `toMatchObject` |
| Strict equality with undefined | `toStrictEqual` |

**toStrictEqual vs toEqual:**

```typescript
// toEqual ignores undefined properties
expect({ a: 1 }).toEqual({ a: 1, b: undefined }) // PASSES

// toStrictEqual is stricter
expect({ a: 1 }).toStrictEqual({ a: 1, b: undefined }) // FAILS
```

**Benefits:**
- Correct comparison semantics
- Clear test intentions
- No mysterious failures

Reference: [Vitest toBe vs toEqual](https://vitest.dev/api/expect#tobe)
