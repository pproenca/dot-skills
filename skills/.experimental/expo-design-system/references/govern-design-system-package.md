---
title: Isolate the Design System as Its Own Package
impact: MEDIUM
impactDescription: prevents feature code from importing private internals
tags: govern, package, boundary, architecture
---

## Isolate the Design System as Its Own Package

When features reach into the design system with deep relative imports, they couple to its folder layout and to raw tokens that should stay private — so any refactor of the internals breaks features. Packaging the design system with a single curated entry point exposes only the public surface and keeps internals free to change.

**Incorrect (deep relative imports into internals):**

```typescript
import { Button } from '../../../design-system/src/components/Button/Button'
import { palette } from '../../../design-system/src/tokens/raw'
// Features depend on the internal folder structure and on raw tokens meant to be private.
```

**Correct (a package with a curated public entry):**

```typescript
// design-system/package.json → { "name": "@clinic/design-system", "exports": { ".": "./src/index.ts" } }

// design-system/src/index.ts — the only public surface
export { Button, Card, AppText } from './components'
export type { AppTheme } from './theme'

// a feature imports the package entry; raw tokens stay private
import { Button, Card, AppText } from '@clinic/design-system'
```

Reference: [Unistyles configuration](https://www.unistyl.es/v3/start/configuration/)
