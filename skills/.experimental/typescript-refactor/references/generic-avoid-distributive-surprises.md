---
title: Control Distributive Conditional Types
impact: MEDIUM-HIGH
impactDescription: prevents unexpected union expansion in type transformations
tags: generic, distributive, conditional-types, type-level
---

## Control Distributive Conditional Types

Conditional types distribute over union members by default when the checked type is a naked type parameter. This causes unexpected behavior when you want to check the union as a whole. Wrap both sides of `extends` in brackets to disable distribution.

**Incorrect (distributes unexpectedly over union):**

```typescript
type IsArray<T> = T extends unknown[] ? true : false

type Result = IsArray<string | number[]>
// Distributes: IsArray<string> | IsArray<number[]>
// Result: false | true = boolean — not what you want
```

**Correct (brackets disable distribution):**

```typescript
type IsArray<T> = [T] extends [unknown[]] ? true : false

type Result = IsArray<string | number[]>
// Checks (string | number[]) as a whole
// Result: false — correct
```

Reference: [TypeScript Handbook - Distributive Conditional Types](https://www.typescriptlang.org/docs/handbook/2/conditional-types.html#distributive-conditional-types)
