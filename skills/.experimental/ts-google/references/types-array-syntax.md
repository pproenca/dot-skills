---
title: Use Consistent Array Type Syntax
impact: HIGH
impactDescription: improves readability and consistency
tags: types, arrays, syntax, style
---

## Use Consistent Array Type Syntax

Use `T[]` for simple types and `Array<T>` for complex types (unions, objects). This improves readability and prevents parsing ambiguity.

**Incorrect (inconsistent or complex syntax):**

```typescript
// Generic for simple types
const numbers: Array<number> = [1, 2, 3]
const names: Array<string> = ['Alice', 'Bob']

// Bracket syntax for complex types (hard to read)
const items: { id: number; name: string }[] = []
const mixed: (string | number)[] = []
```

**Correct (appropriate syntax):**

```typescript
// Bracket syntax for simple types
const numbers: number[] = [1, 2, 3]
const names: string[] = ['Alice', 'Bob']
const matrix: number[][] = [[1, 2], [3, 4]]

// Generic syntax for complex types
const items: Array<{ id: number; name: string }> = []
const mixed: Array<string | number> = []
const callbacks: Array<(value: number) => void> = []

// Readonly arrays
const constants: readonly number[] = [1, 2, 3]
```

**Summary:**
- Simple types: `T[]`, `readonly T[]`
- Multi-dimensional: `T[][]`
- Complex/union types: `Array<T>`
- Tuples: `[T, U]`

Reference: [Google TypeScript Style Guide - Array type](https://google.github.io/styleguide/tsguide.html#array-type)
