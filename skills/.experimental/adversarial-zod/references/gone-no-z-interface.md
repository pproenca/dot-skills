---
title: Avoid z.interface() — it never shipped; use z.object() with getters
tags: gone, objects, recursion, hallucination
---

## Avoid z.interface() — it never shipped; use z.object() with getters

The wrong default is `z.interface({...})` with `"key?"` optionality and getter-based recursion — an API that existed only in Zod 4 **betas** (early 2025) and was cut before the stable release. Models that absorbed beta-era blog posts reproduce it confidently, and it has never compiled against any stable zod@4. What survived into stable is the part that mattered: plain `z.object()` now supports getter-based recursion with full type inference.

**Evidence of violation:** `z.interface(` anywhere in the target.

**Incorrect (beta-only API — does not exist in stable v4):**

```ts
const User = z.interface({
  name: z.string(),
  "nickname?": z.string(),
  get friends() { return z.array(User) },
})
```

**Correct (z.object with getters and .optional()):**

```ts
const User = z.object({
  name: z.string(),
  nickname: z.string().optional(),
  get friends(): z.ZodArray<typeof User> { return z.array(User) },
})
```

Reference: [Zod API — recursive objects](https://zod.dev/api), [Zod 4 changelog](https://zod.dev/v4/changelog)
