---
title: Verify the Test Fails Before Writing Code
impact: CRITICAL
impactDescription: prevents false positives from untested code
tags: cycle, red-phase, failing-test, validation
---

## Verify the Test Fails Before Writing Code

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
