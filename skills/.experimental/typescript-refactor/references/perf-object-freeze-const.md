---
title: Use Object.freeze with as const for True Immutability
impact: MEDIUM
impactDescription: prevents both compile-time and runtime mutation
tags: perf, immutability, object-freeze, const-assertion
---

## Use Object.freeze with as const for True Immutability

`as const` only provides compile-time readonly guarantees — JavaScript code or untyped consumers can still mutate the object. Combine `Object.freeze` for runtime protection with `as const` for compile-time literal inference.

**Incorrect (as const alone, runtime mutable):**

```typescript
const permissions = {
  admin: ["read", "write", "delete"],
  editor: ["read", "write"],
  viewer: ["read"],
} as const

// TypeScript prevents this, but runtime JS doesn't:
// (permissions as any).admin.push("sudo")
```

**Correct (frozen at runtime and compile time):**

```typescript
const permissions = Object.freeze({
  admin: Object.freeze(["read", "write", "delete"] as const),
  editor: Object.freeze(["read", "write"] as const),
  viewer: Object.freeze(["read"] as const),
})

// Runtime: Object.freeze prevents mutation
// Compile-time: as const preserves literal types
```

**When NOT to use this pattern:**
- Hot paths where the freeze overhead matters (rare — freeze is cheap)
- Objects that genuinely need to be mutable
