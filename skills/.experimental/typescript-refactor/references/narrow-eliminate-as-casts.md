---
title: Eliminate as Casts with Proper Narrowing Chains
impact: HIGH
impactDescription: removes 80-90% of type assertions through control flow
tags: narrow, type-assertions, control-flow, refactoring
---

## Eliminate as Casts with Proper Narrowing Chains

Every `as` cast is a promise from developer to compiler with zero runtime verification. Replace casts with narrowing chains: `typeof`, `instanceof`, `in`, discriminant checks, and custom guards narrow types safely through control flow.

**Incorrect (assertion chain, no runtime safety):**

```typescript
function parseConfig(raw: unknown): AppConfig {
  const config = raw as Record<string, unknown>
  return {
    port: config.port as number,
    host: config.host as string,
    debug: config.debug as boolean,
  }
}
```

**Correct (narrowing chain, runtime safe):**

```typescript
function parseConfig(raw: unknown): AppConfig {
  if (typeof raw !== "object" || raw === null) {
    throw new Error("Config must be an object")
  }

  const config = raw as Record<string, unknown>

  if (typeof config.port !== "number") throw new Error("port must be a number")
  if (typeof config.host !== "string") throw new Error("host must be a string")

  return {
    port: config.port,
    host: config.host,
    debug: typeof config.debug === "boolean" ? config.debug : false,
  }
}
```

**Alternative (use a validation library for complex schemas):**

```typescript
import { z } from "zod"

const AppConfigSchema = z.object({
  port: z.number(),
  host: z.string(),
  debug: z.boolean().default(false),
})

function parseConfig(raw: unknown): AppConfig {
  return AppConfigSchema.parse(raw) // Throws with detailed errors
}
```

Reference: [Google TypeScript Style Guide - Type Assertions](https://google.github.io/styleguide/tsguide.html)
