---
title: Compose `using` Resources with Explicit Disposal Ordering
impact: HIGH
impactDescription: prevents resource leaks in 100% of composed scopes; guarantees LIFO disposal even on exception paths
tags: mod, using, await-using, resource-management, typescript-5
---

## Compose `using` Resources with Explicit Disposal Ordering

The TypeScript 5.2 `using` keyword (and `await using` for async disposers) is more than a `try/finally` shorthand. When multiple `using` declarations appear in the same scope, the spec guarantees they are disposed in **last-in-first-out** order — even when an exception is thrown mid-scope, even when one disposer itself throws. Most code that adopts `using` uses one resource at a time and misses this. Library authors composing connection pools, transactions, file handles, and tracing spans need to understand the ordering rules to compose them correctly.

**Incorrect (manual try/finally — easy to get cleanup order wrong):**

```typescript
async function importBatch(file: string) {
  const log = openSpan('importBatch')
  try {
    const conn = await db.connect()
    try {
      const tx = await conn.begin()
      try {
        const reader = fs.createReadStream(file)
        try {
          await processStream(reader, tx)
          await tx.commit()
        } finally {
          reader.close()
        }
      } catch (e) {
        await tx.rollback()  // easy to forget; may run after tx already closed
        throw e
      }
    } finally {
      conn.release()
    }
  } finally {
    log.end()
  }
}
```

**Correct (`using` / `await using` — disposal is structural, ordered, exception-safe):**

```typescript
async function importBatch(file: string) {
  await using log    = openSpan('importBatch')         // disposed last
  await using conn   = await db.connect()
  await using tx     = await conn.begin()              // commit or rollback in [Symbol.asyncDispose]
  using       reader = fs.createReadStream(file)        // sync disposer; closes file handle

  await processStream(reader, tx)
  await tx.commit()
  // Disposal on scope exit: reader → tx → conn → log (LIFO).
  // If processStream throws: same LIFO disposal, and tx's disposer can detect
  // it never committed and roll back.
}
```

To make a resource composable with `using`, implement the `Disposable` or `AsyncDisposable` symbol:

```typescript
class Transaction implements AsyncDisposable {
  private committed = false
  async commit() { /* … */ this.committed = true }
  async rollback() { /* … */ }
  async [Symbol.asyncDispose]() {
    if (!this.committed) await this.rollback()
  }
}
```

Rules for clean composition:
1. **Acquire in dependency order** (transaction depends on connection ⇒ declare connection first). LIFO disposal then unwinds the dependency graph correctly.
2. **Disposers must not throw under normal use** — they're called from a finally-like context, and thrown errors become suppressed errors that complicate debugging. If cleanup can fail, log and swallow.
3. **Mix `using` and `await using` freely** — disposers run synchronously or asynchronously based on declaration. The compiler enforces `await using` only at the call site.

**When NOT to apply:**
- Single-resource scopes where `try/finally` is just as clear and doesn't require the runtime polyfill on older targets.
- Disposables whose lifetime exceeds a single function (request-scoped caches, app-wide connection pools) — `using` is for stack-shaped lifetimes.

**Scope delta:**
- `typescript-refactor`'s `modern-using-keyword` introduces the `using` keyword at the surface. This rule covers what happens when you compose two or three — the LIFO contract, the dependency-order discipline, and the interaction with thrown errors and suppressed errors.

Reference: [TypeScript 5.2 Release Notes — Using Declarations and Explicit Resource Management](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-2.html#using-declarations-and-explicit-resource-management)
