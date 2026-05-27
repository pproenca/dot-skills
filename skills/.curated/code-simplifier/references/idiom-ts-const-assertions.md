---
title: Use const Assertions and readonly for Immutability
impact: LOW-MEDIUM
impactDescription: Prevents accidental mutations, enables 10-20% better type inference for literals
tags: idiom, typescript, immutability, const-assertions
---

## Use const Assertions and readonly for Immutability

Const assertions (`as const`) and `readonly` modifiers signal intent and prevent accidental mutations. They also enable TypeScript to infer literal types instead of widened types, which improves type safety and enables better autocomplete.

**Incorrect (mutable by default, widened types):**

```typescript
// Type is string[], not readonly ["admin", "user", "guest"]
const ROLES = ["admin", "user", "guest"];

// Type is { status: string; code: number }, loses literal info
const ERROR_CODES = {
  NOT_FOUND: { status: "not_found", code: 404 },
  FORBIDDEN: { status: "forbidden", code: 403 },
};

// Can be accidentally mutated
function processItems(items: string[]) {
  items.push("extra"); // Mutates original array
  return items.sort();
}
```

**Correct (immutable with precise types):**

```typescript
// Type is readonly ["admin", "user", "guest"]
const ROLES = ["admin", "user", "guest"] as const;
type Role = typeof ROLES[number]; // "admin" | "user" | "guest"

// Type preserves literal values
const ERROR_CODES = {
  NOT_FOUND: { status: "not_found", code: 404 },
  FORBIDDEN: { status: "forbidden", code: 403 },
} as const;
type ErrorStatus = typeof ERROR_CODES[keyof typeof ERROR_CODES]["status"];

// Signals no mutation, creates new array
function processItems(items: readonly string[]): string[] {
  return [...items, "extra"].sort();
}
```

### When NOT to Use

- Arrays or objects that genuinely need mutation for performance
- Loop counters and accumulator variables
- Builder patterns that rely on mutation

### Benefits

- Literal type inference enables exhaustive switch checks
- `readonly` in function parameters documents non-mutation
- Catches accidental `.push()`, `.pop()`, assignment at compile time
- Enables deriving union types from const arrays/objects
