---
title: Restore Mocks After Each Test
impact: CRITICAL
impactDescription: Prevents mock leakage where mocked behavior persists into unrelated tests
tags: setup, mocks, restoreAllMocks, vi.restoreAllMocks, isolation
---

## Restore Mocks After Each Test

Mocks created with `vi.spyOn` or `vi.fn` persist across tests unless explicitly restored. A mock in one test can affect subsequent tests, causing mysterious failures or false positives.

**Incorrect (mocks not restored):**

```typescript
import { describe, it, expect, vi } from 'vitest'
import * as api from './api'

describe('UserService', () => {
  it('should handle API errors', () => {
    vi.spyOn(api, 'fetchUser').mockRejectedValue(new Error('Network error'))

    // Test error handling...
  })

  it('should fetch user data', async () => {
    // FAILS - fetchUser is still mocked from previous test!
    const user = await api.fetchUser(1)
    expect(user.name).toBe('Alice')
  })
})
```

**Correct (mocks restored):**

```typescript
import { describe, it, expect, vi, afterEach } from 'vitest'
import * as api from './api'

describe('UserService', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('should handle API errors', () => {
    vi.spyOn(api, 'fetchUser').mockRejectedValue(new Error('Network error'))
    // Test error handling...
  })

  it('should fetch user data', async () => {
    // Works - mock was restored
    const user = await api.fetchUser(1)
    expect(user.name).toBe('Alice')
  })
})
```

**Configuration option (recommended):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    restoreMocks: true,  // Automatically restore mocks after each test
  },
})
```

**Mock restoration methods:**

```typescript
// Restore all mocks to original implementation
vi.restoreAllMocks()

// Reset mock state but keep implementation
vi.resetAllMocks()

// Clear mock call history only
vi.clearAllMocks()
```

**Benefits:**
- Tests don't affect each other
- Predictable mock behavior
- Easier to reason about test isolation

Reference: [Vitest Mock Functions](https://vitest.dev/api/vi.html#vi-restoreallmocks)
