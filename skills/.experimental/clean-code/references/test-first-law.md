---
title: Follow the Three Laws of TDD
impact: MEDIUM
impactDescription: achieves 90%+ test coverage naturally
tags: test, tdd, first, laws
---

## Follow the Three Laws of TDD

Test-Driven Development follows three rules: (1) Write a failing test before production code, (2) Write only enough test to fail, (3) Write only enough production code to pass. This cycle repeats.

**Incorrect (writing tests after code):**

```java
// Production code written first, then tests added later (or never)
public class Calculator {
    public int add(int a, int b) {
        return a + b;
    }

    public int divide(int a, int b) {
        return a / b;  // Edge cases not considered
    }
}

// Test written after - may not cover edge cases
@Test
public void testAdd() {
    assertEquals(4, calculator.add(2, 2));
}
// No test for divide by zero because code was written first
```

**Correct (TDD cycle):**

```java
// 1. Write failing test first
@Test
public void divideShouldReturnQuotient() {
    assertEquals(2, calculator.divide(6, 3));
}

// 2. Write minimal code to pass
public int divide(int a, int b) {
    return a / b;
}

// 3. Write next failing test
@Test(expected = IllegalArgumentException.class)
public void divideShouldThrowOnDivideByZero() {
    calculator.divide(6, 0);
}

// 4. Update code to pass
public int divide(int a, int b) {
    if (b == 0) {
        throw new IllegalArgumentException("Cannot divide by zero");
    }
    return a / b;
}
```

**Benefits:**
- Tests cover requirements, not implementation
- Edge cases discovered through test-first thinking
- High coverage achieved naturally

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
