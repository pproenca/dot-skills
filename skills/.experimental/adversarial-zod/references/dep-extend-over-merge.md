---
title: Extend object schemas with .extend(shape) — .merge() is deprecated
tags: dep, objects, composition, deprecated-api
---

## Extend object schemas with .extend(shape) — .merge() is deprecated

The wrong default is `SchemaA.merge(SchemaB)`, the Zod 3 idiom for combining object schemas. zod@4 deprecated `.merge()` in favor of `.extend()` taking a **shape**: `SchemaA.extend(SchemaB.shape)`. For heavy compositions the docs recommend spreading shapes into a fresh `z.object()` — it is easier on tsc than chained extends. Since 4.1 there is also `.safeExtend()`, which statically rejects overrides that break assignability instead of silently widening.

**Evidence of violation:** `.merge(` called on a Zod object schema.

**Incorrect (deprecated):**

```ts
const AuditedRow = BaseRow.merge(AuditFields)
```

**Correct (extend with a shape, or spread for big compositions):**

```ts
const AuditedRow = BaseRow.extend(AuditFields.shape)

// docs-recommended for large or repeated compositions (cheaper for tsc)
const AuditedRow2 = z.object({ ...BaseRow.shape, ...AuditFields.shape })
```

Reference: [Zod 4 changelog — .merge() deprecation](https://zod.dev/v4/changelog), [zod v4.1.0 release — .safeExtend()](https://github.com/colinhacks/zod/releases/tag/v4.1.0)
