---
title: Prefer Function Declarations Over Expressions
impact: HIGH
impactDescription: hoisting enables cleaner code organization
tags: func, declarations, expressions, hoisting
---

## Prefer Function Declarations Over Expressions

Use function declarations for named functions. They are hoisted, making code organization more flexible, and provide better stack traces.

**Incorrect (function expression):**

```typescript
// Arrow function stored in const
const calculateTotal = (items: Item[]): number => {
  return items.reduce((sum, item) => sum + item.price, 0)
}

// Anonymous function expression
const formatDate = function(date: Date): string {
  return date.toISOString()
}
```

**Correct (function declaration):**

```typescript
// Function declaration - hoisted, better stack traces
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0)
}

function formatDate(date: Date): string {
  return date.toISOString()
}
```

**When to use arrow functions:**
- Callbacks: `items.map(item => item.price)`
- When explicit typing is needed: `const handler: EventHandler = (e) => {}`
- Preserving `this` context

**When to use function expressions:**
- Conditional function assignment
- Functions passed directly to other functions

Reference: [Google TypeScript Style Guide - Function declarations](https://google.github.io/styleguide/tsguide.html#function-declarations)
