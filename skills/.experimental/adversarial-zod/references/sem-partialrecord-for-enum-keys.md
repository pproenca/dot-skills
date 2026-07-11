---
title: Use z.partialRecord() for enum-keyed records with optional keys
tags: sem, records, enums, runtime-behavior
---

## Use z.partialRecord() for enum-keyed records with optional keys

The wrong default is assuming `z.record(z.enum([...]), value)` infers `Partial<Record<...>>` and accepts objects missing some keys, as it did in Zod 3. In zod@4, enum-keyed records are **exhaustive**: the inferred type requires every key, and `.parse()` rejects objects that omit any of them. Code carrying the Zod 3 assumption compiles (often with a `Partial<...>` cast papering over the type) and then fails at runtime on legitimate sparse input. `z.partialRecord()` restores the optional-key behavior explicitly.

**Evidence of violation:** a `z.record(z.enum(...) | z.literal(...) | <enum-like schema>, ...)` whose parsed input can legitimately omit keys — shown by `Partial<...>` casts on the result, callers that build the object with a subset of keys, or tests parsing objects missing enum members.

**Incorrect (Zod 3 assumption — parse now rejects sparse input):**

```ts
const PriceOverrides = z.record(z.enum(["basic", "pro", "enterprise"]), z.number())

// Runtime ZodError in v4: "pro" and "enterprise" are required keys
PriceOverrides.parse({ basic: 990 })
```

**Correct (partialRecord makes optional keys explicit):**

```ts
const PriceOverrides = z.partialRecord(z.enum(["basic", "pro", "enterprise"]), z.number())

PriceOverrides.parse({ basic: 990 }) // ok — Partial<Record<"basic" | "pro" | "enterprise", number>>
```

Exhaustive `z.record()` is correct when every key must be present — the violation is only the sparse-input case.

Reference: [Zod 4 changelog — z.record() exhaustiveness](https://zod.dev/v4/changelog)
