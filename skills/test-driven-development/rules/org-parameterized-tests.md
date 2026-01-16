---
title: Use Parameterized Tests for Variations
impact: MEDIUM
impactDescription: reduces test code by 50-70%
tags: org, parameterized, data-driven, test-each
---

## Use Parameterized Tests for Variations

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
