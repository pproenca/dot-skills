---
title: Use CONSTANT_CASE for True Constants
impact: MEDIUM
impactDescription: distinguishes immutable values from variables
tags: naming, constants, CONSTANT_CASE, style
---

## Use CONSTANT_CASE for True Constants

Use `CONSTANT_CASE` only for deeply immutable values at module scope or as static readonly class properties. Local constants use `lowerCamelCase`.

**Incorrect (wrong case for scope):**

```typescript
// Local variable shouldn't be CONSTANT_CASE
function calculate() {
  const MAX_VALUE = 100  // This is a local const
  return MAX_VALUE * 2
}

// Mutable object in CONSTANT_CASE
const DEFAULT_CONFIG = {
  timeout: 5000,
  retries: 3,
}
DEFAULT_CONFIG.timeout = 10000  // Mutated!
```

**Correct (appropriate case):**

```typescript
// Module-level true constants
const MAX_RETRY_COUNT = 3
const API_BASE_URL = 'https://api.example.com'
const HTTP_STATUS_OK = 200

// Immutable object constant
const DEFAULT_CONFIG = {
  timeout: 5000,
  retries: 3,
} as const  // Truly immutable

// Local constants use camelCase
function calculate() {
  const maxValue = 100
  return maxValue * 2
}

// Class static readonly
class HttpClient {
  static readonly DEFAULT_TIMEOUT = 5000
  static readonly MAX_RETRIES = 3
}
```

**CONSTANT_CASE requirements:**
- Module-level or static readonly
- Deeply immutable (primitives or `as const`)
- Never reassigned
- Represents a true constant value, not just a `const` binding

Reference: [Google TypeScript Style Guide - Constants](https://google.github.io/styleguide/tsguide.html#constants)
