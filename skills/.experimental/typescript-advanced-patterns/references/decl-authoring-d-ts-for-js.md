---
title: Author `.d.ts` Files for Plain JavaScript Libraries
impact: MEDIUM
impactDescription: prevents 100% of `any`-typed access to JS-only libraries; eliminates per-call-site casts
tags: decl, d-ts, javascript, declarations, library-integration
---

## Author `.d.ts` Files for Plain JavaScript Libraries

Most JavaScript libraries ship types — either inline or via `@types/*`. When a library doesn't, the choices are: rewrite it (rarely the right call), import as `any` (loses every benefit of TypeScript), or write your own `.d.ts`. Writing a focused declaration file is fast, scopes to the surface your code actually uses, and lives in your repo so refactors and version bumps are local concerns. The pattern is more useful than it sounds — even libraries with `@types/*` packages sometimes ship out-of-date or incomplete types.

**Incorrect (`any`-typed everywhere; refactor-safety lost):**

```typescript
// Library: `tiny-emitter` — no types shipped
import TinyEmitter from 'tiny-emitter'

const bus: any = new TinyEmitter()
bus.on('user:loggedIn', (payload: any) => {
  // payload is any; typos in event names compile; payload shape lost
})
bus.emit('user:loggedin', { id: 1 })  // typo — no error
```

**Correct (write a focused `.d.ts` matching the library's runtime surface):**

```typescript
// src/types/tiny-emitter.d.ts
declare module 'tiny-emitter' {
  export default class TinyEmitter {
    on(event: string, callback: (...args: unknown[]) => void, ctx?: unknown): this
    once(event: string, callback: (...args: unknown[]) => void, ctx?: unknown): this
    emit(event: string, ...args: unknown[]): this
    off(event: string, callback?: (...args: unknown[]) => void): this
  }
}
```

Now `import TinyEmitter from 'tiny-emitter'` gives the typed class. Combine with a typed wrapper to get end-to-end safety:

```typescript
import TinyEmitter from 'tiny-emitter'

interface AppEvents {
  'user:loggedIn':  { userId: string; sessionId: string }
  'user:loggedOut': { userId: string; reason: 'manual' | 'timeout' }
}

class TypedBus<E extends Record<string, unknown>> {
  private inner = new TinyEmitter()
  on<K extends keyof E & string>(event: K, handler: (payload: E[K]) => void) {
    this.inner.on(event, handler as (...args: unknown[]) => void)
  }
  emit<K extends keyof E & string>(event: K, payload: E[K]) {
    this.inner.emit(event, payload)
  }
}

const bus = new TypedBus<AppEvents>()
bus.emit('user:loggedin', {} as never)   // Error: not a key of AppEvents
```

Five rules that make the `.d.ts` reliable:

1. **Match the library's runtime contract, not what you wish it did.** If a method returns `undefined` on error, type it `Foo | undefined`. The declaration's job is to describe reality.
2. **Type only the surface you use.** A 200-method library used for two calls needs two declarations. Adding the rest is yak-shaving.
3. **Prefer `unknown` over `any` for genuine "any shape" parameters.** Forces narrowing at the call site — a feature, not a bug.
4. **Keep `.d.ts` files in `src/types/` (or similar)** with the same base name as the package — `tiny-emitter.d.ts`, not `types.d.ts`. Future-you finds them.
5. **If the upstream library publishes types later, delete yours.** The local declaration silently overrides the package's types, and people will eventually be surprised by the drift.

For non-module JavaScript loaded from a `<script>` tag, augment the global scope instead (see `[[decl-global-augmentation-discipline]]`).

**When NOT to apply:**
- When the library is large and central to the codebase — write proper types or contribute back to `@types/*`. A local hack at scale becomes a maintenance burden.
- When you can wrap the library behind a thin typed adapter — usually clearer than typing the original API.

**Scope delta:**
- Companion to `[[decl-module-augmentation]]` — that rule extends *existing* types; this rule writes types *where none exist*. Together they cover the entire spectrum of integrating untyped or partially-typed external code into a TypeScript codebase.

Reference: [TypeScript Handbook — Modules: Working with Plain Old JavaScript Files](https://www.typescriptlang.org/docs/handbook/modules/theory.html#interop)
