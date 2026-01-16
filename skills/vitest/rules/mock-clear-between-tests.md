---
title: Clear Mock State Between Tests
impact: MEDIUM
impactDescription: Prevents call count and argument contamination between tests
tags: mock, clearAllMocks, mock-state, test-isolation
---

## Clear Mock State Between Tests

Mocks track call history (how many times called, with what arguments). Without clearing between tests, assertions about call counts include calls from previous tests.

**Incorrect (mock state leaks):**

```typescript
import { describe, it, expect, vi } from 'vitest'

const logger = {
  log: vi.fn(),
}

describe('NotificationService', () => {
  it('should log on success', () => {
    notificationService.send('Hello')
    expect(logger.log).toHaveBeenCalledOnce()
  })

  it('should log on failure', () => {
    notificationService.sendFailing('World')
    // FAILS - logger.log has 2 calls (1 from previous test + 1 from this test)
    expect(logger.log).toHaveBeenCalledOnce()
  })
})
```

**Correct (clear mock state):**

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'

const logger = {
  log: vi.fn(),
}

describe('NotificationService', () => {
  beforeEach(() => {
    vi.clearAllMocks() // Clears call history, keeps implementation
  })

  it('should log on success', () => {
    notificationService.send('Hello')
    expect(logger.log).toHaveBeenCalledOnce()
  })

  it('should log on failure', () => {
    notificationService.sendFailing('World')
    // Works - mock state was cleared
    expect(logger.log).toHaveBeenCalledOnce()
  })
})
```

**Mock state methods comparison:**

| Method | Clears Calls | Clears Implementation | Restores Original |
|--------|-------------|----------------------|-------------------|
| `vi.clearAllMocks()` | Yes | No | No |
| `vi.resetAllMocks()` | Yes | Yes | No |
| `vi.restoreAllMocks()` | Yes | Yes | Yes |

**Configuration option:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    clearMocks: true, // Automatically clear mock state between tests
  },
})
```

**Benefits:**
- Accurate call count assertions
- Tests are independent
- No mysterious test order dependencies

Reference: [Vitest vi.clearAllMocks](https://vitest.dev/api/vi.html#vi-clearallmocks)
