---
title: Set Meaningful Coverage Targets
impact: LOW
impactDescription: 2-3× better ROI on testing effort
tags: strat, coverage, metrics, targets
---

## Set Meaningful Coverage Targets

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
