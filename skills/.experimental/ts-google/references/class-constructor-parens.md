---
title: Always Use Parentheses in Constructor Calls
impact: MEDIUM
impactDescription: consistent syntax and prevents parsing ambiguity
tags: class, constructor, syntax, style
---

## Always Use Parentheses in Constructor Calls

Always use parentheses when calling constructors, even when there are no arguments. This improves consistency and prevents potential parsing issues.

**Incorrect (missing parentheses):**

```typescript
const date = new Date
const user = new User
const map = new Map
```

**Correct (with parentheses):**

```typescript
const date = new Date()
const user = new User()
const map = new Map()
const set = new Set<string>()
```

**Why it matters:**
- Consistent with function call syntax
- Avoids ASI (Automatic Semicolon Insertion) edge cases
- Clearer that construction is happening
- Required for generic type arguments

Reference: [Google TypeScript Style Guide - Constructor](https://google.github.io/styleguide/tsguide.html#constructors)
