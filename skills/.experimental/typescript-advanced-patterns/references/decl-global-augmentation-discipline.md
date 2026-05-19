---
title: Scope Global Type Augmentation to Avoid Conflicts
impact: MEDIUM
impactDescription: prevents global type pollution across packages in a monorepo; eliminates 100% of "two packages collide on Window.foo" bugs
tags: decl, global, augmentation, scoping, monorepo
---

## Scope Global Type Augmentation to Avoid Conflicts

Global type augmentation — `declare global { interface Window { ... } }` — is irresistible the first time you use it. It's also the source of every "two packages tried to type Window.analytics differently and now nothing works" bug in a monorepo. The discipline is to (1) never publish global augmentations from a library, (2) confine them to leaf applications, (3) namespace them with a project-specific brand to prevent merge conflicts, and (4) keep them in a clearly-named `*.d.ts` file that the whole team recognises as "the global escape hatch."

**Incorrect (library publishes a global augmentation; consumers collide):**

```typescript
// In an analytics library — distributed via npm
declare global {
  interface Window {
    analytics: { track(event: string): void; identify(userId: string): void }
  }
}

// In a feature-flag library — same npm install
declare global {
  interface Window {
    analytics: { variant(flag: string): boolean }   // same name, different shape
  }
}

// In the application that depends on both:
window.analytics.track('clicked')      // OK in some files, type error in others depending on import order
window.analytics.variant('newSearch')  // same
```

**Correct (libraries export, apps augment with namespaced shape):**

```typescript
// analytics library — no global augmentation. Just exports.
// src/index.ts
export interface AnalyticsClient {
  track(event: string, props?: Record<string, unknown>): void
  identify(userId: string): void
}
export function getAnalytics(): AnalyticsClient { /* … */ }
```

```typescript
// feature-flag library — same discipline
export interface FlagClient {
  variant(flag: string): boolean
}
export function getFlags(): FlagClient { /* … */ }
```

```typescript
// src/types/global.d.ts — in the application only
import type { AnalyticsClient } from 'analytics-sdk'
import type { FlagClient }      from 'feature-flags-sdk'

declare global {
  interface Window {
    __acme: {                  // project-namespaced — no risk of collision
      analytics: AnalyticsClient
      flags: FlagClient
    }
  }
}

export {}  // marker to ensure module status
```

```typescript
// Usage in the application:
window.__acme.analytics.track('clicked')
window.__acme.flags.variant('newSearch')
```

Five rules that make this safe:

1. **Libraries never `declare global`.** Export types and let consumers wire them up.
2. **Apps namespace globals** under a project-specific key (`__acme`, `__internal`, the team's short name). Avoid `analytics`, `auth`, `flags` — generic names collide with whatever browser extension a user has installed.
3. **One file per global concern**, in a predictable path (`src/types/global.d.ts`, `src/types/window.d.ts`). New team members find it instantly.
4. **`export {}` at the file's bottom** to make it a module, not a script — script files implicitly augment the global scope and break tree-shaking in some bundlers.
5. **Augment `globalThis` for non-browser globals.** `declare global { var __cache: Map<string, unknown> }` works for Node globals.

**When NOT to apply:**
- Single-file applications or scripts where the surface is small enough that a flat declaration file is no risk.
- Monorepo internal libraries that are guaranteed to be the only consumer of a global (e.g. a shared test harness) — but document the assumption.

**Scope delta:**
- No existing TypeScript skill in this repo covers global augmentation discipline. It's the partner rule to `[[decl-module-augmentation]]` — both use the same mechanism, but global augmentation has *much* worse blast radius when done wrong.

Reference: [TypeScript Handbook — Global Augmentation](https://www.typescriptlang.org/docs/handbook/declaration-merging.html#global-augmentation)
