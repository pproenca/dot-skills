---
title: Enable isolatedDeclarations for Parallel Declaration Emit
impact: MEDIUM-HIGH
impactDescription: enables per-file .d.ts emit without whole-program checking
tags: compile, isolated-declarations, monorepo, build-performance
---

## Enable isolatedDeclarations for Parallel Declaration Emit

`isolatedDeclarations` (TS 5.5) requires every exported value to have an explicit, locally-inferable type, which lets build tools generate `.d.ts` files from a single file without type-checking the whole program. In a monorepo this turns declaration emit into a parallelizable, per-file step and removes the cross-package type-check bottleneck.

**Incorrect (inferred export types — emit must check the whole program):**

```typescript
// tsconfig: no isolatedDeclarations
export function buildClient(config: ClientConfig) {
  return { send: (req: ApiRequest) => fetch(config.url, req) }
  // .d.ts emit must re-infer this return type across imported modules
}
```

**Correct (explicit export types — emittable in isolation):**

```typescript
// tsconfig: "isolatedDeclarations": true
export function buildClient(config: ClientConfig): ApiClient {
  return { send: (req: ApiRequest) => fetch(config.url, req) }
}
```

It enforces [`compile-explicit-return-types`](compile-explicit-return-types.md) at the compiler level and pairs with [`compile-project-references`](compile-project-references.md) for parallel monorepo builds.

Reference: [TypeScript 5.5 — Isolated Declarations](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-5.html)
