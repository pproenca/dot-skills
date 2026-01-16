---
title: Avoid Over-Mocking
impact: HIGH
impactDescription: Prevents tests that pass despite broken code by testing mocks instead of behavior
tags: mock, over-mocking, test-quality, false-positives
---

## Avoid Over-Mocking

When you mock everything, you're only testing that you called your mocks correctly - not that your code works. Over-mocked tests provide false confidence and break when implementation details change.

**Incorrect (testing mocks, not behavior):**

```typescript
import { describe, it, expect, vi } from 'vitest'

vi.mock('./database')
vi.mock('./validator')
vi.mock('./logger')
vi.mock('./cache')

import { createUser } from './userService'
import { database } from './database'
import { validator } from './validator'
import { logger } from './logger'
import { cache } from './cache'

describe('UserService', () => {
  it('should create user', async () => {
    vi.mocked(validator.validate).mockReturnValue(true)
    vi.mocked(database.insert).mockResolvedValue({ id: 1 })
    vi.mocked(cache.set).mockResolvedValue(undefined)

    await createUser({ name: 'Alice', email: 'alice@test.com' })

    // Testing that mocks were called, not that user was created
    expect(validator.validate).toHaveBeenCalled()
    expect(database.insert).toHaveBeenCalled()
    expect(cache.set).toHaveBeenCalled()
    expect(logger.info).toHaveBeenCalled()
  })
})
```

**Correct (test outcomes, mock only boundaries):**

```typescript
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { setupServer } from 'msw/node'
import { http, HttpResponse } from 'msw'
import { createUser } from './userService'

// Only mock external boundaries (network, database)
const server = setupServer(
  http.post('/api/users', async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json({ id: 1, ...body })
  }),
)

describe('UserService', () => {
  beforeEach(() => server.listen())
  afterEach(() => server.close())

  it('should create user with validated email', async () => {
    // Uses real validator, tests actual behavior
    const user = await createUser({ name: 'Alice', email: 'alice@test.com' })

    expect(user).toMatchObject({
      id: 1,
      name: 'Alice',
      email: 'alice@test.com',
    })
  })

  it('should reject invalid email', async () => {
    // Tests real validation logic
    await expect(createUser({ name: 'Bob', email: 'invalid' }))
      .rejects.toThrow('Invalid email')
  })
})
```

**What to mock vs what to keep real:**

| Mock | Keep Real |
|------|-----------|
| External APIs | Validation logic |
| Databases | Business rules |
| File system | Data transformations |
| Third-party services | Internal utilities |

**Benefits:**
- Tests catch real bugs
- Less maintenance when implementation changes
- Confidence that code actually works

Reference: [Vitest Mocking Guide](https://vitest.dev/guide/mocking)
