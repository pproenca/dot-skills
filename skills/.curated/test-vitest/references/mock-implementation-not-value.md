---
title: Use mockImplementation for Dynamic Mocks
impact: HIGH
impactDescription: Enables context-aware mocks that respond differently based on input
tags: mock, mockImplementation, dynamic-mocks, conditional-behavior
---

## Use mockImplementation for Dynamic Mocks

`mockReturnValue` returns the same value every call. When tests need different responses based on input or call order, use `mockImplementation` for full control over mock behavior.

**Incorrect (static mock for dynamic needs):**

```typescript
import { describe, it, expect, vi } from 'vitest'

describe('UserCache', () => {
  it('should return cached user if exists', async () => {
    const cache = {
      get: vi.fn().mockReturnValue(null), // Always returns null
    }

    // How do we test cache hit vs cache miss with same mock?
    const cachedUser = await cache.get('user-1')
    expect(cachedUser).toBeNull() // Can only test one scenario
  })
})
```

**Correct (dynamic mock implementation):**

```typescript
import { describe, it, expect, vi } from 'vitest'

describe('UserCache', () => {
  it('should return cached user if exists, null otherwise', async () => {
    const cachedUsers = new Map([
      ['user-1', { id: 1, name: 'Alice' }],
    ])

    const cache = {
      get: vi.fn().mockImplementation((key: string) => {
        return cachedUsers.get(key) ?? null
      }),
    }

    // Test cache hit
    expect(cache.get('user-1')).toEqual({ id: 1, name: 'Alice' })

    // Test cache miss
    expect(cache.get('user-999')).toBeNull()
  })
})
```

**Sequential responses with mockImplementationOnce:**

```typescript
describe('RetryService', () => {
  it('should retry on failure then succeed', async () => {
    const api = {
      fetch: vi.fn()
        .mockImplementationOnce(() => { throw new Error('Network error') })
        .mockImplementationOnce(() => { throw new Error('Network error') })
        .mockImplementationOnce(() => ({ data: 'success' })),
    }

    const result = await retryService.fetchWithRetry(api.fetch, 3)

    expect(result).toEqual({ data: 'success' })
    expect(api.fetch).toHaveBeenCalledTimes(3)
  })
})
```

**Benefits:**
- Mocks behave like real implementations
- Test multiple scenarios in one test
- Full control over timing and conditions

Reference: [Vitest Mock Functions](https://vitest.dev/api/mock.html#mockimplementation)
