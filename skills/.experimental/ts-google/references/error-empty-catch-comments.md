---
title: Document Empty Catch Blocks
impact: MEDIUM
impactDescription: explains intentional error suppression
tags: error, catch, comments, documentation
---

## Document Empty Catch Blocks

Empty catch blocks are allowed only with comments explaining why the error is intentionally suppressed.

**Incorrect (unexplained empty catch):**

```typescript
try {
  parseJSON(input)
} catch (e) {
  // Silent failure - why?
}

try {
  await deleteFile(path)
} catch {
  // What errors are we ignoring?
}
```

**Correct (documented empty catch):**

```typescript
try {
  cachedValue = parseJSON(localStorage.getItem('cache'))
} catch (e: unknown) {
  // Cache may be corrupted or missing; continue with empty cache
}

try {
  await deleteFile(tempPath)
} catch (e: unknown) {
  // File may already be deleted; safe to ignore
}

// Alternative: explicit fallback
let config: Config
try {
  config = parseConfig(rawInput)
} catch (e: unknown) {
  // Invalid config format; use defaults
  config = DEFAULT_CONFIG
}
```

**When empty catch is appropriate:**
- Optional cleanup operations
- Cache operations that can fail silently
- Fallback to default behavior
- Operations where failure is expected and handled elsewhere

**When NOT to use empty catch:**
- Critical operations
- User-facing errors
- Debugging/development

Reference: [Google TypeScript Style Guide - Empty catch blocks](https://google.github.io/styleguide/tsguide.html#exceptions)
