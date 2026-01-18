---
title: Use Explicit Type Coercion
impact: LOW-MEDIUM
impactDescription: prevents unexpected coercion behavior
tags: literal, coercion, String, Number, Boolean
---

## Use Explicit Type Coercion

Use explicit coercion functions (`String()`, `Number()`, `Boolean()`) instead of implicit coercion or unary operators.

**Incorrect (implicit coercion):**

```typescript
// Unary + for number coercion
const num = +inputString

// String concatenation for coercion
const str = '' + value

// Double negation for boolean
const bool = !!value

// parseInt without validation
const parsed = parseInt(input)
```

**Correct (explicit coercion):**

```typescript
// Explicit String coercion
const str = String(value)

// Explicit Number coercion with validation
const num = Number(inputString)
if (!Number.isFinite(num)) {
  throw new Error('Invalid number')
}

// Explicit Boolean coercion
const bool = Boolean(value)

// Template literal for string conversion
const message = `Value: ${value}`
```

**Implicit coercion allowed in conditionals:**

```typescript
// Truthy/falsy checks are acceptable
if (array.length) {
  // Non-empty array
}

if (str) {
  // Non-empty string
}

// Exception: enums require explicit comparison
enum Status {
  NONE = 0,
  ACTIVE = 1,
}

// Incorrect - implicit coercion of enum
if (status) {}  // NONE (0) is falsy!

// Correct - explicit comparison
if (status !== Status.NONE) {}
```

Reference: [Google TypeScript Style Guide - Type coercion](https://google.github.io/styleguide/tsguide.html#type-coercion)
