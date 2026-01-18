---
title: Use Rest Parameters Over arguments
impact: HIGH
impactDescription: type-safe variadic functions
tags: func, rest-parameters, arguments, variadic
---

## Use Rest Parameters Over arguments

Use rest parameters (`...args`) instead of the `arguments` object. Rest parameters are typed, work with arrow functions, and are more intuitive.

**Incorrect (arguments object):**

```typescript
function sum() {
  let total = 0
  for (let i = 0; i < arguments.length; i++) {
    total += arguments[i]  // No type checking
  }
  return total
}

// arguments doesn't work in arrow functions
const multiply = () => {
  return Array.from(arguments).reduce((a, b) => a * b, 1)
  // Error: 'arguments' is not defined
}
```

**Correct (rest parameters):**

```typescript
function sum(...numbers: number[]): number {
  return numbers.reduce((total, n) => total + n, 0)
}

// Works with arrow functions
const multiply = (...numbers: number[]): number => {
  return numbers.reduce((a, b) => a * b, 1)
}

// Typed variadic function
function log(level: string, ...messages: unknown[]): void {
  console.log(`[${level}]`, ...messages)
}
```

**Calling variadic functions with spread:**

```typescript
const values = [1, 2, 3, 4, 5]
const total = sum(...values)  // Spread array into arguments
```

**Never:**
- Name any parameter `arguments`
- Use `Function.prototype.apply()` for variadic calls

Reference: [Google TypeScript Style Guide - Rest parameters](https://google.github.io/styleguide/tsguide.html#rest-and-spread-parameters)
