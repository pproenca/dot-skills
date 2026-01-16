---
title: Maintain Type Safety in Mocks
impact: MEDIUM
impactDescription: Catches mock/implementation mismatches at compile time instead of runtime
tags: mock, typescript, type-safety, vi.mocked, MockedFunction
---

## Maintain Type Safety in Mocks

Mocks without proper typing can drift from real implementations. When the real function signature changes, untyped mocks continue to compile but tests test the wrong thing.

**Incorrect (untyped mocks):**

```typescript
import { describe, it, expect, vi } from 'vitest'
import { fetchUser } from './api'

vi.mock('./api')

describe('UserService', () => {
  it('should fetch user', async () => {
    // No type checking - could return anything
    (fetchUser as any).mockResolvedValue({ name: 'Alice' })
    // Missing 'id' field, but TypeScript doesn't catch it

    const user = await fetchUser(1)
    expect(user.name).toBe('Alice')
  })
})
```

**Correct (properly typed mocks):**

```typescript
import { describe, it, expect, vi, type MockedFunction } from 'vitest'
import { fetchUser, type User } from './api'

vi.mock('./api')

// Type-safe mock reference
const mockedFetchUser = fetchUser as MockedFunction<typeof fetchUser>

describe('UserService', () => {
  it('should fetch user', async () => {
    // TypeScript enforces return type matches User
    mockedFetchUser.mockResolvedValue({ id: 1, name: 'Alice', email: 'a@b.com' })

    const user = await mockedFetchUser(1)
    expect(user).toEqual({ id: 1, name: 'Alice', email: 'a@b.com' })
  })
})
```

**Using vi.mocked helper:**

```typescript
import { describe, it, expect, vi } from 'vitest'
import { fetchUser } from './api'

vi.mock('./api')

describe('UserService', () => {
  it('should fetch user', async () => {
    // vi.mocked provides proper typing automatically
    vi.mocked(fetchUser).mockResolvedValue({
      id: 1,
      name: 'Alice',
      email: 'alice@example.com',
    })

    const user = await fetchUser(1)
    expect(user.name).toBe('Alice')
  })
})
```

**Type-safe mock factories:**

```typescript
function createMockUser(overrides?: Partial<User>): User {
  return {
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    ...overrides,
  }
}

vi.mocked(fetchUser).mockResolvedValue(createMockUser({ name: 'Alice' }))
```

**Benefits:**
- Compile-time errors when mock returns wrong type
- IDE autocomplete for mock methods
- Mocks stay in sync with real implementations

Reference: [Vitest vi.mocked](https://vitest.dev/api/vi.html#vi-mocked)
