---
title: Avoid Container Classes with Only Static Members
impact: HIGH
impactDescription: reduces unnecessary abstraction and enables tree-shaking
tags: class, static, modules, organization
---

## Avoid Container Classes with Only Static Members

Classes with only static methods add unnecessary indirection. Export functions directly instead for better tree-shaking and simpler code.

**Incorrect (static container class):**

```typescript
class StringUtils {
  static capitalize(str: string): string {
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  static truncate(str: string, length: number): string {
    return str.length > length ? str.slice(0, length) + '...' : str
  }

  static isEmpty(str: string): boolean {
    return str.trim().length === 0
  }
}

// Usage
StringUtils.capitalize('hello')
```

**Correct (exported functions):**

```typescript
// string-utils.ts
export function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

export function truncate(str: string, length: number): string {
  return str.length > length ? str.slice(0, length) + '...' : str
}

export function isEmpty(str: string): boolean {
  return str.trim().length === 0
}

// Usage
import { capitalize, truncate } from './string-utils'
capitalize('hello')
```

**Benefits:**
- Better tree-shaking (unused functions removed)
- No class instantiation overhead
- Simpler imports
- Works with function composition

Reference: [Google TypeScript Style Guide - Static methods](https://google.github.io/styleguide/tsguide.html#static-methods)
