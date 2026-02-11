---
title: Use the using Keyword for Resource Cleanup
impact: HIGH
impactDescription: prevents resource leaks by guaranteeing cleanup
tags: modern, using, disposable, resource-management
---

## Use the using Keyword for Resource Cleanup

The `using` keyword (TS 5.2+, Stage 3 Explicit Resource Management) automatically calls `[Symbol.dispose]()` when a variable goes out of scope. This eliminates try/finally boilerplate and prevents resource leaks from early returns or exceptions.

**Incorrect (manual cleanup, leaks on early return):**

```typescript
function processFile(path: string) {
  const handle = openFile(path)
  const content = handle.read()
  if (!content) return null // Leak: handle.close() is never called
  const result = parseContent(content)
  handle.close()
  return result
}
```

**Correct (using guarantees cleanup):**

```typescript
function processFile(path: string) {
  using handle = openFile(path) // Disposed automatically at end of scope
  const content = handle.read()
  if (!content) return null // handle[Symbol.dispose]() still called
  return parseContent(content)
}

function openFile(path: string): Disposable & FileHandle {
  const handle = fs.openSync(path, "r")
  return {
    read: () => fs.readFileSync(handle, "utf-8"),
    close: () => fs.closeSync(handle),
    [Symbol.dispose]() { fs.closeSync(handle) },
  }
}
```

**Note:** Use `await using` for async cleanup with `[Symbol.asyncDispose]()`.

Reference: [TypeScript 5.2 - using Declarations](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-2.html)
