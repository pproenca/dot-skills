---
title: Test Behavior Not Implementation
impact: CRITICAL
impactDescription: reduces test brittleness by 50-80%
tags: design, behavior, black-box, maintainability
---

## Test Behavior Not Implementation

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
