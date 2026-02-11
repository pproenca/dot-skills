---
title: Avoid Object.keys Type Widening
impact: MEDIUM
impactDescription: prevents string[] return type from losing key precision
tags: perf, object-keys, type-widening, utility-types
---

## Avoid Object.keys Type Widening

`Object.keys()` returns `string[]`, not `(keyof T)[]`, because TypeScript's structural type system allows objects to have extra properties. Use type-safe alternatives to iterate over known keys without losing type information.

**Incorrect (Object.keys returns string[], loses key types):**

```typescript
interface ThemeColors {
  primary: string
  secondary: string
  accent: string
}

const theme: ThemeColors = { primary: "#000", secondary: "#333", accent: "#0070f3" }

Object.keys(theme).forEach(key => {
  const color = theme[key] // Error: string can't index ThemeColors
})
```

**Correct (typed key iteration):**

```typescript
interface ThemeColors {
  primary: string
  secondary: string
  accent: string
}

const theme: ThemeColors = { primary: "#000", secondary: "#333", accent: "#0070f3" }

function typedKeys<T extends object>(obj: T): (keyof T)[] {
  return Object.keys(obj) as (keyof T)[]
}

typedKeys(theme).forEach(key => {
  const color = theme[key] // Type: string — works correctly
})
```

**Alternative (for-in with type guard):**

```typescript
for (const key in theme) {
  if (key in theme) {
    const color = theme[key as keyof ThemeColors]
  }
}
```

**Note:** The `string[]` return type is intentional — TypeScript can't guarantee no extra properties exist due to structural typing. Use the typed helper only when you control the object's shape.
