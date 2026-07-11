---
title: Reserve zod/mini for hard client-bundle constraints
tags: pkg, zod-mini, bundle-size, packaging
---

## Reserve zod/mini for hard client-bundle constraints

The wrong default is treating `zod/mini` as "regular Zod but better because smaller." Mini trades the chaining API for wrapped functions (`z.optional(z.string())`, `.check(z.minLength(5))`) to become tree-shakable — a real DX tax that the docs themselves recommend against for most projects. The ~3.5kb gzip saving buys nothing on a server (code never ships to a browser) and nothing in a normal app bundle. Worse, mixing `zod` and `zod/mini` in one repo forfeits the size benefit while doubling the API surface every reader must hold.

**Evidence of violation:** an import from `zod/mini` in a file that also contains `createServerFn`, a server-route handler, or a `"use server"` directive, or whose path contains a `server` segment; or a repo whose source imports both `"zod"` and `"zod/mini"`.

**Incorrect (mini's DX tax with zero payoff on the server):**

```ts
// src/server/billing.functions.ts
import * as z from "zod/mini"

const Charge = z.object({
  amount: z.number().check(z.positive()),
  currency: z.optional(z.string()),
})
```

**Correct (regular zod on the server; mini only under a measured bundle budget):**

```ts
// src/server/billing.functions.ts
import * as z from "zod"

const Charge = z.object({
  amount: z.number().positive(),
  currency: z.string().optional(),
})
```

A client-only codebase using mini consistently (no server files, no mixed imports) is a PASS — whether the bundle budget justifies the DX tax is the author's call; the gate polices only server usage and mixing.

Reference: [Zod — zod/mini](https://zod.dev/packages/mini)
