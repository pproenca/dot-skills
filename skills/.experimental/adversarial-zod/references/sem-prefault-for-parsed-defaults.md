---
title: Use .prefault() when a default value must be parsed
tags: sem, defaults, transforms, runtime-behavior
---

## Use .prefault() when a default value must be parsed

The wrong default is Zod 3 muscle memory: writing `.default(value)` and expecting the value to run through the schema's coercion, transforms, and refinements. In zod@4, `.default()` takes the **output** type and **short-circuits parsing** — when the input is `undefined`, the default is returned as-is. On a schema whose input and output types coincide (any `.transform()` from `string` to `string`), the old code still type-checks and silently ships an unprocessed value. `.prefault()` is the v4 spelling of the Zod 3 behavior: the default is parsed like any other input.

**Evidence of violation:** a `.default(v)` chained onto a schema containing `.transform()`, `.pipe()`, or `z.coerce.*`. The only PASS carve-out is a default that is demonstrably the chain's fixed point — parsing `v` would return `v` unchanged (`z.coerce.number().default(0)`, a pre-trimmed string on a `.trim()` chain). When fixed-point status is not demonstrable from the value alone, the verdict is FAIL.

**Incorrect (type-checks, but the default skips the trim):**

```ts
const DisplayName = z.string()
  .transform((s) => s.trim())
  .default("  anonymous  ")

DisplayName.parse(undefined) // "  anonymous  " — transform never ran
```

**Correct (prefault parses the default like real input):**

```ts
const DisplayName = z.string()
  .transform((s) => s.trim())
  .prefault("  anonymous  ")

DisplayName.parse(undefined) // "anonymous"
```

`.default()` remains right when the default is already a finished output value — the violation is specifically a default that still needs processing, and the fail-closed carve-out above keeps that boundary decidable.

Reference: [Zod 4 changelog — default value handling](https://zod.dev/v4/changelog)
