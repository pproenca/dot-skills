---
title: Always Use Braces for Control Structures
impact: MEDIUM-HIGH
impactDescription: prevents bugs from misleading indentation
tags: control, braces, if, for, while, style
---

## Always Use Braces for Control Structures

Always use braces for control structures, even when the body is a single statement. This prevents bugs from misleading indentation.

**Incorrect (missing braces):**

```typescript
if (condition)
  doSomething()
  doSomethingElse()  // Always executes! Misleading indent

for (const item of items)
  process(item)

while (hasMore)
  fetchNext()
```

**Correct (with braces):**

```typescript
if (condition) {
  doSomething()
}
doSomethingElse()

for (const item of items) {
  process(item)
}

while (hasMore) {
  fetchNext()
}
```

**Exception (single-line if):**

```typescript
// Allowed only when entire statement fits on one line
if (isEmpty) return null
if (isReady) start()
```

**Why braces matter:**
- Prevents Apple's "goto fail" style bugs
- Makes code structure explicit
- Safer when adding statements later
- Consistent with other control structures

Reference: [Google TypeScript Style Guide - Control structures](https://google.github.io/styleguide/tsguide.html#control-structures)
