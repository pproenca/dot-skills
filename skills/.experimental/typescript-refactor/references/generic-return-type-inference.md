---
title: Preserve Return Type Inference in Generic Functions
impact: MEDIUM
impactDescription: enables precise downstream typing without manual annotation
tags: generic, return-types, inference, function-signatures
---

## Preserve Return Type Inference in Generic Functions

When a generic function returns a computed type, annotating the return type with a wide interface instead of letting TypeScript infer the precise type loses generic precision at call sites.

**Incorrect (explicit return type widens generic away):**

```typescript
interface Config {
  host: string
  port: number
  debug: boolean
}

function getConfig(key: keyof Config): Config[keyof Config] {
  const config: Config = loadConfig()
  return config[key]
}

const port = getConfig("port") // Type: string | number | boolean — widened
```

**Correct (generic parameter preserves precision):**

```typescript
interface Config {
  host: string
  port: number
  debug: boolean
}

function getConfig<K extends keyof Config>(key: K) {
  const config: Config = loadConfig()
  return config[key] // Return type inferred as Config[K]
}

const port = getConfig("port")   // Type: number
const host = getConfig("host")   // Type: string
const debug = getConfig("debug") // Type: boolean
```

**Note:** For exported non-generic functions, explicit return types are preferred for compiler performance (see `compile-explicit-return-types`). This rule applies specifically to generic functions where inference carries type parameters through.
