# Vitest

**Version 1.0.0**  
community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive testing best practices guide for Vitest, designed for AI agents and LLMs. Contains 44 rules across 8 categories, prioritized by impact from critical (async patterns, test isolation) to incremental (test organization). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated test writing and code review.

---

## Table of Contents

1. [Async Patterns](#1-async-patterns) — **CRITICAL**
   - 1.1 [Await Async Assertions](#11-await-async-assertions)
   - 1.2 [Await User Events to Avoid Act Warnings](#12-await-user-events-to-avoid-act-warnings)
   - 1.3 [Return Promises from Test Functions](#13-return-promises-from-test-functions)
   - 1.4 [Test Async Error Handling Properly](#14-test-async-error-handling-properly)
   - 1.5 [Use Fake Timers for Time-Dependent Code](#15-use-fake-timers-for-time-dependent-code)
   - 1.6 [Use Test Context Expect in Concurrent Tests](#16-use-test-context-expect-in-concurrent-tests)
   - 1.7 [Use vi.waitFor for Async Conditions](#17-use-viwaitfor-for-async-conditions)
2. [Test Setup & Isolation](#2-test-setup-isolation) — **CRITICAL**
   - 2.1 [Avoid Shared Mutable State Between Tests](#21-avoid-shared-mutable-state-between-tests)
   - 2.2 [Clean Up State in afterEach Hooks](#22-clean-up-state-in-aftereach-hooks)
   - 2.3 [Reset Modules When Testing Module State](#23-reset-modules-when-testing-module-state)
   - 2.4 [Restore Mocks After Each Test](#24-restore-mocks-after-each-test)
   - 2.5 [Use beforeAll for Expensive One-Time Setup](#25-use-beforeall-for-expensive-one-time-setup)
   - 2.6 [Use Test Factories for Complex Test Data](#26-use-test-factories-for-complex-test-data)
3. [Mocking Patterns](#3-mocking-patterns) — **HIGH**
   - 3.1 [Avoid Over-Mocking](#31-avoid-over-mocking)
   - 3.2 [Choose vi.spyOn vs vi.mock Appropriately](#32-choose-vispyon-vs-vimock-appropriately)
   - 3.3 [Clear Mock State Between Tests](#33-clear-mock-state-between-tests)
   - 3.4 [Maintain Type Safety in Mocks](#34-maintain-type-safety-in-mocks)
   - 3.5 [Understand vi.mock Hoisting Behavior](#35-understand-vimock-hoisting-behavior)
   - 3.6 [Use mockImplementation for Dynamic Mocks](#36-use-mockimplementation-for-dynamic-mocks)
   - 3.7 [Use MSW for Network Request Mocking](#37-use-msw-for-network-request-mocking)
4. [Performance](#4-performance) — **HIGH**
   - 4.1 [Choose the Right Pool for Performance](#41-choose-the-right-pool-for-performance)
   - 4.2 [Disable Test Isolation When Safe](#42-disable-test-isolation-when-safe)
   - 4.3 [Use Bail for Fast Failure in CI](#43-use-bail-for-fast-failure-in-ci)
   - 4.4 [Use happy-dom Over jsdom When Possible](#44-use-happy-dom-over-jsdom-when-possible)
   - 4.5 [Use Run Mode in CI Environments](#45-use-run-mode-in-ci-environments)
   - 4.6 [Use Sharding for CI Parallelization](#46-use-sharding-for-ci-parallelization)
5. [Snapshot Testing](#5-snapshot-testing) — **MEDIUM**
   - 5.1 [Avoid Large Snapshots](#51-avoid-large-snapshots)
   - 5.2 [Ensure Stable Snapshot Serialization](#52-ensure-stable-snapshot-serialization)
   - 5.3 [Name Snapshot Tests Descriptively](#53-name-snapshot-tests-descriptively)
   - 5.4 [Prefer Inline Snapshots for Small Values](#54-prefer-inline-snapshots-for-small-values)
   - 5.5 [Review Snapshot Updates Before Committing](#55-review-snapshot-updates-before-committing)
6. [Environment](#6-environment) — **MEDIUM**
   - 6.1 [Configure Globals Consistently](#61-configure-globals-consistently)
   - 6.2 [Mock Browser APIs Not Available in Test Environment](#62-mock-browser-apis-not-available-in-test-environment)
   - 6.3 [Override Environment Per File When Needed](#63-override-environment-per-file-when-needed)
   - 6.4 [Use Setup Files for Global Configuration](#64-use-setup-files-for-global-configuration)
7. [Assertions](#7-assertions) — **LOW-MEDIUM**
   - 7.1 [Choose toBe vs toEqual Correctly](#71-choose-tobe-vs-toequal-correctly)
   - 7.2 [Test Edge Cases and Boundaries](#72-test-edge-cases-and-boundaries)
   - 7.3 [Test One Concept Per Test](#73-test-one-concept-per-test)
   - 7.4 [Use expect.assertions for Async Tests](#74-use-expectassertions-for-async-tests)
   - 7.5 [Use Specific Matchers Over Generic Ones](#75-use-specific-matchers-over-generic-ones)
8. [Test Organization](#8-test-organization) — **LOW**
   - 8.1 [Colocate Test Files with Source Files](#81-colocate-test-files-with-source-files)
   - 8.2 [Use Describe Blocks for Logical Grouping](#82-use-describe-blocks-for-logical-grouping)
   - 8.3 [Use skip and only Appropriately](#83-use-skip-and-only-appropriately)
   - 8.4 [Write Descriptive Test Names](#84-write-descriptive-test-names)

---

## 1. Async Patterns

**Impact: CRITICAL**

Race conditions, unhandled promises, and improper async/await handling cause false positives, false negatives, and flaky tests that erode confidence in the test suite.

### 1.1 Await Async Assertions

**Impact: CRITICAL (Prevents false positives where tests pass despite failing assertions)**

Forgetting to await async assertions causes tests to pass before the assertion executes. The test completes successfully while the actual check runs after the test has already passed, hiding real failures.

**Incorrect (missing await):**

```typescript
import { describe, it, expect } from 'vitest'

describe('UserService', () => {
  it('should reject invalid users', () => {
    const service = new UserService()
    // Test passes immediately, assertion runs after test completes
    expect(service.validate({ name: '' })).rejects.toThrow('Name required')
  })
})
```

**Correct (awaited assertion):**

```typescript
import { describe, it, expect } from 'vitest'

describe('UserService', () => {
  it('should reject invalid users', async () => {
    const service = new UserService()
    // Test waits for assertion to complete
    await expect(service.validate({ name: '' })).rejects.toThrow('Name required')
  })
})
```

**Benefits:**
- Tests fail when they should fail
- No silent assertion failures
- Accurate test results

Reference: [Vitest Expect API](https://vitest.dev/api/expect.html)

### 1.2 Await User Events to Avoid Act Warnings

**Impact: CRITICAL (Prevents "not wrapped in act(...)" warnings and ensures UI updates complete)**

When testing React components, user interactions trigger state updates. Forgetting to await these interactions causes the test to continue before React finishes updating, resulting in "not wrapped in act(...)" warnings and flaky assertions.

**Incorrect (missing await on user event):**

```typescript
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect } from 'vitest'

describe('Counter', () => {
  it('should increment on click', () => {
    render(<Counter />)
    const button = screen.getByRole('button', { name: /increment/i })

    // Not awaited - test continues before state update
    userEvent.click(button)

    // May fail intermittently - state update not complete
    expect(screen.getByText('Count: 1')).toBeInTheDocument()
  })
})
```

**Correct (awaited user event):**

```typescript
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect } from 'vitest'

describe('Counter', () => {
  it('should increment on click', async () => {
    const user = userEvent.setup()
    render(<Counter />)
    const button = screen.getByRole('button', { name: /increment/i })

    // Awaited - test waits for all state updates
    await user.click(button)

    expect(screen.getByText('Count: 1')).toBeInTheDocument()
  })
})
```

**Best practice pattern:**

```typescript
import userEvent from '@testing-library/user-event'

describe('Form', () => {
  it('should submit form data', async () => {
    // Setup user instance for proper event handling
    const user = userEvent.setup()
    render(<LoginForm />)

    await user.type(screen.getByLabelText(/email/i), 'test@example.com')
    await user.type(screen.getByLabelText(/password/i), 'password123')
    await user.click(screen.getByRole('button', { name: /submit/i }))

    expect(screen.getByText(/welcome/i)).toBeInTheDocument()
  })
})
```

**Benefits:**
- No act() warnings
- State updates complete before assertions
- Deterministic test behavior

Reference: [Testing Library User Event](https://testing-library.com/docs/user-event/intro)

### 1.3 Return Promises from Test Functions

**Impact: CRITICAL (Prevents tests from completing before async operations finish)**

When a test function returns a promise, Vitest waits for it to resolve before marking the test complete. Forgetting to return the promise causes the test to finish prematurely, potentially hiding failures.

**Incorrect (promise not returned):**

```typescript
import { describe, it, expect } from 'vitest'

describe('API', () => {
  it('should fetch user data', () => {
    // Promise is created but not returned - test completes immediately
    fetchUser(1).then(user => {
      expect(user.name).toBe('Alice')
    })
  })
})
```

**Correct (promise returned):**

```typescript
import { describe, it, expect } from 'vitest'

describe('API', () => {
  it('should fetch user data', () => {
    // Returning the promise ensures Vitest waits for completion
    return fetchUser(1).then(user => {
      expect(user.name).toBe('Alice')
    })
  })
})
```

**Alternative (async/await - preferred):**

```typescript
import { describe, it, expect } from 'vitest'

describe('API', () => {
  it('should fetch user data', async () => {
    const user = await fetchUser(1)
    expect(user.name).toBe('Alice')
  })
})
```

**Benefits:**
- Test runner waits for all assertions
- Failed promises cause test failures
- Clearer async flow with async/await

Reference: [Vitest Test API](https://vitest.dev/api/)

### 1.4 Test Async Error Handling Properly

**Impact: CRITICAL (Prevents tests from passing when async operations fail silently)**

Testing that async functions throw errors requires proper assertion patterns. Using try-catch manually is error-prone - if the function doesn't throw, the test passes incorrectly. Use `expect().rejects` for clean, reliable error testing.

**Incorrect (manual try-catch):**

```typescript
import { describe, it, expect } from 'vitest'

describe('API', () => {
  it('should throw on invalid input', async () => {
    try {
      await api.createUser({ email: 'invalid' })
      // If we forget this line, test passes when it shouldn't
      // expect.fail('Should have thrown')
    } catch (error) {
      expect(error.message).toContain('Invalid email')
    }
  })
})
```

**Correct (expect.rejects):**

```typescript
import { describe, it, expect } from 'vitest'

describe('API', () => {
  it('should throw on invalid input', async () => {
    // Automatically fails if promise resolves instead of rejects
    await expect(api.createUser({ email: 'invalid' }))
      .rejects.toThrow('Invalid email')
  })
})
```

**Testing specific error types:**

```typescript
describe('API', () => {
  it('should throw ValidationError on invalid input', async () => {
    await expect(api.createUser({ email: 'invalid' }))
      .rejects.toThrow(ValidationError)
  })

  it('should include error details', async () => {
    await expect(api.createUser({ email: 'invalid' }))
      .rejects.toMatchObject({
        code: 'VALIDATION_ERROR',
        field: 'email',
      })
  })
})
```

**When NOT to use this pattern:**
- When testing that a function doesn't throw (use regular await)
- When you need to inspect multiple properties of the caught error

**Benefits:**
- Test fails if promise resolves unexpectedly
- Clean, declarative syntax
- Works with error instances, messages, and matchers

Reference: [Vitest Expect Rejects](https://vitest.dev/api/expect.html#rejects)

### 1.5 Use Fake Timers for Time-Dependent Code

**Impact: CRITICAL (Eliminates timer-based flaky tests and reduces test duration by 100×)**

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

### 1.6 Use Test Context Expect in Concurrent Tests

**Impact: CRITICAL (Prevents snapshot collision and assertion cross-contamination in parallel tests)**

When using `test.concurrent`, multiple tests run simultaneously. Using the global `expect` can cause snapshot collisions and assertion mix-ups. Extract `expect` from the test context to ensure proper isolation.

**Incorrect (global expect in concurrent tests):**

```typescript
import { describe, test, expect } from 'vitest'

describe('Formatters', () => {
  test.concurrent('formats dates', async () => {
    const result = formatDate(new Date('2024-01-01'))
    // Global expect - snapshots may collide with other concurrent tests
    expect(result).toMatchSnapshot()
  })

  test.concurrent('formats currency', async () => {
    const result = formatCurrency(1234.56)
    expect(result).toMatchSnapshot()
  })
})
```

**Correct (context expect in concurrent tests):**

```typescript
import { describe, test } from 'vitest'

describe('Formatters', () => {
  test.concurrent('formats dates', async ({ expect }) => {
    const result = formatDate(new Date('2024-01-01'))
    // Context expect - properly isolated per test
    expect(result).toMatchSnapshot()
  })

  test.concurrent('formats currency', async ({ expect }) => {
    const result = formatCurrency(1234.56)
    expect(result).toMatchSnapshot()
  })
})
```

**When this matters:**
- When using `test.concurrent` with snapshots
- When concurrent tests share similar assertion patterns
- In large test suites with parallel execution

**Benefits:**
- Each concurrent test has its own expect instance
- Snapshots are correctly tracked per test
- No cross-contamination between parallel tests

Reference: [Vitest Concurrent Tests](https://vitest.dev/api/#test-concurrent)

### 1.7 Use vi.waitFor for Async Conditions

**Impact: CRITICAL (Replaces arbitrary timeouts with condition-based waiting, eliminating flaky tests)**

Arbitrary timeouts (setTimeout with fixed delays) are the #1 cause of flaky tests. They either wait too long (slow tests) or not long enough (flaky tests). Use `vi.waitFor` to poll for conditions instead.

**Incorrect (arbitrary timeout):**

```typescript
import { describe, it, expect } from 'vitest'

describe('DataLoader', () => {
  it('should load data', async () => {
    const loader = new DataLoader()
    loader.start()

    // Arbitrary 500ms - might be too short on slow CI, too long for fast machines
    await new Promise(r => setTimeout(r, 500))

    expect(loader.data).toEqual({ items: [1, 2, 3] })
  })
})
```

**Correct (condition-based waiting):**

```typescript
import { describe, it, expect, vi } from 'vitest'

describe('DataLoader', () => {
  it('should load data', async () => {
    const loader = new DataLoader()
    loader.start()

    // Polls condition until true or timeout
    await vi.waitFor(() => {
      expect(loader.data).toEqual({ items: [1, 2, 3] })
    })
  })
})
```

**With custom options:**

```typescript
await vi.waitFor(
  () => {
    expect(element.textContent).toBe('Loaded')
  },
  {
    timeout: 5000,  // Max wait time
    interval: 100,  // Poll interval
  }
)
```

**When NOT to use this pattern:**
- When you have full control over timing (use fake timers instead)
- For synchronous operations

**Benefits:**
- Tests complete as fast as possible
- No arbitrary delays that cause flakiness
- Clear timeout errors when conditions aren't met

Reference: [Vitest vi.waitFor](https://vitest.dev/api/vi.html#vi-waitfor)

---

## 2. Test Setup & Isolation

**Impact: CRITICAL**

Shared state, missing cleanup, and improper beforeEach/afterEach patterns cause cascading failures where one test pollutes the environment for subsequent tests.

### 2.1 Avoid Shared Mutable State Between Tests

**Impact: CRITICAL (Eliminates order-dependent test failures and enables reliable parallel execution)**

Sharing mutable state between tests creates hidden dependencies. Tests pass when run alone but fail in the suite, or fail only when run in a specific order. Each test must create its own state.

**Incorrect (shared mutable state):**

```typescript
import { describe, it, expect, beforeAll } from 'vitest'

// Shared state - modified by tests
const testUsers: User[] = []

describe('UserRepository', () => {
  beforeAll(() => {
    testUsers.push({ id: 1, name: 'Alice' })
  })

  it('should find user by id', () => {
    const user = repository.find(testUsers, 1)
    expect(user.name).toBe('Alice')
  })

  it('should add new user', () => {
    testUsers.push({ id: 2, name: 'Bob' })
    expect(testUsers).toHaveLength(2)
  })

  it('should list all users', () => {
    // FLAKY - depends on previous test running first
    // May have 1 or 2 users depending on test order
    expect(repository.list(testUsers)).toHaveLength(2)
  })
})
```

**Correct (isolated state per test):**

```typescript
import { describe, it, expect, beforeEach } from 'vitest'

describe('UserRepository', () => {
  let testUsers: User[]

  beforeEach(() => {
    // Fresh state for each test
    testUsers = [{ id: 1, name: 'Alice' }]
  })

  it('should find user by id', () => {
    const user = repository.find(testUsers, 1)
    expect(user.name).toBe('Alice')
  })

  it('should add new user', () => {
    testUsers.push({ id: 2, name: 'Bob' })
    expect(testUsers).toHaveLength(2)
  })

  it('should list all users', () => {
    // Always 1 user - independent of other tests
    expect(repository.list(testUsers)).toHaveLength(1)
  })
})
```

**Factory pattern for complex state:**

```typescript
function createTestUser(overrides?: Partial<User>): User {
  return {
    id: Math.random(),
    name: 'Test User',
    email: 'test@example.com',
    ...overrides,
  }
}

describe('UserService', () => {
  it('should validate user email', () => {
    const user = createTestUser({ email: 'invalid' })
    expect(service.validate(user)).toBe(false)
  })
})
```

**Benefits:**
- Tests can run in any order
- Tests can run in parallel safely
- Failures are isolated and easy to debug

Reference: [Vitest Test Isolation](https://vitest.dev/guide/improving-performance#test-isolation)

### 2.2 Clean Up State in afterEach Hooks

**Impact: CRITICAL (Prevents test pollution where one test's side effects cause subsequent tests to fail)**

Tests that modify global state, DOM, or shared resources must clean up after themselves. Without cleanup, tests become order-dependent - they pass in isolation but fail when run together, or vice versa.

**Incorrect (no cleanup):**

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'

describe('ThemeService', () => {
  beforeEach(() => {
    // Sets global state
    window.localStorage.setItem('theme', 'dark')
  })

  it('should read theme from storage', () => {
    expect(ThemeService.getTheme()).toBe('dark')
  })

  // Other tests may fail because localStorage still has 'dark'
})
```

**Correct (proper cleanup):**

```typescript
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'

describe('ThemeService', () => {
  beforeEach(() => {
    window.localStorage.setItem('theme', 'dark')
  })

  afterEach(() => {
    // Clean up after each test
    window.localStorage.clear()
  })

  it('should read theme from storage', () => {
    expect(ThemeService.getTheme()).toBe('dark')
  })
})
```

**Common cleanup patterns:**

```typescript
import { describe, afterEach, vi } from 'vitest'

describe('Integration tests', () => {
  afterEach(() => {
    // Restore all mocks
    vi.restoreAllMocks()

    // Clear all timers
    vi.useRealTimers()

    // Clean DOM
    document.body.innerHTML = ''

    // Clear storage
    localStorage.clear()
    sessionStorage.clear()

    // Reset modules
    vi.resetModules()
  })
})
```

**Benefits:**
- Tests are independent of execution order
- No mysterious failures when running full suite
- Easier debugging - each test starts clean

Reference: [Vitest Setup and Teardown](https://vitest.dev/api/#setup-and-teardown)

### 2.3 Reset Modules When Testing Module State

**Impact: HIGH (Ensures modules with cached state are properly isolated between tests)**

JavaScript modules cache their exports. If a module has internal state (like a singleton or configuration), that state persists across tests. Use `vi.resetModules()` to clear the module cache and get fresh instances.

**Incorrect (cached module state):**

```typescript
import { describe, it, expect, vi } from 'vitest'
import { config } from './config'

describe('Config', () => {
  it('should load default config', () => {
    expect(config.apiUrl).toBe('https://api.example.com')
  })

  it('should allow overrides', () => {
    config.apiUrl = 'https://staging.example.com'
    expect(config.apiUrl).toBe('https://staging.example.com')
  })

  it('should still have default', () => {
    // FAILS - config still has staging URL from previous test
    expect(config.apiUrl).toBe('https://api.example.com')
  })
})
```

**Correct (reset modules between tests):**

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'

describe('Config', () => {
  beforeEach(() => {
    vi.resetModules()
  })

  it('should load default config', async () => {
    const { config } = await import('./config')
    expect(config.apiUrl).toBe('https://api.example.com')
  })

  it('should allow overrides', async () => {
    const { config } = await import('./config')
    config.apiUrl = 'https://staging.example.com'
    expect(config.apiUrl).toBe('https://staging.example.com')
  })

  it('should still have default', async () => {
    // Works - fresh module instance
    const { config } = await import('./config')
    expect(config.apiUrl).toBe('https://api.example.com')
  })
})
```

**Alternative with vi.doMock:**

```typescript
describe('Config with env vars', () => {
  beforeEach(() => {
    vi.resetModules()
  })

  it('should use production URL', async () => {
    vi.stubEnv('NODE_ENV', 'production')
    const { config } = await import('./config')
    expect(config.apiUrl).toContain('production')
  })

  it('should use development URL', async () => {
    vi.stubEnv('NODE_ENV', 'development')
    const { config } = await import('./config')
    expect(config.apiUrl).toContain('localhost')
  })
})
```

**Benefits:**
- Each test gets fresh module state
- Singletons are properly isolated
- Module-level side effects don't leak

Reference: [Vitest vi.resetModules](https://vitest.dev/api/vi.html#vi-resetmodules)

### 2.4 Restore Mocks After Each Test

**Impact: CRITICAL (Prevents mock leakage where mocked behavior persists into unrelated tests)**

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

### 2.5 Use beforeAll for Expensive One-Time Setup

**Impact: HIGH (Reduces test suite time by 50-90% for tests with expensive setup)**

Operations like database connections, file system setup, or API client initialization should run once per suite, not before every test. Using `beforeEach` for expensive operations multiplies execution time unnecessarily.

**Incorrect (expensive setup in beforeEach):**

```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest'

describe('DatabaseRepository', () => {
  let db: Database

  beforeEach(async () => {
    // 500ms connection time × number of tests
    db = await Database.connect(connectionString)
    await db.migrate()
  })

  afterEach(async () => {
    await db.disconnect()
  })

  it('should create record', async () => { /* ... */ })
  it('should read record', async () => { /* ... */ })
  it('should update record', async () => { /* ... */ })
  // 10 tests = 5000ms just for setup
})
```

**Correct (one-time setup with beforeAll):**

```typescript
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'

describe('DatabaseRepository', () => {
  let db: Database

  beforeAll(async () => {
    // 500ms once for entire suite
    db = await Database.connect(connectionString)
    await db.migrate()
  })

  afterAll(async () => {
    await db.disconnect()
  })

  beforeEach(async () => {
    // Only reset data between tests, not connection
    await db.truncate('users')
  })

  it('should create record', async () => { /* ... */ })
  it('should read record', async () => { /* ... */ })
  it('should update record', async () => { /* ... */ })
  // 10 tests = 500ms setup total
})
```

**When to use each:**

| Hook | Use For |
|------|---------|
| `beforeAll` | Database connections, server startup, expensive fixtures |
| `beforeEach` | Resetting state, seeding test data, creating fresh instances |
| `afterEach` | Clearing state, restoring mocks |
| `afterAll` | Closing connections, cleanup after all tests |

**Benefits:**
- Dramatic reduction in test suite time
- Faster feedback loops
- More efficient CI/CD runs

Reference: [Vitest Setup and Teardown](https://vitest.dev/api/#setup-and-teardown)

### 2.6 Use Test Factories for Complex Test Data

**Impact: MEDIUM (Reduces test setup boilerplate by 60% and improves test readability)**

Hardcoded test data is verbose, repetitive, and hard to maintain. Factories create test objects with sensible defaults while allowing tests to override only the fields they care about.

**Incorrect (hardcoded test data):**

```typescript
import { describe, it, expect } from 'vitest'

describe('OrderService', () => {
  it('should calculate total for single item', () => {
    const order = {
      id: '123',
      customerId: 'cust-1',
      items: [{ productId: 'prod-1', name: 'Widget', price: 10, quantity: 1 }],
      status: 'pending',
      createdAt: new Date(),
      updatedAt: new Date(),
      shippingAddress: { street: '123 Main St', city: 'NYC', zip: '10001' },
    }
    expect(service.calculateTotal(order)).toBe(10)
  })

  it('should calculate total for multiple items', () => {
    // Same verbose object with minor changes
    const order = {
      id: '456',
      customerId: 'cust-2',
      items: [
        { productId: 'prod-1', name: 'Widget', price: 10, quantity: 2 },
        { productId: 'prod-2', name: 'Gadget', price: 20, quantity: 1 },
      ],
      status: 'pending',
      createdAt: new Date(),
      updatedAt: new Date(),
      shippingAddress: { street: '456 Oak Ave', city: 'LA', zip: '90001' },
    }
    expect(service.calculateTotal(order)).toBe(40)
  })
})
```

**Correct (using factories):**

```typescript
import { describe, it, expect } from 'vitest'

// Factory with sensible defaults
function createOrder(overrides: Partial<Order> = {}): Order {
  return {
    id: crypto.randomUUID(),
    customerId: 'test-customer',
    items: [],
    status: 'pending',
    createdAt: new Date(),
    updatedAt: new Date(),
    shippingAddress: createAddress(),
    ...overrides,
  }
}

function createOrderItem(overrides: Partial<OrderItem> = {}): OrderItem {
  return {
    productId: crypto.randomUUID(),
    name: 'Test Product',
    price: 10,
    quantity: 1,
    ...overrides,
  }
}

describe('OrderService', () => {
  it('should calculate total for single item', () => {
    const order = createOrder({
      items: [createOrderItem({ price: 10, quantity: 1 })],
    })
    expect(service.calculateTotal(order)).toBe(10)
  })

  it('should calculate total for multiple items', () => {
    const order = createOrder({
      items: [
        createOrderItem({ price: 10, quantity: 2 }),
        createOrderItem({ price: 20, quantity: 1 }),
      ],
    })
    expect(service.calculateTotal(order)).toBe(40)
  })
})
```

**Benefits:**
- Tests focus on what matters
- Less boilerplate to maintain
- Easy to create variations

Reference: [Test Data Builders Pattern](https://vitest.dev/guide/test-context)

---

## 3. Mocking Patterns

**Impact: HIGH**

Incorrect vi.mock/vi.spyOn usage, missing mock restoration, and over-mocking lead to brittle tests that pass when they should fail or test mocks instead of real behavior.

### 3.1 Avoid Over-Mocking

**Impact: HIGH (Prevents tests that pass despite broken code by testing mocks instead of behavior)**

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

### 3.2 Choose vi.spyOn vs vi.mock Appropriately

**Impact: HIGH (Prevents over-mocking and ensures tests exercise real code paths)**

`vi.mock` replaces entire modules, while `vi.spyOn` wraps individual functions. Using `vi.mock` when you only need to mock one function leads to over-mocking - your tests stop exercising real code.

**Incorrect (over-mocking with vi.mock):**

```typescript
import { describe, it, expect, vi } from 'vitest'
import { formatDate, parseDate, validateDate } from './dateUtils'

// Mocks ALL exports - tests won't use real formatDate or parseDate
vi.mock('./dateUtils', () => ({
  formatDate: vi.fn(),
  parseDate: vi.fn(),
  validateDate: vi.fn().mockReturnValue(true),
}))

describe('DatePicker', () => {
  it('should validate selected date', () => {
    // Only testing that validateDate is called, not that it works
    expect(validateDate('2024-01-01')).toBe(true)
  })
})
```

**Correct (targeted mocking with vi.spyOn):**

```typescript
import { describe, it, expect, vi, afterEach } from 'vitest'
import * as dateUtils from './dateUtils'

describe('DatePicker', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('should format valid dates', () => {
    // Uses real formatDate implementation
    expect(dateUtils.formatDate(new Date('2024-01-01'))).toBe('Jan 1, 2024')
  })

  it('should handle validation errors gracefully', () => {
    // Only mock validateDate for this specific test
    vi.spyOn(dateUtils, 'validateDate').mockReturnValue(false)

    const result = dateUtils.validateDate('invalid')
    expect(result).toBe(false)
  })
})
```

**When to use each:**

| Approach | Use When |
|----------|----------|
| `vi.mock` | Mocking external dependencies (APIs, databases), entire modules |
| `vi.spyOn` | Mocking specific functions, preserving other behavior |
| `vi.spyOn` with `mockImplementation` | Temporarily changing behavior for one test |

**Partial mocking pattern:**

```typescript
vi.mock('./api', async () => {
  const actual = await vi.importActual('./api')
  return {
    ...actual,
    // Only mock fetchUser, keep other exports real
    fetchUser: vi.fn(),
  }
})
```

**Benefits:**
- Tests exercise more real code
- Easier to identify what's actually being tested
- Less brittle when module internals change

Reference: [Vitest Mocking](https://vitest.dev/guide/mocking)

### 3.3 Clear Mock State Between Tests

**Impact: MEDIUM (Prevents call count and argument contamination between tests)**

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

### 3.4 Maintain Type Safety in Mocks

**Impact: MEDIUM (Catches mock/implementation mismatches at compile time instead of runtime)**

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

### 3.5 Understand vi.mock Hoisting Behavior

**Impact: HIGH (Prevents "module not mocked" errors and unexpected real implementations)**

`vi.mock()` calls are hoisted to the top of the file, executing before any imports. This means you can't use variables defined outside the mock factory, and the mock applies even to imports that appear earlier in the file.

**Incorrect (using external variable in mock):**

```typescript
import { describe, it, expect, vi } from 'vitest'
import { fetchUser } from './api'

const mockResponse = { id: 1, name: 'Alice' }

// ERROR: mockResponse is not defined when this runs
vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue(mockResponse),
}))

describe('UserService', () => {
  it('should return user', async () => {
    const user = await fetchUser(1)
    expect(user).toEqual(mockResponse)
  })
})
```

**Correct (inline mock value):**

```typescript
import { describe, it, expect, vi } from 'vitest'
import { fetchUser } from './api'

vi.mock('./api', () => ({
  fetchUser: vi.fn().mockResolvedValue({ id: 1, name: 'Alice' }),
}))

describe('UserService', () => {
  it('should return user', async () => {
    const user = await fetchUser(1)
    expect(user).toEqual({ id: 1, name: 'Alice' })
  })
})
```

**Alternative (vi.hoisted for shared variables):**

```typescript
import { describe, it, expect, vi } from 'vitest'
import { fetchUser } from './api'

// vi.hoisted runs at hoisting time, before imports
const { mockFetchUser } = vi.hoisted(() => ({
  mockFetchUser: vi.fn(),
}))

vi.mock('./api', () => ({
  fetchUser: mockFetchUser,
}))

describe('UserService', () => {
  it('should return user', async () => {
    mockFetchUser.mockResolvedValue({ id: 1, name: 'Alice' })
    const user = await fetchUser(1)
    expect(user).toEqual({ id: 1, name: 'Alice' })
  })
})
```

**Benefits:**
- Mocks work as expected
- Variables are available at mock definition time
- Clear control over mock behavior per test

Reference: [Vitest vi.mock](https://vitest.dev/api/vi.html#vi-mock)

### 3.6 Use mockImplementation for Dynamic Mocks

**Impact: HIGH (Enables context-aware mocks that respond differently based on input)**

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

### 3.7 Use MSW for Network Request Mocking

**Impact: HIGH (Provides realistic request/response mocking at the network level)**

Mocking fetch or axios directly means you're not testing the actual HTTP layer. MSW (Mock Service Worker) intercepts real network requests, providing realistic mocking that catches integration issues.

**Incorrect (mocking fetch directly):**

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'

describe('UserAPI', () => {
  beforeEach(() => {
    // Mocks the fetch function, not the network behavior
    global.fetch = vi.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({ id: 1, name: 'Alice' }),
    })
  })

  it('should fetch user', async () => {
    const user = await api.getUser(1)
    expect(user.name).toBe('Alice')
    // Doesn't test: request headers, URL construction, error status codes
  })
})
```

**Correct (MSW for network mocking):**

```typescript
import { describe, it, expect, beforeAll, afterAll, afterEach } from 'vitest'
import { setupServer } from 'msw/node'
import { http, HttpResponse } from 'msw'

const server = setupServer(
  http.get('/api/users/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'Alice' })
  }),

  http.post('/api/users', async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json({ id: 1, ...body }, { status: 201 })
  }),
)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

describe('UserAPI', () => {
  it('should fetch user', async () => {
    const user = await api.getUser(1)
    expect(user.name).toBe('Alice')
  })

  it('should handle 404', async () => {
    server.use(
      http.get('/api/users/:id', () => {
        return new HttpResponse(null, { status: 404 })
      }),
    )

    await expect(api.getUser(999)).rejects.toThrow('User not found')
  })

  it('should create user', async () => {
    const user = await api.createUser({ name: 'Bob' })
    expect(user.id).toBe(1)
  })
})
```

**Setup file for global MSW:**

```typescript
// vitest.setup.ts
import { beforeAll, afterAll, afterEach } from 'vitest'
import { server } from './mocks/server'

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())
```

**Benefits:**
- Tests real HTTP behavior (headers, status codes, body parsing)
- Catches URL construction bugs
- Same mock handlers work in tests and development

Reference: [MSW Documentation](https://mswjs.io/docs/)

---

## 4. Performance

**Impact: HIGH**

Test isolation overhead, pool selection, parallelization settings, and environment choices affect CI/CD execution time by 2-10×, directly impacting developer feedback loops.

### 4.1 Choose the Right Pool for Performance

**Impact: HIGH (2-5× performance difference between pool types on large test suites)**

Vitest supports different execution pools: `forks` (default), `threads`, and `vmThreads`. The default `forks` prioritizes compatibility but can be significantly slower. Consider `threads` for better performance.

**Default (forks pool):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Default - most compatible, but can be slower
    pool: 'forks',
  },
})
```

**Optimized (threads pool):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Generally faster, but some edge cases may not work
    pool: 'threads',
  },
})
```

**Pool comparison:**

| Pool | Speed | Isolation | Compatibility | Best For |
|------|-------|-----------|---------------|----------|
| `forks` | Slower | Full process | Highest | Default, native modules |
| `threads` | Faster | Worker threads | High | Most projects |
| `vmThreads` | Medium | VM contexts | Medium | Memory-constrained |

**Tuning thread count:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    pool: 'threads',
    poolOptions: {
      threads: {
        // Match CPU cores for compute-bound tests
        minThreads: 1,
        maxThreads: 4,
      },
    },
  },
})
```

**CLI usage:**

```bash
# Quick switch to threads pool
vitest --pool=threads

# Check if it improves your suite
vitest --pool=threads --reporter=verbose
```

**When to use forks:**
- Tests use native modules that don't work with worker threads
- Tests have compatibility issues with threads pool
- You need full process isolation

**Benefits:**
- Significant speedup for large test suites
- Better resource utilization
- Faster CI/CD feedback

Reference: [Vitest Pool Configuration](https://vitest.dev/config/#pool)

### 4.2 Disable Test Isolation When Safe

**Impact: HIGH (30-50% faster test execution for well-isolated tests)**

By default, Vitest runs each test file in an isolated environment. This ensures tests don't affect each other but adds overhead. For projects with proper cleanup, disabling isolation speeds up execution significantly.

**Default (full isolation):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Default - each file runs in fresh environment
    isolate: true,
  },
})
```

**Optimized (disabled isolation):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Faster - files share environment
    isolate: false,
  },
})
```

**Prerequisites for disabling isolation:**

1. Tests properly clean up after themselves
2. No global state modification without restoration
3. All mocks are restored in afterEach
4. No test relies on being the first/only test in the environment

**Hybrid approach with projects:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    projects: [
      {
        // Unit tests - safe to share environment
        name: 'unit',
        include: ['src/**/*.test.ts'],
        isolate: false,
      },
      {
        // Integration tests - need isolation
        name: 'integration',
        include: ['tests/integration/**/*.test.ts'],
        isolate: true,
      },
    ],
  },
})
```

**CLI usage:**

```bash
# Quick test with isolation disabled
vitest --no-isolate

# Check for tests that depend on isolation
vitest --no-isolate --reporter=verbose
```

**When NOT to disable isolation:**
- Tests modify global state without cleanup
- Tests use `vi.mock` at the module level without `vi.resetModules`
- Tests have known order dependencies

**Benefits:**
- Faster test suite execution
- Reduced memory usage
- Quicker feedback loops

Reference: [Vitest Improving Performance](https://vitest.dev/guide/improving-performance#test-isolation)

### 4.3 Use Bail for Fast Failure in CI

**Impact: MEDIUM (Saves CI minutes by stopping early when tests fail)**

When running in CI, continuing after failures wastes time and resources. The `--bail` flag stops test execution after a configurable number of failures, providing faster feedback on broken builds.

**Without bail (runs all tests):**

```bash
# Continues running all 1000 tests even after first failure
npx vitest run
# Takes 10 minutes, reports 50 failures
```

**With bail (stops early):**

```bash
# Stops after first failure
npx vitest run --bail=1
# Takes 30 seconds, reports 1 failure
```

**Configuration:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    bail: process.env.CI ? 1 : 0, // 0 means no bail
  },
})
```

**Higher bail count for flaky detection:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Stop after 3 failures - catches multiple issues
    bail: 3,
  },
})
```

**CI workflow with bail:**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    steps:
      - run: npx vitest run --bail=1
      # If tests fail, subsequent steps are skipped
```

**When NOT to use bail:**
- Running full test suite for comprehensive failure report
- Debugging multiple related failures
- Generating complete coverage reports

**Combining with retry:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    bail: 1,
    retry: 2, // Retry flaky tests before bailing
  },
})
```

**Benefits:**
- Faster CI feedback
- Reduced CI costs (fewer compute minutes)
- Developers see failures immediately

Reference: [Vitest CLI Options](https://vitest.dev/guide/cli#options)

### 4.4 Use happy-dom Over jsdom When Possible

**Impact: HIGH (2-3× faster DOM operations compared to jsdom)**

happy-dom is significantly faster than jsdom for most DOM testing scenarios. While jsdom has broader compatibility, happy-dom handles the majority of use cases with better performance.

**Slower (jsdom):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    environment: 'jsdom',
  },
})
```

**Faster (happy-dom):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    environment: 'happy-dom',
  },
})
```

**Per-file environment override:**

```typescript
// tests/complex-dom.test.ts
/**
 * @vitest-environment jsdom
 */

// This file uses jsdom for better compatibility
import { describe, it, expect } from 'vitest'

describe('Complex DOM interactions', () => {
  it('should handle edge case that happy-dom misses', () => {
    // Test code that requires jsdom
  })
})
```

**When to prefer jsdom:**
- Tests rely on specific DOM features not implemented in happy-dom
- Third-party libraries require jsdom
- You need `MutationObserver` edge cases
- Legacy code with complex DOM manipulation

**When happy-dom works well:**
- React/Vue/Svelte component testing
- Basic DOM queries and manipulation
- Testing Library based tests
- Most application testing scenarios

**Mixed configuration:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Default to happy-dom for speed
    environment: 'happy-dom',

    // Override for specific files
    environmentMatchGlobs: [
      ['**/jsdom-required/**', 'jsdom'],
      ['**/node-only/**', 'node'],
    ],
  },
})
```

**Benefits:**
- Faster test execution
- Lower memory usage
- Same API as jsdom for most operations

Reference: [happy-dom GitHub](https://github.com/capricorn86/happy-dom)

### 4.5 Use Run Mode in CI Environments

**Impact: MEDIUM (Avoids watch mode overhead and file system polling in CI)**

Vitest's default watch mode is designed for development, continuously watching files and providing an interactive UI. In CI, this overhead is wasted. Use `--run` to execute tests once and exit.

**Incorrect (watch mode in CI):**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    steps:
      # Watch mode starts, hangs waiting for file changes
      - run: npx vitest
```

**Correct (run mode in CI):**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    steps:
      # Runs tests once and exits
      - run: npx vitest run
```

**Automatic detection:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Vitest automatically uses run mode when CI=true
    // But explicit configuration is clearer
    watch: !process.env.CI,
  },
})
```

**Additional CI optimizations:**

```yaml
jobs:
  test:
    env:
      CI: true
    steps:
      - run: npx vitest run --reporter=github-actions
```

**CI-specific reporters:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    reporters: process.env.CI
      ? ['default', 'github-actions']
      : ['default'],
  },
})
```

**Package.json scripts:**

```json
{
  "scripts": {
    "test": "vitest",
    "test:ci": "vitest run --coverage"
  }
}
```

**Benefits:**
- No hanging processes in CI
- Faster startup without watch setup
- Clear exit codes for CI systems

Reference: [Vitest CLI](https://vitest.dev/guide/cli)

### 4.6 Use Sharding for CI Parallelization

**Impact: HIGH (Linear speedup with additional CI nodes (3 nodes = ~3× faster))**

Sharding splits your test suite across multiple CI machines. Each machine runs a subset of tests in parallel, providing near-linear speedup with additional nodes.

**Without sharding (single node):**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx vitest run
```

**With sharding (multiple nodes):**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1, 2, 3]
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx vitest run --reporter=blob --shard=${{ matrix.shard }}/3

  merge-reports:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - uses: actions/download-artifact@v4
      - run: npx vitest --merge-reports
```

**Blob reporter for merged results:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    reporters: process.env.CI ? ['blob'] : ['default'],
  },
})
```

**Coverage with sharding:**

```yaml
jobs:
  test:
    strategy:
      matrix:
        shard: [1, 2, 3]
    steps:
      - run: npx vitest run --coverage --shard=${{ matrix.shard }}/3

  merge:
    needs: test
    steps:
      - run: npx vitest --merge-reports --coverage
```

**Optimal shard count:**

| Test Suite Size | Recommended Shards |
|-----------------|-------------------|
| < 100 tests | 1-2 |
| 100-500 tests | 2-4 |
| 500-1000 tests | 4-6 |
| > 1000 tests | 6-10 |

**Benefits:**
- Near-linear speedup with additional nodes
- Merged coverage and reports
- Works with any CI system

Reference: [Vitest Test Sharding](https://vitest.dev/guide/improving-performance#sharding)

---

## 5. Snapshot Testing

**Impact: MEDIUM**

Snapshot sprawl, poor snapshot hygiene, and unstable serialization reduce test maintainability and lead to blindly updated snapshots that mask real bugs.

### 5.1 Avoid Large Snapshots

**Impact: MEDIUM (Large snapshots are rarely reviewed and blindly updated, masking real bugs)**

Snapshots over 50-100 lines become noise that reviewers skip. When updates happen, developers press "u" without reviewing changes, allowing bugs to slip through. Snapshot smaller, more focused pieces instead.

**Incorrect (entire component output):**

```typescript
import { describe, it, expect } from 'vitest'
import { render } from '@testing-library/react'

describe('Dashboard', () => {
  it('should render correctly', () => {
    const { container } = render(<Dashboard user={testUser} data={testData} />)
    // 500-line snapshot - no one will review changes
    expect(container.innerHTML).toMatchSnapshot()
  })
})
```

**Correct (focused snapshots):**

```typescript
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'

describe('Dashboard', () => {
  it('should display user name', () => {
    render(<Dashboard user={testUser} data={testData} />)
    expect(screen.getByRole('heading', { name: /alice/i })).toBeInTheDocument()
  })

  it('should render stats correctly', () => {
    render(<Dashboard user={testUser} data={testData} />)
    // Small, focused snapshot
    expect(screen.getByTestId('stats')).toMatchInlineSnapshot(`
      <div data-testid="stats">
        <span>Views: 1,234</span>
        <span>Clicks: 567</span>
      </div>
    `)
  })

  it('should show correct navigation links', () => {
    render(<Dashboard user={testUser} data={testData} />)
    const links = screen.getAllByRole('link')
    expect(links.map(l => l.textContent)).toEqual([
      'Home', 'Profile', 'Settings'
    ])
  })
})
```

**Signs of snapshot abuse:**
- Snapshot files larger than the test files
- Most PRs include "Update snapshots" commits
- Reviewers skip snapshot changes in code review
- Snapshots contain unstable data (dates, IDs)

**Better alternatives:**
- Assert specific properties
- Use focused inline snapshots
- Test behavior, not markup

**Benefits:**
- Snapshots get actually reviewed
- Changes are easier to understand
- Tests remain maintainable

Reference: [Vitest Snapshot Best Practices](https://vitest.dev/guide/snapshot)

### 5.2 Ensure Stable Snapshot Serialization

**Impact: MEDIUM (Eliminates false snapshot failures from non-deterministic data)**

Snapshots containing dates, random IDs, or other non-deterministic values change on every run. This forces constant snapshot updates and makes tests useless for detecting actual changes.

**Incorrect (unstable data):**

```typescript
import { describe, it, expect } from 'vitest'

describe('OrderSerializer', () => {
  it('should serialize order', () => {
    const order = createOrder({ item: 'Widget' })
    // Snapshot changes every run due to timestamp and ID
    expect(order).toMatchInlineSnapshot(`
      {
        "id": "abc123-def456-...",
        "createdAt": "2024-01-15T10:30:00.000Z",
        "item": "Widget"
      }
    `)
  })
})
```

**Correct (stable serialization):**

```typescript
import { describe, it, expect, vi } from 'vitest'

describe('OrderSerializer', () => {
  it('should serialize order', () => {
    // Fix the date
    vi.setSystemTime(new Date('2024-01-01T00:00:00Z'))

    // Mock ID generation
    vi.spyOn(crypto, 'randomUUID').mockReturnValue('test-uuid-1234')

    const order = createOrder({ item: 'Widget' })
    expect(order).toMatchInlineSnapshot(`
      {
        "id": "test-uuid-1234",
        "createdAt": "2024-01-01T00:00:00.000Z",
        "item": "Widget"
      }
    `)
  })
})
```

**Using property matchers:**

```typescript
describe('OrderSerializer', () => {
  it('should serialize order with dynamic fields', () => {
    const order = createOrder({ item: 'Widget' })

    expect(order).toMatchInlineSnapshot(
      {
        id: expect.any(String),
        createdAt: expect.any(Date),
      },
      `
      {
        "id": Any<String>,
        "createdAt": Any<Date>,
        "item": "Widget"
      }
    `
    )
  })
})
```

**Custom serializers for complex types:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    snapshotSerializers: ['./test/serializers/date-serializer.ts'],
  },
})
```

**Benefits:**
- Snapshots only change when behavior changes
- No false positives from timestamps
- Reliable CI builds

Reference: [Vitest Snapshot Serializers](https://vitest.dev/guide/snapshot#custom-serializers)

### 5.3 Name Snapshot Tests Descriptively

**Impact: LOW (Improves snapshot file organization and failure debugging)**

Snapshot names are derived from test names. Generic names like "should work" or "renders correctly" make it hard to find and understand snapshots. Descriptive names document what the snapshot represents.

**Incorrect (generic names):**

```typescript
import { describe, it, expect } from 'vitest'

describe('Button', () => {
  it('should render', () => {
    expect(render(<Button>Click</Button>)).toMatchSnapshot()
  })

  it('should render 2', () => {
    expect(render(<Button disabled>Click</Button>)).toMatchSnapshot()
  })

  it('works', () => {
    expect(render(<Button variant="primary">Click</Button>)).toMatchSnapshot()
  })
})

// __snapshots__/Button.test.ts.snap contains:
// - "Button should render 1"
// - "Button should render 2 1"
// - "Button works 1"
// Which is which?
```

**Correct (descriptive names):**

```typescript
import { describe, it, expect } from 'vitest'

describe('Button', () => {
  it('renders with default props', () => {
    expect(render(<Button>Click</Button>)).toMatchSnapshot()
  })

  it('renders in disabled state', () => {
    expect(render(<Button disabled>Click</Button>)).toMatchSnapshot()
  })

  it('renders with primary variant', () => {
    expect(render(<Button variant="primary">Click</Button>)).toMatchSnapshot()
  })
})

// __snapshots__/Button.test.ts.snap contains:
// - "Button renders with default props 1"
// - "Button renders in disabled state 1"
// - "Button renders with primary variant 1"
// Clear what each represents
```

**Custom snapshot names:**

```typescript
it('renders button states', () => {
  expect(render(<Button>Click</Button>)).toMatchSnapshot('default state')
  expect(render(<Button disabled>Click</Button>)).toMatchSnapshot('disabled state')
})
```

**Benefits:**
- Easy to find specific snapshots
- Clear failure messages
- Self-documenting test files

Reference: [Vitest Snapshot Guide](https://vitest.dev/guide/snapshot)

### 5.4 Prefer Inline Snapshots for Small Values

**Impact: MEDIUM (Improves test readability by showing expected output directly in test code)**

File-based snapshots require jumping between test files and `.snap` files. For small values (under 10-15 lines), inline snapshots keep expected output visible in the test, making reviews and debugging faster.

**Less readable (file snapshot):**

```typescript
import { describe, it, expect } from 'vitest'

describe('UserSerializer', () => {
  it('should serialize user', () => {
    const user = { id: 1, name: 'Alice', role: 'admin' }
    // Have to open __snapshots__/user.test.ts.snap to see expected value
    expect(serialize(user)).toMatchSnapshot()
  })
})
```

**More readable (inline snapshot):**

```typescript
import { describe, it, expect } from 'vitest'

describe('UserSerializer', () => {
  it('should serialize user', () => {
    const user = { id: 1, name: 'Alice', role: 'admin' }
    // Expected value visible directly in test
    expect(serialize(user)).toMatchInlineSnapshot(`
      {
        "id": 1,
        "name": "Alice",
        "role": "admin"
      }
    `)
  })
})
```

**When to use file snapshots:**
- Large objects (>15 lines)
- Binary data or complex structures
- HTML/JSX components with many elements
- Generated code or documentation

**When to use inline snapshots:**
- Small objects and primitives
- Error messages
- Simple serialized data
- API response shapes

**Updating inline snapshots:**

```bash
# Update all snapshots
vitest -u

# Interactive update in watch mode
# Press 'u' when prompted
```

**Benefits:**
- Test is self-documenting
- Changes visible in code review diffs
- No context switching to .snap files

Reference: [Vitest Inline Snapshots](https://vitest.dev/guide/snapshot#inline-snapshots)

### 5.5 Review Snapshot Updates Before Committing

**Impact: MEDIUM (Prevents bugs from being silently committed via blind snapshot updates)**

Blindly running `vitest -u` and committing updated snapshots is a common source of bugs. Always review snapshot changes to verify they represent intended behavior changes, not regressions.

**Incorrect workflow:**

```bash
# Tests fail
vitest run

# Blindly update all snapshots without reviewing
vitest -u

# Commit without checking what changed
git add -A && git commit -m "Update snapshots"
# Bug shipped - snapshot now contains wrong output
```

**Correct workflow:**

```bash
# Tests fail
vitest run

# Review what's different before updating
git diff

# If changes are intentional, update
vitest -u

# Review the snapshot changes specifically
git diff --cached **/*.snap
git diff --cached **/*.test.ts

# Commit with context
git add -A && git commit -m "Update user serialization to include email field"
```

**Interactive snapshot update:**

```bash
# Watch mode allows reviewing each update
vitest --watch

# Press 'u' to update all snapshots
# Or use 'i' for interactive update (one at a time)
```

**CI protection:**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    steps:
      - run: npx vitest run
      # Fail CI if snapshots are out of date
      # Forces developers to update locally and review
```

**Questions to ask when reviewing:**
- Did I expect this output to change?
- Does the new output look correct?
- Is this change related to my code changes?
- Could this be hiding a regression?

**Benefits:**
- Catches accidental behavior changes
- Maintains snapshot quality as documentation
- Forces intentional changes

Reference: [Vitest Snapshot Updating](https://vitest.dev/guide/snapshot#updating-snapshots)

---

## 6. Environment

**Impact: MEDIUM**

DOM environment selection (jsdom vs happy-dom), browser API availability, and environment leakage affect test reliability and execution speed.

### 6.1 Configure Globals Consistently

**Impact: LOW (Determines whether imports are required for test APIs)**

Vitest can inject test APIs (`describe`, `it`, `expect`) globally or require explicit imports. Both approaches work, but mixing them causes confusion. Choose one and apply consistently.

**Option 1: Explicit imports (default, recommended):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    globals: false, // Default
  },
})
```

```typescript
// Tests require imports - explicit dependencies
import { describe, it, expect, vi } from 'vitest'

describe('Calculator', () => {
  it('should add numbers', () => {
    expect(add(1, 2)).toBe(3)
  })
})
```

**Option 2: Global injection:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    globals: true,
  },
})
```

```typescript
// vitest.d.ts (for TypeScript)
/// <reference types="vitest/globals" />
```

```typescript
// Tests use globals - no imports needed
describe('Calculator', () => {
  it('should add numbers', () => {
    expect(add(1, 2)).toBe(3)
  })
})
```

**Pros and cons:**

| Approach | Pros | Cons |
|----------|------|------|
| Explicit imports | Clear dependencies, better IDE support, tree-shakeable | More boilerplate |
| Globals | Less boilerplate, Jest-like | Implicit dependencies, needs type reference |

**ESLint configuration for globals:**

```javascript
// .eslintrc.js
module.exports = {
  env: {
    'vitest-globals/env': true,
  },
  plugins: ['vitest-globals'],
}
```

**Benefits:**
- Consistent codebase
- No confusion about where APIs come from
- Proper TypeScript support either way

Reference: [Vitest Globals](https://vitest.dev/config/#globals)

### 6.2 Mock Browser APIs Not Available in Test Environment

**Impact: MEDIUM (Prevents "X is not defined" errors when testing browser-specific code)**

Even with jsdom/happy-dom, some browser APIs are missing or incomplete. Tests fail with "X is not defined" when code uses APIs like `ResizeObserver`, `IntersectionObserver`, or `matchMedia`. Mock these APIs in setup.

**Incorrect (crashes on missing API):**

```typescript
// Component uses ResizeObserver
export function ResponsiveComponent() {
  useEffect(() => {
    const observer = new ResizeObserver(() => {})
    // ResizeObserver is not defined in jsdom!
  }, [])
}
```

**Correct (mock missing APIs):**

```typescript
// vitest.setup.ts
import { vi } from 'vitest'

// ResizeObserver mock
global.ResizeObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
}))

// IntersectionObserver mock
global.IntersectionObserver = vi.fn().mockImplementation(() => ({
  observe: vi.fn(),
  unobserve: vi.fn(),
  disconnect: vi.fn(),
  root: null,
  rootMargin: '',
  thresholds: [],
}))

// matchMedia mock
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
})
```

**Commonly missing APIs:**

```typescript
// vitest.setup.ts

// scrollTo
window.scrollTo = vi.fn()

// localStorage (enhanced mock)
const localStorageMock = {
  getItem: vi.fn(),
  setItem: vi.fn(),
  removeItem: vi.fn(),
  clear: vi.fn(),
}
Object.defineProperty(window, 'localStorage', { value: localStorageMock })

// fetch (if not using MSW)
global.fetch = vi.fn()

// crypto.randomUUID
Object.defineProperty(global, 'crypto', {
  value: {
    randomUUID: () => 'test-uuid-1234',
  },
})
```

**Benefits:**
- Tests run without browser API errors
- Predictable mock behavior
- Can verify interactions with browser APIs

Reference: [Vitest Environment Mocking](https://vitest.dev/guide/mocking)

### 6.3 Override Environment Per File When Needed

**Impact: MEDIUM (Allows mixing node and browser tests without separate config files)**

Not all tests need a DOM environment. Running DOM tests in node mode fails, while running pure logic tests in jsdom wastes resources. Use per-file environment overrides to match test needs.

**Incorrect (same environment for all):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // All tests run in jsdom, even pure logic tests
    environment: 'jsdom',
  },
})
```

**Correct (per-file environment):**

```typescript
// src/utils/math.test.ts
// Pure logic - no DOM needed, runs faster in node
import { describe, it, expect } from 'vitest'

describe('math utils', () => {
  it('should add numbers', () => {
    expect(add(1, 2)).toBe(3)
  })
})
```

```typescript
// src/components/Button.test.tsx
/**
 * @vitest-environment happy-dom
 */
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'

describe('Button', () => {
  it('should render', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByRole('button')).toBeInTheDocument()
  })
})
```

**Environment options:**

| Environment | Use For |
|-------------|---------|
| `node` (default) | Pure logic, Node.js APIs, utilities |
| `jsdom` | Full DOM compatibility, complex browser APIs |
| `happy-dom` | Fast DOM testing, most component tests |
| `edge-runtime` | Edge function testing |

**Configuration-based overrides:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Default to node for speed
    environment: 'node',

    // Pattern-based overrides
    environmentMatchGlobs: [
      ['src/components/**', 'happy-dom'],
      ['src/hooks/**', 'happy-dom'],
      ['tests/e2e/**', 'jsdom'],
    ],
  },
})
```

**Benefits:**
- Faster tests for pure logic
- Correct environment for DOM tests
- Flexible per-test-file control

Reference: [Vitest Test Environment](https://vitest.dev/guide/environment)

### 6.4 Use Setup Files for Global Configuration

**Impact: MEDIUM (Centralizes test setup and ensures consistent environment across all tests)**

Repeating setup code in every test file (like Testing Library matchers, MSW handlers, or global mocks) leads to inconsistency and duplication. Setup files run once before tests and apply to all files.

**Incorrect (repeated setup in each file):**

```typescript
// Every test file has this boilerplate
import '@testing-library/jest-dom'
import { server } from './mocks/server'
import { beforeAll, afterAll, afterEach } from 'vitest'

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

// ...actual tests
```

**Correct (centralized setup file):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    setupFiles: ['./vitest.setup.ts'],
  },
})
```

```typescript
// vitest.setup.ts
import '@testing-library/jest-dom'
import { beforeAll, afterAll, afterEach } from 'vitest'
import { server } from './mocks/server'

// Testing Library matchers
expect.extend(matchers)

// MSW setup
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

// Global mocks
vi.mock('./config', () => ({
  config: { apiUrl: 'http://localhost:3000' },
}))
```

**Test files become cleaner:**

```typescript
// src/components/UserList.test.tsx
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'

// No boilerplate - just tests
describe('UserList', () => {
  it('should render users', async () => {
    render(<UserList />)
    expect(await screen.findByText('Alice')).toBeInTheDocument()
  })
})
```

**Multiple setup files:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    setupFiles: [
      './vitest.setup.ts',      // Base setup
      './vitest.mocks.ts',      // Global mocks
      './vitest.matchers.ts',   // Custom matchers
    ],
  },
})
```

**Benefits:**
- DRY - setup code in one place
- Consistent environment across all tests
- Easier to update global configuration

Reference: [Vitest Setup Files](https://vitest.dev/config/#setupfiles)

---

## 7. Assertions

**Impact: LOW-MEDIUM**

Weak assertions, missing edge cases, and improper matcher selection reduce bug detection capability and produce tests that pass despite incorrect behavior.

### 7.1 Choose toBe vs toEqual Correctly

**Impact: LOW (Prevents false positives from reference vs value comparison)**

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

### 7.2 Test Edge Cases and Boundaries

**Impact: MEDIUM (Catches bugs that happy-path-only tests miss)**

Tests that only cover the happy path miss bugs that occur with edge cases. Empty arrays, null values, zero, negative numbers, and boundary conditions are where most bugs hide.

**Incorrect (happy path only):**

```typescript
import { describe, it, expect } from 'vitest'

describe('calculateDiscount', () => {
  it('should apply discount', () => {
    expect(calculateDiscount(100, 10)).toBe(90)
  })
})
// What about 0% discount? 100% discount? Negative prices? Null input?
```

**Correct (edge cases covered):**

```typescript
import { describe, it, expect } from 'vitest'

describe('calculateDiscount', () => {
  // Happy path
  it('should apply 10% discount to $100', () => {
    expect(calculateDiscount(100, 10)).toBe(90)
  })

  // Zero boundary
  it('should handle 0% discount', () => {
    expect(calculateDiscount(100, 0)).toBe(100)
  })

  // Upper boundary
  it('should handle 100% discount', () => {
    expect(calculateDiscount(100, 100)).toBe(0)
  })

  // Zero price
  it('should handle $0 price', () => {
    expect(calculateDiscount(0, 50)).toBe(0)
  })

  // Error cases
  it('should throw for negative discount', () => {
    expect(() => calculateDiscount(100, -10)).toThrow('Discount cannot be negative')
  })

  it('should throw for discount over 100%', () => {
    expect(() => calculateDiscount(100, 150)).toThrow('Discount cannot exceed 100%')
  })

  // Null/undefined
  it('should throw for null price', () => {
    expect(() => calculateDiscount(null, 10)).toThrow()
  })
})
```

**Common edge cases checklist:**

| Category | Cases to Test |
|----------|---------------|
| Numbers | 0, 1, -1, MAX_SAFE_INTEGER, NaN, Infinity |
| Strings | "", " ", very long strings, special characters |
| Arrays | [], [single item], [many items] |
| Objects | {}, null, missing properties |
| Dates | past, future, now, invalid dates |
| Async | timeout, network error, empty response |

**Benefits:**
- Catches bugs before production
- Documents expected behavior at boundaries
- Improves code robustness

Reference: [Vitest Test Patterns](https://vitest.dev/api/)

### 7.3 Test One Concept Per Test

**Impact: LOW-MEDIUM (Improves failure diagnosis and test maintainability)**

Tests that verify multiple unrelated behaviors are hard to debug when they fail. You can't tell which behavior broke. Split tests so each focuses on one concept.

**Incorrect (multiple concepts):**

```typescript
import { describe, it, expect } from 'vitest'

describe('User', () => {
  it('should work correctly', () => {
    const user = new User('Alice', 'alice@test.com')

    // Testing creation
    expect(user.name).toBe('Alice')
    expect(user.email).toBe('alice@test.com')

    // Testing validation
    expect(user.isValid()).toBe(true)

    // Testing formatting
    expect(user.toString()).toBe('Alice <alice@test.com>')

    // Testing update
    user.updateEmail('new@test.com')
    expect(user.email).toBe('new@test.com')

    // If this test fails, which behavior is broken?
  })
})
```

**Correct (one concept per test):**

```typescript
import { describe, it, expect } from 'vitest'

describe('User', () => {
  describe('creation', () => {
    it('should set name and email from constructor', () => {
      const user = new User('Alice', 'alice@test.com')
      expect(user.name).toBe('Alice')
      expect(user.email).toBe('alice@test.com')
    })
  })

  describe('validation', () => {
    it('should be valid with proper name and email', () => {
      const user = new User('Alice', 'alice@test.com')
      expect(user.isValid()).toBe(true)
    })

    it('should be invalid with empty name', () => {
      const user = new User('', 'alice@test.com')
      expect(user.isValid()).toBe(false)
    })
  })

  describe('formatting', () => {
    it('should format as "name <email>"', () => {
      const user = new User('Alice', 'alice@test.com')
      expect(user.toString()).toBe('Alice <alice@test.com>')
    })
  })

  describe('updateEmail', () => {
    it('should update the email address', () => {
      const user = new User('Alice', 'alice@test.com')
      user.updateEmail('new@test.com')
      expect(user.email).toBe('new@test.com')
    })
  })
})
```

**Signs of testing too much:**
- Test name uses "and" (e.g., "should create and validate")
- More than 5-7 assertions
- Test requires complex setup for unrelated behaviors
- Test name is vague ("should work", "handles everything")

**Benefits:**
- Failing tests clearly indicate what broke
- Easy to add new test cases
- Tests serve as documentation

Reference: [Vitest Test Organization](https://vitest.dev/api/)

### 7.4 Use expect.assertions for Async Tests

**Impact: MEDIUM (Prevents tests from passing when async assertions are skipped)**

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

### 7.5 Use Specific Matchers Over Generic Ones

**Impact: MEDIUM (Provides clearer failure messages and catches more specific bugs)**

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

---

## 8. Test Organization

**Impact: LOW**

File structure, naming conventions, describe block nesting, and test grouping patterns affect long-term maintainability and test discoverability.

### 8.1 Colocate Test Files with Source Files

**Impact: LOW (Reduces navigation overhead and improves test discoverability)**

Placing tests in a separate `__tests__` directory far from source files makes them hard to find and maintain. Colocating tests next to their source files improves discoverability and encourages testing.

**Harder to maintain (separate directory):**

```
src/
  components/
    Button.tsx
    UserList.tsx
  utils/
    format.ts
    validate.ts
tests/
  components/
    Button.test.tsx
    UserList.test.tsx
  utils/
    format.test.ts
    validate.test.ts
```

**Easier to maintain (colocated):**

```
src/
  components/
    Button.tsx
    Button.test.tsx
    UserList.tsx
    UserList.test.tsx
  utils/
    format.ts
    format.test.ts
    validate.ts
    validate.test.ts
```

**Vitest configuration:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Match test files next to source
    include: ['src/**/*.{test,spec}.{ts,tsx}'],
  },
})
```

**Alternative: Adjacent test directories:**

```
src/
  components/
    Button/
      Button.tsx
      Button.test.tsx
      index.ts
    UserList/
      UserList.tsx
      UserList.test.tsx
      UserList.stories.tsx
      index.ts
```

**Build exclusion:**

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      external: [/\.test\.tsx?$/], // Exclude test files from build
    },
  },
})
```

**Benefits:**
- Easy to find tests for any file
- Missing tests are obvious
- Related files stay together

Reference: [Vitest Include Patterns](https://vitest.dev/config/#include)

### 8.2 Use Describe Blocks for Logical Grouping

**Impact: LOW (Improves test output readability and enables scoped setup/teardown)**

Flat test files with many `it()` blocks are hard to scan. Use `describe()` blocks to group related tests, enabling scoped setup and clearer failure messages.

**Incorrect (flat structure):**

```typescript
import { describe, it, expect } from 'vitest'

it('should create user with valid data', () => {})
it('should fail to create user with invalid email', () => {})
it('should fail to create user with short password', () => {})
it('should update user name', () => {})
it('should update user email', () => {})
it('should fail to update with invalid email', () => {})
it('should delete user', () => {})
it('should fail to delete non-existent user', () => {})
// Hard to see the structure
```

**Correct (logical grouping):**

```typescript
import { describe, it, expect, beforeEach } from 'vitest'

describe('UserService', () => {
  describe('create', () => {
    it('should create user with valid data', () => {})

    describe('validation', () => {
      it('should reject invalid email', () => {})
      it('should reject short password', () => {})
    })
  })

  describe('update', () => {
    beforeEach(() => {
      // Setup specific to update tests
    })

    it('should update user name', () => {})
    it('should update user email', () => {})
    it('should reject invalid email', () => {})
  })

  describe('delete', () => {
    it('should delete existing user', () => {})
    it('should throw for non-existent user', () => {})
  })
})
```

**Test output comparison:**

```
# Flat structure output
✓ should create user with valid data
✓ should fail to create user with invalid email
✗ should fail to create user with short password
# Which feature is failing?

# Grouped structure output
✓ UserService > create > should create user with valid data
✓ UserService > create > validation > should reject invalid email
✗ UserService > create > validation > should reject short password
# Clear: create validation is failing
```

**Nesting limits:**
- Keep nesting to 2-3 levels max
- If deeper, consider splitting into separate files

**Benefits:**
- Clearer test output
- Scoped beforeEach/afterEach
- Easy to run subsets (`vitest UserService.create`)

Reference: [Vitest describe](https://vitest.dev/api/#describe)

### 8.3 Use skip and only Appropriately

**Impact: LOW (Prevents accidentally committing focused or skipped tests)**

`test.only` and `test.skip` are useful during development but dangerous when committed. CI should catch these to prevent accidentally running incomplete test suites.

**During development (acceptable):**

```typescript
import { describe, it, expect } from 'vitest'

describe('FeatureUnderDevelopment', () => {
  // Focus on the test you're writing
  it.only('should handle the new case', () => {
    expect(newFeature()).toBe(true)
  })

  it('other test that would slow you down', () => {
    // This won't run while you focus on the above
  })
})
```

**In committed code (problematic):**

```typescript
// DON'T commit this!
it.only('should work', () => {}) // Only this test runs, all others skipped

// Also problematic
it.skip('broken test we ignore', () => {}) // Technical debt accumulating
```

**CI protection with eslint:**

```javascript
// .eslintrc.js
module.exports = {
  rules: {
    'vitest/no-focused-tests': 'error',  // Fails on .only
    'vitest/no-disabled-tests': 'warn',  // Warns on .skip
  },
}
```

**Vitest CLI protection:**

```bash
# Fail if .only tests are found
vitest run --allowOnly=false
```

**Proper skip usage with reason:**

```typescript
// If you must skip, document why
it.skip('should integrate with legacy API', () => {
  // TODO: Re-enable when legacy API migration complete (JIRA-1234)
})

// Or use todo for planned tests
it.todo('should handle rate limiting')
```

**Benefits:**
- Full test suite always runs in CI
- Skipped tests don't accumulate silently
- Clear tracking of incomplete tests

Reference: [Vitest Only and Skip](https://vitest.dev/api/#test-only)

### 8.4 Write Descriptive Test Names

**Impact: LOW (Improves test documentation and failure debugging)**

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

---

## References

1. [https://vitest.dev/guide/improving-performance](https://vitest.dev/guide/improving-performance)
2. [https://vitest.dev/guide/profiling-test-performance](https://vitest.dev/guide/profiling-test-performance)
3. [https://vitest.dev/guide/mocking](https://vitest.dev/guide/mocking)
4. [https://vitest.dev/guide/snapshot](https://vitest.dev/guide/snapshot)
5. [https://vitest.dev/guide/browser/component-testing](https://vitest.dev/guide/browser/component-testing)
6. [https://trunk.io/blog/how-to-avoid-and-detect-flaky-tests-in-vitest](https://trunk.io/blog/how-to-avoid-and-detect-flaky-tests-in-vitest)
7. [https://mswjs.io/docs/](https://mswjs.io/docs/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |