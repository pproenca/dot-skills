---
title: Avoid Deeply Recursive Type Definitions
impact: MEDIUM-HIGH
impactDescription: prevents exponential type-checking time and IDE freezes
tags: compile, recursion, type-level, performance
---

## Avoid Deeply Recursive Type Definitions

Recursive types that nest beyond ~50 levels cause exponential compiler work, IDE lag, and cryptic "Type instantiation is excessively deep" errors. Flatten recursive types or add explicit depth limits.

**Incorrect (unbounded recursion, compiler chokes):**

```typescript
type DeepPartial<T> = {
  [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K]
}

type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K]
}

// Applying both to a deep nested config type explodes compiler memory
type Config = DeepReadonly<DeepPartial<AppConfig>>
```

**Correct (bounded recursion with depth limit):**

```typescript
type DeepPartial<T, Depth extends number[] = []> =
  Depth["length"] extends 5
    ? T
    : {
        [K in keyof T]?: T[K] extends object
          ? DeepPartial<T[K], [...Depth, 0]>
          : T[K]
      }

// Or simply avoid deep recursion — flatten instead
type ShallowConfig = Partial<Pick<AppConfig, "database">> & {
  database?: Partial<AppConfig["database"]>
}
```

**When NOT to use this pattern:**
- Simple single-level recursion (e.g., linked list types) is fine

Reference: [TypeScript Performance Wiki](https://github.com/microsoft/TypeScript/wiki/Performance)
