---
title: Handle Nullable Types Correctly
impact: CRITICAL
impactDescription: prevents null reference errors
tags: types, null, undefined, optional, nullable
---

## Handle Nullable Types Correctly

Type aliases must NOT include `|null` or `|undefined`. Add nullability only at usage sites. Prefer optional properties over `|undefined`.

**Incorrect (nullability in type alias):**

```typescript
// Nullability baked into type
type CoffeeResponse = Latte | Americano | undefined

interface UserCache {
  user: User | null  // Forces all consumers to handle null
}
```

**Correct (nullability at usage site):**

```typescript
// Clean base type
type CoffeeResponse = Latte | Americano

// Nullability added where needed
class CoffeeService {
  getOrder(): CoffeeResponse | undefined {
    // May not find an order
  }
}

interface UserCache {
  user?: User  // Optional property preferred
}
```

**Guidelines:**
- Use `undefined` for JavaScript APIs (more idiomatic)
- Use `null` for DOM and Google APIs (conventional)
- Prefer `field?: Type` over `field: Type | undefined`
- Check for both with `value == null` when appropriate

**Incorrect (redundant undefined):**

```typescript
interface Config {
  timeout: number | undefined  // Redundant
}
```

**Correct (optional property):**

```typescript
interface Config {
  timeout?: number  // Cleaner, same semantics
}
```

Reference: [Google TypeScript Style Guide - Null vs Undefined](https://google.github.io/styleguide/tsguide.html#null-vs-undefined)
