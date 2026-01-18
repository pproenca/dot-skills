---
title: Use Correct Number Literal Formats
impact: LOW-MEDIUM
impactDescription: consistent and readable numeric literals
tags: literal, numbers, hex, binary, octal
---

## Use Correct Number Literal Formats

Use lowercase prefixes for non-decimal numbers. Never use leading zeros for decimal numbers. Use underscores for readability in long numbers.

**Incorrect (inconsistent or hard-to-read formats):**

```typescript
// Uppercase prefix
const hex = 0XABC

// Leading zero (looks like octal in some languages)
const port = 0080

// Hard to read large numbers
const billion = 1000000000
```

**Correct (consistent lowercase prefixes):**

```typescript
// Hexadecimal - lowercase 0x
const hexColor = 0xffffff
const permissions = 0x755

// Binary - lowercase 0b
const flags = 0b1010
const mask = 0b11110000

// Octal - lowercase 0o
const fileMode = 0o755

// Decimal - no leading zeros
const port = 80
const count = 42

// Underscores for readability (ES2021+)
const billion = 1_000_000_000
const bytes = 0xff_ff_ff_ff
const binary = 0b1111_0000_1111_0000
```

**Numeric parsing:**

```typescript
// Use Number() for parsing
const parsed = Number(input)
if (!Number.isFinite(parsed)) {
  throw new Error('Invalid number')
}

// Never use parseInt without radix (except radix 10)
const decimal = Number(str)  // Preferred
const hex = parseInt(hexStr, 16)  // When radix needed
```

Reference: [Google TypeScript Style Guide - Number literals](https://google.github.io/styleguide/tsguide.html#number-literals)
