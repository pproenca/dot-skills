---
title: Pass both key and value schemas to z.record()
tags: gone, records, removed-api
---

## Pass both key and value schemas to z.record()

The wrong default is the Zod 3 single-argument form `z.record(valueSchema)`, where string keys were implied. zod@4 made the key schema **mandatory** — the single-argument overload was removed, so the old form is a compile error. The fix is mechanical: state the key schema explicitly.

**Evidence of violation:** `z.record(` called with a single argument.

**Incorrect (removed in 4.0 — does not compile):**

```ts
const FeatureFlags = z.record(z.boolean())
```

**Correct (explicit key schema):**

```ts
const FeatureFlags = z.record(z.string(), z.boolean())
```

Reference: [Zod 4 changelog — z.record() requires two arguments](https://zod.dev/v4/changelog)
