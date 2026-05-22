---
title: Parse and Type Environment Variables Once
impact: MEDIUM
impactDescription: eliminates scattered env-var reads
tags: runtime, environment, validation, config
---

## Parse and Type Environment Variables Once

`process.env.X` is typed `string | undefined`, and migrated JavaScript reads it directly in dozens of places, each assuming it exists and is the right type. Parse and validate the environment into a typed config object once at startup so the rest of the app consumes guaranteed types — and a missing variable fails loudly on boot, not deep in a request.

**Incorrect (raw env reads scattered everywhere):**

```typescript
// string | undefined, read in many files, parsed ad hoc each time.
const pool = createPool({
  max: Number(process.env.DB_POOL_MAX), // NaN when unset, no error
  ssl: process.env.DB_SSL === "true",
})
```

**Correct (validate once into a typed config):**

```typescript
import { z } from "zod"

const Env = z.object({
  DB_POOL_MAX: z.coerce.number().int().positive().default(10),
  DB_SSL: z.enum(["true", "false"]).transform((v) => v === "true"),
})

export const env = Env.parse(process.env) // fails at startup if misconfigured

const pool = createPool({ max: env.DB_POOL_MAX, ssl: env.DB_SSL })
```

Reference: [Zod: Coercion](https://zod.dev/api)
