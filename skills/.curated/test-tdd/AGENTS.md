# Test-Driven Development

**Version 0.1.0**  
Community  
January 2026

> **Note:**
> This document is mainly for agents and LLMs to follow when practicing test-driven development,
> writing tests, or refactoring test suites. Humans may also find it useful,
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive guide to Test-Driven Development practices, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (red-green-refactor cycle, test design principles) to strategic (test pyramid, coverage targets). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide test writing, refactoring, and code generation.

---

## Table of Contents

1. [Red-Green-Refactor Cycle](#1-red-green-refactor-cycle) — **CRITICAL**
   - 1.1 [Maintain a Test List](#11-maintain-a-test-list)
   - 1.2 [Refactor Immediately After Green](#12-refactor-immediately-after-green)
   - 1.3 [Take Small Incremental Steps](#13-take-small-incremental-steps)
   - 1.4 [Verify the Test Fails Before Writing Code](#14-verify-the-test-fails-before-writing-code)
   - 1.5 [Write Only Enough Code to Pass the Test](#15-write-only-enough-code-to-pass-the-test)
   - 1.6 [Write the Test Before the Implementation](#16-write-the-test-before-the-implementation)
2. [Test Design Principles](#2-test-design-principles) — **CRITICAL**
   - 2.1 [Avoid Logic in Tests](#21-avoid-logic-in-tests)
   - 2.2 [Follow the Arrange-Act-Assert Pattern](#22-follow-the-arrange-act-assert-pattern)
   - 2.3 [One Logical Assertion Per Test](#23-one-logical-assertion-per-test)
   - 2.4 [Test Behavior Not Implementation](#24-test-behavior-not-implementation)
   - 2.5 [Test Edge Cases and Boundaries](#25-test-edge-cases-and-boundaries)
   - 2.6 [Use Descriptive Test Names](#26-use-descriptive-test-names)
3. [Test Isolation & Dependencies](#3-test-isolation-dependencies) — **HIGH**
   - 3.1 [Avoid Shared Mutable State Between Tests](#31-avoid-shared-mutable-state-between-tests)
   - 3.2 [Mock External Dependencies](#32-mock-external-dependencies)
   - 3.3 [Prefer Stubs Over Mocks for Queries](#33-prefer-stubs-over-mocks-for-queries)
   - 3.4 [Use Dependency Injection for Testability](#34-use-dependency-injection-for-testability)
   - 3.5 [Write Deterministic Tests](#35-write-deterministic-tests)
4. [Test Data Management](#4-test-data-management) — **HIGH**
   - 4.1 [Avoid Mystery Guests](#41-avoid-mystery-guests)
   - 4.2 [Keep Test Setup Minimal](#42-keep-test-setup-minimal)
   - 4.3 [Use Builder Pattern for Complex Objects](#43-use-builder-pattern-for-complex-objects)
   - 4.4 [Use Factories for Test Data Creation](#44-use-factories-for-test-data-creation)
   - 4.5 [Use Unique Identifiers Per Test](#45-use-unique-identifiers-per-test)
5. [Assertions & Verification](#5-assertions-verification) — **MEDIUM**
   - 5.1 [Assert on Error Messages and Types](#51-assert-on-error-messages-and-types)
   - 5.2 [Create Custom Matchers for Domain Assertions](#52-create-custom-matchers-for-domain-assertions)
   - 5.3 [Every Test Must Have Assertions](#53-every-test-must-have-assertions)
   - 5.4 [Use Snapshot Testing Judiciously](#54-use-snapshot-testing-judiciously)
   - 5.5 [Use Specific Assertions](#55-use-specific-assertions)
6. [Test Organization & Structure](#6-test-organization-structure) — **MEDIUM**
   - 6.1 [Extract Reusable Test Utilities](#61-extract-reusable-test-utilities)
   - 6.2 [Follow Consistent Test File Structure](#62-follow-consistent-test-file-structure)
   - 6.3 [Group Tests by Behavior Not Method](#63-group-tests-by-behavior-not-method)
   - 6.4 [Use Parameterized Tests for Variations](#64-use-parameterized-tests-for-variations)
   - 6.5 [Use Setup and Teardown Hooks Appropriately](#65-use-setup-and-teardown-hooks-appropriately)
7. [Test Performance & Reliability](#7-test-performance-reliability) — **MEDIUM**
   - 7.1 [Avoid Arbitrary Sleep Calls](#71-avoid-arbitrary-sleep-calls)
   - 7.2 [Eliminate Network Calls in Unit Tests](#72-eliminate-network-calls-in-unit-tests)
   - 7.3 [Fix Flaky Tests Immediately](#73-fix-flaky-tests-immediately)
   - 7.4 [Keep Unit Tests Under 100ms](#74-keep-unit-tests-under-100ms)
   - 7.5 [Parallelize Independent Tests](#75-parallelize-independent-tests)
8. [Test Pyramid & Strategy](#8-test-pyramid-strategy) — **LOW**
   - 8.1 [Follow the Test Pyramid](#81-follow-the-test-pyramid)
   - 8.2 [Limit E2E Tests to Critical User Paths](#82-limit-e2e-tests-to-critical-user-paths)
   - 8.3 [Set Meaningful Coverage Targets](#83-set-meaningful-coverage-targets)
   - 8.4 [Test Integration at Service Boundaries](#84-test-integration-at-service-boundaries)
   - 8.5 [Use Mutation Testing to Validate Test Quality](#85-use-mutation-testing-to-validate-test-quality)

---

## 1. Red-Green-Refactor Cycle

**Impact: CRITICAL**

The core TDD loop is the foundation of test-driven development. Breaking the cycle leads to untested code, design debt, and lost confidence in the test suite.

### 1.1 Maintain a Test List

**Impact: CRITICAL (prevents scope creep and forgotten cases)**

Before coding, write down all the test cases you can think of. Work through them one at a time. This prevents scope creep during implementation and ensures edge cases aren't forgotten.

**Incorrect (ad-hoc test discovery):**

```typescript
// Start coding without a plan
test('parses valid JSON', () => {
  expect(parseConfig('{"key": "value"}')).toEqual({ key: 'value' })
})
// Pass, move on

test('handles nested objects', () => {
  expect(parseConfig('{"a": {"b": 1}}')).toEqual({ a: { b: 1 } })
})
// Pass, move on, forget about error cases

// Ship to production, crashes on invalid input
// Edge cases discovered by users, not tests
```

**Correct (test list first):**

```typescript
/*
 * Test List for parseConfig:
 * [x] parses valid JSON object
 * [x] parses nested objects
 * [x] parses arrays
 * [ ] throws on invalid JSON syntax
 * [ ] throws on non-object root (array, string, number)
 * [ ] handles empty object {}
 * [ ] handles unicode characters
 * [ ] handles escaped quotes in strings
 */

// Work through list systematically
test('parses valid JSON object', () => {
  expect(parseConfig('{"key": "value"}')).toEqual({ key: 'value' })
})

test('throws on invalid JSON syntax', () => {
  expect(() => parseConfig('{invalid}')).toThrow('Invalid JSON')
})

test('throws on non-object root', () => {
  expect(() => parseConfig('[1, 2, 3]')).toThrow('Config must be an object')
})

// Add new cases to list as you discover them
// Cross off completed tests
```

**Managing the test list:**
- Keep it visible (comment block, sticky note, or task tracker)
- Add new cases as you think of them during implementation
- Prioritize by risk and importance
- Don't remove items, mark them done

Reference: [Test Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)

### 1.2 Refactor Immediately After Green

**Impact: CRITICAL (prevents technical debt accumulation)**

The REFACTOR phase is not optional. Once tests pass, immediately clean up both production and test code. Skipping refactoring accumulates technical debt that compounds over time.

**Incorrect (skipping refactor phase):**

```typescript
// Test passes, move on to next feature
test('calculates order total with tax', () => {
  const order = { items: [{ price: 100 }, { price: 50 }], taxRate: 0.1 }
  expect(calculateTotal(order)).toBe(165)
})

// Quick and dirty implementation, "will clean up later"
function calculateTotal(order: Order): number {
  let t = 0
  for (let i = 0; i < order.items.length; i++) {
    t = t + order.items[i].price
  }
  t = t + t * order.taxRate
  return t
}
// Technical debt: unclear variable names, imperative style
```

**Correct (refactor while context is fresh):**

```typescript
test('calculates order total with tax', () => {
  const order = { items: [{ price: 100 }, { price: 50 }], taxRate: 0.1 }
  expect(calculateTotal(order)).toBe(165)
})

// After GREEN, immediately refactor
function calculateTotal(order: Order): number {
  const subtotal = order.items.reduce((sum, item) => sum + item.price, 0)
  const tax = subtotal * order.taxRate
  return subtotal + tax
}
// Clean: descriptive names, functional style, clear intent
```

**The refactor checklist:**
- Rename unclear variables and functions
- Extract repeated code into functions
- Remove duplication in test setup
- Simplify complex conditionals

**Note:** Run tests after each refactoring step to ensure behavior is preserved.

Reference: [Red-Green-Refactor - James Shore](http://www.jamesshore.com/v2/blog/2005/red-green-refactor)

### 1.3 Take Small Incremental Steps

**Impact: CRITICAL (2-5× faster debugging from smaller change sets)**

Each red-green-refactor cycle should take seconds to minutes, not hours. Small steps provide rapid feedback, reduce debugging time, and make it easy to identify what broke.

**Incorrect (giant leaps):**

```typescript
// One massive test covering entire feature
test('user registration with validation and email', async () => {
  const result = await registerUser({
    email: 'test@example.com',
    password: 'SecurePass123!',
    name: 'John Doe'
  })

  expect(result.success).toBe(true)
  expect(result.user.email).toBe('test@example.com')
  expect(result.user.emailVerified).toBe(false)
  expect(emailService.sendVerification).toHaveBeenCalled()
  expect(await database.users.findByEmail('test@example.com')).toBeDefined()
})

// Then write hundreds of lines to make it pass
// When it fails, unclear which part is broken
```

**Correct (baby steps):**

```typescript
// Step 1: User can be created
test('creates user with email and name', () => {
  const user = createUser({ email: 'test@example.com', name: 'John' })
  expect(user.email).toBe('test@example.com')
})
// Implement, refactor, commit

// Step 2: Password validation
test('rejects weak passwords', () => {
  expect(() => createUser({
    email: 'test@example.com',
    password: '123'
  })).toThrow('Password too weak')
})
// Implement, refactor, commit

// Step 3: Email verification flag
test('new users start with unverified email', () => {
  const user = createUser({ email: 'test@example.com', name: 'John' })
  expect(user.emailVerified).toBe(false)
})
// Implement, refactor, commit

// Each step: ~30 seconds to 2 minutes
```

**Benefits of small steps:**
- Failures are immediately traceable to last change
- Easier to maintain focus and flow
- Can commit after each passing cycle
- Natural breakpoints for review or pause

Reference: [The Cycles of TDD - Clean Coder Blog](http://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html)

### 1.4 Verify the Test Fails Before Writing Code

**Impact: CRITICAL (prevents false positives from untested code)**

Always run your new test and watch it fail before writing implementation code. A test that passes immediately either tests nothing meaningful or the feature already exists.

**Incorrect (never seeing red):**

```typescript
// Write test
test('validates email format', () => {
  expect(isValidEmail('user@example.com')).toBe(true)
})

// Immediately write implementation without running test
function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
}

// Run tests - passes, but did the test ever fail?
// Could be testing the wrong function or have a typo
```

**Correct (verify RED before GREEN):**

```typescript
// Step 1: Write test
test('validates email format', () => {
  expect(isValidEmail('user@example.com')).toBe(true)
})

// Step 2: Run test - see it fail
// Error: isValidEmail is not defined
// This confirms the test is wired up correctly

// Step 3: Write minimal stub
function isValidEmail(email: string): boolean {
  return false
}

// Step 4: Run test - see it fail with correct assertion
// Expected: true, Received: false
// This confirms the assertion is testing the right thing

// Step 5: Implement
function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
}

// Step 6: Run test - see it pass (GREEN)
```

**Why this matters:**
- Confirms test is actually running
- Validates the assertion checks what you intend
- Catches copy-paste errors from other tests
- Proves the test can detect failure

Reference: [Test Driven Development - Martin Fowler](https://martinfowler.com/bliki/TestDrivenDevelopment.html)

### 1.5 Write Only Enough Code to Pass the Test

**Impact: CRITICAL (prevents over-engineering and YAGNI violations)**

In the GREEN phase, write the absolute minimum code needed to make the failing test pass. Resist the urge to add features, optimizations, or "obvious" improvements not yet required by a test.

**Incorrect (over-engineering in GREEN phase):**

```typescript
test('returns user by id', async () => {
  const user = await userService.getById('user-123')
  expect(user.id).toBe('user-123')
})

// Implementation does more than needed
class UserService {
  private cache = new Map<string, User>()
  private logger = new Logger()

  async getById(id: string): Promise<User> {
    // Caching not required by any test yet
    if (this.cache.has(id)) {
      this.logger.info('Cache hit', { id })
      return this.cache.get(id)!
    }

    const user = await this.repository.findById(id)
    this.cache.set(id, user)
    this.logger.info('Cache miss', { id })
    return user
  }
}
```

**Correct (minimal implementation):**

```typescript
test('returns user by id', async () => {
  const user = await userService.getById('user-123')
  expect(user.id).toBe('user-123')
})

// Implementation does exactly what's needed
class UserService {
  async getById(id: string): Promise<User> {
    return this.repository.findById(id)
  }
}
// Add caching only when a test requires it
```

**When to expand:**
- Only when a new test requires additional behavior
- During the REFACTOR phase for structural improvements
- Never add untested features "while you're in there"

Reference: [The Cycles of TDD - Clean Coder Blog](http://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html)

### 1.6 Write the Test Before the Implementation

**Impact: CRITICAL (prevents 40-90% of defects)**

Writing the test first forces you to think about the API design and expected behavior before writing production code. This leads to better interfaces and catches design issues early.

**Incorrect (implementation first, test as afterthought):**

```typescript
// 1. Write implementation first
function calculateDiscount(price: number, customerType: string): number {
  if (customerType === 'premium') {
    return price * 0.2
  }
  if (customerType === 'regular') {
    return price * 0.1
  }
  return 0
}

// 2. Write test after (often skipped or superficial)
test('calculateDiscount works', () => {
  expect(calculateDiscount(100, 'premium')).toBe(20)
})
// Edge cases forgotten, API already locked in
```

**Correct (test first, implementation follows):**

```typescript
// 1. Write failing test first (RED)
describe('calculateDiscount', () => {
  it('applies 20% discount for premium customers', () => {
    expect(calculateDiscount(100, 'premium')).toBe(20)
  })

  it('applies 10% discount for regular customers', () => {
    expect(calculateDiscount(100, 'regular')).toBe(10)
  })

  it('returns zero discount for unknown customer types', () => {
    expect(calculateDiscount(100, 'unknown')).toBe(0)
  })
})

// 2. Write minimal implementation to pass (GREEN)
function calculateDiscount(price: number, customerType: string): number {
  const discounts: Record<string, number> = { premium: 0.2, regular: 0.1 }
  return price * (discounts[customerType] ?? 0)
}
```

**Benefits:**
- Forces consideration of edge cases before implementation
- Results in more testable, better-designed APIs
- Ensures tests actually verify behavior, not just exercise code

Reference: [Test Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)

---

## 2. Test Design Principles

**Impact: CRITICAL**

Well-designed tests are maintainable, readable, and catch real bugs. Poor test design creates brittle, hard-to-maintain tests that provide false confidence.

### 2.1 Avoid Logic in Tests

**Impact: CRITICAL (eliminates bugs in test code itself)**

Tests should be straightforward sequences of setup, action, and verification. Conditionals, loops, and complex calculations in tests can contain bugs, making tests unreliable.

**Incorrect (logic in tests):**

```typescript
test('calculates correct totals for all order types', () => {
  const orderTypes = ['standard', 'express', 'overnight']
  const expectedMultipliers = [1, 1.5, 2.5]

  for (let i = 0; i < orderTypes.length; i++) {
    const order = createOrder({ type: orderTypes[i], basePrice: 100 })
    const total = calculateShipping(order)

    // Bug: if expectedMultipliers array is wrong, test passes bad code
    expect(total).toBe(100 * expectedMultipliers[i])
  }
})

test('filters active users', () => {
  const users = createUsers(10)
  const activeUsers = users.filter(u => u.isActive)  // Logic in test!

  const result = filterActiveUsers(users)

  // If filter logic is wrong in both places, test passes
  expect(result).toEqual(activeUsers)
})
```

**Correct (explicit, linear tests):**

```typescript
test('standard shipping uses base price', () => {
  const order = createOrder({ type: 'standard', basePrice: 100 })
  const total = calculateShipping(order)
  expect(total).toBe(100)
})

test('express shipping adds 50% surcharge', () => {
  const order = createOrder({ type: 'express', basePrice: 100 })
  const total = calculateShipping(order)
  expect(total).toBe(150)
})

test('overnight shipping adds 150% surcharge', () => {
  const order = createOrder({ type: 'overnight', basePrice: 100 })
  const total = calculateShipping(order)
  expect(total).toBe(250)
})

test('filterActiveUsers returns only active users', () => {
  const activeUser = createUser({ isActive: true })
  const inactiveUser = createUser({ isActive: false })

  const result = filterActiveUsers([activeUser, inactiveUser])

  expect(result).toEqual([activeUser])
})
```

**Exceptions:**
- Parameterized tests with test framework support (e.g., `test.each`)
- Simple array literals for multiple assertions on same object

Reference: [Unit Testing Best Practices - Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices)

### 2.2 Follow the Arrange-Act-Assert Pattern

**Impact: CRITICAL (makes tests 2-3× more readable)**

Structure every test with three distinct phases: Arrange (setup), Act (execute), Assert (verify). This pattern makes tests predictable and easy to understand.

**Incorrect (phases interleaved):**

```typescript
test('processes order', async () => {
  const user = createUser()
  expect(user.orders).toHaveLength(0)  // Assert before Act

  const product = createProduct({ price: 100 })
  await orderService.addToCart(user.id, product.id)  // Act 1
  expect(await cartService.getItems(user.id)).toHaveLength(1)  // Assert 1

  const order = await orderService.checkout(user.id)  // Act 2
  expect(order.total).toBe(100)  // Assert 2
  expect(order.status).toBe('pending')  // Assert 2 continued

  await paymentService.process(order.id)  // Act 3
  expect(order.status).toBe('paid')  // Assert 3
})
```

**Correct (clear AAA structure):**

```typescript
test('checkout creates order with cart total', async () => {
  // Arrange
  const user = await createUser()
  const product = await createProduct({ price: 100 })
  await cartService.addItem(user.id, product.id)

  // Act
  const order = await orderService.checkout(user.id)

  // Assert
  expect(order.total).toBe(100)
  expect(order.status).toBe('pending')
})

test('processPayment marks order as paid', async () => {
  // Arrange
  const order = await createOrder({ status: 'pending', total: 100 })

  // Act
  await paymentService.process(order.id)

  // Assert
  const updated = await orderService.getById(order.id)
  expect(updated.status).toBe('paid')
})
```

**Guidelines:**
- One Act per test (single method call or user action)
- Assert only the outcomes of that specific Act
- Blank lines between sections improve readability
- Comments (`// Arrange`, `// Act`, `// Assert`) are optional but helpful

Reference: [AAA Pattern in Unit Testing - Semaphore](https://semaphore.io/blog/aaa-pattern-test-automation)

### 2.3 One Logical Assertion Per Test

**Impact: CRITICAL (reduces failure diagnosis time to O(1))**

Each test should verify one logical concept. When a test fails, you should know exactly what's broken without reading the test body.

**Incorrect (multiple unrelated assertions):**

```typescript
test('user service', async () => {
  const user = await userService.create({ name: 'Alice', email: 'alice@test.com' })

  expect(user.id).toBeDefined()
  expect(user.name).toBe('Alice')
  expect(user.email).toBe('alice@test.com')
  expect(user.createdAt).toBeInstanceOf(Date)

  const fetched = await userService.getById(user.id)
  expect(fetched).toEqual(user)

  await userService.delete(user.id)
  expect(await userService.getById(user.id)).toBeNull()
})
// If this fails, which operation broke?
```

**Correct (one concept per test):**

```typescript
describe('UserService', () => {
  describe('create', () => {
    it('generates a unique id', async () => {
      const user = await userService.create({ name: 'Alice', email: 'alice@test.com' })
      expect(user.id).toBeDefined()
    })

    it('stores provided name and email', async () => {
      const user = await userService.create({ name: 'Alice', email: 'alice@test.com' })
      expect(user).toMatchObject({ name: 'Alice', email: 'alice@test.com' })
    })

    it('sets createdAt to current time', async () => {
      const before = new Date()
      const user = await userService.create({ name: 'Alice', email: 'alice@test.com' })
      expect(user.createdAt.getTime()).toBeGreaterThanOrEqual(before.getTime())
    })
  })

  describe('getById', () => {
    it('returns previously created user', async () => {
      const created = await userService.create({ name: 'Alice', email: 'alice@test.com' })
      const fetched = await userService.getById(created.id)
      expect(fetched).toEqual(created)
    })
  })
})
```

**Note:** Multiple `expect` statements are fine when they verify the same logical assertion (e.g., checking multiple properties of a single return value).

Reference: [Unit Testing Best Practices - Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices)

### 2.4 Test Behavior Not Implementation

**Impact: CRITICAL (reduces test brittleness by 50-80%)**

Tests should verify what the code does (behavior), not how it does it (implementation). Implementation-coupled tests break during refactoring even when behavior is preserved.

**Incorrect (testing implementation details):**

```typescript
test('sortUsers calls quicksort with correct comparator', () => {
  const quicksortSpy = jest.spyOn(sortUtils, 'quicksort')

  sortUsers(users, 'name')

  expect(quicksortSpy).toHaveBeenCalledWith(
    users,
    expect.any(Function)
  )
  // Breaks if we switch to mergesort, even though behavior is identical
})

test('caches user in internal Map', () => {
  const service = new UserService()
  service.getUser('123')

  // Testing private implementation detail
  expect(service['cache'].has('123')).toBe(true)
  // Breaks if we change cache structure
})
```

**Correct (testing observable behavior):**

```typescript
test('sortUsers returns users ordered by name', () => {
  const users = [
    { name: 'Charlie', id: '1' },
    { name: 'Alice', id: '2' },
    { name: 'Bob', id: '3' }
  ]

  const sorted = sortUsers(users, 'name')

  expect(sorted.map(u => u.name)).toEqual(['Alice', 'Bob', 'Charlie'])
  // Passes regardless of sorting algorithm used
})

test('getUser returns same instance on repeated calls', () => {
  const service = new UserService()

  const first = await service.getUser('123')
  const second = await service.getUser('123')

  expect(first).toBe(second)
  // Tests caching behavior without knowing how it's implemented
})
```

**Ask yourself:**
- Would this test break if I refactored the internals?
- Am I testing public API or private implementation?
- Does this test document what users of this code care about?

Reference: [Testing Implementation Details - Kent C. Dodds](https://kentcdodds.com/blog/testing-implementation-details)

### 2.5 Test Edge Cases and Boundaries

**Impact: CRITICAL (catches 60-80% of production bugs)**

Happy path tests alone miss most bugs. Explicitly test boundaries, empty states, error conditions, and unusual inputs where bugs typically hide.

**Incorrect (happy path only):**

```typescript
test('paginates results', () => {
  const items = createItems(100)
  const result = paginate(items, { page: 1, pageSize: 10 })

  expect(result.items).toHaveLength(10)
  expect(result.totalPages).toBe(10)
})
// Works for normal case, crashes in production on edge cases
```

**Correct (comprehensive edge case coverage):**

```typescript
describe('paginate', () => {
  // Happy path
  it('returns requested page of items', () => {
    const items = createItems(100)
    const result = paginate(items, { page: 2, pageSize: 10 })
    expect(result.items).toHaveLength(10)
    expect(result.currentPage).toBe(2)
  })

  // Empty state
  it('returns empty array when no items exist', () => {
    const result = paginate([], { page: 1, pageSize: 10 })
    expect(result.items).toEqual([])
    expect(result.totalPages).toBe(0)
  })

  // Boundary: last page partial
  it('returns partial page when items dont fill last page', () => {
    const items = createItems(25)
    const result = paginate(items, { page: 3, pageSize: 10 })
    expect(result.items).toHaveLength(5)
  })

  // Boundary: page beyond range
  it('returns empty array when page exceeds total pages', () => {
    const items = createItems(10)
    const result = paginate(items, { page: 5, pageSize: 10 })
    expect(result.items).toEqual([])
  })

  // Invalid input
  it('throws when page is zero or negative', () => {
    expect(() => paginate([], { page: 0, pageSize: 10 })).toThrow()
    expect(() => paginate([], { page: -1, pageSize: 10 })).toThrow()
  })

  // Boundary: single item
  it('handles single item correctly', () => {
    const items = createItems(1)
    const result = paginate(items, { page: 1, pageSize: 10 })
    expect(result.items).toHaveLength(1)
    expect(result.totalPages).toBe(1)
  })
})
```

**Edge case checklist:**
- Empty collections
- Single item
- Maximum values
- Zero and negative numbers
- Null/undefined inputs
- Boundary conditions (off-by-one)
- Concurrent access

Reference: [Test Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)

### 2.6 Use Descriptive Test Names

**Impact: CRITICAL (2-3× faster failure diagnosis)**

Test names should describe the scenario and expected outcome so clearly that you understand what broke without reading the test code.

**Incorrect (vague or technical names):**

```typescript
test('test1', () => { /* ... */ })

test('calculator', () => { /* ... */ })

test('divide', () => { /* ... */ })

test('divideByZeroTest', () => { /* ... */ })

test('should work correctly', () => { /* ... */ })
```

**Correct (scenario and outcome in name):**

```typescript
// Pattern: [unit]_[scenario]_[expectedBehavior]
test('divide_positiveNumbers_returnsQuotient', () => {
  expect(divide(10, 2)).toBe(5)
})

test('divide_byZero_throwsDivisionError', () => {
  expect(() => divide(10, 0)).toThrow(DivisionError)
})

// Pattern: "should [outcome] when [condition]"
test('should return empty array when no users match filter', () => {
  const result = filterUsers(users, { role: 'nonexistent' })
  expect(result).toEqual([])
})

// Pattern: "it [does something]"
describe('ShoppingCart', () => {
  describe('addItem', () => {
    it('increases total by item price', () => { /* ... */ })
    it('increments item count', () => { /* ... */ })
    it('throws when item is out of stock', () => { /* ... */ })
  })
})
```

**Good test names answer:**
- What is being tested?
- Under what conditions?
- What is the expected result?

**Benefits:**
- Failed tests are immediately understandable
- Test suite serves as living documentation
- Easy to identify missing test cases

Reference: [Unit Test Naming Conventions - TheCodeBuzz](https://thecodebuzz.com/tdd-unit-testing-naming-conventions-and-standards/)

---

## 3. Test Isolation & Dependencies

**Impact: HIGH**

Isolated tests run fast, are deterministic, and pinpoint failures precisely. Coupled tests create flaky suites that erode developer trust.

### 3.1 Avoid Shared Mutable State Between Tests

**Impact: HIGH (eliminates 74% of test order dependency bugs)**

Each test must run in isolation without depending on or affecting other tests. Shared state causes tests to pass or fail based on execution order.

**Incorrect (shared mutable state):**

```typescript
// Shared across all tests in file
let userCount = 0
let database: User[] = []

test('creates first user', () => {
  const user = createUser({ name: 'Alice' })
  database.push(user)
  userCount++

  expect(database).toHaveLength(1)
  expect(userCount).toBe(1)
})

test('creates second user', () => {
  const user = createUser({ name: 'Bob' })
  database.push(user)
  userCount++

  // Fails if tests run in different order or parallel
  expect(database).toHaveLength(2)
  expect(userCount).toBe(2)
})
```

**Correct (isolated state per test):**

```typescript
describe('createUser', () => {
  let database: User[]

  beforeEach(() => {
    // Fresh state for each test
    database = []
  })

  test('creates first user', () => {
    const user = createUser({ name: 'Alice' })
    database.push(user)

    expect(database).toHaveLength(1)
  })

  test('creates second user', () => {
    const user = createUser({ name: 'Bob' })
    database.push(user)

    // Always passes regardless of test order
    expect(database).toHaveLength(1)
  })
})
```

**Isolation techniques:**
- Reset state in `beforeEach`
- Use unique identifiers per test (e.g., UUID)
- Wrap tests in database transactions that rollback
- Create fresh instances instead of reusing singletons

Reference: [Software Testing Anti-patterns - Codepipes](https://blog.codepipes.com/testing/software-testing-antipatterns.html)

### 3.2 Mock External Dependencies

**Impact: HIGH (makes tests 10-100× faster)**

Replace external systems (databases, APIs, file systems) with test doubles. This makes tests fast, deterministic, and independent of external state.

**Incorrect (using real external dependencies):**

```typescript
test('sends welcome email to new user', async () => {
  const user = await userService.register({
    email: 'test@example.com',
    name: 'Alice'
  })

  // Actually sends email - slow, unreliable, costs money
  // Fails if email server is down
  // Clutters real inbox or spam folder
  const emails = await checkEmailInbox('test@example.com')
  expect(emails).toContainEqual(expect.objectContaining({
    subject: 'Welcome to our platform!'
  }))
})
```

**Correct (mock external dependency):**

```typescript
test('sends welcome email to new user', async () => {
  // Arrange
  const mockEmailService = {
    send: jest.fn().mockResolvedValue({ success: true })
  }
  const userService = new UserService({ emailService: mockEmailService })

  // Act
  await userService.register({
    email: 'test@example.com',
    name: 'Alice'
  })

  // Assert
  expect(mockEmailService.send).toHaveBeenCalledWith({
    to: 'test@example.com',
    subject: 'Welcome to our platform!',
    body: expect.stringContaining('Alice')
  })
})
```

**What to mock:**
- HTTP APIs and network calls
- Databases
- File system operations
- Email/SMS services
- Third-party SDKs
- System clock and randomness

**What NOT to mock:**
- The code under test itself
- Simple value objects
- Pure utility functions

Reference: [Isolating Dependencies - Code Magazine](https://www.codemag.com/article/0906061/Isolating-Dependencies-in-Tests-Using-Mocks-and-Stubs)

### 3.3 Prefer Stubs Over Mocks for Queries

**Impact: HIGH (reduces test brittleness)**

Use stubs (return canned responses) for methods that return data. Reserve mocks (verify interactions) for methods that perform actions. Over-mocking leads to brittle tests.

**Incorrect (mocking everything):**

```typescript
test('displays user profile', async () => {
  const mockUserService = {
    getById: jest.fn().mockResolvedValue({ id: '123', name: 'Alice' }),
    getPreferences: jest.fn().mockResolvedValue({ theme: 'dark' }),
    getAvatar: jest.fn().mockResolvedValue('/avatar.png')
  }

  await renderProfile('123', mockUserService)

  // Verifying query calls creates coupling to implementation
  expect(mockUserService.getById).toHaveBeenCalledWith('123')
  expect(mockUserService.getPreferences).toHaveBeenCalledWith('123')
  expect(mockUserService.getAvatar).toHaveBeenCalledWith('123')
  // Test breaks if we batch these calls or change call order
})
```

**Correct (stubs for queries, mocks for commands):**

```typescript
test('displays user profile with preferences', async () => {
  // Stub: just provide data, don't verify calls
  const userService = {
    getById: async () => ({ id: '123', name: 'Alice' }),
    getPreferences: async () => ({ theme: 'dark' }),
    getAvatar: async () => '/avatar.png'
  }

  const { getByText, getByRole } = await renderProfile('123', userService)

  // Assert on observable output, not internal calls
  expect(getByText('Alice')).toBeInTheDocument()
  expect(document.body).toHaveClass('theme-dark')
})

test('saves updated preferences', async () => {
  // Mock: verify the command was called correctly
  const mockUserService = {
    getById: async () => ({ id: '123', name: 'Alice' }),
    getPreferences: async () => ({ theme: 'dark' }),
    savePreferences: jest.fn().mockResolvedValue({ success: true })
  }

  await updateTheme('123', 'light', mockUserService)

  // Commands should be verified
  expect(mockUserService.savePreferences).toHaveBeenCalledWith('123', {
    theme: 'light'
  })
})
```

**Guidelines:**
- **Queries** (return data, no side effects): Use stubs
- **Commands** (perform actions, have side effects): Use mocks
- When in doubt, stub it

Reference: [Mocks Aren't Stubs - Martin Fowler](https://martinfowler.com/articles/mocksArentStubs.html)

### 3.4 Use Dependency Injection for Testability

**Impact: HIGH (enables isolation without hacks)**

Design code to receive dependencies through constructor or method parameters rather than creating them internally. This enables easy substitution of test doubles.

**Incorrect (hard-coded dependencies):**

```typescript
class OrderService {
  async createOrder(items: Item[]): Promise<Order> {
    // Hard-coded dependency - impossible to test without real database
    const db = new DatabaseConnection()
    const order = await db.insert('orders', { items })

    // Hard-coded dependency - actually sends emails during tests
    const emailer = new EmailService()
    await emailer.send(order.userEmail, 'Order confirmed')

    return order
  }
}

// Test requires real database and email service
test('creates order', async () => {
  const service = new OrderService()
  const order = await service.createOrder([{ id: '1', price: 100 }])
  expect(order).toBeDefined()
  // Flaky, slow, sends real emails
})
```

**Correct (dependencies injected):**

```typescript
interface Database {
  insert(table: string, data: unknown): Promise<{ id: string }>
}

interface Emailer {
  send(to: string, subject: string): Promise<void>
}

class OrderService {
  constructor(
    private db: Database,
    private emailer: Emailer
  ) {}

  async createOrder(items: Item[]): Promise<Order> {
    const order = await this.db.insert('orders', { items })
    await this.emailer.send(order.userEmail, 'Order confirmed')
    return order
  }
}

// Test with injected fakes
test('creates order and sends confirmation', async () => {
  const fakeDb: Database = {
    insert: jest.fn().mockResolvedValue({
      id: 'order-123',
      userEmail: 'test@example.com'
    })
  }
  const fakeEmailer: Emailer = {
    send: jest.fn().mockResolvedValue(undefined)
  }

  const service = new OrderService(fakeDb, fakeEmailer)
  const order = await service.createOrder([{ id: '1', price: 100 }])

  expect(order.id).toBe('order-123')
  expect(fakeEmailer.send).toHaveBeenCalledWith(
    'test@example.com',
    'Order confirmed'
  )
})
```

**Benefits:**
- Tests run without real infrastructure
- Easy to test error conditions
- Clear dependencies in constructor
- Production code receives real implementations

Reference: [Dependency Injection - Tao of Testing](https://jasonpolites.github.io/tao-of-testing/ch3-1.1.html)

### 3.5 Write Deterministic Tests

**Impact: HIGH (eliminates flaky test failures)**

Tests must produce the same result every time when code hasn't changed. Non-deterministic tests erode trust and get ignored.

**Incorrect (non-deterministic tests):**

```typescript
test('generates unique order id', () => {
  const order = createOrder()
  // Depends on current time - flaky around midnight
  expect(order.id).toMatch(/^ORD-2024-/)
})

test('token expires in future', () => {
  const token = generateToken()
  // Race condition: might fail if test runs at exact boundary
  expect(token.expiresAt.getTime()).toBeGreaterThan(Date.now())
})

test('shuffles items randomly', () => {
  const items = [1, 2, 3, 4, 5]
  const shuffled = shuffle(items)
  // Non-deterministic: might be same order by chance
  expect(shuffled).not.toEqual(items)
})
```

**Correct (deterministic tests):**

```typescript
test('generates unique order id with date prefix', () => {
  // Inject fixed clock
  const fixedDate = new Date('2024-06-15T10:30:00Z')
  jest.useFakeTimers().setSystemTime(fixedDate)

  const order = createOrder()

  expect(order.id).toMatch(/^ORD-2024-06-15-/)
  jest.useRealTimers()
})

test('token expires 1 hour after creation', () => {
  const fixedNow = new Date('2024-06-15T10:00:00Z')
  jest.useFakeTimers().setSystemTime(fixedNow)

  const token = generateToken()

  const expectedExpiry = new Date('2024-06-15T11:00:00Z')
  expect(token.expiresAt).toEqual(expectedExpiry)
  jest.useRealTimers()
})

test('shuffle changes element positions', () => {
  // Seed random number generator for reproducibility
  const shuffler = createShuffler({ seed: 12345 })
  const items = [1, 2, 3, 4, 5]

  const shuffled = shuffler.shuffle(items)

  // Deterministic with seeded RNG
  expect(shuffled).toEqual([3, 1, 5, 2, 4])
})
```

**Sources of non-determinism to control:**
- Current time/date
- Random number generation
- External API responses
- File system state
- Network latency
- Parallel execution order

Reference: [Flaky Tests - Datadog](https://www.datadoghq.com/knowledge-center/flaky-tests/)

---

## 4. Test Data Management

**Impact: HIGH**

Proper test data setup prevents mystery guests, reduces coupling between tests, and keeps tests focused on the behavior being verified.

### 4.1 Avoid Mystery Guests

**Impact: HIGH (2-3× faster test comprehension)**

All test data should be visible within the test or clearly referenced. Hidden data loaded from fixtures or external files makes tests impossible to understand in isolation.

**Incorrect (mystery guest from fixtures):**

```typescript
// fixtures/users.json - somewhere else in the codebase
// { "testUser": { "id": "u1", "role": "admin", "permissions": ["read", "write", "delete"] } }

test('admin can delete posts', async () => {
  // Where does testUser come from? What role? What permissions?
  const result = await deletePost('post-123', fixtures.testUser)

  expect(result.success).toBe(true)
})

test('user permissions are checked', async () => {
  // Reader must hunt through fixture files to understand
  await expect(deletePost('post-123', fixtures.regularUser))
    .rejects.toThrow('Forbidden')
})
```

**Correct (data visible in test):**

```typescript
test('admin can delete posts', async () => {
  // All relevant information visible
  const admin = createUser({ role: 'admin', permissions: ['delete'] })

  const result = await deletePost('post-123', admin)

  expect(result.success).toBe(true)
})

test('users without delete permission cannot delete posts', async () => {
  const user = createUser({ role: 'member', permissions: ['read'] })

  await expect(deletePost('post-123', user))
    .rejects.toThrow('Forbidden')
})
```

**When fixtures are acceptable:**
- Reference data that never changes (country codes, currencies)
- Large datasets for performance testing
- Seed data for integration tests (clearly documented)

**Signs of mystery guests:**
- Test fails and you have to search for data definitions
- Changing a fixture breaks unrelated tests
- Test name doesn't explain why a particular fixture is used

Reference: [Software Testing Anti-patterns - Codepipes](https://blog.codepipes.com/testing/software-testing-antipatterns.html)

### 4.2 Keep Test Setup Minimal

**Impact: HIGH (2-5× faster test execution and comprehension)**

Include only the data necessary for the specific test. Excessive setup obscures the test's purpose and slows execution.

**Incorrect (excessive setup):**

```typescript
test('validates email format', () => {
  // Full user object when only email matters
  const user = {
    id: '123',
    firstName: 'John',
    lastName: 'Doe',
    email: 'invalid-email',
    dateOfBirth: new Date('1990-01-01'),
    address: {
      street: '123 Main St',
      city: 'Springfield',
      state: 'IL',
      zipCode: '12345'
    },
    preferences: {
      newsletter: true,
      notifications: { email: true, sms: false }
    },
    createdAt: new Date(),
    updatedAt: new Date()
  }

  const errors = validateUser(user)

  expect(errors).toContain('Invalid email format')
})
```

**Correct (minimal setup):**

```typescript
test('validates email format', () => {
  // Only email is relevant to this test
  const user = createUser({ email: 'invalid-email' })

  const errors = validateUser(user)

  expect(errors).toContain('Invalid email format')
})

// Or even simpler if testing just the email validator
test('rejects email without @ symbol', () => {
  const result = isValidEmail('invalidemail')

  expect(result).toBe(false)
})
```

**Guidelines:**
- If a property isn't in the test name, question whether it's needed
- Let factories provide default values for irrelevant properties
- Prefer testing smaller units that need less setup
- Complex setup often indicates design issues in production code

Reference: [Rails Testing Antipatterns - Semaphore](https://semaphore.io/blog/2014/01/14/rails-testing-antipatterns-fixtures-and-factories.html)

### 4.3 Use Builder Pattern for Complex Objects

**Impact: HIGH (reduces complex setup code by 40-60%)**

For objects with many optional fields or complex construction, use the builder pattern to create readable, flexible test setup.

**Incorrect (unwieldy object construction):**

```typescript
test('processes order with all options', () => {
  const order = {
    id: '123',
    customer: { id: 'c1', name: 'Alice', tier: 'premium' },
    items: [
      { productId: 'p1', quantity: 2, price: 100 },
      { productId: 'p2', quantity: 1, price: 50 }
    ],
    shipping: { method: 'express', address: { city: 'NYC', zip: '10001' } },
    payment: { method: 'card', cardLast4: '1234' },
    discount: { code: 'SAVE10', percent: 10 },
    giftWrap: true,
    giftMessage: 'Happy Birthday!'
  }

  const result = processOrder(order)
  expect(result.total).toBe(225)
})
```

**Correct (fluent builder):**

```typescript
// test-utils/order-builder.ts
class OrderBuilder {
  private order: Partial<Order> = {}

  withCustomer(tier: 'basic' | 'premium' = 'basic'): this {
    this.order.customer = createCustomer({ tier })
    return this
  }

  withItems(...items: Array<{ price: number; quantity?: number }>): this {
    this.order.items = items.map(item =>
      createOrderItem({ price: item.price, quantity: item.quantity ?? 1 })
    )
    return this
  }

  withDiscount(percent: number): this {
    this.order.discount = { code: 'TEST', percent }
    return this
  }

  withExpressShipping(): this {
    this.order.shipping = { method: 'express', address: createAddress() }
    return this
  }

  asGift(message: string): this {
    this.order.giftWrap = true
    this.order.giftMessage = message
    return this
  }

  build(): Order {
    return createOrder(this.order)
  }
}

const anOrder = () => new OrderBuilder()

// Clean, readable test
test('processes order with all options', () => {
  const order = anOrder()
    .withCustomer('premium')
    .withItems({ price: 100, quantity: 2 }, { price: 50 })
    .withDiscount(10)
    .withExpressShipping()
    .asGift('Happy Birthday!')
    .build()

  const result = processOrder(order)

  expect(result.total).toBe(225)
})
```

**When to use builders:**
- Objects with 5+ optional fields
- Complex nested structures
- Multiple valid configurations
- When tests need different combinations of options

Reference: [Effective tests: Creating test data - Dave Development](https://davedevelopment.co.uk/2015/11/11/creating-test-data-with-fixture-factories.html)

### 4.4 Use Factories for Test Data Creation

**Impact: HIGH (reduces test setup code by 60-80%)**

Create factory functions that generate test objects with sensible defaults. Override only the properties relevant to each test, keeping setup minimal and focused.

**Incorrect (verbose inline object creation):**

```typescript
test('calculates order total with discount', () => {
  const order = {
    id: '123',
    userId: 'user-456',
    items: [
      { id: 'item-1', name: 'Widget', price: 100, quantity: 2 },
      { id: 'item-2', name: 'Gadget', price: 50, quantity: 1 }
    ],
    discount: 0.1,
    status: 'pending',
    createdAt: new Date('2024-01-01'),
    updatedAt: new Date('2024-01-01'),
    shippingAddress: {
      street: '123 Main St',
      city: 'Springfield',
      zipCode: '12345',
      country: 'USA'
    }
  }
  // 20 lines of setup for a test about discount calculation
  expect(calculateTotal(order)).toBe(225)  // (200 + 50) * 0.9
})
```

**Correct (factory with relevant overrides):**

```typescript
// factories/order.ts
function createOrder(overrides: Partial<Order> = {}): Order {
  return {
    id: `order-${Math.random().toString(36).slice(2)}`,
    userId: 'default-user',
    items: [],
    discount: 0,
    status: 'pending',
    createdAt: new Date(),
    updatedAt: new Date(),
    shippingAddress: createAddress(),
    ...overrides
  }
}

function createOrderItem(overrides: Partial<OrderItem> = {}): OrderItem {
  return {
    id: `item-${Math.random().toString(36).slice(2)}`,
    name: 'Test Product',
    price: 10,
    quantity: 1,
    ...overrides
  }
}

// Test focuses only on relevant data
test('calculates order total with discount', () => {
  const order = createOrder({
    items: [
      createOrderItem({ price: 100, quantity: 2 }),
      createOrderItem({ price: 50, quantity: 1 })
    ],
    discount: 0.1
  })

  expect(calculateTotal(order)).toBe(225)
})
```

**Benefits:**
- Tests show only relevant data
- Single place to update when model changes
- Consistent default values across tests
- Readable test intent

Reference: [Test Factories - Radan Skoric](https://radanskoric.com/articles/test-factories-principal-of-minimal-defaults)

### 4.5 Use Unique Identifiers Per Test

**Impact: HIGH (prevents test pollution)**

Generate unique IDs for test entities to prevent conflicts between tests running in parallel or sharing a database.

**Incorrect (hard-coded IDs):**

```typescript
test('creates user', async () => {
  await userService.create({ id: 'user-1', email: 'test@example.com' })
  const user = await userService.getById('user-1')
  expect(user.email).toBe('test@example.com')
})

test('updates user', async () => {
  // Uses same ID - fails if tests run in parallel or wrong order
  await userService.create({ id: 'user-1', email: 'test@example.com' })
  await userService.update('user-1', { email: 'new@example.com' })
  const user = await userService.getById('user-1')
  expect(user.email).toBe('new@example.com')
})

test('deletes user', async () => {
  // May delete user from other test
  await userService.delete('user-1')
  expect(await userService.getById('user-1')).toBeNull()
})
```

**Correct (unique IDs):**

```typescript
function uniqueId(prefix: string = ''): string {
  return `${prefix}${Date.now()}-${Math.random().toString(36).slice(2)}`
}

test('creates user', async () => {
  const userId = uniqueId('user-')
  const email = `${uniqueId()}@example.com`

  await userService.create({ id: userId, email })
  const user = await userService.getById(userId)

  expect(user.email).toBe(email)
})

test('updates user', async () => {
  const userId = uniqueId('user-')
  await userService.create({ id: userId, email: 'original@example.com' })

  await userService.update(userId, { email: 'updated@example.com' })

  const user = await userService.getById(userId)
  expect(user.email).toBe('updated@example.com')
})

// Or use factory that generates unique IDs automatically
test('deletes user', async () => {
  const user = await createAndSaveUser()

  await userService.delete(user.id)

  expect(await userService.getById(user.id)).toBeNull()
})
```

**Benefits:**
- Tests can run in any order
- Tests can run in parallel
- No cleanup needed between tests
- Failures are isolated to single test

Reference: [How to deal with flaky tests - Semaphore](https://semaphore.io/community/tutorials/how-to-deal-with-and-eliminate-flaky-tests)

---

## 5. Assertions & Verification

**Impact: MEDIUM**

Clear, specific assertions catch bugs and document expected behavior. Weak or missing assertions let bugs slip through undetected.

### 5.1 Assert on Error Messages and Types

**Impact: MEDIUM (prevents false positives from wrong errors)**

When testing error conditions, verify both the error type and message. Catching any error isn't enough - the right error must be thrown.

**Incorrect (any error passes):**

```typescript
test('throws on invalid email', () => {
  // Passes if ANY error is thrown, even unrelated ones
  expect(() => createUser({ email: 'invalid' })).toThrow()
})

test('throws on missing required field', async () => {
  // Catches network errors, type errors, anything
  await expect(saveUser({})).rejects.toBeDefined()
})
```

**Correct (specific error assertions):**

```typescript
test('throws ValidationError for invalid email', () => {
  expect(() => createUser({ email: 'invalid' }))
    .toThrow(ValidationError)
})

test('error message indicates invalid email format', () => {
  expect(() => createUser({ email: 'invalid' }))
    .toThrow('Invalid email format')
})

test('throws with specific error details', () => {
  expect(() => createUser({ email: 'invalid' }))
    .toThrow(expect.objectContaining({
      code: 'VALIDATION_ERROR',
      field: 'email'
    }))
})

test('async operation throws NotFoundError', async () => {
  await expect(getUser('nonexistent'))
    .rejects.toThrow(NotFoundError)
})

test('error includes resource identifier', async () => {
  await expect(getUser('user-999'))
    .rejects.toThrow(/user-999/)
})
```

**What to assert:**
- Error class/type when using custom errors
- Error message content (exact or partial match)
- Error code or status when applicable
- Associated data (field name, invalid value)

Reference: [Unit Testing Best Practices - Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices)

### 5.2 Create Custom Matchers for Domain Assertions

**Impact: MEDIUM (reduces assertion code by 60-80%)**

For frequently-tested domain concepts, create custom matchers that express intent clearly and provide helpful failure messages.

**Incorrect (repeated complex assertions):**

```typescript
test('creates valid order', () => {
  const order = createOrder(orderData)

  // Repeated validation logic in every test
  expect(order.id).toMatch(/^ORD-\d{8}$/)
  expect(order.status).toBe('pending')
  expect(order.items.length).toBeGreaterThan(0)
  expect(order.total).toBeGreaterThan(0)
  expect(order.createdAt).toBeInstanceOf(Date)
})

test('checkout produces valid order', () => {
  const order = await checkout(cart)

  // Same checks duplicated
  expect(order.id).toMatch(/^ORD-\d{8}$/)
  expect(order.status).toBe('pending')
  expect(order.items.length).toBeGreaterThan(0)
  expect(order.total).toBeGreaterThan(0)
  expect(order.createdAt).toBeInstanceOf(Date)
})
```

**Correct (custom domain matcher):**

```typescript
// test-utils/matchers.ts
expect.extend({
  toBeValidOrder(received: unknown) {
    const order = received as Order
    const errors: string[] = []

    if (!order.id?.match(/^ORD-\d{8}$/)) {
      errors.push(`Invalid order ID: ${order.id}`)
    }
    if (order.status !== 'pending') {
      errors.push(`Expected status 'pending', got '${order.status}'`)
    }
    if (!order.items?.length) {
      errors.push('Order has no items')
    }
    if (!order.total || order.total <= 0) {
      errors.push(`Invalid total: ${order.total}`)
    }

    return {
      pass: errors.length === 0,
      message: () => errors.join('\n')
    }
  }
})

// Clean, expressive tests
test('creates valid order', () => {
  const order = createOrder(orderData)
  expect(order).toBeValidOrder()
})

test('checkout produces valid order', () => {
  const order = await checkout(cart)
  expect(order).toBeValidOrder()
})
```

**Good candidates for custom matchers:**
- Domain object validation
- Date/time comparisons
- Complex object structure checks
- API response validation
- State machine transitions

Reference: [Jest Custom Matchers](https://jestjs.io/docs/expect#expectextendmatchers)

### 5.3 Every Test Must Have Assertions

**Impact: MEDIUM (prevents false passing tests)**

A test without assertions always passes, providing false confidence. Every test must verify expected outcomes through explicit assertions.

**Incorrect (no assertions):**

```typescript
test('processes payment', async () => {
  const order = createOrder({ total: 100 })
  const payment = createPayment({ orderId: order.id, amount: 100 })

  // Calls the function but doesn't verify anything
  await paymentService.process(payment)
  // Test passes even if process() does nothing
})

test('user registration flow', async () => {
  const userData = { email: 'test@example.com', password: 'secret123' }

  const user = await userService.register(userData)
  await emailService.sendWelcome(user.id)
  await analyticsService.trackSignup(user.id)

  // Multiple operations, zero verification
  // Could silently fail and test still passes
})
```

**Correct (explicit assertions):**

```typescript
test('processes payment and updates order status', async () => {
  const order = createOrder({ total: 100, status: 'pending' })
  const payment = createPayment({ orderId: order.id, amount: 100 })

  await paymentService.process(payment)

  const updatedOrder = await orderService.getById(order.id)
  expect(updatedOrder.status).toBe('paid')
  expect(updatedOrder.paidAt).toBeDefined()
})

test('registration creates user and sends welcome email', async () => {
  const mockEmailService = { sendWelcome: jest.fn() }
  const userService = new UserService({ emailService: mockEmailService })

  const user = await userService.register({
    email: 'test@example.com',
    password: 'secret123'
  })

  expect(user.id).toBeDefined()
  expect(user.email).toBe('test@example.com')
  expect(mockEmailService.sendWelcome).toHaveBeenCalledWith(user.id)
})
```

**Common assertion-free antipatterns:**
- "Smoke tests" that just call methods
- Tests that only set up data
- Tests that verify internal state through logging

Reference: [Software Testing Anti-patterns - Codepipes](https://blog.codepipes.com/testing/software-testing-antipatterns.html)

### 5.4 Use Snapshot Testing Judiciously

**Impact: MEDIUM (prevents snapshot blindness)**

Snapshots are useful for detecting unintended changes but can become meaningless if overused. Use them for stable outputs and review changes carefully.

**Incorrect (snapshot everything):**

```typescript
test('user service', () => {
  const user = userService.create({ name: 'Alice', email: 'alice@test.com' })
  // Snapshot includes timestamps, IDs - breaks on every run
  expect(user).toMatchSnapshot()
})

test('renders user list', () => {
  const component = render(<UserList users={mockUsers} />)
  // 500-line snapshot that nobody reviews
  expect(component).toMatchSnapshot()
})

// When snapshot fails, developer just runs `--updateSnapshot`
// without actually reviewing what changed
```

**Correct (targeted snapshots):**

```typescript
test('user has expected structure', () => {
  const user = userService.create({ name: 'Alice', email: 'alice@test.com' })

  // Snapshot only stable parts
  expect({
    name: user.name,
    email: user.email,
    role: user.role
  }).toMatchSnapshot()
})

test('error message format', () => {
  const error = validateUser({ email: 'invalid' })
  // Snapshots work well for error message text
  expect(error.message).toMatchSnapshot()
})

// Prefer explicit assertions for behavior
test('renders correct number of users', () => {
  const { getAllByRole } = render(<UserList users={mockUsers} />)
  expect(getAllByRole('listitem')).toHaveLength(mockUsers.length)
})

// Inline snapshots for small, reviewable outputs
test('formats date correctly', () => {
  const formatted = formatDate(new Date('2024-06-15'))
  expect(formatted).toMatchInlineSnapshot(`"June 15, 2024"`)
})
```

**Snapshot best practices:**
- Keep snapshots small and focused
- Use inline snapshots for short outputs
- Exclude non-deterministic values (IDs, timestamps)
- Review snapshot changes in code review
- Prefer explicit assertions for critical behavior

Reference: [Snapshot Testing - Jest](https://jestjs.io/docs/snapshot-testing)

### 5.5 Use Specific Assertions

**Impact: MEDIUM (2-5× faster debugging from better failure messages)**

Use the most specific assertion available for the check. Specific assertions provide better failure messages and document expected behavior more clearly.

**Incorrect (generic assertions):**

```typescript
test('filters active users', () => {
  const users = [
    { id: '1', active: true },
    { id: '2', active: false }
  ]

  const result = filterActiveUsers(users)

  // Generic - failure message: "expected true to be false"
  expect(result.length === 1).toBe(true)
  expect(result[0].id === '1').toBe(true)
})

test('user has expected properties', () => {
  const user = getUser('123')

  // Generic - unhelpful failure message
  expect(user !== null).toBe(true)
  expect(typeof user.email === 'string').toBe(true)
})
```

**Correct (specific assertions):**

```typescript
test('filters active users', () => {
  const users = [
    { id: '1', active: true },
    { id: '2', active: false }
  ]

  const result = filterActiveUsers(users)

  // Specific - failure: "expected [array] to have length 1, got 0"
  expect(result).toHaveLength(1)
  // Specific - failure: "expected {id: '2'} to match {id: '1'}"
  expect(result[0]).toMatchObject({ id: '1' })
})

test('user has expected properties', () => {
  const user = getUser('123')

  // Specific - failure: "expected null not to be null"
  expect(user).not.toBeNull()
  // Specific - failure: "expected 123 to be a string"
  expect(user.email).toEqual(expect.any(String))
})
```

**Preferred matchers:**
- `toHaveLength()` over `.length === n`
- `toContain()` over `includes() === true`
- `toMatchObject()` over checking each property
- `toThrow()` over try/catch with boolean
- `toBeGreaterThan()` over `> comparison === true`

Reference: [Jest Expect API](https://jestjs.io/docs/expect)

---

## 6. Test Organization & Structure

**Impact: MEDIUM**

Well-organized test suites are maintainable and navigable. Poor organization hides tests, causes duplication, and increases maintenance burden.

### 6.1 Extract Reusable Test Utilities

**Impact: MEDIUM (reduces duplication by 40-60%)**

Create shared test utilities for common operations. Keep them in a dedicated location so all tests can use consistent patterns.

**Incorrect (duplicated test code):**

```typescript
// user.test.ts
test('creates user', async () => {
  const response = await request(app)
    .post('/api/users')
    .set('Authorization', `Bearer ${await getTestToken()}`)
    .set('Content-Type', 'application/json')
    .send({ email: 'test@example.com', name: 'Test' })

  expect(response.status).toBe(201)
})

// order.test.ts
test('creates order', async () => {
  // Same boilerplate repeated
  const response = await request(app)
    .post('/api/orders')
    .set('Authorization', `Bearer ${await getTestToken()}`)
    .set('Content-Type', 'application/json')
    .send({ items: [{ productId: '123', quantity: 1 }] })

  expect(response.status).toBe(201)
})
```

**Correct (extracted utilities):**

```typescript
// test-utils/api.ts
export function createApiClient(token?: string) {
  const client = {
    async post<T>(path: string, body: unknown): Promise<ApiResponse<T>> {
      const req = request(app)
        .post(path)
        .set('Content-Type', 'application/json')

      if (token) {
        req.set('Authorization', `Bearer ${token}`)
      }

      return req.send(body)
    },
    // get, put, delete...
  }
  return client
}

export async function authenticatedClient() {
  const token = await getTestToken()
  return createApiClient(token)
}

// user.test.ts
test('creates user', async () => {
  const api = await authenticatedClient()

  const response = await api.post('/api/users', {
    email: 'test@example.com',
    name: 'Test'
  })

  expect(response.status).toBe(201)
})

// order.test.ts
test('creates order', async () => {
  const api = await authenticatedClient()

  const response = await api.post('/api/orders', {
    items: [{ productId: '123', quantity: 1 }]
  })

  expect(response.status).toBe(201)
})
```

**Common test utilities:**
- API client wrappers
- Authentication helpers
- Database seeding functions
- Factory functions
- Custom matchers
- Wait/polling utilities

Reference: [Jest Manual - Setup Files](https://jestjs.io/docs/configuration#setupfilesafterenv-array)

### 6.2 Follow Consistent Test File Structure

**Impact: MEDIUM (reduces time finding tests)**

Establish and follow a consistent pattern for test file location and naming. Developers should instantly know where to find tests for any code.

**Incorrect (inconsistent structure):**

```text
src/
  services/
    userService.ts
    tests/
      userService.spec.ts
  models/
    user.ts
tests/
  models/
    user.test.ts
spec/
  integration/
    user_tests.js
__tests__/
  userStuff.ts
```

**Correct (consistent co-located tests):**

```text
src/
  services/
    userService.ts
    userService.test.ts        # Unit tests next to source
  models/
    user.ts
    user.test.ts
  components/
    UserProfile.tsx
    UserProfile.test.tsx
tests/
  integration/                  # Integration tests separate
    user-registration.test.ts
    checkout-flow.test.ts
  e2e/                         # E2E tests separate
    user-journey.test.ts
```

**Alternative (mirror structure):**

```text
src/
  services/
    userService.ts
  models/
    user.ts
tests/
  unit/
    services/
      userService.test.ts      # Mirrors src/ structure
    models/
      user.test.ts
  integration/
    user-registration.test.ts
```

**Naming conventions:**
- `*.test.ts` or `*.spec.ts` - pick one, use consistently
- Match source file name: `userService.ts` → `userService.test.ts`
- Use descriptive integration test names: `checkout-flow.test.ts`

Reference: [Jest Configuration - testMatch](https://jestjs.io/docs/configuration#testmatch-arraystring)

### 6.3 Group Tests by Behavior Not Method

**Impact: MEDIUM (2-3× faster test navigation and discovery)**

Organize tests around features and behaviors that users care about, not around implementation methods. This makes tests serve as documentation.

**Incorrect (grouped by method):**

```typescript
describe('UserService', () => {
  describe('create', () => {
    test('test 1', () => { /* ... */ })
    test('test 2', () => { /* ... */ })
    test('test 3', () => { /* ... */ })
  })

  describe('update', () => {
    test('test 1', () => { /* ... */ })
    test('test 2', () => { /* ... */ })
  })

  describe('delete', () => {
    test('test 1', () => { /* ... */ })
  })
})
// Reader doesn't know what behaviors are being tested
```

**Correct (grouped by behavior):**

```typescript
describe('UserService', () => {
  describe('user registration', () => {
    it('creates user with provided email and name', () => { /* ... */ })
    it('generates unique user ID', () => { /* ... */ })
    it('sends welcome email to new user', () => { /* ... */ })
    it('rejects duplicate email addresses', () => { /* ... */ })
    it('validates email format', () => { /* ... */ })
  })

  describe('profile updates', () => {
    it('updates user name', () => { /* ... */ })
    it('validates new email before update', () => { /* ... */ })
    it('sends verification email when email changes', () => { /* ... */ })
    it('preserves unchanged fields', () => { /* ... */ })
  })

  describe('account deletion', () => {
    it('removes user data', () => { /* ... */ })
    it('cancels active subscriptions', () => { /* ... */ })
    it('sends confirmation email', () => { /* ... */ })
  })
})
// Tests read like feature documentation
```

**Benefits:**
- Tests document features, not implementation
- Easy to find tests for specific behaviors
- Missing behaviors become obvious
- Refactoring methods doesn't require reorganizing tests

Reference: [BDD and the Given-When-Then pattern](https://martinfowler.com/bliki/GivenWhenThen.html)

### 6.4 Use Parameterized Tests for Variations

**Impact: MEDIUM (reduces test code by 50-70%)**

When testing the same behavior with different inputs, use parameterized tests instead of duplicating test code.

**Incorrect (duplicated tests):**

```typescript
test('validates email: missing @', () => {
  expect(isValidEmail('userexample.com')).toBe(false)
})

test('validates email: missing domain', () => {
  expect(isValidEmail('user@')).toBe(false)
})

test('validates email: missing local part', () => {
  expect(isValidEmail('@example.com')).toBe(false)
})

test('validates email: valid simple', () => {
  expect(isValidEmail('user@example.com')).toBe(true)
})

test('validates email: valid with dots', () => {
  expect(isValidEmail('user.name@example.com')).toBe(true)
})
// 5 tests with identical structure
```

**Correct (parameterized tests):**

```typescript
describe('isValidEmail', () => {
  it.each([
    ['user@example.com', true, 'simple valid email'],
    ['user.name@example.com', true, 'email with dots'],
    ['user+tag@example.com', true, 'email with plus tag'],
    ['userexample.com', false, 'missing @ symbol'],
    ['user@', false, 'missing domain'],
    ['@example.com', false, 'missing local part'],
    ['user@@example.com', false, 'double @ symbol'],
    ['user@.com', false, 'domain starts with dot'],
  ])('returns %s for %s (%s)', (email, expected, _description) => {
    expect(isValidEmail(email)).toBe(expected)
  })
})

// Alternative with table syntax
describe('calculateShipping', () => {
  it.each`
    weight | distance | expected | description
    ${1}   | ${10}    | ${5.00}  | ${'light, short distance'}
    ${1}   | ${100}   | ${10.00} | ${'light, long distance'}
    ${10}  | ${10}    | ${15.00} | ${'heavy, short distance'}
    ${10}  | ${100}   | ${25.00} | ${'heavy, long distance'}
  `('costs $expected for $description', ({ weight, distance, expected }) => {
    expect(calculateShipping(weight, distance)).toBe(expected)
  })
})
```

**When to parameterize:**
- Same function with different inputs
- Boundary value testing
- Validation rules with multiple cases
- Format conversions

**When NOT to parameterize:**
- Different setup or behavior per case
- When it obscures what's being tested

Reference: [Jest test.each](https://jestjs.io/docs/api#testeachtablename-fn-timeout)

### 6.5 Use Setup and Teardown Hooks Appropriately

**Impact: MEDIUM (reduces setup duplication by 30-50%)**

Use `beforeEach`/`afterEach` for common setup that applies to all tests in a block. Avoid hooks when they obscure test behavior or create hidden dependencies.

**Incorrect (hooks hide test behavior):**

```typescript
describe('OrderService', () => {
  let service: OrderService
  let user: User
  let product: Product
  let cart: Cart

  beforeEach(async () => {
    service = new OrderService()
    user = await createUser({ tier: 'premium' })  // Why premium?
    product = await createProduct({ price: 100 })  // Why 100?
    cart = await createCart({ userId: user.id })
    await cart.addItem(product.id, 2)  // Why 2 items?
  })

  test('calculates total', () => {
    // Reader must check beforeEach to understand test
    const total = service.calculateTotal(cart)
    expect(total).toBe(200)  // Unexplained number, unclear where it comes from
  })
})
```

**Correct (hooks for infrastructure, tests show data):**

```typescript
describe('OrderService', () => {
  let service: OrderService

  // Hook for infrastructure only
  beforeEach(() => {
    service = new OrderService()
  })

  afterEach(async () => {
    await cleanupTestOrders()
  })

  test('calculates total from item prices and quantities', () => {
    // Test shows all relevant data
    const cart = createCart({
      items: [
        { productId: 'p1', price: 100, quantity: 2 },
        { productId: 'p2', price: 50, quantity: 1 }
      ]
    })

    const total = service.calculateTotal(cart)

    expect(total).toBe(250)  // 100*2 + 50*1, reader can verify
  })

  test('applies premium discount', () => {
    const cart = createCart({
      items: [{ productId: 'p1', price: 100, quantity: 1 }],
      userTier: 'premium'  // Explicit: test is about premium discount
    })

    const total = service.calculateTotal(cart)

    expect(total).toBe(90)  // 10% premium discount
  })
})
```

**Guidelines:**
- Use hooks for: service instantiation, database cleanup, mock resets
- Avoid hooks for: test-specific data, scenario setup
- If a test needs different setup, create a nested describe block

Reference: [Jest Setup and Teardown](https://jestjs.io/docs/setup-teardown)

---

## 7. Test Performance & Reliability

**Impact: MEDIUM**

Fast, reliable tests encourage frequent execution. Slow or flaky tests get ignored, reducing the value of the entire test suite.

### 7.1 Avoid Arbitrary Sleep Calls

**Impact: MEDIUM (eliminates 54% of async-related flakiness)**

Never use fixed delays to wait for async operations. Use explicit waits for specific conditions instead - they're faster and more reliable.

**Incorrect (arbitrary sleep):**

```typescript
test('updates UI after data loads', async () => {
  render(<UserProfile userId="123" />)

  // Wait "long enough" for data to load
  await sleep(2000)

  expect(screen.getByText('Alice')).toBeInTheDocument()
})
// Slow (always waits 2s) and flaky (might not be enough)

test('processes background job', async () => {
  await jobQueue.enqueue({ type: 'send-email', to: 'user@test.com' })

  // Hope the job completes in 5 seconds
  await sleep(5000)

  expect(await getEmailCount('user@test.com')).toBe(1)
})
// Wastes 5s even if job completes in 100ms
```

**Correct (explicit conditions):**

```typescript
test('updates UI after data loads', async () => {
  render(<UserProfile userId="123" />)

  // Wait for specific element to appear
  await waitFor(() => {
    expect(screen.getByText('Alice')).toBeInTheDocument()
  })
})
// Fast: returns as soon as condition is met

test('processes background job', async () => {
  await jobQueue.enqueue({ type: 'send-email', to: 'user@test.com' })

  // Poll for completion with timeout
  await waitFor(
    async () => {
      const count = await getEmailCount('user@test.com')
      expect(count).toBe(1)
    },
    { timeout: 5000, interval: 100 }
  )
})
// Returns immediately when done, fails fast if broken

// For event-based systems
test('receives message after publish', async () => {
  const messagePromise = new Promise(resolve => {
    subscriber.once('message', resolve)
  })

  publisher.publish({ data: 'test' })

  const message = await messagePromise
  expect(message.data).toBe('test')
})
```

**Async waiting strategies:**
- `waitFor()` with condition check
- Promise-based event listeners
- Polling with exponential backoff
- Test framework's built-in async utilities

Reference: [Testing Library - Async Utilities](https://testing-library.com/docs/dom-testing-library/api-async/)

### 7.2 Eliminate Network Calls in Unit Tests

**Impact: MEDIUM (makes tests 10-100× faster)**

Unit tests should never make real network requests. Network calls are slow, unreliable, and create dependencies on external systems.

**Incorrect (real network calls):**

```typescript
test('fetches user profile', async () => {
  // Real HTTP request - slow, flaky, requires running server
  const response = await fetch('http://localhost:3000/api/users/123')
  const user = await response.json()

  expect(user.name).toBe('Alice')
})

test('sends notification', async () => {
  // Real external API call - costs money, slow, can fail
  const result = await notificationService.send({
    to: 'test@example.com',
    message: 'Hello'
  })

  expect(result.delivered).toBe(true)
})
```

**Correct (mocked network):**

```typescript
test('fetches user profile', async () => {
  // Mock the fetch function
  const mockUser = { id: '123', name: 'Alice', email: 'alice@test.com' }
  global.fetch = jest.fn().mockResolvedValue({
    ok: true,
    json: async () => mockUser
  })

  const user = await userService.getProfile('123')

  expect(user.name).toBe('Alice')
  expect(fetch).toHaveBeenCalledWith(
    expect.stringContaining('/api/users/123')
  )
})

test('sends notification', async () => {
  const mockNotificationApi = {
    send: jest.fn().mockResolvedValue({ delivered: true, messageId: 'm1' })
  }
  const service = new NotificationService(mockNotificationApi)

  const result = await service.send({
    to: 'test@example.com',
    message: 'Hello'
  })

  expect(result.delivered).toBe(true)
  expect(mockNotificationApi.send).toHaveBeenCalledWith({
    to: 'test@example.com',
    message: 'Hello'
  })
})
```

**Mocking strategies:**
- Jest mock functions: `jest.fn()`, `jest.spyOn()`
- Mock service worker (MSW) for HTTP interception
- Dependency injection with fake implementations
- Environment-based mock configuration

Reference: [MSW - Mock Service Worker](https://mswjs.io/)

### 7.3 Fix Flaky Tests Immediately

**Impact: MEDIUM (preserves trust in test suite)**

A flaky test is one that sometimes passes and sometimes fails without code changes. Fix or quarantine flaky tests immediately - they erode trust in the entire suite.

**Incorrect (ignoring flaky tests):**

```typescript
test('processes concurrent requests', async () => {
  // Race condition - passes 90% of the time
  const results = await Promise.all([
    service.process(request1),
    service.process(request2)
  ])

  // Sometimes fails due to timing
  expect(results[0].completedBefore(results[1])).toBe(true)
})

// Team learns to just re-run failed builds
// Eventually ignores all test failures
// Real bugs slip through
```

**Correct (fix the root cause):**

```typescript
test('processes requests in order received', async () => {
  // Control the timing explicitly
  const processOrder: string[] = []

  const mockProcessor = {
    process: jest.fn().mockImplementation(async (req) => {
      processOrder.push(req.id)
      return { id: req.id, timestamp: Date.now() }
    })
  }

  const service = new RequestService(mockProcessor)

  await service.processInOrder([
    { id: 'req-1' },
    { id: 'req-2' }
  ])

  // Assert on the controlled behavior
  expect(processOrder).toEqual(['req-1', 'req-2'])
})

// Alternative: fix the async timing issue
test('handles concurrent requests', async () => {
  const startTime = Date.now()

  const results = await Promise.all([
    service.process(request1),
    service.process(request2)
  ])

  // Assert on stable properties, not timing
  expect(results).toHaveLength(2)
  expect(results.every(r => r.status === 'completed')).toBe(true)
})
```

**Flaky test triage:**
1. Identify: Track flaky test frequency
2. Quarantine: Move to separate suite if can't fix immediately
3. Fix: Address root cause (timing, shared state, external deps)
4. Prevent: Add monitoring for new flaky tests

**Common causes:**
- Race conditions and timing dependencies
- Shared mutable state
- External service dependencies
- Non-deterministic data (time, random)

Reference: [Flaky Tests Mitigation - Semaphore](https://semaphore.io/blog/flaky-tests-mitigation)

### 7.4 Keep Unit Tests Under 100ms

**Impact: MEDIUM (enables rapid feedback loops)**

Individual unit tests should complete in milliseconds. Slow tests discourage frequent execution and break the TDD rhythm.

**Incorrect (slow unit test):**

```typescript
test('validates user data', async () => {
  // Real database connection - 50-200ms
  const db = await connectToDatabase()
  await db.seed(testData)

  // Real API call - 100-500ms
  const validationResult = await externalValidationService.validate(userData)

  // File system operations - 10-50ms
  await writeValidationReport(validationResult)

  expect(validationResult.isValid).toBe(true)
})
// Total: 160-750ms per test
// 100 tests = 16-75 seconds
```

**Correct (fast unit test):**

```typescript
test('validates user data format', () => {
  // In-memory, no I/O
  const userData = createUser({ email: 'valid@example.com', age: 25 })

  const result = validateUserData(userData)

  expect(result.isValid).toBe(true)
})
// Total: <5ms

test('returns errors for invalid email', () => {
  const userData = createUser({ email: 'invalid' })

  const result = validateUserData(userData)

  expect(result.errors).toContain('Invalid email format')
})
// Total: <5ms
// 100 tests = <500ms
```

**Techniques for fast tests:**
- Mock external dependencies
- Use in-memory implementations
- Avoid file I/O in unit tests
- Lazy-load expensive resources
- Parallelize independent tests

**Benchmarks:**
- Single unit test: <100ms
- Unit test suite: <10 seconds
- Full test run: <5 minutes

Reference: [The Practical Test Pyramid - Martin Fowler](https://martinfowler.com/articles/practical-test-pyramid.html)

### 7.5 Parallelize Independent Tests

**Impact: MEDIUM (reduces suite time by 50-80%)**

Run independent tests in parallel to reduce total suite execution time. Design tests to be isolation-safe for parallel execution.

**Incorrect (sequential execution):**

```typescript
// jest.config.js
module.exports = {
  maxWorkers: 1  // Forces sequential execution
}

// Tests share database state
describe('UserService', () => {
  beforeAll(async () => {
    await db.users.deleteMany({})  // Clears ALL users
  })

  test('creates user', async () => {
    await userService.create({ id: 'user-1', name: 'Alice' })
    const count = await db.users.count()
    expect(count).toBe(1)  // Assumes no other tests created users
  })
})

// Other test file accessing same table
describe('OrderService', () => {
  test('associates order with user', async () => {
    // Fails if UserService tests haven't run yet
    const order = await orderService.create({ userId: 'user-1' })
    expect(order.userId).toBe('user-1')
  })
})
```

**Correct (parallel-safe tests):**

```typescript
// jest.config.js
module.exports = {
  maxWorkers: '50%'  // Use half of available CPUs
}

// Tests use unique identifiers
describe('UserService', () => {
  test('creates user', async () => {
    const userId = `user-${Date.now()}-${Math.random()}`

    await userService.create({ id: userId, name: 'Alice' })

    const user = await db.users.findById(userId)
    expect(user).toBeDefined()
  })
})

// Each test is independent
describe('OrderService', () => {
  test('associates order with user', async () => {
    // Creates its own test data
    const user = await createTestUser()
    const order = await orderService.create({ userId: user.id })

    expect(order.userId).toBe(user.id)
  })
})
```

**Parallel-safety checklist:**
- No shared mutable state between tests
- Unique IDs for all test entities
- No assumptions about test execution order
- Database transactions or isolated test databases
- Mock external services per-test

**Configuration:**
- Jest: `maxWorkers` in config
- Vitest: `threads` option
- pytest: `pytest-xdist` plugin

Reference: [Jest Configuration - maxWorkers](https://jestjs.io/docs/configuration#maxworkers-number--string)

---

## 8. Test Pyramid & Strategy

**Impact: LOW**

Strategic test distribution across unit, integration, and E2E layers optimizes coverage while minimizing maintenance cost and execution time.

### 8.1 Follow the Test Pyramid

**Impact: LOW (reduces test infrastructure cost by 10-100×)**

Distribute tests according to the pyramid: many unit tests at the base, fewer integration tests in the middle, and minimal E2E tests at the top.

**Incorrect (inverted pyramid):**

```text
           ┌─────────────────────────────┐
           │      E2E Tests (500)        │  ← Slow, expensive, flaky
           ├─────────────────────────────┤
           │   Integration Tests (100)   │
           ├─────────────────────────────┤
           │    Unit Tests (50)          │  ← Fast, cheap, stable
           └─────────────────────────────┘

Test run time: 45 minutes
Maintenance cost: HIGH
Flakiness: FREQUENT
Infrastructure cost: $10,000/month
```

**Correct (proper pyramid):**

```text
                    ┌───────────┐
                    │ E2E (20)  │  ← Critical user journeys only
                ┌───┴───────────┴───┐
                │ Integration (100)  │  ← Component boundaries
            ┌───┴───────────────────┴───┐
            │     Unit Tests (500)       │  ← Business logic
            └───────────────────────────┘

Test run time: 5 minutes
Maintenance cost: LOW
Flakiness: RARE
Infrastructure cost: $100/month
```

**Distribution guidelines:**
| Layer | Count | Scope | Speed |
|-------|-------|-------|-------|
| Unit | 70-80% | Single function/class | <100ms |
| Integration | 15-25% | Multiple components | <5s |
| E2E | 5-10% | Full user journey | <30s |

**What to test at each level:**
- **Unit**: Business logic, calculations, transformations
- **Integration**: API contracts, database queries, service interactions
- **E2E**: Critical user paths, smoke tests, happy paths

Reference: [The Practical Test Pyramid - Martin Fowler](https://martinfowler.com/articles/practical-test-pyramid.html)

### 8.2 Limit E2E Tests to Critical User Paths

**Impact: LOW (reduces maintenance burden)**

End-to-end tests are expensive to maintain and slow to run. Reserve them for critical user journeys that generate revenue or core functionality.

**Incorrect (E2E for everything):**

```typescript
// E2E tests for every feature
describe('User Settings', () => {
  it('changes theme to dark mode', async () => { /* 30s test */ })
  it('changes theme to light mode', async () => { /* 30s test */ })
  it('updates avatar', async () => { /* 30s test */ })
  it('changes language to Spanish', async () => { /* 30s test */ })
  it('changes language to French', async () => { /* 30s test */ })
  // ... 50 more settings tests
})

// E2E for edge cases
describe('Error handling', () => {
  it('shows error on network timeout', async () => { /* 30s test */ })
  it('shows error on invalid input', async () => { /* 30s test */ })
  // ... 30 more error tests
})

// Total: 100 E2E tests, 50 minutes runtime
```

**Correct (E2E for critical paths only):**

```typescript
// E2E for core revenue-generating flows
describe('Critical User Journeys', () => {
  it('completes signup to first purchase', async () => {
    await page.goto('/signup')
    await page.fill('[name=email]', 'new@customer.com')
    await page.fill('[name=password]', 'SecurePass123!')
    await page.click('button[type=submit]')

    await page.waitForURL('/dashboard')
    await page.click('[data-testid=browse-products]')
    await page.click('[data-testid=product-1]')
    await page.click('[data-testid=add-to-cart]')
    await page.click('[data-testid=checkout]')
    // ... complete purchase

    await expect(page.locator('.order-confirmation')).toBeVisible()
  })

  it('existing user can login and reorder', async () => { /* ... */ })

  it('user can contact support', async () => { /* ... */ })
})

// 3-5 critical E2E tests, 5 minutes runtime
// Settings, error handling tested at unit/integration level
```

**E2E test candidates:**
- Signup/onboarding flow
- Purchase/checkout
- Core feature happy path
- Authentication flows
- Critical admin operations

**Test at lower levels:**
- Input validation (unit)
- Error messages (unit)
- API edge cases (integration)
- Settings variations (integration)

Reference: [Testing Pyramid - Mike Cohn](https://www.mountaingoatsoftware.com/blog/the-forgotten-layer-of-the-test-automation-pyramid)

### 8.3 Set Meaningful Coverage Targets

**Impact: LOW (2-3× better ROI on testing effort)**

Aim for high coverage on critical paths, not 100% everywhere. Coverage is a guide, not a goal - focus on meaningful tests over hitting numbers.

**Incorrect (coverage as goal):**

```typescript
// Chasing 100% coverage
test('getter returns value', () => {
  const user = new User({ name: 'Alice' })
  expect(user.getName()).toBe('Alice')  // Tests trivial getter
})

test('setter sets value', () => {
  const user = new User({ name: 'Alice' })
  user.setName('Bob')
  expect(user.getName()).toBe('Bob')  // Tests trivial setter
})

test('toString returns string', () => {
  const user = new User({ name: 'Alice' })
  expect(typeof user.toString()).toBe('string')  // Meaningless test
})

// Result: 100% coverage, but critical business logic untested
// Tests don't prevent bugs, just satisfy metric
```

**Correct (strategic coverage):**

```typescript
// High coverage on critical business logic
describe('PaymentProcessor', () => {
  it('calculates tax correctly for each region', () => { /* ... */ })
  it('applies discounts in correct order', () => { /* ... */ })
  it('handles currency conversion', () => { /* ... */ })
  it('prevents double-charging', () => { /* ... */ })
  it('validates card details', () => { /* ... */ })
})
// 95% coverage on critical module

// Lower coverage acceptable on utilities
describe('StringUtils', () => {
  it('capitalizes first letter', () => { /* ... */ })
  // Don't test every edge case of simple utility
})
// 60% coverage acceptable on simple utilities
```

**Coverage strategy:**
| Module Type | Target | Rationale |
|-------------|--------|-----------|
| Business logic | 90%+ | Critical, complex |
| API handlers | 80%+ | User-facing |
| Utilities | 60%+ | Simple, stable |
| Generated code | 0% | Tested elsewhere |

**Better metrics:**
- Mutation score (test effectiveness)
- Bug escape rate (tests vs. production bugs)
- Mean time to detect (how quickly tests catch bugs)

Reference: [Code Coverage Best Practices - Google Testing Blog](https://testing.googleblog.com/2020/08/code-coverage-best-practices.html)

### 8.4 Test Integration at Service Boundaries

**Impact: LOW (prevents integration failures in production)**

Integration tests should verify contracts between components - API shapes, database schemas, and service interfaces. Test the boundaries, not the internals.

**Incorrect (testing implementation through integration):**

```typescript
test('user creation flow', async () => {
  // Testing implementation details through integration test
  const result = await request(app)
    .post('/api/users')
    .send({ email: 'test@example.com', name: 'Alice' })

  // Checking database internals
  const dbRecord = await db.query('SELECT * FROM users WHERE email = $1', ['test@example.com'])
  expect(dbRecord.rows[0].password_hash).toMatch(/^\$2b\$/)  // bcrypt format
  expect(dbRecord.rows[0].created_at).toBeDefined()

  // Checking email service internals
  const sentEmails = mockEmailService.getSentEmails()
  expect(sentEmails[0].template).toBe('welcome-v2')
  expect(sentEmails[0].templateVars.activationLink).toMatch(/\/activate\//)
})
```

**Correct (testing boundary contracts):**

```typescript
describe('POST /api/users', () => {
  it('returns created user with id', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', name: 'Alice' })

    // Test API contract, not implementation
    expect(response.status).toBe(201)
    expect(response.body).toMatchObject({
      id: expect.any(String),
      email: 'test@example.com',
      name: 'Alice'
    })
  })

  it('returns 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'invalid', name: 'Alice' })

    expect(response.status).toBe(400)
    expect(response.body.error).toBeDefined()
  })

  it('returns 409 for duplicate email', async () => {
    await createUser({ email: 'existing@example.com' })

    const response = await request(app)
      .post('/api/users')
      .send({ email: 'existing@example.com', name: 'Bob' })

    expect(response.status).toBe(409)
  })
})
```

**Integration test focus:**
- HTTP status codes and response shapes
- Database constraints and relationships
- Queue message formats
- External API contracts
- Error handling at boundaries

Reference: [Contract Testing - Pact](https://docs.pact.io/)

### 8.5 Use Mutation Testing to Validate Test Quality

**Impact: LOW (detects 30-50% more weak assertions)**

Mutation testing introduces small bugs (mutants) into code and checks if tests catch them. A high mutation score indicates your tests actually verify behavior.

**Incorrect (high coverage, low mutation score):**

```typescript
// Implementation
function calculateDiscount(price: number, isPremium: boolean): number {
  if (isPremium) {
    return price * 0.2
  }
  return price * 0.1
}

// Test with 100% line coverage but poor assertions
test('calculates discount', () => {
  const result = calculateDiscount(100, true)
  expect(result).toBeDefined()  // Passes even if logic is wrong
})

// Mutation testing creates mutants like:
// - return price * 0.3  (change constant)
// - return price * 0.1  (remove premium branch)
// - return price / 0.2  (change operator)
// All mutants SURVIVE because assertion is too weak
```

**Correct (high mutation score):**

```typescript
describe('calculateDiscount', () => {
  it('applies 20% discount for premium customers', () => {
    const result = calculateDiscount(100, true)
    expect(result).toBe(20)  // Specific value kills mutants
  })

  it('applies 10% discount for regular customers', () => {
    const result = calculateDiscount(100, false)
    expect(result).toBe(10)
  })

  it('scales discount with price', () => {
    expect(calculateDiscount(200, true)).toBe(40)
    expect(calculateDiscount(50, false)).toBe(5)
  })
})
// All mutants are KILLED by specific assertions
```

**Interpreting scores:**
- **90%+**: Excellent test suite quality
- **70-89%**: Good, review surviving mutants
- **<70%**: Tests need strengthening

**Tools:**
- JavaScript/TypeScript: Stryker Mutator
- Java: PIT
- Python: mutmut
- Go: gremlins

**Note:** Run mutation testing periodically, not on every commit (it's slow).

Reference: [Mutation Testing - Codecov](https://about.codecov.io/blog/mutation-testing-how-to-ensure-code-coverage-isnt-a-vanity-metric/)

---

## References

1. [https://martinfowler.com/bliki/TestDrivenDevelopment.html](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
2. [http://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html](http://blog.cleancoder.com/uncle-bob/2014/12/17/TheCyclesOfTDD.html)
3. [https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices)
4. [https://testing.googleblog.com/2020/08/code-coverage-best-practices.html](https://testing.googleblog.com/2020/08/code-coverage-best-practices.html)
5. [https://semaphore.io/blog/aaa-pattern-test-automation](https://semaphore.io/blog/aaa-pattern-test-automation)
6. [https://docs.pytest.org/en/stable/how-to/fixtures.html](https://docs.pytest.org/en/stable/how-to/fixtures.html)
7. [https://martinfowler.com/articles/practical-test-pyramid.html](https://martinfowler.com/articles/practical-test-pyramid.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |