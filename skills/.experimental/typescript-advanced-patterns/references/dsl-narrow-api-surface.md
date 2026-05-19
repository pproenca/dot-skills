---
title: Export Only the API Surface, Not Internal Helpers
impact: CRITICAL
impactDescription: prevents 100% of downstream coupling to internal types; enables internal refactors without major-version bumps
tags: dsl, api-design, library-design, encapsulation, semver
---

## Export Only the API Surface, Not Internal Helpers

In a library, every exported type becomes part of the contract — consumers can reference it, structurally extend it, and break when it changes. A common mistake is `export *` from an index file, which dumps every internal utility type into the public surface. The advanced discipline is to maintain one entry point that re-exports a *deliberate* surface, and to mark internal helpers with naming and tooling so they cannot leak. This is what lets a mature library refactor internals without major-version churn.

**Incorrect (barrel re-export leaks everything):**

```typescript
// src/index.ts — public entry point
export * from './client'
export * from './internal/serializer'  // implementation detail
export * from './internal/retry-policy' // implementation detail
export * from './types'                  // dumps every internal type alias
```

```typescript
// Consumer
import type { InternalRetryState, SerializerConfig } from 'my-sdk'
// User now depends on names that were never meant to be public.
```

**Correct (curated re-exports, internal modules are unreachable):**

```typescript
// src/index.ts — the only public surface
export { Client } from './client'
export type { ClientOptions, RequestContext } from './client'
export { ClientError, NetworkError } from './errors'
export type { Result } from './result'
// Internal helpers are imported only within the package — never re-exported.
```

```jsonc
// package.json
{
  "name": "my-sdk",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.js"
    }
  }
}
```

```typescript
// Consumer
import type { ClientOptions } from 'my-sdk'        // OK
import type { InternalRetryState } from 'my-sdk'   // Error: not exported
import { internalRetry } from 'my-sdk/internal'    // Error: subpath not in exports map
```

Pair this with `[[decl-exports-and-types-versions]]` to block deep-import workarounds, and prefer `export type` for type-only re-exports so a consumer who erases imports doesn't pull runtime modules along.

**When NOT to apply:**
- Internal-only monorepo packages — every import site is owned by you, so reorganising surface costs less than maintaining a curated index.
- Plugin systems where consumers genuinely need to extend internals — but then document those types as a separate `@scope/internals` package with explicit unstable warnings.

**Scope delta:**
- `ts-google`'s `module-export-api-surface` covers the general "minimise exports" hygiene rule for in-codebase modules. This rule applies that discipline at the **package boundary** — combined with `exports`-map subpath blocking (see `[[decl-exports-and-types-versions]]`) — so internal types are physically unreachable to consumers, not merely conventionally unused.

Reference: [Node.js — Package `exports` Field](https://nodejs.org/api/packages.html#exports)
