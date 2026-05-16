---
title: Use a Function When the Class Has No Identity
impact: CRITICAL
impactDescription: eliminates 50-100 lines of class ceremony around a stateless function
tags: frame, functions, classes, oop
---

## Use a Function When the Class Has No Identity

A class earns its existence when it holds state across method calls, or when polymorphism is genuinely needed. A class with no fields (or only fields set once at construction and never mutated) where every method is a pure transform of inputs is a *function*. Wrapping it in a class adds construction sites, dependency injection, mocking ceremony, and forces every caller to know who instantiates it — for nothing.

**Incorrect (a class doing what a function does, with full DI ceremony):**

```typescript
export class PriceFormatter {
  constructor(private readonly locale: string) {}

  format(amount: number, currency: string): string {
    return new Intl.NumberFormat(this.locale, { style: 'currency', currency }).format(amount);
  }
}

// At every call site:
const formatter = new PriceFormatter(user.locale);
const text = formatter.format(99.99, 'EUR');

// And the DI module that wires it, the test that mocks it, the interface that types it...
// All of that ceremony for what is a single Intl call.
```

**Correct (a function — no construction, no DI, no mock):**

```typescript
export function formatPrice(amount: number, currency: string, locale: string): string {
  return new Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount);
}

// Call site:
const text = formatPrice(99.99, 'EUR', user.locale);
```

**Symptoms that the class wants to be a function:**

- Constructor stores values that are only used to thread into one method's call.
- Every method is `static` or could be.
- Tests do `new X(...)` once and immediately call one method.
- The class has no internal state that mutates across calls.
- The class's interface has exactly one method (the "command object" smell).

**When NOT to use this pattern:**

- The class holds genuine state — a connection pool, a cache, a counter. Keep it.
- You need polymorphism — multiple implementations swappable behind an interface. Keep it.
- The constructor performs *expensive* setup that should be reused (compile a regex, open a DB connection). Keep it, but consider a module-level singleton instead.

**Stateful-looking but actually function (partial application):**

```typescript
// If you do want to "bind" the locale once for several formatters:
export const makePriceFormatter = (locale: string) =>
  (amount: number, currency: string) =>
    new Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount);

const fmt = makePriceFormatter(user.locale);
fmt(99.99, 'EUR');
// A closure is a one-line stateful object. No class needed.
```

Reference: [A Philosophy of Software Design](https://web.stanford.edu/~ouster/cgi-bin/aposd.php) — John Ousterhout
