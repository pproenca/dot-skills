---
title: Pick Tests-as-Spec or Tests-as-Documentation Per File
impact: MEDIUM
impactDescription: prevents audience-mixing in test files
tags: meta, tests, documentation, specification
---

## Pick Tests-as-Spec or Tests-as-Documentation Per File

Tests serve two audiences. **Spec-tests** target the compiler and CI: minimal, exhaustive, one concept per case, comprehensive coverage. **Doc-tests** target the future reader: narrative, selective, canonical examples of how the module is used. The styles are different. Mixing them produces tests that do neither well — readers can't find the docs in the spec noise, and CI signal is buried in narrative.

**Incorrect (dogmatic mixing — one giant file for both audiences):**

```ts
// Checkout.test.ts — 80 tests, mixed styles.
// Exhaustive branch coverage AND occasional "here's how to use Checkout"
// narrative tests with huge setup blocks. Neither audience is well-served.

describe('Checkout', () => {
  test('rejects empty cart', () => { /* 1-line spec */ });
  test('rejects missing payment', () => { /* 1-line spec */ });
  // ...60 more 1-line specs...

  test('full happy path: customer adds 3 items, applies coupon, checks out', () => {
    // 40 lines of narrative setup demonstrating canonical usage
    // — buried in the middle of branch-coverage specs.
  });

  test('rejects negative quantity', () => { /* 1-line spec */ });
  // ...more specs...
});
```

**Correct (balanced — split by audience):**

```ts
// Checkout.spec.ts — for CI. Exhaustive, minimal, one concept per test.
describe('Checkout (spec)', () => {
  test('rejects empty cart', () => { /* ... */ });
  test('rejects missing payment', () => { /* ... */ });
  test('rejects negative quantity', () => { /* ... */ });
  test('applies coupon before tax', () => { /* ... */ });
  // ...exhaustive cases...
});
```

```ts
// Checkout.examples.test.ts — for humans. 3-5 narrative tests
// showing canonical usage. Each is a worked example readers can copy.
describe('Checkout (canonical usage)', () => {
  test('typical happy path: registered customer with saved payment', () => {
    // Narrative setup. The test IS the example.
  });

  test('guest checkout with coupon', () => {
    // ...
  });

  test('subscription renewal', () => {
    // ...
  });
});
```

**When NOT to apply this pattern:**
- Small modules where the total test count is low enough that one file naturally serves both audiences without noise.
- Libraries where executable example docs (`*.examples.ts` outside the test runner, or doctest-style) already cover the documentation audience.
- Teams whose convention is "one test file per source file" and whose tooling/coverage gates depend on it — follow the convention.

**Why this matters:** Test code communicates to two audiences with conflicting needs (CI wants minimal exhaustiveness; humans want narrative selectivity). Splitting by audience lets each be excellent; mixing forces both to be mediocre.

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Kent Beck — Test Desiderata](https://kentbeck.github.io/TestDesiderata/)
