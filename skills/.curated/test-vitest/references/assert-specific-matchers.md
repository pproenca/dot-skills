---
title: Use Specific Matchers Over Generic Ones
impact: MEDIUM
impactDescription: Provides clearer failure messages and catches more specific bugs
tags: assert, matchers, specificity, error-messages
---

## Use Specific Matchers Over Generic Ones

Generic matchers like `toBe(true)` or `toEqual([])` produce vague failure messages. Specific matchers like `toBeEmpty()` or `toContain()` describe intent better and give actionable error messages.

**Incorrect (generic matchers):**

```typescript
import { describe, it, expect } from 'vitest'

describe('UserService', () => {
  it('should find users', () => {
    const users = service.findAll()

    // Failure: "expected false to be true"
    expect(users.length > 0).toBe(true)

    // Failure: "expected [] to equal ['Alice']"
    expect(users.map(u => u.name)).toEqual(['Alice'])

    // Failure: "expected null to be false"
    expect(users[0].active === true).toBe(true)
  })
})
```

**Correct (specific matchers):**

```typescript
import { describe, it, expect } from 'vitest'

describe('UserService', () => {
  it('should find users', () => {
    const users = service.findAll()

    // Failure: "expected [] not to be empty"
    expect(users).not.toHaveLength(0)

    // Failure: "expected [] to contain 'Alice'"
    expect(users.map(u => u.name)).toContain('Alice')

    // Failure: "expected { active: false } to have property active: true"
    expect(users[0]).toHaveProperty('active', true)
  })
})
```

**Common matcher upgrades:**

| Generic | Specific |
|---------|----------|
| `toBe(true)` | `toBeTruthy()` or specific condition |
| `toBe(false)` | `toBeFalsy()` or `not.toX()` |
| `toBe(null)` | `toBeNull()` |
| `toBe(undefined)` | `toBeUndefined()` |
| `toEqual([])` | `toHaveLength(0)` or `toBeEmpty()` |
| `expect(arr.includes(x)).toBe(true)` | `toContain(x)` |
| `expect(str.includes(x)).toBe(true)` | `toContain(x)` |
| `expect(obj.x).toBe(val)` | `toHaveProperty('x', val)` |
| `expect(typeof x).toBe('string')` | `expect.any(String)` |

**Benefits:**
- Clearer test intent
- More helpful failure messages
- Faster debugging

Reference: [Vitest Expect Matchers](https://vitest.dev/api/expect)
