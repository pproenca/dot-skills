---
title: Validate Environment Configuration at Boundary with Schema Inference
impact: MEDIUM-HIGH
impactDescription: prevents 100% of misconfigured-env runtime crashes; pushes errors to startup rather than first-request
tags: impl, env, config, schema, boundary
---

## Validate Environment Configuration at Boundary with Schema Inference

`process.env.SOME_KEY` is typed as `string | undefined`, every consumer must null-check it, and missing variables cause failures at the first request that touches them — often hours after deploy. The boundary pattern: parse the whole environment through a schema once at startup, expose the parsed result as a typed object, and crash early on missing or malformed values. Every consumer reads typed properties; no consumer ever touches `process.env` directly.

**Incorrect (raw `process.env` access — late failures, no shape protection):**

```typescript
const PORT  = process.env.PORT ?? '3000'                  // string
const DB    = process.env.DATABASE_URL                     // string | undefined
const RETRY = parseInt(process.env.HTTP_RETRY ?? '3', 10)  // NaN if non-numeric env value

app.listen(parseInt(PORT, 10))                            // crashes if PORT='abc'
db.connect(DB!)                                            // crashes after first query if DB is missing
```

**Correct (schema-parsed env at startup; typed config exported once):**

```typescript
// src/config.ts — loaded once at startup
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV:     z.enum(['development', 'staging', 'production']),
  PORT:         z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().url(),
  HTTP_RETRY:   z.coerce.number().int().min(0).max(10).default(3),
  LOG_LEVEL:    z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  FEATURE_NEW_CHECKOUT: z.coerce.boolean().default(false),
})

const parsed = envSchema.safeParse(process.env)
if (!parsed.success) {
  // Pretty-print and crash early so the failure is on startup logs, not first-request logs.
  console.error('Invalid environment configuration:')
  for (const issue of parsed.error.issues) {
    console.error(`  ${issue.path.join('.')}: ${issue.message}`)
  }
  process.exit(1)
}

export const config = parsed.data
//   ^ { NODE_ENV: 'development' | 'staging' | 'production';
//       PORT: number; DATABASE_URL: string; HTTP_RETRY: number;
//       LOG_LEVEL: 'debug' | 'info' | 'warn' | 'error';
//       FEATURE_NEW_CHECKOUT: boolean }

// Everywhere else:
import { config } from './config'

app.listen(config.PORT)              // number
db.connect(config.DATABASE_URL)      // string
if (config.FEATURE_NEW_CHECKOUT) { /* … */ }  // boolean
```

Three design rules:

1. **One file owns env parsing.** Never `process.env.X` outside this file. Lint with eslint-plugin-no-process-env or grep in CI.
2. **Coerce explicitly.** `z.coerce.number()` turns `"3000"` into `3000`; without it, env strings stay strings and arithmetic explodes silently.
3. **Defaults belong in the schema.** Don't fall back at the consumer (`config.PORT ?? 3000`) — defaults in the schema document the contract once.

For multi-environment systems, derive separate types per environment if the contract differs:

```typescript
const baseSchema = z.object({ /* always present */ })
const prodSchema = baseSchema.extend({ SENTRY_DSN: z.string().url() })
const devSchema  = baseSchema.extend({ SENTRY_DSN: z.string().url().optional() })

const schema = process.env.NODE_ENV === 'production' ? prodSchema : devSchema
```

**When NOT to apply:**
- One-off scripts where the env shape is trivial and the boilerplate exceeds the benefit.
- Edge-runtime environments where `process.env` access has cost — measure first; in most cases the parse-once pattern still wins.

**Scope delta:**
- Applies `[[dsl-schema-first-inference]]` to the env-config domain. The general schema-first rule says "derive types from schemas"; this rule names the boundary (one file, one schema, one parse at startup) where that pays off most.

Reference: [Zod — `safeParse`](https://zod.dev/?id=safeparse)
