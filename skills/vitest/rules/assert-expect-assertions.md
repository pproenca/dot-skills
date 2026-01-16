---
title: Use expect.assertions for Async Tests
impact: MEDIUM
impactDescription: Prevents tests from passing when async assertions are skipped
tags: assert, expect.assertions, async, verification
---

## Use expect.assertions for Async Tests

In async tests with conditional or callback-based assertions, it's possible for the test to complete without any assertions running. `expect.assertions(n)` verifies that exactly n assertions were called.

**Incorrect (assertions might not run):**

```typescript
import { describe, it, expect } from 'vitest'

describe('EventEmitter', () => {
  it('should emit data event', () => {
    const emitter = new EventEmitter()

    emitter.on('data', (data) => {
      expect(data).toBe('test')
    })

    // If event never fires, test passes with 0 assertions!
    emitter.emit('data', 'test')
  })
})
```

**Correct (assertion count verified):**

```typescript
import { describe, it, expect } from 'vitest'

describe('EventEmitter', () => {
  it('should emit data event', () => {
    expect.assertions(1) // Fails if assertion doesn't run

    const emitter = new EventEmitter()

    emitter.on('data', (data) => {
      expect(data).toBe('test')
    })

    emitter.emit('data', 'test')
  })
})
```

**With async callbacks:**

```typescript
describe('FileProcessor', () => {
  it('should process all files', async () => {
    expect.assertions(3) // Expect 3 files to be processed

    const files = ['a.txt', 'b.txt', 'c.txt']
    const processor = new FileProcessor()

    await processor.processAll(files, (file) => {
      expect(file).toMatch(/\.txt$/)
    })
  })
})
```

**Alternative: expect.hasAssertions:**

```typescript
describe('API', () => {
  it('should handle all responses', async () => {
    expect.hasAssertions() // Fails if zero assertions

    const responses = await api.fetchAll()

    responses.forEach(response => {
      expect(response.status).toBe(200)
    })
  })
})
```

**When to use:**
- Event handlers and callbacks
- Dynamic number of assertions in loops
- Tests with conditional logic
- Promise chains with `.then()` assertions

**Benefits:**
- Catches tests that pass without testing anything
- Verifies callbacks and events fire as expected
- More reliable async test coverage

Reference: [Vitest expect.assertions](https://vitest.dev/api/expect#expect-assertions)
