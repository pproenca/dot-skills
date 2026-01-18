---
title: Avoid Assignment in Conditional Expressions
impact: MEDIUM
impactDescription: prevents accidental assignment bugs
tags: control, conditionals, assignment, style
---

## Avoid Assignment in Conditional Expressions

Never use assignment within conditional expressions. It's difficult to distinguish from comparison and leads to bugs.

**Incorrect (assignment in condition):**

```typescript
// Easy to mistake for comparison
if (user = getUser()) {
  // Is this assignment or typo'd comparison?
}

// Assignment in while condition
while (line = reader.readLine()) {
  process(line)
}
```

**Correct (separate assignment):**

```typescript
// Clear assignment before condition
const user = getUser()
if (user) {
  process(user)
}

// Clear loop structure
let line = reader.readLine()
while (line) {
  process(line)
  line = reader.readLine()
}

// Or use for-of for iterables
for (const line of reader) {
  process(line)
}
```

**Why this matters:**
- `=` vs `==` vs `===` are easy to confuse
- Assignment returns the assigned value (truthy/falsy check)
- Code review becomes harder
- Some linters warn/error on this pattern

Reference: [Google TypeScript Style Guide - Assignment in conditionals](https://google.github.io/styleguide/tsguide.html#assignment-in-control-structures)
