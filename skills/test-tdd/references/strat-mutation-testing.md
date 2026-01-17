---
title: Use Mutation Testing to Validate Test Quality
impact: LOW
impactDescription: detects 30-50% more weak assertions
tags: strat, mutation-testing, quality, coverage
---

## Use Mutation Testing to Validate Test Quality

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
