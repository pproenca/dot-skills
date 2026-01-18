---
title: Use Single Quotes for Strings
impact: LOW-MEDIUM
impactDescription: consistent string syntax throughout codebase
tags: literal, strings, quotes, style
---

## Use Single Quotes for Strings

Use single quotes for ordinary string literals. Use template literals for strings that contain interpolation or span multiple lines.

**Incorrect (double quotes and concatenation):**

```typescript
// Double quotes for ordinary strings
const name = "Alice"
const message = "Hello, world"

// String concatenation instead of template
const greeting = "Hello, " + name + "!"

// Line continuation with backslash
const longString = "This is a very long \
string that continues"
```

**Correct (single quotes and template literals):**

```typescript
// Single quotes for ordinary strings
const name = 'Alice'
const message = 'Hello, world'

// Template literal for interpolation
const greeting = `Hello, ${name}!`

// Template literal for multi-line
const longString = `
  This is a very long
  string that spans
  multiple lines
`

// Single quotes with escaping when needed
const quote = 'She said, "Hello"'
const apostrophe = "It's working"  // Double quotes to avoid escaping
```

**When to use template literals:**
- String interpolation: `\`Hello, ${name}\``
- Multi-line strings
- Complex string building

Reference: [Google TypeScript Style Guide - String literals](https://google.github.io/styleguide/tsguide.html#string-literals)
