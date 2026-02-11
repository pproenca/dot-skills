---
title: Use Result Types Instead of Thrown Exceptions
impact: MEDIUM
impactDescription: eliminates unhandled exception paths across call sites
tags: error, result-type, discriminated-unions, error-handling
---

## Use Result Types Instead of Thrown Exceptions

Thrown exceptions bypass the type system — callers have no compile-time indication that a function can fail. A discriminated `Result` type makes success and failure explicit in the return type, forcing callers to handle both cases.

**Incorrect (thrown exceptions invisible to type system):**

```typescript
function parseJson(raw: string): Config {
  try {
    return JSON.parse(raw)
  } catch {
    throw new Error("Invalid JSON") // Caller has no type-level warning
  }
}

const config = parseJson(input) // Looks infallible — but throws
```

**Correct (Result type makes failure explicit):**

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E }

function parseJson(raw: string): Result<Config> {
  try {
    return { ok: true, value: JSON.parse(raw) }
  } catch (err) {
    return { ok: false, error: new Error("Invalid JSON", { cause: err }) }
  }
}

const result = parseJson(input)
if (!result.ok) {
  console.error(result.error.message) // Must handle error
  return
}
console.log(result.value) // Narrowed to Config
```

**When NOT to use this pattern:**
- Truly exceptional situations (out of memory, network down) where recovery is impossible
- Infrastructure code where try/catch boundaries are already well-defined
