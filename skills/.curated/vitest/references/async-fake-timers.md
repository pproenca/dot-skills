---
title: Use Fake Timers for Time-Dependent Code
impact: CRITICAL
impactDescription: Eliminates timer-based flaky tests and reduces test duration by 100×
tags: async, timers, fake-timers, vi.useFakeTimers, flaky-tests
---

## Use Fake Timers for Time-Dependent Code

Real timers (setTimeout, setInterval) introduce non-determinism and slow tests. A 5-second timeout means a 5-second test. Fake timers let you control time programmatically, making tests instant and deterministic.

**Incorrect (real timers):**

```typescript
import { describe, it, expect } from 'vitest'

describe('Debounce', () => {
  it('should call function after delay', async () => {
    const callback = vi.fn()
    const debounced = debounce(callback, 1000)

    debounced()
    // Actually waits 1 second - slow and can be flaky
    await new Promise(r => setTimeout(r, 1100))

    expect(callback).toHaveBeenCalledOnce()
  })
})
```

**Correct (fake timers):**

```typescript
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'

describe('Debounce', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('should call function after delay', () => {
    const callback = vi.fn()
    const debounced = debounce(callback, 1000)

    debounced()
    expect(callback).not.toHaveBeenCalled()

    vi.advanceTimersByTime(1000)
    expect(callback).toHaveBeenCalledOnce()
  })
})
```

**Timer Control Methods:**

```typescript
// Advance by specific time
vi.advanceTimersByTime(1000)

// Run all pending timers
vi.runAllTimers()

// Run only currently pending timers (not new ones they create)
vi.runOnlyPendingTimers()

// Advance to next timer
vi.advanceTimersToNextTimer()

// Mock system time
vi.setSystemTime(new Date('2024-01-01'))
```

**Benefits:**
- Tests run instantly regardless of timer duration
- Deterministic behavior - no flaky failures
- Full control over time progression

Reference: [Vitest Fake Timers](https://vitest.dev/guide/mocking#timers)
