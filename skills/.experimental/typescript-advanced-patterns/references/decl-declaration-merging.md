---
title: Merge Interface, Namespace, and Class Declarations to Extend APIs
impact: MEDIUM
impactDescription: enables extensible plugin systems, registry patterns, and library-style API surfaces
tags: decl, declaration-merging, namespaces, interfaces, plugin-system
---

## Merge Interface, Namespace, and Class Declarations to Extend APIs

TypeScript merges declarations with the same name in the same scope according to specific rules — multiple `interface` declarations combine into one, `namespace`s merge their exports, a class can be augmented by a same-named namespace to attach static members, and so on. This is the mechanism behind module augmentation, HKT emulation, and most plugin systems. Knowing exactly which combinations merge — and which don't — is the difference between a working extension point and a confusing compile error.

**Incorrect (try to extend a class by re-declaring it — silently shadows):**

```typescript
// src/lib.ts
export class Logger {
  log(msg: string) { console.log(msg) }
}

// src/extensions.ts
import { Logger } from './lib'

class Logger {                   // shadows the import in this file only
  static configure(opts: object) { /* … */ }
}

Logger.configure({})             // works here
import('./lib').then(({ Logger }) => Logger.configure({}))  // fails — original Logger has no `configure`
```

**Correct (merge a namespace into a class to add static members; merge interfaces to extend records):**

```typescript
// 1. Class + namespace merge — adds static-side members and nested types
export class Logger {
  log(msg: string) { console.log(msg) }
}

export namespace Logger {
  export interface Options { level: 'debug' | 'info' | 'warn' | 'error' }
  export function configure(opts: Options): void { /* … */ }
}

Logger.configure({ level: 'info' })   // OK
const opts: Logger.Options = { level: 'debug' }  // nested type accessible

// 2. Interface + interface merge — adds members to an existing record
interface UserContext { id: string }
interface UserContext { roles: string[] }
const u: UserContext = { id: 'u_1', roles: ['admin'] }  // both fields required

// 3. Namespace + namespace merge — adds exports to an existing namespace
namespace Routes {
  export const list = '/users'
}
namespace Routes {
  export const create = '/users'  // adds to the same namespace
}

// 4. Open-extension registry (the HKT pattern, see `[[tlp-hkt-emulation]]`)
interface PluginRegistry {}        // open for extension
declare module './registry' {
  interface PluginRegistry { auth: AuthPlugin; cache: CachePlugin }
}
```

**What merges, what doesn't:**

| Left | Right | Result |
|------|-------|--------|
| `interface` | `interface` | Single merged interface (members combined) |
| `namespace` | `namespace` | Single merged namespace (exports combined) |
| `class` | `namespace` (same name) | Class + static members from namespace |
| `function` | `namespace` (same name) | Function + properties from namespace |
| `enum` | `namespace` (same name) | Enum + helper members from namespace |
| `class` | `class` | Error — duplicate identifier |
| `interface` | `type` alias | Error — `type` aliases can't merge |
| `class` | `interface` | Only at declaration site — class implements interface, no member merge |

Merging applies *per scope*. Two interfaces in different modules with the same name do not merge unless you augment via `declare module`.

**When NOT to apply:**
- Cases where a clear naming distinction would do — `Logger` plus a `LoggerOptions` type is often clearer than `Logger.Options`. Reserve merging for genuine extension points and registry patterns.
- When the team is unfamiliar with merge semantics — debugging "where did this property come from" across a merged surface is hard. Document every intentional merge.

**Scope delta:**
- Companion to `[[decl-module-augmentation]]`. Module augmentation *uses* declaration merging across module boundaries; this rule covers the same-scope merge semantics and what shapes are mergeable.

Reference: [TypeScript Handbook — Declaration Merging](https://www.typescriptlang.org/docs/handbook/declaration-merging.html)
