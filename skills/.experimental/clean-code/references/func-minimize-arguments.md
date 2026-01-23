---
title: Minimize Function Arguments
impact: HIGH
impactDescription: reduces cognitive load and testing complexity
tags: func, arguments, parameters, simplicity
---

## Minimize Function Arguments

The ideal number of arguments for a function is zero (niladic). Next comes one (monadic), followed closely by two (dyadic). Three arguments (triadic) should be avoided where possible.

**Incorrect (too many arguments):**

```java
// Flag arguments are bad - function does different things
public void render(boolean isSuite) {}

// Four arguments - hard to remember order
public Circle makeCircle(double x, double y, double radius, String color) {}

// Order matters and is easy to confuse
public void assertExpectedEqualsActual(String expected, String actual) {}
```

**Correct (minimized arguments):**

```java
// Separate functions instead of flag
public void renderForSingleTest() {}
public void renderForSuite() {}

// Encapsulate related arguments in objects
public Circle makeCircle(Point center, double radius, Color color) {}

// Even better - use a builder for many optional params
Circle circle = Circle.builder()
    .center(new Point(0, 0))
    .radius(5.0)
    .color(Color.RED)
    .build();

// Self-documenting method name
assertThat(actual).isEqualTo(expected);
```

**Why fewer arguments?**
- Easier to understand
- Easier to test (fewer combinations)
- Less chance of argument order errors

**Acceptable monadic forms:**
- Asking a question: `boolean fileExists(String path)`
- Transforming input: `InputStream openFile(String path)`
- Events: `void passwordAttemptFailed(int attempts)`

Reference: [Clean Code, Chapter 3: Functions](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
