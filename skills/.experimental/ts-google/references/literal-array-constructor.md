---
title: Avoid Array Constructor
impact: LOW-MEDIUM
impactDescription: prevents confusing Array constructor behavior
tags: literal, arrays, constructor, syntax
---

## Avoid Array Constructor

Never use the `Array()` constructor. Its behavior is confusing (single number creates sparse array). Use array literals or `Array.from()`.

**Incorrect (Array constructor):**

```typescript
// Single number creates sparse array of that length
const arr = new Array(3)  // [empty × 3], not [3]

// Multiple arguments create array with those elements
const arr2 = new Array(1, 2, 3)  // [1, 2, 3]

// Inconsistent behavior is confusing
const a = Array(3)      // [empty × 3]
const b = Array('3')    // ['3']
```

**Correct (array literals and Array.from):**

```typescript
// Array literals
const empty: number[] = []
const numbers = [1, 2, 3]
const strings = ['a', 'b', 'c']

// Array.from for creating arrays with specific length
const fiveZeros = Array.from({ length: 5 }, () => 0)  // [0, 0, 0, 0, 0]
const indices = Array.from({ length: 5 }, (_, i) => i)  // [0, 1, 2, 3, 4]

// Array.from with typed generics
const typed = Array.from<number>({ length: 3 })  // [undefined, undefined, undefined]

// Spread for copying
const copy = [...original]

// fill() for same value
const threes = new Array(5).fill(3)  // [3, 3, 3, 3, 3] - fill() makes it dense
```

**Object constructor also forbidden:**

```typescript
// Incorrect
const obj = new Object()
const obj2 = Object()

// Correct
const obj = {}
const obj2: Record<string, unknown> = {}
```

Reference: [Google TypeScript Style Guide - Array constructor](https://google.github.io/styleguide/tsguide.html#array-constructor)
