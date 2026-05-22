---
title: Type JSON.parse Results Through Validation
impact: MEDIUM
impactDescription: prevents untyped JSON propagation
tags: runtime, json, validation, unknown
---

## Type JSON.parse Results Through Validation

`JSON.parse` returns `any`, so its result spreads untyped through everything it feeds — and annotating the call site (`JSON.parse(s) as Config`) is an unchecked assertion that is simply false when the file on disk does not match. Assign the result to `unknown` and validate it, so the parsed value earns its type instead of claiming it.

**Incorrect (annotated parse — the type is a lie):**

```typescript
// If the config file drifts from Config, this still compiles and the wrong
// shape flows everywhere with no runtime check.
const config = JSON.parse(readFileSync("config.json", "utf8")) as Config
startServer(config.port)
```

**Correct (parse to unknown, then validate):**

```typescript
import { z } from "zod"

const ConfigSchema = z.object({ port: z.number().int(), host: z.string() })

const raw: unknown = JSON.parse(readFileSync("config.json", "utf8"))
const config = ConfigSchema.parse(raw) // throws if the file drifts
startServer(config.port)
```

Reference: [Effective TypeScript: Item 71](https://effectivetypescript.com/)
