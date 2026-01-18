---
title: Use Default Parameters Sparingly
impact: MEDIUM
impactDescription: prevents side effects in parameter defaults
tags: func, parameters, defaults, side-effects
---

## Use Default Parameters Sparingly

Default parameter initializers should be simple values. Avoid side effects, complex expressions, or mutable default values.

**Incorrect (complex or side-effect defaults):**

```typescript
// Side effect in default
function createUser(name: string, id = generateId()) {
  // generateId() called even when id is provided as undefined
}

// Mutable default object
function processConfig(config = { timeout: 5000 }) {
  config.timeout = 10000  // Mutates default object
}

// Complex expression
function calculate(
  value: number,
  multiplier = getGlobalMultiplier() * localFactor
) {}
```

**Correct (simple defaults):**

```typescript
// Simple literal defaults
function createUser(name: string, id?: string) {
  const userId = id ?? generateId()  // Explicit generation
}

// Spread to avoid mutation
function processConfig(config: Partial<Config> = {}) {
  const fullConfig = { timeout: 5000, ...config }
}

// Simple defaults only
function greet(name: string, greeting = 'Hello') {
  return `${greeting}, ${name}`
}

// Optional parameter with explicit handling
function fetchData(url: string, timeout?: number) {
  const actualTimeout = timeout ?? DEFAULT_TIMEOUT
}
```

**Guidelines:**
- Use literals, constants, or simple references
- Avoid function calls in defaults
- Never mutate default values
- Consider optional parameters with explicit handling

Reference: [Google TypeScript Style Guide - Default parameters](https://google.github.io/styleguide/tsguide.html#default-and-rest-parameters)
