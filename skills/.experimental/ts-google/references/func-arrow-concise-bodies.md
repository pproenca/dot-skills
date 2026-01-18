---
title: Use Concise Arrow Function Bodies Appropriately
impact: MEDIUM
impactDescription: improves readability for simple transforms
tags: func, arrow-functions, concise, style
---

## Use Concise Arrow Function Bodies Appropriately

Use concise arrow function bodies (without braces) only when the return value is used. Use block bodies when the return value is ignored or when multiple statements are needed.

**Incorrect (mismatched body style):**

```typescript
// Block body when concise would work
const doubled = numbers.map(n => {
  return n * 2
})

// Concise body when return value is ignored
button.addEventListener('click', e => console.log(e))
// Return value of console.log is ignored but expression returns it
```

**Correct (appropriate body style):**

```typescript
// Concise body when return value is used
const doubled = numbers.map(n => n * 2)
const names = users.map(user => user.name)
const filtered = items.filter(item => item.active)

// Block body when return value is ignored
button.addEventListener('click', (e) => {
  console.log(e)
})

// Block body for multiple statements
const processed = items.map((item) => {
  const normalized = normalize(item)
  return transform(normalized)
})
```

**Using void operator to clarify intent:**

```typescript
// Explicitly discard return value with void
myPromise.then(v => void console.log(v))
// Makes it clear return value is intentionally ignored
```

Reference: [Google TypeScript Style Guide - Arrow function bodies](https://google.github.io/styleguide/tsguide.html#rebinding-this)
