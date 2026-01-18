---
title: Use Correct Generator Function Syntax
impact: MEDIUM
impactDescription: consistent, readable generator definitions
tags: func, generators, syntax, iterators
---

## Use Correct Generator Function Syntax

Attach the `*` to the `function` keyword with no space. For `yield*`, attach to the `yield` keyword. This provides visual consistency.

**Incorrect (inconsistent asterisk placement):**

```typescript
// Space before asterisk
function * generator() {
  yield 1
}

// Asterisk attached to name
function *generator() {
  yield 1
}

// Inconsistent yield* spacing
function* delegate() {
  yield * otherGenerator()
}
```

**Correct (asterisk on keyword):**

```typescript
// Generator function
function* numberGenerator(): Generator<number> {
  yield 1
  yield 2
  yield 3
}

// Delegating generator
function* combined(): Generator<number> {
  yield* numberGenerator()
  yield* [4, 5, 6]
}

// Generator method in class
class DataStream {
  *[Symbol.iterator](): Generator<Data> {
    for (const item of this.items) {
      yield item
    }
  }
}

// Async generator
async function* fetchPages(): AsyncGenerator<Page> {
  let page = 1
  while (true) {
    const data = await fetchPage(page++)
    if (!data) break
    yield data
  }
}
```

Reference: [Google TypeScript Style Guide - Generator functions](https://google.github.io/styleguide/tsguide.html#generator-functions)
