---
title: Type Default and Optional Parameters Precisely
impact: HIGH
impactDescription: enables caller autocomplete on options
tags: surface, optional-parameters, defaults
---

## Type Default and Optional Parameters Precisely

JavaScript hides an options object behind `opts = opts || {}`, leaving callers to guess which keys are accepted and the compiler unable to check any of them. Typed optional parameters with destructured defaults expose the exact shape, give callers autocomplete, and let the compiler validate every field they pass.

**Incorrect (untyped options blob — callers guess the keys):**

```typescript
// opts is implicitly any; nothing tells a caller what retry() accepts.
function retry(task, opts) {
  const max = (opts && opts.max) || 3
  const delay = (opts && opts.delay) || 100
  return runWithRetry(task, max, delay)
}
```

**Correct (typed optional parameter with defaults):**

```typescript
interface RetryOptions {
  max?: number
  delay?: number
}

function retry(task: () => Promise<void>, opts: RetryOptions = {}): Promise<void> {
  const { max = 3, delay = 100 } = opts
  return runWithRetry(task, max, delay)
}
```

Reference: [Effective TypeScript](https://effectivetypescript.com/)
