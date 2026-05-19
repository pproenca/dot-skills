---
title: Augment Third-Party Module Types Without Patching Source
impact: MEDIUM
impactDescription: enables typed access to runtime-added properties without forking type definitions
tags: decl, module-augmentation, declaration-merging, third-party
---

## Augment Third-Party Module Types Without Patching Source

A common situation: a library exposes a type that's almost right, but you need to add a field, narrow an enum, or extend an interface for your project's use of it. Editing `node_modules` is a non-starter; copying the type and forking it is duplication. **Module augmentation** lets you re-open a third-party module's types from your own code, declaration-merge new properties into its existing interfaces, and have those additions show up at every call site — without touching the source.

**Incorrect (cast at every site or maintain a parallel type):**

```typescript
// Express's Request doesn't have `userId` — your auth middleware attaches one
import type { Request } from 'express'

app.get('/me', (req: Request, res) => {
  const userId = (req as Request & { userId?: string }).userId  // cast everywhere
  // …
})

app.get('/orders', (req: Request, res) => {
  const userId = (req as any).userId  // or worse, `any`
  // …
})
```

**Correct (augment the module once; every consumer sees the new field):**

```typescript
// src/types/express.d.ts
import 'express'

declare module 'express-serve-static-core' {
  interface Request {
    userId?: string         // attached by auth middleware
    requestId: string       // attached by tracing middleware (always present after middleware)
    tenant?: { id: string; plan: 'free' | 'pro' | 'enterprise' }
  }
}
```

```typescript
// Anywhere in the codebase
app.get('/me', (req, res) => {
  const userId = req.userId        // string | undefined — recognised
  const reqId  = req.requestId     // string — recognised
})
```

Three rules that make augmentation reliable:

1. **Augment the *implementation* module, not the re-export.** Express's `Request` type is declared in `express-serve-static-core`, not `express`. Augmenting the wrong module silently no-ops.
2. **The augmentation file must be a module.** A bare `declare module` in a script file augments the global scope instead. Add `import 'express'` (a side-effect import) or `export {}` at the top to ensure module status.
3. **Augmented properties must be optional or always-present.** A required property that's actually set by middleware mid-pipeline makes early-pipeline code lie about its state — model it as optional or use a separate post-middleware Request type.

A second canonical use: extending the `Window` interface for project-specific globals:

```typescript
// src/types/window.d.ts
export {}
declare global {
  interface Window {
    analytics: {
      track(event: string, props?: Record<string, unknown>): void
      identify(userId: string): void
    }
  }
}
```

**When NOT to apply:**
- When the library exports types via `class` declarations rather than `interface` — classes don't declaration-merge. Augment the surrounding namespace, or wrap in your own interface.
- When the change is invasive (changing existing field types, removing fields) — augmentation only adds. Fork the type or contribute upstream.
- When the library ships an `@types/*` package you can extend differently (`tsconfig.json` `paths` or `typeRoots`); augmentation is the right tool only when you want changes to layer *on top* of the upstream types.

**Scope delta:**
- No existing TypeScript skill in this repo covers module augmentation. It's a niche but essential library-integration technique — used by every meaningful Express/Next.js/Vite project.

Reference: [TypeScript Handbook — Module Augmentation](https://www.typescriptlang.org/docs/handbook/declaration-merging.html#module-augmentation)
